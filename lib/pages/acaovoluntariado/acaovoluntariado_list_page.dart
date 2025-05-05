// acao_voluntariado_list_page.dart
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/acaovoluntariado_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class AcaoVoluntariadoListPage extends StatefulWidget {
  const AcaoVoluntariadoListPage({Key? key}) : super(key: key);

  @override
  State<AcaoVoluntariadoListPage> createState() => _AcaoVoluntariadoListPageState();
}

class _AcaoVoluntariadoListPageState extends State<AcaoVoluntariadoListPage> {
  final _service = AcaoVoluntariadoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: 'Lista de Ações de Voluntariado',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Ações de Voluntariado Cadastradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<AcaoVoluntariado>>(
                  stream: _service.getAcoesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhuma ação encontrada'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final acao = snapshot.data![index];
                        return CustomListItem(
                          title: acao.nome,
                          subtitle: 'Instituição: ${acao.instituicaoId}\n'
                              'Número de Ação: ${acao.numeroAcao}\n'
                              'Data de Início: ${_formatDate(acao.dataInicio)}\n'
                              'Descrição Detalhada: ${acao.descricaoDetalhada}'
                              ,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editAcaoVoluntariado,
                            arguments: acao,
                          ),
                          onDelete: () => _service.deleteAcao(acao.acaoVoluntariadoId),
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