// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/institucao.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class InstituicaoFormPage extends StatefulWidget {
  final Instituicao? instituicao;

  const InstituicaoFormPage({Key? key, this.instituicao}) : super(key: key);

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
          print("Instituição atualizada com ID: ${newInstituicao.instituicaoId}");
        }

        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        print("Erro ao salvar instituição: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar instituição. Tente novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.instituicao != null;
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
                ),
                CustomTextField(
                  controller: _enderecoCtrl,
                  label: 'Endereço',
                  isRequired: true,
                ),
                CustomTextField(
                  controller: _contactoCtrl,
                  label: 'Contacto',
                  isRequired: true,
                ),
                CustomTextField(
                  controller: _descricaoCtrl,
                  label: 'Descrição Detalhada',
                  isRequired: true,
                ),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  isRequired: true,
                  isEmail: true,
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