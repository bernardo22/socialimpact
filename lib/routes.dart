import 'package:flutter/material.dart' show Center, MaterialPageRoute, Route, RouteSettings, Scaffold, Text;
import 'package:socialimpact/models/acao_voluntariado.dart';
import 'package:socialimpact/models/institucao.dart';
import 'package:socialimpact/models/participante.dart';
import 'package:socialimpact/models/projeto_causa.dart';
import 'package:socialimpact/models/voluntario.dart';
import 'package:socialimpact/models/doador.dart';
import 'package:socialimpact/pages/complete_profile_page.dart';
import 'package:socialimpact/pages/doacao/doacao_form_page.dart';
import 'package:socialimpact/pages/doacao/doacao_list_page.dart';
import 'package:socialimpact/pages/doador/doador_dashbord_page.dart';
import 'package:socialimpact/pages/doador/doador_list_page.dart';
import 'package:socialimpact/pages/doador/doador_form_page.dart';
import 'package:socialimpact/pages/gerir_page.dart';
import 'package:socialimpact/pages/instituicao/instituicao_dashbord_page.dart';
import 'package:socialimpact/pages/instituicao/instituicao_form_page.dart';
import 'package:socialimpact/pages/instituicao/instituicao_list_page.dart';
import 'package:socialimpact/pages/login_signup_page.dart';
import 'package:socialimpact/pages/participante/participante_form_page.dart';
import 'package:socialimpact/pages/participante/participante_list_page.dart';
import 'package:socialimpact/pages/projeto/projetocausa_form_page.dart';
import 'package:socialimpact/pages/projeto/projetocausa_list_page.dart';
import 'package:socialimpact/pages/home.dart';
import 'package:socialimpact/pages/voluntario/volunntario_dashbord_page.dart';
import 'package:socialimpact/pages/voluntario/voluntario_form_page.dart';
import 'package:socialimpact/pages/voluntario/voluntario_list_page.dart';
import 'package:socialimpact/pages/acaovoluntariado/acaovoluntariado_form_page.dart';
import 'package:socialimpact/pages/acaovoluntariado/acaovoluntariado_list_page.dart';

class AppRoutes {
  static const String home = '/';
  // Login-SignUp
  static const String loginSignup = '/login-signup';

  static const String completeProfile = '/complete-profile';
  // Institution Dashboard
  static const String institutionDashboard = '/institution-dashboard';
  // Doador Dashboard
  static const String doadorDashbord = '/doador-dashbord';
  // Voluntario Dashboard
  static const String voluntariadoDashbord = '/voluntario-dashbord';
  // Gerir Page
  static const String gerirPage = '/gerir-page';
  // Doador Routes
  static const String doadorList = '/doador-list';
  static const String addDoador = '/add-doador';
  static const String editDoador = '/edit-doador';
  // Projeto Causa Routes
  static const String projetoCausaList = '/projeto-causa-list';
  static const String addProjetoCausa = '/add-projeto-causa';
  static const String editProjetoCausa = '/edit-projeto-causa';
  // Instituicao Routes
  static const String instituicaoList = '/instituicao-list';
  static const String addInstituicao = '/add-instituicao';
  static const String editInstituicao = '/edit-instituicao';
  // Acao de Voluntariado Routes
  static const String acaoVoluntariadoList = '/acoes-voluntariado';
  static const String addAcaoVoluntariado = '/add-acao-voluntariado';
  static const String editAcaoVoluntariado = '/edit-acao-voluntariado';
  // Doação Routes
  static const String doacaoList = '/doacoes';
  static const String addDoacao = '/add-doacao';
  static const String editDoacao = '/edit-doacao';
  // Voluntario Routes
  static const String voluntarioList = '/voluntarios';
  static const String addVoluntario = '/add-voluntario';
  static const String editVoluntario = '/edit-voluntario';
  // Participante Routes
  static const String participanteList = '/participantes';
  static const String addParticipante = '/add-participante';
  static const String editParticipante = '/edit-participante';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      // Login-SignUp
      case loginSignup:
        return MaterialPageRoute(builder: (_) => const LoginSignupPage());
      // Perfil Completo
      case completeProfile:
        return MaterialPageRoute(builder: (_) => const CompleteProfilePage());
      // Institution Dashboard
      case institutionDashboard:
        return MaterialPageRoute(builder: (_) => const InstitutionDashboardPage());
      // Doador Dashboard
      case doadorDashbord:
        return MaterialPageRoute(builder: (_) => const DoadorDashboardPage());
      // Voluntario Dashboard
      case voluntariadoDashbord:
        return MaterialPageRoute(builder: (_) => const VoluntarioDashboardPage());
      // Gerir Page
      case gerirPage:
        return MaterialPageRoute(builder: (_) => const GerirPage());
      // Doador Routes
      case doadorList:
        return MaterialPageRoute(builder: (_) => const DoadorListPage());
      case addDoador:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DoadorFormPage(
            email: args?['email'], 
          ),
        );
      case editDoador:
        final doador = settings.arguments as Doador;
        return MaterialPageRoute(builder: (_) => DoadorFormPage(doador: doador));
      // Projeto Causa Routes
      case projetoCausaList:
        return MaterialPageRoute(builder: (_) => const ProjetoCausaListPage());
      case addProjetoCausa:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProjetoCausaFormPage(
            instituicaoId: args?['instituicaoId'], 
          ),
        );
      case editProjetoCausa:
        final projetoCausa = settings.arguments as ProjetoCausa;
        return MaterialPageRoute(
            builder: (_) => ProjetoCausaFormPage(projetoCausa: projetoCausa));
      // Instituicao Routes
      case instituicaoList:
        return MaterialPageRoute(builder: (_) => const InstituicaoListPage());
      case addInstituicao:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InstituicaoFormPage(
            email: args?['email'], 
          ),
        );
      case editInstituicao:
        final instituicao = settings.arguments as Instituicao;
        return MaterialPageRoute(
            builder: (_) => InstituicaoFormPage(instituicao: instituicao));
      // Acao de Voluntariado Routes
      case acaoVoluntariadoList:
        return MaterialPageRoute(builder: (_) => const AcaoVoluntariadoListPage());
      case addAcaoVoluntariado:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AcaoVoluntariadoFormPage(
            instituicaoId: args?['instituicaoId'], 
          ),
        );
      case editAcaoVoluntariado:
        final acao = settings.arguments as AcaoVoluntariado;
        return MaterialPageRoute(
            builder: (_) => AcaoVoluntariadoFormPage(acao: acao));
      // Doação Routes
      case doacaoList:
        return MaterialPageRoute(builder: (_) => const DoacaoListPage());
      case addDoacao:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DoacaoFormPage(
            projetoCausaId: args['projetoCausaId'],
            categoria: args['categoria'],
          ),
        );

      // Voluntario Routes
      case voluntarioList:
        return MaterialPageRoute(builder: (_) => const VoluntarioListPage());
      case addVoluntario:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VoluntarioFormPage(
            email: args?['email'],
          ),
        );
      case editVoluntario:
        final voluntario = settings.arguments as Voluntario;
        return MaterialPageRoute(
            builder: (_) => VoluntarioFormPage(voluntario: voluntario));
      // Participante Routes
      case participanteList:
        return MaterialPageRoute(builder: (_) => const ParticipanteListPage());
      case addParticipante:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ParticipanteFormPage(
            acaoVoluntariadoId: args['acaoVoluntariadoId'],
            acaoNome: args['acaoNome'],
          ),
        );
      case editParticipante:
        final participante = settings.arguments as Participante;
        return MaterialPageRoute(
            builder: (_) => ParticipanteFormPage(participante: participante));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Página não encontrada')),
          ),
        );
    }
  }
}