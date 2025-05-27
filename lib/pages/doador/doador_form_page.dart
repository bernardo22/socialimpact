// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:socialimpact/models/doador.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class DoadorFormPage extends StatefulWidget {
  final Doador? doador;

  const DoadorFormPage({Key? key, this.doador}) : super(key: key);

  @override
  State<DoadorFormPage> createState() => _DoadorFormPageState();
}

class _DoadorFormPageState extends State<DoadorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = DoadorService();

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _nifCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.doador != null) {
      _nomeCtrl.text = widget.doador!.nome;
      _emailCtrl.text = widget.doador!.email;
      _contactoCtrl.text = widget.doador!.contacto;
      _nifCtrl.text = widget.doador!.nif;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _contactoCtrl.dispose();
    _nifCtrl.dispose();
    super.dispose();
  }
  
  Future<void> _save() async {
  if (_formKey.currentState!.validate()) {
    try {
      final newDoador = Doador(
        doadorId: widget.doador?.doadorId ?? '', // Ensure ID is blank if new
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        contacto: _contactoCtrl.text.trim(),
        nif: _nifCtrl.text.trim(),
      );

      if (widget.doador == null) { 
        final id = await _service.createDoador(newDoador); // Firestore generates the ID
        print("Novo doador criado com ID: $id");
      } else {
        await _service.updateDoador(newDoador);
        print("Doador atualizado com ID: ${newDoador.doadorId}");
      }

      if (!mounted) return;
      Navigator.pop(context); 
    } catch (e) {
      print("Erro ao salvar doador: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar doador. Tente novamente."))
      );
    }
  }
}

  
  bool _validateNIF(String nif) {
    if (nif.length != 9 || !RegExp(r'^\d{9}$').hasMatch(nif)) return false;

    List<int> weights = [9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;

    for (int i = 0; i < 8; i++) {
      sum += int.parse(nif[i]) * weights[i];
    }

    int checkDigit = 11 - (sum % 11);
    if (checkDigit >= 10) checkDigit = 0;

    return checkDigit == int.parse(nif[8]);
  }

  @override
  @override
Widget build(BuildContext context) {
  final isEdit = widget.doador != null;
  return Scaffold( 
    body: AppBasePage(
      title: isEdit ? 'Editar Doador' : 'Novo Doador',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                  if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
                    return 'O nome deve conter apenas letras.';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _emailCtrl,
                label: 'Email',
                isRequired: true,
                isEmail: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O email é obrigatório.';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
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
                  if (!RegExp(r'^9\d{8}$').hasMatch(value)) {
                    return 'O contacto deve ter 9 dígitos e começar com 9.';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _nifCtrl,
                label: 'NIF',
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O NIF é obrigatório.';
                  }
                  if (!_validateNIF(value)) {
                    return 'NIF inválido. Deve ter 9 dígitos e ser válido.';
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