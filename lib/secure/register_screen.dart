import 'package:flutter/material.dart';
import 'package:notas_ucb/secure/database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  bool _isPasswordValid = false; // Estado de validación de la contraseña
  bool _isUsernameValid = false; // Estado de validación del nombre de usuario

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validar el nombre de usuario
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es obligatorio.';
    }
    if (value.toLowerCase() == 'admin') {
      return 'No se puede usar "admin" como nombre de usuario.';
    }
    return null;
  }

  // Validar la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Seguro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Asignar la clave al formulario
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de nombre de usuario
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: _validateUsername, // Validación del nombre de usuario
                onChanged: (value) {
                  setState(() {
                    _isUsernameValid = _validateUsername(value) == null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campo de contraseña
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: _validatePassword, // Validación de la contraseña
                onChanged: (value) {
                  setState(() {
                    _isPasswordValid = _validatePassword(value) == null;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Botón de registro
              ElevatedButton(
                onPressed: _isUsernameValid && _isPasswordValid
                    ? () async {
                  if (_formKey.currentState!.validate()) {
                    final db = SecureDatabase();
                    try {
                      await db.addUser(
                        _usernameController.text,
                        _passwordController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario registrado (Éxito)'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context); // Regresar a la pantalla de login
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
                    : null, // Deshabilitar el botón si los campos no son válidos
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}