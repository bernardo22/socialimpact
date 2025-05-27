// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class AcaoVoluntariadoFormPage extends StatefulWidget {
  final AcaoVoluntariado? acao;
  final String? instituicaoId; 

  const AcaoVoluntariadoFormPage({Key? key, this.acao, this.instituicaoId})
      : super(key: key);

  @override
  State<AcaoVoluntariadoFormPage> createState() =>
      _AcaoVoluntariadoFormPageState();
}

class _AcaoVoluntariadoFormPageState extends State<AcaoVoluntariadoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = AcaoVoluntariadoService();
  final _instituicaoService = InstituicaoService();
  final _nomeCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _instituicaoIdCtrl = TextEditingController(); 
  DateTime? _dataInicio;
  DateTime? _dataFim;
  DateTime? _notificacaoDate;
  String? _instituicaoNome;

  @override
  void initState() {
    super.initState();
    if (widget.acao != null) {
      _loadInitialData();   
    } else {
      if (widget.instituicaoId != null) {
        // Use instituicaoId from arguments if provided
        _instituicaoIdCtrl.text = widget.instituicaoId!;
        _fetchInstituicaoById(widget.instituicaoId!);
      } else {
        // Fallback to email-based lookup
        _fetchInstituicaoByEmail();
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _numeroCtrl.dispose();
    _descricaoCtrl.dispose();
    _instituicaoIdCtrl.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final data = widget.acao!;
    _nomeCtrl.text = data.nome;
    _numeroCtrl.text = data.numeroAcao;
    _descricaoCtrl.text = data.descricaoDetalhada;
    _instituicaoIdCtrl.text = data.instituicaoId;
    _dataInicio = data.dataInicio;
    _dataFim = data.dataFim;
    _notificacaoDate = data.diaHoraEnviarNotificacao;
    _fetchInstituicaoById(data.instituicaoId); // Fetch name for existing action
  }

  // Fetch institution by email 
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
    }
  }

  // Fetch institution by ID (for editing or when instituicaoId is provided)
  Future<void> _fetchInstituicaoById(String instituicaoId) async {
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
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isStartDate ? _dataInicio = picked : _dataFim = picked);
    }
  }

  Future<void> _selectNotificationDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _notificacaoDate = picked);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() && _dataInicio != null) {
      try {
        final newAcao = AcaoVoluntariado(
          acaoVoluntariadoId: widget.acao?.acaoVoluntariadoId ?? '',
          instituicaoId: _instituicaoIdCtrl.text.trim(),
          dataInicio: _dataInicio!,
          dataFim: _dataFim,
          descricaoDetalhada: _descricaoCtrl.text.trim(),
          nome: _nomeCtrl.text.trim(),
          numeroAcao: _numeroCtrl.text.trim(),
          diaHoraEnviarNotificacao: _notificacaoDate,
        );

        widget.acao == null
            ? await _service.createAcao(newAcao)
            : await _service.updateAcao(newAcao);

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
        title: widget.acao == null
            ? 'Nova Ação de Voluntariado'
            : 'Editar Ação de Voluntariado',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nomeCtrl,
                    label: 'Nome da Ação',
                    isRequired: true,
                  ),
                  CustomTextField(
                    controller: _numeroCtrl,
                    label: 'Número da Ação',
                    isRequired: true,
                    isNumber: true,
                  ),
                  if(_instituicaoNome != null)
                    CustomTextField(
                      controller: TextEditingController(text: _instituicaoNome), 
                      label: 'Nome da Instituição',
                      isRequired: false,
                      isNumber: false,
                    ),
                  CustomTextField(
                    controller: _descricaoCtrl,
                    label: 'Descrição Detalhada',
                    isRequired: true,
                    keyboardType: TextInputType.multiline,
                  ),
                  _buildDateField('Data Início', _dataInicio, true),
                  _buildDateField('Data Fim (Opcional)', _dataFim, false),
                  _buildDateField('Notificação (Opcional)', _notificacaoDate, false),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: widget.acao == null ? 'Registar' : 'Guardar Alterações',
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

  Widget _buildDateField(String label, DateTime? date, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => label.contains('Notificação')
            ? _selectNotificationDate(context)
            : _selectDate(context, label.contains('Início')),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date?.toIso8601String().split('T').first ?? 'Selecione a data',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}