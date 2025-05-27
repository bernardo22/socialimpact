// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/doacao.dart';
import 'package:socialimpact/pages/doacao/doacao_pagamento_page.dart';
import 'package:socialimpact/services/doacao_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class DoacaoFormPage extends StatefulWidget {
  final Doacao? doacao;
  final String? projetoCausaId;
  final String? categoria;

  const DoacaoFormPage({
    Key? key,
    this.doacao,
    this.projetoCausaId,
    this.categoria,
  }) : super(key: key);

  @override
  State createState() => _DoacaoFormPageState();
}

class _DoacaoFormPageState extends State<DoacaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = DoacaoService();
  final _doadorService = DoadorService();

  final _doadorIdCtrl = TextEditingController();
  final _valorDoadoCtrl = TextEditingController();

  String? _categoria;
  String? _doadorNome;
  DateTime? _dataDoacao;

  @override
  void initState() {
    super.initState();

    if (widget.doacao != null) {
      _loadInitialData();
    } else {
      _categoria = widget.categoria;
      _dataDoacao = DateTime.now(); // Default to today
      _fetchDoadorData();
    }
  }

  @override
  void dispose() {
    _doadorIdCtrl.dispose();
    _valorDoadoCtrl.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final doacao = widget.doacao!;
    _doadorIdCtrl.text = doacao.doadorId;
    _valorDoadoCtrl.text = doacao.valorDoado.toString();
    _dataDoacao = doacao.dataDoacao;
    _categoria = widget.categoria;
    _fetchDoadorData();
  }

  void _fetchDoadorData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        final doador = await _doadorService.getDoadorByEmail(user.email!);
        if (doador != null && mounted) {
          setState(() {
            _doadorIdCtrl.text = doador.doadorId;
            _doadorNome = doador.nome;
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar dados do Doador: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dataDoacao = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataDoacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data da doação')),
      );
      return;
    }

    try {
      final double valor = double.tryParse(_valorDoadoCtrl.text.trim()) ?? 0.0;

      if (widget.doacao == null) {
        // Navigate to payment page
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoacaoPagamentoPage(
              valorDoacao: valor,
              doadorId: _doadorIdCtrl.text.trim(),
              projetoCausaId: widget.projetoCausaId ?? '',
              dataDoacao: _dataDoacao!,
            ),
          ),
        );
      } else {
        final updatedDoacao = Doacao(
          doacaoId: widget.doacao!.doacaoId,
          doadorId: _doadorIdCtrl.text.trim(),
          projetoCausaId: widget.projetoCausaId ?? '',
          valorDoado: valor,
          dataDoacao: _dataDoacao!,
        );
        await _service.updateDoacao(updatedDoacao);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação atualizada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: widget.doacao == null ? 'Nova Doação' : 'Editar Doação',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_categoria != null)
                    CustomTextField(
                      controller: TextEditingController(text: _categoria),
                      label: 'Categoria do Projeto',
                      isRequired: false,
                      enabled: false,
                    ),
                  if (_doadorNome != null)
                    CustomTextField(
                      controller: TextEditingController(text: _doadorNome),
                      label: 'Nome do Doador',
                      isRequired: false,
                      enabled: false,
                    ),
                  CustomTextField(
                    controller: _valorDoadoCtrl,
                    label: 'Valor Doado (€)',
                    isRequired: true,
                    isNumber: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data da Doação',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        child: Text(
                          _dataDoacao?.toLocal().toString().split(' ')[0] ?? 'Selecione a data',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.doacao == null ? 'Fazer Doação' : 'Guardar Alterações',
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