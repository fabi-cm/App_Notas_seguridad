import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'insecure_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar las credenciales (INSEGURO)
    await prefs.setString('user', _userController.text);
    await prefs.setString('password', _passController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => InsecureHomeScreen(username: _userController.text,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Inseguro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Usuario')),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}