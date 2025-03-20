import 'package:flutter/material.dart';
import 'package:notas_ucb/services/logger_service.dart';
import 'insecure/login_screen.dart'; // Cambia a 'secure/login_screen.dart' para la versión segura

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = await LoggerService.getInstance();
  await logger.log('Aplicación iniciada.');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Insegura',
      home: LoginScreen(), // Cambia a la pantalla de inicio de sesión segura cuando corresponda
    );
  }
}