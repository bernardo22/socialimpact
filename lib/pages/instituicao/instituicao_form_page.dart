// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/institucao.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class InstituicaoFormPage extends StatefulWidget {
  final Instituicao? instituicao;
  final String? email;

  const InstituicaoFormPage({Key? key, this.instituicao, this.email})
      : super(key: key);

  @override
  State<InstituicaoFormPage> createState() => _InstituicaoFormPageState();
}

class _InstituicaoFormPageState extends State<InstituicaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = InstituicaoService();

  final _nomeCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.instituicao != null) {
      _nomeCtrl.text = widget.instituicao!.nome;
      _enderecoCtrl.text = widget.instituicao!.endereco;
      _contactoCtrl.text = widget.instituicao!.contacto;
      _descricaoCtrl.text = widget.instituicao!.descricaoDetalhadaDaInstituicao;
      _emailCtrl.text = widget.instituicao!.email;
    } else {
      _emailCtrl.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _enderecoCtrl.dispose();
    _contactoCtrl.dispose();
    _descricaoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newInstituicao = Instituicao(
          instituicaoId: widget.instituicao?.instituicaoId ?? '',
          nome: _nomeCtrl.text.trim(),
          endereco: _enderecoCtrl.text.trim(),
          contacto: _contactoCtrl.text.trim(),
          descricaoDetalhadaDaInstituicao: _descricaoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        );

        if (widget.instituicao == null) {
          final id = await _service.createInstituicao(newInstituicao);
          print("Nova instituição criada com ID: $id");
        } else {
          await _service.updateInstituicao(newInstituicao);
          print(
              "Instituição atualizada com ID: ${newInstituicao.instituicaoId}");
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        print("Erro ao salvar instituição: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro ao salvar instituição. Tente novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.instituicao != null;
    if (!isEdit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('email')) {
        _emailCtrl.text = args['email'];
      }
    }

    return Scaffold(
      body: AppBasePage(
        title: isEdit ? 'Editar Instituição' : 'Nova Instituição',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nomeCtrl,
                  label: 'Nome da Instituição',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome é obrigatório.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _enderecoCtrl,
                  label: 'Endereço',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O endereço é obrigatório.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _contactoCtrl,
                  label: 'Contacto',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O contacto é obrigatório.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _descricaoCtrl,
                  label: 'Descrição Detalhada',
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'A descrição é obrigatória.';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  isRequired: true,
                  isEmail: true,
                  enabled: !isEdit &&
                      widget.email ==
                          null, // Disable if email is passed or editing
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O email é obrigatório.';
                    }
                    if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value)) {
                      return 'Informe um email válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: isEdit ? 'Guardar Alterações' : 'Registar',
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
