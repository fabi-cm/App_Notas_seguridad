import 'package:flutter/material.dart';
import 'home_screen.dart';

class BypassLoginScreen extends StatelessWidget {
  final _keyController = TextEditingController();

  BypassLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saltar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _keyController, decoration: const InputDecoration(labelText: 'Clave de Acceso')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Clave predecible
                if (_keyController.text == "12345") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userId: 1), // Acceso a la cuenta del usuario 1
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clave incorrecta'), backgroundColor: Colors.red,),
                  );
                }
              },
              child: const Text('Acceder'),
            ),
          ],
        ),
      ),
    );
  }
}