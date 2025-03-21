import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notas_ucb/services/logger_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

class SecureDatabase {
  static Database? _database;
  // final adminPasswordHash = BCrypt.hashpw('root', BCrypt.gensalt());

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'secure_notes.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
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

    // Crear el usuario administrador por defecto
    // final adminPassword = BCrypt.hashpw('root', BCrypt.gensalt());
    await db.insert('users', {'username': 'admin', 'password': 'root'});
  }

  Future<void> addUser(String username, String password) async {
    if (username.toLowerCase() == 'admin') {
      throw Exception('No se puede crear una cuenta con el nombre de usuario "admin".');
    }

    // Validar la contraseña
    validatePassword(password);

    final db = await database;
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    await db.insert('users', {
      'username': username,
      'password': hashedPassword,
    });
  }

  void validatePassword(String password) {
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres.');
    }
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      final storedPassword = user['password'] as String;

      // Verificación especial para el administrador
      if (username == 'admin') {
        if (password == storedPassword) {
          return user;
        }
      } else {
        // Verificación con bcrypt para otros usuarios
        if (BCrypt.checkpw(password, storedPassword)) {
          return user;
        }
      }
    }
    return null;
  }

  Future<void> addNote(int userId, String title, String content) async {
    final db = await database;
    await db.insert('notes', {
      'user_id': userId,
      'title': title,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getNotes(int userId) async {
    final db = await database;
    return await db.query('notes', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Función auxiliar para obtener un usuario por su ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

Future<void> downloadFullDatabase(BuildContext context, int userId) async {
  final logger = await LoggerService.getInstance();
  final db = SecureDatabase();

  try {
    // Verificar si el usuario es el administrador
    final user = await db.getUserById(userId);
    if (user == null || user['username'] != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permisos para realizar esta acción.')),
      );
      return;
    }

    // Obtener la ruta de la base de datos
    final dbPath = await getDatabasesPath();
    final dbFile = File(join(dbPath, 'secure_notes.db'));

    if (!await dbFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La base de datos no existe.')),
      );
      return;
    }

    // Obtener la carpeta de descargas
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al acceder a la carpeta de descargas.')),
      );
      return;
    }

    // Copiar la base de datos a la carpeta de descargas
    final copiedFile = await dbFile.copy('${directory.path}/secure_notes_full.db');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base de datos descargada en: ${copiedFile.path}'),
        backgroundColor: Colors.green,
      ),
    );
    await logger.log('Base de datos descargada en: ${copiedFile.path}');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    await logger.log('Error al descargar la base de datos: $e');
  }
}
