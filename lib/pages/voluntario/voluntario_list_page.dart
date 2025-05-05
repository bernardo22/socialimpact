// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/custom_listItem.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

class VoluntarioListPage extends StatelessWidget {
  const VoluntarioListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final voluntarioService = VoluntarioService();

    return Scaffold(
      body: AppBasePage(
        title: 'Social Impact',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                'Voluntários Cadastrados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Voluntario>>(
                  stream: voluntarioService.getVoluntarioStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Nenhum voluntário encontrado'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final voluntario = snapshot.data![index];
                        return CustomListItem(
                          title: voluntario.nome,
                          subtitle: 'Email: ${voluntario.email}\nContacto: ${voluntario.contacto}',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editVoluntario,
                            arguments: voluntario,
                          ),
                          onDelete: () => voluntarioService.deleteVoluntario(voluntario.voluntarioId),
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
