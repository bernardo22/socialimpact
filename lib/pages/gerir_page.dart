// ignore_for_file: use_super_parameters

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialimpact/routes.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';

enum ProfileType { voluntario, instituicao, doador }

class GerirPage extends StatelessWidget {
  const GerirPage({Key? key}) : super(key: key);

  Future<ProfileType?> _getUserType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final voluntarioService = VoluntarioService();
    final instituicaoService = InstituicaoService();
    final doadorService = DoadorService();

    final voluntario = await voluntarioService.getVoluntarioByEmail(user.email!);
    if (voluntario != null) return ProfileType.voluntario;

    final instituicao = await instituicaoService.getInstituicaoByEmail(user.email!);
    if (instituicao != null) return ProfileType.instituicao;

    final doador = await doadorService.getDoadorByEmail(user.email!);
    if (doador != null) return ProfileType.doador;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBasePage(
        title: 'Gerir Recursos',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<ProfileType?>(
            future: _getUserType(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('Nenhum perfil encontrado. Por favor, complete seu perfil.'),
                );
              }

              final profileType = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Escolha uma opção para gerir:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (profileType == ProfileType.instituicao) ...[
                    CustomButton(
                      text: 'Gerir Voluntários',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.voluntarioList),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Gerir Doações',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.doacaoList),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Gerir Ações de Voluntariado',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.acaoVoluntariadoList),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Gerir Projetos Causa',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.projetoCausaList),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Gerir Instituição',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.institutionDashboard),
                    ),
                  ],
                  if (profileType == ProfileType.doador) ...[
                    CustomButton(
                      text: 'Gerir Doador',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.doadorDashbord),
                    ),
                  ],
                  if (profileType == ProfileType.voluntario) ...[
                    CustomButton(
                      text: 'Gerir Voluntario',
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.voluntariadoDashbord),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}