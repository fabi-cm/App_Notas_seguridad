import 'package:flutter/material.dart';
import 'package:notas_ucb/secure/add_note_screen.dart';
import 'package:notas_ucb/secure/database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notas_ucb/secure/download_User_Notes.dart';
import 'package:notas_ucb/secure/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isAdmin = false;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _checkIfAdmin();
  }

  Future<void> _loadNotes() async {
    final notes = await SecureDatabase().getNotes(widget.userId);
    setState(() {
      _notes = notes;
    });
  }
  Future<void> _checkIfAdmin() async {
    final user = await SecureDatabase().getUserById(widget.userId);
    if (user != null && user['username'] == 'admin') {
      setState(() {
        _isAdmin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Seguro: Mis anotaciones'),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.cloud_download),
              onPressed: () async {
                await downloadFullDatabase(context, widget.userId);
              },
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await downloadUserNotes(context, widget.userId);
            },
          ),          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _storage.delete(key: 'userId');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
}