import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio Seguro')),
      body: Center(child: const Text('Bienvenido, has iniciado sesión.')),
    );
  }
}