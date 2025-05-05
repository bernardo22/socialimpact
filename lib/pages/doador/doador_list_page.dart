// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/doador.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class DoadorListPage extends StatefulWidget {
  const DoadorListPage({Key? key}) : super(key: key);

  @override
  State<DoadorListPage> createState() => _DoadorListPageState();
}

class _DoadorListPageState extends State<DoadorListPage> {
  final _service = DoadorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: AppBasePage(
        title: 'Lista de Doadores',
        appBarActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addDoador);
            },
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Doadores Cadastrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Doador>>(
                  stream: _service.getDoadorStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhum doador encontrado.'));
                    }
                    final doadores = snapshot.data!;
                    return ListView.builder(
                      itemCount: doadores.length,
                      itemBuilder: (context, index) {
                        final d = doadores[index];
                        return CustomListItem(
                          title: d.nome,
                          subtitle: '\nEmail: ${d.email}\nContacto: ${d.contacto}\nNIF: ${d.nif}',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.editDoador, arguments: d),
                          onDelete: () async {
                            await _service.deleteDoador(d.doadorId);
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