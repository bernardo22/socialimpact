// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/participante.dart';
import 'package:socialimpact/pages/home.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/services/participante_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class ParticipanteFormPage extends StatefulWidget {
  final Participante? participante;
  final String? acaoVoluntariadoId;
  final String? acaoNome;

  const ParticipanteFormPage({
    Key? key,
    this.participante,
    this.acaoVoluntariadoId,
    this.acaoNome,
  }) : super(key: key);

  @override
  State<ParticipanteFormPage> createState() => _ParticipanteFormPageState();
}

class _ParticipanteFormPageState extends State<ParticipanteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ParticipanteService();

  final _voluntarioIdCtrl = TextEditingController();
  DateTime? _dataInscricao;
  bool _cancelou = false;
  bool _participou = false;
  String? _acaoNome;
  String? _voluntarioNome;
  bool _isVoluntario = false;
  DateTime? _acaoDataInicio;

  @override
  void initState() {
    super.initState();

    if (widget.participante != null) {
      final p = widget.participante!;
      _voluntarioIdCtrl.text = p.voluntarioId;
      _dataInscricao = p.dataInscricao;
      _cancelou = p.cancelou;
      _participou = p.participou;
      _acaoNome = widget.acaoNome;
      _fetchAcaoData(p.acaoVoluntariadoId);
    } else if (widget.acaoVoluntariadoId != null && widget.acaoNome != null) {
      _acaoNome = widget.acaoNome!;
      _dataInscricao = DateTime.now();
      _fetchAcaoData(widget.acaoVoluntariadoId!);
    }

    _fetchVoluntarioData();
  }

  @override
  void dispose() {
    _voluntarioIdCtrl.dispose();
    super.dispose();
  }

  void _fetchVoluntarioData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      final voluntario =
          await VoluntarioService().getVoluntarioByEmail(user.email!);
      if (voluntario != null && mounted) {
        setState(() {
          _voluntarioIdCtrl.text = voluntario.voluntarioId;
          _voluntarioNome = voluntario.nome;
          _isVoluntario = true;
        });
      } else {
        setState(() {
          _isVoluntario = false;
        });
      }
    }
  }

  _fetchAcaoData(String acaoVoluntariadoId) async {
    try {
      final acao =
          await AcaoVoluntariadoService().getAcaoById(acaoVoluntariadoId);
      if (acao != null && mounted) {
        setState(() {
          _acaoDataInicio = acao.dataInicio;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados da ação: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataInscricao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dataInscricao = picked);
  }

  Future<Participante?> _save() async {
    if (!_formKey.currentState!.validate()) return null;

    if (_dataInscricao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de inscrição')),
      );
      return null;
    }
    
    if (widget.participante == null && widget.acaoVoluntariadoId != null) {
      try {
        final acao = await AcaoVoluntariadoService()
            .getAcaoById(widget.acaoVoluntariadoId!);
        if (acao == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ação de voluntariado não encontrada')),
          );
          return null;
        }
        final today = DateTime.now();
        final actionDate = DateTime(
            acao.dataInicio.year, acao.dataInicio.month, acao.dataInicio.day);
        final currentDate = DateTime(today.year, today.month, today.day);
        if (actionDate.isBefore(currentDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Não é possível inscrever-se em ações passadas')),
          );
          return null;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar a ação: $e')),
        );
        return null;
      }
    }

    try {
      final participante = Participante(
        participanteAcaoVoluntariadoId:
            widget.participante?.participanteAcaoVoluntariadoId ?? '',
        voluntarioId: _voluntarioIdCtrl.text.trim(),
        acaoVoluntariadoId: widget.participante?.acaoVoluntariadoId ??
            widget.acaoVoluntariadoId ??
            '',
        dataInscricao: _dataInscricao!,
        cancelou: _cancelou,
        participou: _participou,
      );

      if (widget.participante == null) {
        final newId = await _service.createParticipante(participante);
        return participante.copyWith(participanteAcaoVoluntariadoId: newId);
      } else {
        await _service.updateParticipante(participante);
        return participante;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
      return null;
    }
  }

  void _confirmationDialog(Participante participante) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inscrição Confirmada! 🎉'),
        content: Text(
            'Sua inscrição na ação "${_acaoNome ?? ''}" foi efetuada com sucesso.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(),
                ),
              );
            },
            
            child: const Text('Ok Home'),
          ),
        ],
      ),
    );
  }

  bool _canEditParticipou() {
    if (_acaoDataInicio == null) return false;
    final today = DateTime.now();
    final actionDate = DateTime(
        _acaoDataInicio!.year, _acaoDataInicio!.month, _acaoDataInicio!.day);
    final currentDate = DateTime(today.year, today.month, today.day);
    return currentDate.isAfter(actionDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: widget.participante == null
            ? 'Novo Participante'
            : 'Editar Participante',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_voluntarioNome != null)
                    CustomTextField(
                      controller: TextEditingController(text: _voluntarioNome),
                      label: 'Voluntário',
                      isRequired: false,
                      enabled: false,
                    ),
                  if (_acaoNome != null)
                    CustomTextField(
                      controller: TextEditingController(text: _acaoNome),
                      label: 'Ação de Voluntariado',
                      isRequired: false,
                      enabled: false,
                    ),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Data de Inscrição',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14)),
                      child: Text(
                          _dataInscricao?.toLocal().toString().split(' ')[0] ??
                              'Selecione a data'),
                    ),
                  ),
                  if (!_isVoluntario) ...[
                    SwitchListTile(
                      title: const Text("Cancelou?"),
                      value: _cancelou,
                      onChanged: (val) => setState(() => _cancelou = val),
                    ),
                    SwitchListTile(
                      title: const Text("Participou?"),
                      value: _participou,
                      onChanged: _canEditParticipou()
                          ? (val) => setState(() => _participou = val)
                          : null, // Disable if action date hasn't passed
                      subtitle: !_canEditParticipou()
                          ? const Text(
                              'A participação só pode ser marcada após a data da ação.',
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.participante == null
                        ? 'Inscrever-se'
                        : 'Guardar Alterações',
                    onPressed: () async {
                      final participanteSalvo = await _save();
                      if (participanteSalvo != null &&
                          widget.participante == null) {
                        if (!mounted) return;
                        _confirmationDialog(participanteSalvo);
                      } else if (participanteSalvo != null) {
                        Navigator.pop(context);
                      }
                    },
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
