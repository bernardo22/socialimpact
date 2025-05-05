// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/doacao.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';
import 'package:socialimpact/services/doacao_service.dart';

class DoacaoPagamentoPage extends StatefulWidget {
  final double valorDoacao;
  final String doadorId;
  final String projetoCausaId;
  final DateTime dataDoacao;

  const DoacaoPagamentoPage({
    Key? key,
    required this.valorDoacao,
    required this.doadorId,
    required this.projetoCausaId,
    required this.dataDoacao,
  }) : super(key: key);

  @override
  State<DoacaoPagamentoPage> createState() => _DoacaoPagamentoPageState();
}

class _DoacaoPagamentoPageState extends State<DoacaoPagamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cartaoNumeroCtrl = TextEditingController();
  final TextEditingController _cartaoNomeCtrl = TextEditingController();
  final TextEditingController _cartaoValidadeCtrl = TextEditingController();
  final TextEditingController _cartaoCvvCtrl = TextEditingController();
  final DoacaoService _doacaoService = DoacaoService();

  @override
  void dispose() {
    _cartaoNumeroCtrl.dispose();
    _cartaoNomeCtrl.dispose();
    _cartaoValidadeCtrl.dispose();
    _cartaoCvvCtrl.dispose();
    super.dispose();
  }

  void _confirmarDoacao() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save donation to Firestore (triggers sendDonationProofEmail)
        final newDoacao = Doacao(
          doacaoId: '', // Firestore will generate the ID
          doadorId: widget.doadorId,
          projetoCausaId: widget.projetoCausaId,
          valorDoado: widget.valorDoacao,
          dataDoacao: widget.dataDoacao,
        );
        await _doacaoService.createDoacao(newDoacao);

        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Doação Confirmada! 🎉'),
            content: Text(
              'Sua doação de €${widget.valorDoacao.toStringAsFixed(2)} foi efetuada com sucesso. O comprovativo foi enviado para o seu email.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar doação: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      title: 'Pagamento da Doação',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cartaoNumeroCtrl,
                label: 'Número do Cartão',
                isRequired: true,
                isNumber: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length != 16) return 'Número do cartão inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _cartaoNomeCtrl,
                label: 'Nome no Cartão',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cartaoValidadeCtrl,
                      label: 'Validade (MM/AA)',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return 'Formato inválido (MM/AA)';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _cartaoCvvCtrl,
                      label: 'CVV',
                      isRequired: true,
                      isNumber: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Campo obrigatório';
                        if (value.length != 3) return 'CVV inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Confirmar Doação',
                onPressed: _confirmarDoacao,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}