// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/participante.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/participante_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class ParticipanteListPage extends StatelessWidget {
  const ParticipanteListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participanteService = ParticipanteService();

    return Scaffold(
      body: AppBasePage(
        title: 'Social Impact',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Participantes Cadastrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Participante>>(
                  stream: participanteService.getParticipantesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhum participante encontrado'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final participante = snapshot.data![index];
                        return CustomListItem(
                          title: 'Voluntário ID: ${participante.voluntarioId}',
                          subtitle: 'Ação: ${participante.acaoVoluntariadoId}\n'
                              'Inscrição: ${_formatDate(participante.dataInscricao)}\n'
                              'Cancelou: ${participante.cancelou ? "Sim" : "Não"}\n'
                              'Participou: ${participante.participou ? "Sim" : "Não"}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editParticipante,
                            arguments: participante,
                          ),
                          onDelete: () => participanteService.deleteParticipante(participante.participanteAcaoVoluntariadoId),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
