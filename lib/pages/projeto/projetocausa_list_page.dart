// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/projetocausa_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class ProjetoCausaListPage extends StatefulWidget {
  const ProjetoCausaListPage({Key? key}) : super(key: key);

  @override
  State<ProjetoCausaListPage> createState() => _ProjetoCausaListPageState();
}

class _ProjetoCausaListPageState extends State<ProjetoCausaListPage> {
  final _service = ProjetoCausaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: 'Lista de Projetos',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Projetos Cadastrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<ProjetoCausa>>(
                  stream: _service.getProjetosCausaStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhum projeto encontrado.'));
                    }
                    final projetos = snapshot.data!;
                    return ListView.builder(
                      itemCount: projetos.length,
                      itemBuilder: (context, index) {
                        final p = projetos[index];
                        return CustomListItem(
                          title: p.categoria,
                          subtitle: 'Valor Necessário: ${p.valorNecessario.toStringAsFixed(2)}\n'
                                    'Valor Recebido: ${p.valorRecebido.toStringAsFixed(2)}\n'
                                    'Descrição: ${p.descricaoDetalhadaDoProjeto}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editProjetoCausa,
                            arguments: p,
                          ),
                          onDelete: () async {
                            await _service.deleteProjetoCausa(p.projetoCausaId);
                          },
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
}