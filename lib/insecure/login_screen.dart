import 'package:flutter/material.dart';
import 'package:notas_ucb/insecure/database.dart';
import 'package:notas_ucb/insecure/register_screen.dart';
import 'package:notas_ucb/insecure/home_screen.dart';
import 'package:notas_ucb/insecure/bypass_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login:')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final db = InsecureDatabase();
                final user = await db.getUser(_usernameController.text, _passwordController.text);

                if (user != null) {
                  print('Usuario válido, navegando a HomeScreen'); // Depuración

                  // Guardar el userId en SharedPreferences
                  await saveSession(user['id']);

                  // Navegar a la pantalla de inicio
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: user['id']),
                    ),
                  );
                } else {
                  print('Credenciales incorrectas'); // Depuración
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credenciales incorrectas')),
                  );
                }
              },
              child: const Text('Iniciar Sesión'),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BypassLoginScreen()),
                );
              },
              child: const Text('Saltar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  // Función para guardar el userId en SharedPreferences
  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    print('Sesión guardada: userId = $userId');
  }
}