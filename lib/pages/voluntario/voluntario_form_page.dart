// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class VoluntarioFormPage extends StatefulWidget {
  final Voluntario? voluntario;

  const VoluntarioFormPage({Key? key, this.voluntario}) : super(key: key);

  @override
  State<VoluntarioFormPage> createState() => _VoluntarioFormPageState();
}

class _VoluntarioFormPageState extends State<VoluntarioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = VoluntarioService();

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.voluntario != null) {
      _nomeCtrl.text = widget.voluntario!.nome;
      _emailCtrl.text = widget.voluntario!.email;
      _contactoCtrl.text = widget.voluntario!.contacto;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _contactoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newVoluntario = Voluntario(
          voluntarioId: widget.voluntario?.voluntarioId ?? '',
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          contacto: _contactoCtrl.text.trim(),
        );

        if (widget.voluntario == null) {
          await _service.createVoluntario(newVoluntario);
        } else {
          await _service.updateVoluntario(newVoluntario);
        }
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: widget.voluntario == null ? 'Novo Voluntário' : 'Editar Voluntário',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nomeCtrl,
                    label: 'Nome',
                    isRequired: true,
                  ),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    isRequired: true,
                    isEmail: true,
                  ),
                  CustomTextField(
                    controller: _contactoCtrl,
                    label: 'Contacto',
                    isRequired: true,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.voluntario == null ? 'Registar' : 'Guardar Alterações',
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
