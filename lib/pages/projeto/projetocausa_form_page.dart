// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/services/projetocausa_service.dart';
import 'package:socialimpact/services/instituicao_service.dart'; 
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class ProjetoCausaFormPage extends StatefulWidget {
  final ProjetoCausa? projetoCausa;
  final String? instituicaoId;

  const ProjetoCausaFormPage({Key? key, this.projetoCausa, this.instituicaoId})
      : super(key: key);

  @override
  State<ProjetoCausaFormPage> createState() => _ProjetoCausaFormPageState();
}

class _ProjetoCausaFormPageState extends State<ProjetoCausaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProjetoCausaService();
  final _instituicaoService = InstituicaoService(); 

  final _instituicaoIdCtrl = TextEditingController(); 
  final _categoriaCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  DateTime? _dataProjeto;
  final _valorNecessarioCtrl = TextEditingController();
  final _valorRecebidoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  String? _instituicaoNome; // To display the institution name

  @override
  void initState() {
    super.initState();
    if (widget.projetoCausa != null) {
      // Editing an existing project
      _instituicaoIdCtrl.text = widget.projetoCausa!.instituicaoId;
      _categoriaCtrl.text = widget.projetoCausa!.categoria;
      _nomeCtrl.text = widget.projetoCausa!.nome;
      _dataProjeto = widget.projetoCausa!.dataProjeto;
      _valorNecessarioCtrl.text = widget.projetoCausa!.valorNecessario.toString();
      _valorRecebidoCtrl.text = widget.projetoCausa!.valorRecebido.toString();
      _descricaoCtrl.text = widget.projetoCausa!.descricaoDetalhadaDoProjeto;
      _fetchInstituicaoNameById(widget.projetoCausa!.instituicaoId); // Fetch name for display
    } else {
      // Creating a new project
      if (widget.instituicaoId != null) {
        _instituicaoIdCtrl.text = widget.instituicaoId!;
        _fetchInstituicaoNameById(widget.instituicaoId!);
      } else {
        _fetchInstituicaoByEmail(); // Fetch based on logged-in user
      }
    }
  }

  @override
  void dispose() {
    _instituicaoIdCtrl.dispose();
    _categoriaCtrl.dispose();
    _nomeCtrl.dispose();
    _valorNecessarioCtrl.dispose();
    _valorRecebidoCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  // Fetch institution by email for new projects
  Future<void> _fetchInstituicaoByEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _instituicaoNome = 'Usuário não autenticado';
        });
        return;
      }
      final email = user.email;
      if (email == null) {
        setState(() {
          _instituicaoNome = 'Email não disponível';
        });
        return;
      }
      final instituicao = await _instituicaoService.getInstituicaoByEmail(email);
      if (instituicao != null) {
        setState(() {
          _instituicaoNome = instituicao.nome;
          _instituicaoIdCtrl.text = instituicao.instituicaoId;
        });
      } else {
        setState(() {
          _instituicaoNome = 'Instituição não encontrada para este email';
        });
      }
    } catch (e) {
      setState(() {
        _instituicaoNome = 'Erro ao carregar instituição';
      });
      print("Erro ao buscar instituição por email: $e");
    }
  }

  // Fetch institution name by ID (for editing or when instituicaoId is provided)
  Future<void> _fetchInstituicaoNameById(String instituicaoId) async {
    try {
      final instituicao = await _instituicaoService.getInstituicaoById(instituicaoId);
      if (instituicao != null) {
        setState(() {
          _instituicaoNome = instituicao.nome;
        });
      } else {
        setState(() {
          _instituicaoNome = 'Instituição não encontrada';
        });
      }
    } catch (e) {
      setState(() {
        _instituicaoNome = 'Erro ao carregar nome';
      });
      print("Erro ao buscar nome da instituição: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataProjeto ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dataProjeto = picked);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_dataProjeto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a data')),
        );
        return;
      }

      try {
        final newProjetoCausa = ProjetoCausa(
          projetoCausaId: widget.projetoCausa?.projetoCausaId ?? '',
          instituicaoId: _instituicaoIdCtrl.text.trim(),
          categoria: _categoriaCtrl.text.trim(),
          nome: _nomeCtrl.text.trim(),
          dataProjeto: _dataProjeto!,
          valorNecessario:
              double.tryParse(_valorNecessarioCtrl.text.trim()) ?? 0.0,
          valorRecebido: double.tryParse(_valorRecebidoCtrl.text.trim()) ?? 0.0,
          descricaoDetalhadaDoProjeto: _descricaoCtrl.text.trim(),
        );

        if (widget.projetoCausa == null) {
          final id = await _service.createProjetoCausa(newProjetoCausa);
          print("Novo projeto criado com ID: $id");
        } else {
          await _service.updateProjetoCausa(newProjetoCausa);
          print("Projeto atualizado com ID: ${newProjetoCausa.projetoCausaId}");
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        print("Erro ao salvar projeto: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar projeto. Tente novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.projetoCausa != null;
    return Scaffold(
      body: AppBasePage(
        title: isEdit ? 'Editar Projeto' : 'Novo Projeto',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_instituicaoNome != null)
                  CustomTextField(
                    controller: TextEditingController(text: _instituicaoNome),
                    label: 'Nome da Instituição',
                    isNumber: false,
                    isRequired: false,
                  ),
                CustomTextField(
                  controller: _nomeCtrl,
                  label: 'Nome do Projeto',
                  isRequired: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Nome do Projeto é obrigatório' : null,
                ),
                CustomTextField(
                  controller: _categoriaCtrl,
                  label: 'Categoria',
                  isRequired: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Categoria é obrigatória' : null,
                ),
                CustomTextField(
                  controller: _valorNecessarioCtrl,
                  label: 'Valor Necessário',
                  isRequired: true,
                  isNumber: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Valor Necessário é obrigatório' : null,
                ),
                CustomTextField(
                  controller: _valorRecebidoCtrl,
                  label: 'Valor Recebido',
                  isRequired: true,
                  isNumber: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Valor Recebido é obrigatório' : null,
                ),
                CustomTextField(
                  controller: _descricaoCtrl,
                  label: 'Descrição Detalhada',
                  isRequired: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Descrição é obrigatória' : null,
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data do Projeto Causa',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    child: Text(
                      _dataProjeto?.toLocal().toString().split(' ')[0] ??
                          'Selecione a Data',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: isEdit ? 'Salvar Alterações' : 'Cadastrar',
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}