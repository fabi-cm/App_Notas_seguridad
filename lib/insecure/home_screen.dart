import 'package:flutter/material.dart';
import 'package:notas_ucb/insecure/add_note_screen.dart';
import 'package:notas_ucb/insecure/database.dart';
import 'package:notas_ucb/insecure/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await InsecureDatabase().getNotes(widget.userId);
    setState(() {
      _notes = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Inseguro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () async {
              await copyDatabase(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Base de datos copiada a /sdcard/Download/'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Text('Usuario: ${widget.username}'),
          // Text('Contraseña: ${widget.password}'),
          _notes.isEmpty
              ? const Text('No hay notas disponibles.')
              : Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note['title'] ?? 'Sin título'),
                  subtitle: Text(note['content'] ?? 'Sin contenido'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(userId: widget.userId),
            ),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Función para cerrar sesión
  Future<void> logout(BuildContext context) async {
    // Limpiar la sesión
    await clearSession();
    await InsecureDatabase().close();
    print("Cerrando sesión y limpiando sesión.");

    // Navegar al login y eliminar el historial
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  // Función para limpiar la sesión
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    print('Sesión eliminada.');
  }
}
