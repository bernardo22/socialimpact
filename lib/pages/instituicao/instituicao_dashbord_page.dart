// institution_dashboard_page.dart
// ignore_for_file: use_super_parameters, unnecessary_null_comparison, avoid_print, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/models/doacao.dart';
import 'package:socialimpact/models/participante.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/models/doador.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/services/doacao_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/services/participante_service.dart';
import 'package:socialimpact/services/projetocausa_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class InstitutionDashboardPage extends StatefulWidget {
  const InstitutionDashboardPage({Key? key}) : super(key: key);

  @override
  State<InstitutionDashboardPage> createState() =>
      _InstitutionDashboardPageState();
}

class _InstitutionDashboardPageState extends State<InstitutionDashboardPage> {
  final InstituicaoService _instituicaoService = InstituicaoService();
  final ProjetoCausaService _projetoService = ProjetoCausaService();
  final DoacaoService _doacaoService = DoacaoService();
  final AcaoVoluntariadoService _acaoService = AcaoVoluntariadoService();
  final ParticipanteService _participanteService = ParticipanteService();
  final VoluntarioService _voluntarioService = VoluntarioService();
  final DoadorService _doadorService = DoadorService();

  String? _institutionId;

  @override
  void initState() {
    super.initState();
    _loadInstitutionId();
  }

  Future<void> _loadInstitutionId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final instituicao =
          await _instituicaoService.getInstituicaoByEmail(user.email!);
      if (instituicao != null && mounted) {
        setState(() {
          _institutionId = instituicao.instituicaoId;
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

  @override
  Widget build(BuildContext context) {
    if (_institutionId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: AppBasePage(
        title: 'Dashboard da Instituição',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectsSection(),
              const SizedBox(height: 20),
              _buildActionsFullSection(),
              const SizedBox(height: 20),
              _buildVParticipantVolunteerActionsSection(),
              const SizedBox(height: 20),
              _buildDonationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return StreamBuilder<List<ProjetoCausa>>(
      stream: _projetoService.getProjetosCausaStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final projects = snapshot.data!
            .where((proj) => proj.instituicaoId == _institutionId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projeto Causa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    text: 'Novo Projeto',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addProjetoCausa,
                      arguments: {'instituicaoId': _institutionId},
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return CustomListItem(
                  title: project.nome,
                  subtitle: 'Categoria: ${project.categoria}\n'
                      'Valor Necessário: €${project.valorNecessario.toStringAsFixed(2)}\n'
                      'Valor Recebido: €${project.valorRecebido.toStringAsFixed(2)}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.editProjetoCausa,
                    arguments: project,
                  ),
                  onDelete: () => _projetoService
                      .deleteProjetoCausa(project.projetoCausaId),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionsFullSection() {
    return StreamBuilder<List<AcaoVoluntariado>>(
      stream: _acaoService.getAcoesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final actions = snapshot.data!
            .where((action) => action.instituicaoId == _institutionId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ações de Voluntariado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    text: 'Nova Ação',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addAcaoVoluntariado,
                      arguments: {'instituicaoId': _institutionId},
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return CustomListItem(
                  title: action.nome,
                  subtitle: 'Número de Ação: ${action.numeroAcao}\n'
                      'Data de Início: ${_formatDate(action.dataInicio)}\n'
                      'Descrição: ${action.descricaoDetalhada}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.editAcaoVoluntariado,
                    arguments: action,
                  ),
                  onDelete: () =>
                      _acaoService.deleteAcao(action.acaoVoluntariadoId),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVParticipantVolunteerActionsSection() {
    return StreamBuilder<List<AcaoVoluntariado>>(
      stream: _acaoService.getActionsByInstitution(_institutionId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print('Não há dados da ação para a Instituição $_institutionId');
          return const CircularProgressIndicator();
        }
        final actions = snapshot.data!;
        print(
            'Encontrou ${actions.length} Ações para a instituição $_institutionId');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Participantes por Ações de Voluntariado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return ExpansionTile(
                  title: Text(action.nome),
                  subtitle: Text('Início: ${_formatDate(action.dataInicio)}'),
                  children: [
                    StreamBuilder<List<Participante>>(
                      stream: _participanteService.getParticipantesStream(),
                      builder: (context, participantSnapshot) {
                        if (participantSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          print(
                              'Há espera de participantes para a ação ${action.nome}');
                          return const CircularProgressIndicator();
                        }
                        if (!participantSnapshot.hasData) {
                          print(
                              'Não há participantes para a ação ${action.nome}');
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Erro ao carregar participantes.'),
                          );
                        }
                        final participants = participantSnapshot.data!
                            .where((p) =>
                                p.acaoVoluntariadoId ==
                                action.acaoVoluntariadoId)
                            .toList();
                        print(
                            'Participantes para ${action.nome}: ${participants.length}');
                        print('Ação ID: ${action.acaoVoluntariadoId}');

                        if (participants.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Nenhum participante encontrado.'),
                          );
                        }

                        return StreamBuilder<List<Voluntario>>(
                          stream: _voluntarioService.getVoluntarioStream(),
                          builder: (context, voluntarioSnapshot) {
                            if (!voluntarioSnapshot.hasData) {
                              print(
                                  'No voluntario data for action ${action.nome}');
                              return const CircularProgressIndicator();
                            }
                            final voluntarios = voluntarioSnapshot.data!;
                            final voluntarioMap = {
                              for (var v in voluntarios) v.voluntarioId: v.nome
                            };

                            return Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Participantes',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ...participants.map((p) => ListTile(
                                      title: Text(
                                          'Voluntário: ${voluntarioMap[p.voluntarioId] ?? 'Desconhecido (${p.voluntarioId})'}'),
                                      subtitle: Text(
                                          'Inscrição: ${_formatDate(p.dataInscricao)}\n'
                                          'Participou: ${p.participou ? "Sim" : "Não"}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.editParticipante,
                                          arguments: p,
                                        ).then((_) => setState(() {})),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.editAcaoVoluntariado,
                                          arguments: action,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _acaoService.deleteAcao(
                                                action.acaoVoluntariadoId),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonationsSection() {
    return StreamBuilder<List<ProjetoCausa>>(
      stream: _projetoService.getProjetosCausaStream(),
      builder: (context, projectSnapshot) {
        if (!projectSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final projects = projectSnapshot.data!
            .where((proj) => proj.instituicaoId == _institutionId)
            .toList();

        if (projects.isEmpty) {
          return const Text('Nenhum projeto encontrado.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doações por Projeto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...projects.map((project) => StreamBuilder<List<Doacao>>(
                  stream: _doacaoService
                      .getDoacoesByProjeto(project.projetoCausaId),
                  builder: (context, donationSnapshot) {
                    if (donationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    if (!donationSnapshot.hasData) {
                      print('Não há dados de doação para ${project.nome}');
                      return ExpansionTile(
                        title: Text(project.nome),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Erro ao carregar doações.'),
                          ),
                        ],
                      );
                    }
                    final donations = donationSnapshot.data!;
                    print('Doações para ${project.nome}: ${donations.length}');
                    if (donations.isEmpty) {
                      return ExpansionTile(
                        title: Text(project.nome),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Nenhuma doação encontrada.'),
                          ),
                        ],
                      );
                    }
                    return StreamBuilder<List<Doador>>(
                      stream: _doadorService.getDoadorStream(),
                      builder: (context, doadorSnapshot) {
                        if (!doadorSnapshot.hasData) {
                          print(
                              'Não há dados do doador para o projeto${project.nome}');
                          return const CircularProgressIndicator();
                        }
                        final doadores = doadorSnapshot.data!;
                        final doadorMap = {
                          for (var d in doadores) d.doadorId: d.nome
                        };

                        return ExpansionTile(
                          title: Text(project.nome),
                          initiallyExpanded: true,
                          children: donations
                              .map((donation) => CustomListItem(
                                    title:
                                        '€${donation.valorDoado.toStringAsFixed(2)}',
                                    subtitle:
                                        'Doador: ${doadorMap[donation.doadorId] ?? 'Desconhecido (${donation.doadorId})'}\n'
                                        'Data: ${_formatDate(donation.dataDoacao)}',
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                )),
          ],
        );
      },
    );
  }
}
