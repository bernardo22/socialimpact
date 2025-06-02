// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class VoluntarioFormPage extends StatefulWidget {
  final Voluntario? voluntario;
  final String? email;

  const VoluntarioFormPage({Key? key, this.voluntario, this.email})
      : super(key: key);

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
    } else {
      _emailCtrl.text = widget.email!;
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
    final isEdit = widget.voluntario != null;

    if (!isEdit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('email')) {
        _emailCtrl.text = args['email'];
      }
    }
    return Scaffold(
      body: AppBasePage(
        title: isEdit ? 'Novo Voluntário' : 'Editar Voluntário',
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome é obrigatório.';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    isRequired: true,
                    isEmail: true,
                    enabled: !isEdit && widget.email == null,
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
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.voluntario == null
                        ? 'Registar'
                        : 'Guardar Alterações',
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
