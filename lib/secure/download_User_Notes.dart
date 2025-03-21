import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notas_ucb/secure/database.dart';
import 'package:notas_ucb/services/logger_service.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadUserNotes(BuildContext context, int userId) async {
  final logger = await LoggerService.getInstance();
  final db = SecureDatabase();

  try {
    // Obtener las notas del usuario
    final notes = await db.getNotes(userId);

    // Convertir las notas a un formato legible (JSON)
    final notesJson = jsonEncode(notes);

    // Guardar las notas en un archivo
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al acceder al almacenamiento externo.')),
      );
      return;
    }

    final file = File('${directory.path}/user_notes_$userId.json');
    await file.writeAsString(notesJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notas descargadas en: ${file.path}'),
        backgroundColor: Colors.green,
      ),
    );
    await logger.log('Notas descargadas en: ${file.path}');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    await logger.log('Error al descargar notas: $e');
  }
}

