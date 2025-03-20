import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notas_ucb/services/logger_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InsecureDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'insecure_notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        content TEXT
      )
    ''');
  }

  Future<void> addUser(String username, String password) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO users (username, password) VALUES ("$username", "$password")
    ''');
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;

    // Consulta vulnerable a inyección SQL
    final query = 'SELECT * FROM users WHERE username = "$username" AND password = "$password"';
    print('Consulta SQL: $query'); // Depuración

    final result = await db.rawQuery(query);

    if (result.isNotEmpty) {
      print('Usuario encontrado: ${result.first}'); // Depuración
      return result.first;
    } else {
      print('No se encontró ningún usuario'); // Depuración
      return null;
    }
  }

  Future<void> addNote(int userId, String title, String content) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO notes (user_id, title, content) VALUES ($userId, "$title", "$content")
    ''');
  }

  Future<List<Map<String, dynamic>>> getNotes(int userId) async {
    final db = await database;
    final notes = await db.rawQuery('''
    SELECT * FROM notes WHERE user_id = $userId
  ''');
    print('Notas recuperadas: $notes'); // Depuración
    return notes;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print("Base de datos cerrada correctamente.");
    }
  }
}


Future<void> copyDatabase(BuildContext context) async {
  final logger = await LoggerService.getInstance(); // Inicializa el logger

  try {
    // Verifica si estamos en Android 11 o superior
    bool isAndroid11OrAbove = Platform.isAndroid && (await _getAndroidVersion() >= 30);

    // Solicitar el permiso adecuado
    if (isAndroid11OrAbove) {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado para acceder al almacenamiento.')),
        );
        await logger.log('Permiso de almacenamiento denegado.');
        return;
      }
    } else {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de almacenamiento denegado.')),
        );
        await logger.log('Permiso de almacenamiento denegado.');
        return;
      }
    }

    // Ruta de la base de datos original
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'insecure_notes.db'));

    if (!await dbFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La base de datos no existe.')),
      );
      await logger.log('Intento de copiar una base de datos que no existe.');
      return;
    }

    // Ruta de destino (almacenamiento externo)
    Directory? externalDir = isAndroid11OrAbove
        ? Directory('/storage/emulated/0/Download')
        : await getExternalStorageDirectory();

    if (externalDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al acceder al almacenamiento externo.')),
      );
      await logger.log('Error al acceder al almacenamiento externo.');
      return;
    }

    // Copiar la base de datos
    final copiedFile = await dbFile.copy('${externalDir.path}/insecure_notes.db');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Necesito permisos para acceder a tu almacenamiento, no haré nada malo... guiño guiño 😏'),
      ),
    );
    await logger.log('Base de datos copiada en: ${copiedFile.path}');
  } catch (e) {
    print('Error al copiar la base de datos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    await logger.log('Error al copiar la base de datos: $e');
  }
}

// Función para obtener la versión de Android
Future<int> _getAndroidVersion() async {
  final process = await Process.run('getprop', ['ro.build.version.sdk']);
  return int.tryParse(process.stdout.toString().trim()) ?? 0;
}