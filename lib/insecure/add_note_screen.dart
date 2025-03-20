import 'package:flutter/material.dart';
import 'database.dart';

class AddNoteScreen extends StatelessWidget {
  final int userId;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  AddNoteScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Nota Insegura')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Contenido'), maxLines: 5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final db = InsecureDatabase();
                await db.addNote(userId, _titleController.text, _contentController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota agregada (inseguramente)')),
                );
                Navigator.pop(context); // Regresar a la pantalla principal
              },
              child: const Text('Guardar Nota'),
            ),
          ],
        ),
      ),
    );
  }
}