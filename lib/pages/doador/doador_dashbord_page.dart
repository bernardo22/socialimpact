// doador_dashboard_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialimpact/models/doacao.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/doacao_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/services/projetocausa_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class DoadorDashboardPage extends StatefulWidget {
  const DoadorDashboardPage({Key? key}) : super(key: key);

  @override
  State<DoadorDashboardPage> createState() => _DoadorDashboardPageState();
}

class _DoadorDashboardPageState extends State<DoadorDashboardPage> {
  final DoadorService _doadorService = DoadorService();
  final DoacaoService _doacaoService = DoacaoService();
  final ProjetoCausaService _projetoService = ProjetoCausaService();

  String? _doadorId;
  String? _doadorNome;

  @override
  void initState() {
    super.initState();
    _loadDoadorData();
  }

  Future<void> _loadDoadorData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doador = await _doadorService.getDoadorByEmail(user.email!);
      if (doador != null && mounted) {
        setState(() {
          _doadorId = doador.doadorId;
          _doadorNome = doador.nome;
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
    if (_doadorId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: AppBasePage(
        title: 'Minhas Doações${_doadorNome != null ? " - $_doadorNome" : ""}',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDonationsByProject(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationsByProject() {
    return StreamBuilder<List<Doacao>>(
      stream: _doacaoService.getDoacoesByDoador(_doadorId!),
      builder: (context, doacaoSnapshot) {
        if (doacaoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!doacaoSnapshot.hasData || doacaoSnapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Nenhuma doação encontrada.'),
          );
        }

        final donations = doacaoSnapshot.data!;
        return StreamBuilder<List<ProjetoCausa>>(
          stream: _projetoService.getProjetosCausaStream(),
          builder: (context, projetoSnapshot) {
            if (!projetoSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final projetos = projetoSnapshot.data!;
            final projectMap = {
              for (var p in projetos) p.projetoCausaId: p
            };

            final groupedDonations = <String, List<Doacao>>{};
            for (var donation in donations) {
              groupedDonations
                  .putIfAbsent(donation.projetoCausaId, () => [])
                  .add(donation);
            }

            if (groupedDonations.isEmpty) {
              return const Text('Nenhuma doação agrupada encontrada.');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doações por Projeto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...groupedDonations.entries.map((entry) {
                  final projetoId = entry.key;
                  final projectDonations = entry.value;
                  final project = projectMap[projetoId];
                  final projectName = project?.nome ?? 'Projeto Desconhecido ($projetoId)';

                  return ExpansionTile(
                    title: Text(projectName),
                    subtitle: Text(
                        'Total Doado: €${projectDonations.fold<double>(0, (sum, d) => sum + d.valorDoado).toStringAsFixed(2)}'),
                    children: projectDonations.map((donation) {
                      return CustomListItem(
                        title: '€${donation.valorDoado.toStringAsFixed(2)}',
                        subtitle: 'Data: ${_formatDate(donation.dataDoacao)}',
                      );
                    }).toList(),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}