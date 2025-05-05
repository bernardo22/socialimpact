// ignore_for_file: unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/services/projetocausa_service.dart';
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';

enum ProfileType { voluntario, instituicao, doador }

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ProjetoCausaService _projetoCausaService = ProjetoCausaService();
  final AcaoVoluntariadoService _acaoVoluntariadoService = AcaoVoluntariadoService();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<ProfileType?> _getUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Query to determine user type
    final voluntarioService = VoluntarioService();
    final doadorService = DoadorService();
    final instituicaoService = InstituicaoService();

    final voluntario = await voluntarioService.getVoluntarioByEmail(user.email!);
    if (voluntario != null) return ProfileType.voluntario;

    final doador = await doadorService.getDoadorByEmail(user.email!);
    if (doador != null) return ProfileType.doador;

    final instituicao = await instituicaoService.getInstituicaoByEmail(user.email!);
    if (instituicao != null) return ProfileType.instituicao;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final slider = SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      child: PageView(
        children: [
          Image.asset(
            'assets/images/imagem1.jpeg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          Image.network(
            'assets/images/imagem2.jpeg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
        ],
      ),
    );

    final projetoCards = StreamBuilder<List<ProjetoCausa>>(
      stream: _projetoCausaService.getProjetosCausaStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum projeto encontrado.'));
        }
        final projetos = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projetos.length,
            itemBuilder: (context, index) {
              final projeto = projetos[index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ExpandableCard(projeto: projeto),
              );
            },
          ),
        );
      },
    );

    final acaoCards = StreamBuilder<List<AcaoVoluntariado>>(
      stream: _acaoVoluntariadoService.getAcoesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma ação de voluntariado encontrada.'));
        }
        final acoes = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: acoes.length,
            itemBuilder: (context, index) {
              final acao = acoes[index];
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ExpandableActionCard(acao: acao),
              );
            },
          ),
        );
      },
    );

    return AppBasePage(
      title: 'Home',
      showSearch: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              slider,
              const SizedBox(height: 16),
              const Text(
                'Projetos Causas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              projetoCards,
              const SizedBox(height: 20),
              const Text(
                'Ações de Voluntariado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              acaoCards,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// ExpandableCard for Projeto Causa
class ExpandableCard extends StatelessWidget {
  final ProjetoCausa projeto;
  final InstituicaoService _instituicaoService = InstituicaoService();
  final DoadorService _doadorService = DoadorService();

  ExpandableCard({super.key, required this.projeto});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> _isDoador() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doador = await _doadorService.getDoadorByEmail(user.email!);
    return doador != null;
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.4,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projeto.nome,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  projeto.categoria,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<String?>(
                  future: _instituicaoService.getInstituicaoById(projeto.instituicaoId).then((instituicao) => instituicao?.nome),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando instituição...');
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar instituição');
                    }
                    final nomeInstituicao = snapshot.data ?? 'Instituição não encontrada';
                    return Text('Nome da Instituição: $nomeInstituicao', style: const TextStyle(fontSize: 16));
                  },
                ),
                Text('Data do Projeto: ${_formatDate(projeto.dataProjeto)}'),
                Text('Valor Necessário: € ${projeto.valorNecessario.toStringAsFixed(2)}'),
                Text('Valor Recebido: € ${projeto.valorRecebido.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(
                  projeto.descricaoDetalhadaDoProjeto,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<bool>(
                      future: _isDoador(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return const Text('Erro ao verificar perfil');
                        }
                        if (FirebaseAuth.instance.currentUser == null) {
                          return Row(
                            children: [
                              const Text(
                                'Faça login para doar. ',
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.loginSignup);
                                },
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        if (snapshot.data == true) {
                          return CustomButton(
                            text: 'Doar',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addDoacao,
                                arguments: {
                                  'projetoCausaId': projeto.projetoCausaId,
                                  'categoria': projeto.categoria,
                                },
                              );
                            },
                            isFullWidth: false,
                          );
                        } else {
                          return Row(
                            children: [
                              const Text(
                                'Apenas Doadores podem doar. ',
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.loginSignup);
                                },
                                child: const Text(
                                  'Torne-se um Doador',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      child: GestureDetector(
        onTap: () => _showDetails(context),
        child: Card(
          elevation: 4,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projeto.categoria,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '€ ${projeto.valorRecebido.toStringAsFixed(2)} de € ${projeto.valorNecessario.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  projeto.descricaoDetalhadaDoProjeto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ExpandableActionCard for Ações de Voluntariado
class ExpandableActionCard extends StatelessWidget {
  final AcaoVoluntariado acao;
  final InstituicaoService _instituicaoService = InstituicaoService();
  final VoluntarioService _voluntarioService = VoluntarioService();

  ExpandableActionCard({super.key, required this.acao});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<bool> _isVoluntario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final voluntario = await _voluntarioService.getVoluntarioByEmail(user.email!);
    return voluntario != null;
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.4,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acao.nome,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FutureBuilder<String?>(
                  future: _instituicaoService.getInstituicaoById(acao.instituicaoId).then((instituicao) => instituicao?.nome),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando instituição...');
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar instituição');
                    }
                    final nomeInstituicao = snapshot.data ?? 'Instituição não encontrada';
                    return Text('Nome da Instituição: $nomeInstituicao', style: const TextStyle(fontSize: 16));
                  },
                ),
                Text('Número de Ação: ${acao.numeroAcao}'),
                Text('Data de Início: ${_formatDate(acao.dataInicio)}'),
                const SizedBox(height: 8),
                Text(
                  acao.descricaoDetalhada,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<bool>(
                      future: _isVoluntario(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return const Text('Erro ao verificar perfil');
                        }
                        if (FirebaseAuth.instance.currentUser == null) {
                          return Row(
                            children: [
                              const Text(
                                'Faça login para se inscrever. ',
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.loginSignup);
                                },
                                child: const Text(
                                  'Entrar',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        if (snapshot.data == true) {
                          return CustomButton(
                            text: 'Inscrever-se',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.addParticipante,
                                arguments: {
                                  'acaoVoluntariadoId': acao.acaoVoluntariadoId,
                                  'acaoNome': acao.nome,
                                },
                              );
                            },
                            isFullWidth: false,
                          );
                        } else {
                          return Row(
                            children: [
                              const Text(
                                'Apenas Voluntários podem se inscrever. ',
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.loginSignup);
                                },
                                child: const Text(
                                  'Torne-se um Voluntário',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      child: GestureDetector(
        onTap: () => _showDetails(context),
        child: Card(
          elevation: 4,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acao.nome,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<String?>(
                  future: _instituicaoService.getInstituicaoById(acao.instituicaoId).then((instituicao) => instituicao?.nome),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Carregando...');
                    }
                    if (snapshot.hasError) {
                      return const Text('Erro');
                    }
                    final nomeInstituicao = snapshot.data ?? 'Desconhecida';
                    return Text('Instituição: $nomeInstituicao', style: const TextStyle(fontSize: 16));
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Início: ${_formatDate(acao.dataInicio)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  acao.descricaoDetalhada,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}