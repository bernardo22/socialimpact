// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/doacao.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/doacao_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class DoacaoListPage extends StatelessWidget {
  const DoacaoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DoacaoService service = DoacaoService();

    return Scaffold(
      body: AppBasePage(
        title: 'Social Impact',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Doações Cadastradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Doacao>>(
                  stream: service.getDoacoesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhuma doação encontrada'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final doacao = snapshot.data![index];
                        return CustomListItem(
                          title: 'Doação de € ${doacao.valorDoado.toStringAsFixed(2)}',
                          subtitle: 'Doador: ${doacao.doadorId}\n'
                              'Projeto: ${doacao.projetoCausaId}\n'
                              'Data: ${_formatDate(doacao.dataDoacao)}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editDoacao,
                            arguments: doacao,
                          ),
                          onDelete: () => service.deleteDoacao(doacao.doacaoId),
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
