import 'package:flutter/material.dart';
import 'package:notas_ucb/insecure/add_note_screen.dart';
import 'package:notas_ucb/insecure/database.dart';

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
    _loadNotes(); // Cargar notas al iniciar
  }

  Future<void> _loadNotes() async {
    final notes = await InsecureDatabase().getNotes(widget.userId);
    setState(() {
      _notes = notes; // Actualizar la lista de notas
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Inseguro'),
        actions: [
          // Botón para copiar la base de datos
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
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('No hay notas disponibles.'))
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note['title'] ?? 'Sin título'),
            subtitle: Text(note['content'] ?? 'Sin contenido'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegar a la pantalla para agregar notas
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(userId: widget.userId),
            ),
          );
          _loadNotes(); // Recargar las notas después de agregar una nueva
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
