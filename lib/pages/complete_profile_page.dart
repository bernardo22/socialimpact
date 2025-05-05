// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/institucao.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/models/doador.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';
import 'package:socialimpact/routes.dart';

enum ProfileType { voluntario, instituicao, doador }

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({Key? key}) : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final VoluntarioService _voluntarioService = VoluntarioService();
  final InstituicaoService _instituicaoService = InstituicaoService();
  final DoadorService _doadorService = DoadorService();

  // Shared controllers
  final TextEditingController _nomeCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _contactoCtrl = TextEditingController();

  // Specific for Instituição
  final TextEditingController _enderecoCtrl = TextEditingController();
  final TextEditingController _descricaoCtrl = TextEditingController();

  // Specific for Doador
  final TextEditingController _nifCtrl = TextEditingController();

  // Current selected profile type
  ProfileType _selectedType = ProfileType.voluntario;

  Voluntario? _currentVoluntario;
  Instituicao? _currentInstituicao;
  Doador? _currentDoador;

  // Flag to determine if profile type can be changed
  bool _canChangeProfileType = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Pre-fill email from Firebase user
    _emailCtrl.text = user.email ?? '';

    
    _nomeCtrl.clear();
    _contactoCtrl.clear();
    _enderecoCtrl.clear();
    _descricaoCtrl.clear();
    _nifCtrl.clear();

    // Check existing profiles and lock profile type
    final voluntario = await _voluntarioService.getVoluntarioByEmail(user.email!);
    final instituicao = await _instituicaoService.getInstituicaoByEmail(user.email!);
    final doador = await _doadorService.getDoadorByEmail(user.email!);

    setState(() {
      if (voluntario != null) {
        _currentVoluntario = voluntario;
        _selectedType = ProfileType.voluntario;
        _nomeCtrl.text = voluntario.nome;
        _contactoCtrl.text = voluntario.contacto;
        _canChangeProfileType = false; 
      } else if (instituicao != null) {
        _currentInstituicao = instituicao;
        _selectedType = ProfileType.instituicao;
        _nomeCtrl.text = instituicao.nome;
        _contactoCtrl.text = instituicao.contacto;
        _enderecoCtrl.text = instituicao.endereco;
        _descricaoCtrl.text = instituicao.descricaoDetalhadaDaInstituicao;
        _canChangeProfileType = false; 
      } else if (doador != null) {
        _currentDoador = doador;
        _selectedType = ProfileType.doador;
        _nomeCtrl.text = doador.nome;
        _contactoCtrl.text = doador.contacto;
        _nifCtrl.text = doador.nif;
        _canChangeProfileType = false;
      } else {
        _canChangeProfileType = true; // Allow profile type selection if no profile exists
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (_selectedType == ProfileType.voluntario) {
        final voluntario = Voluntario(
          voluntarioId: _currentVoluntario?.voluntarioId ?? '',
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          contacto: _contactoCtrl.text.trim(),
        );
        if (_currentVoluntario == null) {
          await _voluntarioService.createVoluntario(voluntario);
        } else {
          await _voluntarioService.updateVoluntario(voluntario);
        }
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (_selectedType == ProfileType.instituicao) {
        final instituicao = Instituicao(
          instituicaoId: _currentInstituicao?.instituicaoId ?? '',
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          contacto: _contactoCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim(),
          descricaoDetalhadaDaInstituicao: _descricaoCtrl.text.trim(),
        );
        if (_currentInstituicao == null) {
          await _instituicaoService.createInstituicao(instituicao);
        } else {
          await _instituicaoService.updateInstituicao(instituicao);
        }
        Navigator.pushReplacementNamed(context, AppRoutes.institutionDashboard);
      } else if (_selectedType == ProfileType.doador) {
        final doador = Doador(
          doadorId: _currentDoador?.doadorId ?? '',
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          contacto: _contactoCtrl.text.trim(),
          nif: _nifCtrl.text.trim(),
        );
        if (_currentDoador == null) {
          await _doadorService.createDoador(doador);
        } else {
          await _doadorService.updateDoador(doador);
        }
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
      // Saving a new profile, lock the profile type
      if (_canChangeProfileType) {
        setState(() {
          _canChangeProfileType = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar perfil: $e")),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (_selectedType == ProfileType.voluntario && _currentVoluntario != null) {
          await user.delete();
          await _voluntarioService.deleteVoluntario(_currentVoluntario!.voluntarioId);
        } else if (_selectedType == ProfileType.instituicao && _currentInstituicao != null) {
          await user.delete();
          await _instituicaoService.deleteInstituicao(_currentInstituicao!.instituicaoId);
        } else if (_selectedType == ProfileType.doador && _currentDoador != null) {
          await user.delete();
          await _doadorService.deleteDoador(_currentDoador!.doadorId);
        }
      }
      Navigator.pushReplacementNamed(context, AppRoutes.loginSignup);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao excluir conta: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _contactoCtrl.dispose();
    _enderecoCtrl.dispose();
    _descricaoCtrl.dispose();
    _nifCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          // If user is not logged in, redirect to login/signup page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.loginSignup);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Por favor, faça login para acessar esta página.")),
            );
          });
          return const SizedBox.shrink(); // Return an empty widget while redirecting
        }

        return AppBasePage(
          title: 'Perfil Completo',
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Tipo de Perfil: "),
                    DropdownButton<ProfileType>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: ProfileType.voluntario,
                          child: Text("Voluntário"),
                        ),
                        DropdownMenuItem(
                          value: ProfileType.instituicao,
                          child: Text("Instituição"),
                        ),
                        DropdownMenuItem(
                          value: ProfileType.doador,
                          child: Text("Doador"),
                        ),
                      ],
                      onChanged: _canChangeProfileType
                          ? (ProfileType? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  _selectedType = newValue;
                                  _currentVoluntario = null;
                                  _currentInstituicao = null;
                                  _currentDoador = null;
                                });
                                await _loadUserData();
                              }
                            }
                          : null, // Disable dropdown if profile type can't be changed
                      disabledHint: Text(_selectedType == ProfileType.voluntario
                          ? "Voluntário"
                          : _selectedType == ProfileType.instituicao
                              ? "Instituição"
                              : "Doador"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        CustomTextField(
                          controller: _nomeCtrl,
                          label: _selectedType == ProfileType.voluntario
                              ? "Nome do Voluntário"
                              : _selectedType == ProfileType.instituicao
                                  ? "Nome da Instituição"
                                  : "Nome do Doador",
                          isRequired: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Nome é obrigatório' : null,
                        ),
                        CustomTextField(
                          controller: _emailCtrl,
                          label: "Email",
                          isRequired: true,
                          isEmail: true,
                          enabled: false,
                          validator: (value) =>
                              value!.isEmpty ? 'Email é obrigatório' : null,
                        ),
                        CustomTextField(
                          controller: _contactoCtrl,
                          label: _selectedType == ProfileType.voluntario
                              ? "Contacto do Voluntário"
                              : _selectedType == ProfileType.instituicao
                                  ? "Contacto da Instituição"
                                  : "Contacto do Doador",
                          isRequired: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Contacto é obrigatório' : null,
                        ),
                        if (_selectedType == ProfileType.instituicao) ...[
                          CustomTextField(
                            controller: _enderecoCtrl,
                            label: "Endereço da Instituição",
                            isRequired: true,
                            validator: (value) =>
                                value!.isEmpty ? 'Endereço é obrigatório' : null,
                          ),
                          CustomTextField(
                            controller: _descricaoCtrl,
                            label: "Descrição Detalhada da Instituição",
                            isRequired: true,
                            validator: (value) =>
                                value!.isEmpty ? 'Descrição é obrigatória' : null,
                          ),
                        ],
                        if (_selectedType == ProfileType.doador)
                          CustomTextField(
                            controller: _nifCtrl,
                            label: "NIF do Doador",
                            isRequired: true,
                            validator: (value) =>
                                value!.isEmpty ? 'NIF é obrigatório' : null,
                          ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: _currentVoluntario == null &&
                                  _currentInstituicao == null &&
                                  _currentDoador == null
                              ? "Criar Perfil"
                              : "Salvar Alterações",
                          onPressed: _saveChanges,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: "Terminar sessão",
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacementNamed(context, AppRoutes.loginSignup);
                          },
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 20),
                        if (_currentVoluntario != null ||
                            _currentInstituicao != null ||
                            _currentDoador != null)
                          CustomButton(
                            text: "Excluir Conta",
                            onPressed: _deleteAccount,
                            isFullWidth: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}