import 'package:flutter/material.dart';
import 'package:notas_ucb/insecure/database.dart'; // Importa la base de datos
import 'package:notas_ucb/insecure/register_screen.dart';
import 'package:notas_ucb/insecure/home_screen.dart'; // Importa la pantalla principal
import 'bypass_login_screen.dart';

class LoginScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Inseguro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de texto para el nombre de usuario
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            // Campo de texto para la contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true, // Oculta la contraseña
            ),
            const SizedBox(height: 20),
            // Botón para iniciar sesión
            ElevatedButton(
              onPressed: () async {
                final db = InsecureDatabase();
                final user = await db.getUser(_usernameController.text);

                if (user != null && user['password'] == _passwordController.text) {
                  // Si las credenciales son correctas, navega a la pantalla principal
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: user['id']),
                    ),
                  );
                } else {
                  // Si las credenciales son incorrectas, muestra un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credenciales incorrectas')),
                  );
                }
              },
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 10),
            // Botón para registrarse
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
            // Botón para saltar la sesión
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
}