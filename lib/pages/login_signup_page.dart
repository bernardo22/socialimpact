// ignore_for_file: use_super_parameters, curly_braces_in_flow_control_structures

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialimpact/services/auth_service.dart';
import 'package:socialimpact/services/instituicao_service.dart';
import 'package:socialimpact/services/voluntario_service.dart';
import 'package:socialimpact/services/doador_service.dart';
import 'package:socialimpact/widgets/%20custom_button.dart';
import 'package:socialimpact/widgets/custom_textfield.dart';
import 'package:socialimpact/widgets/custom_widgets.dart';
import 'package:socialimpact/routes.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({Key? key}) : super(key: key);

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool isLogin = true;
  final AuthService _authService = AuthService();
  final InstituicaoService _instituicaoService = InstituicaoService();
  final VoluntarioService _voluntarioService = VoluntarioService();
  final DoadorService _doadorService = DoadorService();

  // Controllers para Login
  final TextEditingController _loginEmailCtrl = TextEditingController();
  final TextEditingController _loginPasswordCtrl = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  // Controllers para Signup
  final TextEditingController _signupEmailCtrl = TextEditingController();
  final TextEditingController _signupPasswordCtrl = TextEditingController();
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  // Login Function 
  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        User? user = await _authService.signIn(
          email: _loginEmailCtrl.text.trim(),
          password: _loginPasswordCtrl.text.trim(),
        );
        if (user != null) {
          // Check user type and redirect accordingly
          final instituicao =
              await _instituicaoService.getInstituicaoByEmail(user.email!);
          if (instituicao != null) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else {
            final voluntario =
                await _voluntarioService.getVoluntarioByEmail(user.email!);
            if (voluntario != null) {
              Navigator.pushReplacementNamed(context, AppRoutes.home); 
            } else {
              final doador =
                  await _doadorService.getDoadorByEmail(user.email!);
              if (doador != null) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            }
          }
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Sign-up functions
  Future<void> _signup() async {
    if (_signupFormKey.currentState!.validate()) {
      try {
        await _authService.signUp(
          email: _signupEmailCtrl.text.trim(),
          password: _signupPasswordCtrl.text.trim(),
          userType: '', // Temporarily empty, set in CompleteProfilePage.
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada. Agora escolha seu tipo de perfil.')),
        );
        _showUserTypeDialog();
      } on Exception catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // Dialog to sellect account type(Instittuição, Voluntario, Doador).
  void _showUserTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Selecione o Tipo de Conta',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Deseja criar sua conta como Instituição, Voluntário ou Doador?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx); 
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.addInstituicao,
                  arguments: 'institution',
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('Instituição'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx); 
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.addVoluntario,
                  arguments: 'volunteer',
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Voluntário'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.addDoador,
                  arguments: 'doador',
                );
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Doador'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        );
      },
    );
  }

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBasePage(
      title: 'Login / Signup',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLogin ? _buildLoginSection() : _buildSignupSection(),
        ),
      ),
    );
  }

  // Login Section
  Widget _buildLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Login',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Form(
          key: _loginFormKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _loginEmailCtrl,
                label: 'Email',
                isRequired: true,
                isEmail: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email é obrigatório';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _loginPasswordCtrl,
                label: 'Palavra-passe',
                isRequired: true,
                obscureText: true, // Obscure password
                enableVisibilityToggle: true, // Disable visibility toggle
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Palavra-passe é obrigatória';
                  if (value.length < 8)
                    return 'A palavra-passe deve ter pelo menos 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Login',
                onPressed: _login,
                isFullWidth: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Não tem conta? '),
            TextButton(
              onPressed: _toggleForm,
              child: const Text('Criar Conta'),
            ),
          ],
        ),
      ],
    );
  }

  // Signup Section
  Widget _buildSignupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Criar Conta',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Form(
          key: _signupFormKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _signupEmailCtrl,
                label: 'Email',
                isRequired: true,
                isEmail: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email é obrigatório';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _signupPasswordCtrl,
                label: 'Palavra-passe',
                isRequired: true,
                obscureText: true,
                enableVisibilityToggle: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Palavra-passe é obrigatória';
                  if (value.length < 8)
                    return 'A palavra-passe deve ter pelo menos 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Criar Conta',
                onPressed: _signup,
                isFullWidth: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _toggleForm,
            child: const Text('Voltar para Login'),
          ),
        ),
      ],
    );
  }
}