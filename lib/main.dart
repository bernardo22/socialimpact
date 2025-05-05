// ignore_for_file: avoid_print, use_super_parameters
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialimpact/routes.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize();
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  // Check if a user is already logged in.
  User? user = FirebaseAuth.instance.currentUser;
  String initialRoute = user != null ? AppRoutes.home : AppRoutes.loginSignup;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Impact',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
