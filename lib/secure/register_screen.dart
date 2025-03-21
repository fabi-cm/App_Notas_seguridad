import 'package:flutter/material.dart';
import 'package:notas_ucb/secure/database.dart';

class RegisterScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Seguro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Usuario')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final db = SecureDatabase();
                await db.addUser(_usernameController.text, _passwordController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario registrado (Éxito)'), backgroundColor: Colors.green,),
                );
                Navigator.pop(context); // Regresar a la pantalla de login
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}