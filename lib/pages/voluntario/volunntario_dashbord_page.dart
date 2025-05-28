// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/models/participante.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/services/participante_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class VoluntarioDashboardPage extends StatefulWidget {
  const VoluntarioDashboardPage({Key? key}) : super(key: key);

  @override
  State<VoluntarioDashboardPage> createState() => _VoluntarioDashboardPageState();
}

class _VoluntarioDashboardPageState extends State<VoluntarioDashboardPage> {
  final VoluntarioService _voluntarioService = VoluntarioService();
  final ParticipanteService _participanteService = ParticipanteService();
  final AcaoVoluntariadoService _acaoService = AcaoVoluntariadoService();

  String? _voluntarioId;
  String? _voluntarioNome;
  String? _sortOption = 'data_asc';

  @override
  void initState() {
    super.initState();
    _loadVoluntarioData();
  }

  Future<void> _loadVoluntarioData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final voluntario = await _voluntarioService.getVoluntarioByEmail(user.email!);
      if (voluntario != null && mounted) {
        setState(() {
          _voluntarioId = voluntario.voluntarioId;
          _voluntarioNome = voluntario.nome;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginSignup);
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginSignup);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _cancelParticipation(String participanteId) async {
    await _participanteService.updateParticipante(
      Participante(
        participanteAcaoVoluntariadoId: participanteId,
        voluntarioId: _voluntarioId!,
        acaoVoluntariadoId: '', // Fetched from existing data
        dataInscricao: DateTime.now(), // Will be overwritten
        cancelou: true,
        participou: false,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Participação cancelada com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_voluntarioId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: AppBasePage(
        title: 'Minhas Ações de Voluntariado${_voluntarioNome != null ? " - $_voluntarioNome" : ""}',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSortDropdown(),
              const SizedBox(height: 10),
              _buildVolunteerActionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(){
    return DropdownButton<String>(
      value: _sortOption,
      isExpanded: true,
      hint: const Text('Ordenar por'),
      items: const [
        DropdownMenuItem(
          value: 'data_asc',
          child: Text('Data (Mais antiga primeiro)'),
        ),
        DropdownMenuItem(
          value: 'data_desc',
          child: Text('Data (Mais recente primeiro)')
        ),
        DropdownMenuItem(
          value: 'name_asc',
          child: Text('Nome (A-Z)'),
        ),
      ], 
      onChanged: (value) {
        if (value != null){
          setState(() {
            _sortOption = value;
          });
        }
      }
    );
  }

  Widget _buildVolunteerActionsList() {
    return StreamBuilder<List<Participante>>(
      stream: _participanteService.getParticipantesByVoluntario(_voluntarioId!),
      builder: (context, participanteSnapshot) {
        if (participanteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!participanteSnapshot.hasData || participanteSnapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Nenhuma ação de voluntariado encontrada.'),
          );
        }

        final participantes = participanteSnapshot.data!;
        return StreamBuilder<List<AcaoVoluntariado>>(
          stream: _acaoService.getAcoesStream(),
          builder: (context, acaoSnapshot) {
            if (!acaoSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final acoes = acaoSnapshot.data!;
            final acaoMap = {for (var a in acoes) a.acaoVoluntariadoId: a};

            final sortedParticipantes = List<Participante>.from(participantes);
            sortedParticipantes.sort((a, b){
                final acaoA = acaoMap[a.acaoVoluntariadoId];
                final acaoB = acaoMap[b.acaoVoluntariadoId];
                final nameA = acaoA?.nome ?? 'zzz';
                final nameB = acaoB?.nome ?? 'zzz';
                final dateA = acaoA?.dataInicio ?? DateTime.now();
                final dateB = acaoB?.dataInicio ?? DateTime.now();

                if(_sortOption == 'data_asc'){
                  return dateA.compareTo(dateB);
                } else if (_sortOption == 'date_desc') {
                  return dateB.compareTo(dateA);
                } else {
                  return nameA.compareTo(nameB);
                }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ações Inscritas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: participantes.length,
                  itemBuilder: (context, index) {
                    final participante = participantes[index];
                    final acao = acaoMap[participante.acaoVoluntariadoId];
                    final acaoNome = acao?.nome ?? 'Ação de Voluntariado Cancelada';

                    return CustomListItem(
                      title: acaoNome,
                      subtitle: 'Data de Início: ${_formatDate(acao?.dataInicio ?? DateTime.now())}\n'
                          'Inscrição: ${_formatDate(participante.dataInscricao)}\n'
                          'Descrição:  ${acao?.descricaoDetalhada}\n'
                          'Status: ${participante.cancelou ? "Cancelada" : participante.participou ? "Participou" : "Inscrito"}',
                      onDelete: participante.cancelou
                          ? null // No cancel option if already canceled
                          : () => _cancelParticipation(participante.participanteAcaoVoluntariadoId),
                      trailingText: participante.cancelou ? null : 'Cancelar', 
                    ); 
                  },
                ),
              ],
              
            );
          },
        );
      },
    );
  }
}