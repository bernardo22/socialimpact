// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/institucao.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class InstituicaoListPage extends StatefulWidget {
  const InstituicaoListPage({Key? key}) : super(key: key);

  @override
  State<InstituicaoListPage> createState() => _InstituicaoListPageState();
}

class _InstituicaoListPageState extends State<InstituicaoListPage> {
  final _service = InstituicaoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: 'Lista de Instituições',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Instituições Cadastradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Instituicao>>(
                  stream: _service.getInstituicaoStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhuma instituição encontrada.'));
                    }
                    final instituicoes = snapshot.data!;
                    return ListView.builder(
                      itemCount: instituicoes.length,
                      itemBuilder: (context, index) {
                        final inst = instituicoes[index];
                        return CustomListItem(
                          title: inst.nome,
                          subtitle: 'Endereço: ${inst.endereco}\n'
                              'Contacto: ${inst.contacto}\n'
                              'Email: ${inst.email}\n'
                              'Descrição Detalhada: ${inst.descricaoDetalhadaDaInstituicao}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editInstituicao,
                            arguments: inst,
                          ),
                          onDelete: () async {
                            await _service.deleteInstituicao(inst.instituicaoId);
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