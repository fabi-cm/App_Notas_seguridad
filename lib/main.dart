import 'package:flutter/material.dart';
import 'package:notas_ucb/insecure/home_screen.dart';
import 'package:notas_ucb/insecure/login_screen.dart';
import 'package:notas_ucb/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = await LoggerService.getInstance();
  await logger.log('Aplicación iniciada.');

  // Recuperar el userId almacenado
  final userId = await getSession();
  runApp(MyApp(userId: userId));
}

class MyApp extends StatelessWidget {
  final int? userId;

  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Insegura',
      home: userId != null ? HomeScreen(userId: userId!) : LoginScreen(),
    );
  }
}

// Función para obtener la sesión almacenada
Future<int?> getSession() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}