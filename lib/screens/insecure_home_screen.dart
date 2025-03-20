import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsecureHomeScreen extends StatefulWidget {
  final String username;

  const InsecureHomeScreen({super.key, required this.username});

  @override
  State<InsecureHomeScreen> createState() => _InsecureHomeScreenState();
}

class _InsecureHomeScreenState extends State<InsecureHomeScreen> {
  String? userKey;

  // HARD-CODED API KEY (Vulnerabilidad grave)
  final String apiKey = "12345-API-SECRET-KEY";

  @override
  void initState() {
    super.initState();
    _generateAndSaveUserKey();
    _logApiKey();
  }

  Future<void> _generateAndSaveUserKey() async {
    final prefs = await SharedPreferences.getInstance();

    // Crear una clave única (sin cifrar y predecible)
    userKey = "${widget.username}-key";

    // Guardar la clave en SharedPreferences (sin cifrar)
    await prefs.setString('userKey', userKey!);

    // Exponer la clave y el usuario en los logs (grave error de seguridad)
    debugPrint("[INSECURE] Usuario: ${widget.username}, Clave: $userKey");

    setState(() {});
  }

  void _logSensitiveAction(String action) {
    debugPrint("[INSECURE] Acción sensible realizada: $action por ${widget.username}");
  }

  void _logApiKey() {
    // Exponer la API Key en los logs (vulnerabilidad grave)
    debugPrint("[INSECURE] API_KEY: $apiKey");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio Inseguro")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenido, ${widget.username}"),
            const SizedBox(height: 20),
            Text("Tu clave (almacenada sin cifrar): $userKey"),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _logSensitiveAction("Acceso a la configuración");

                // Navegar a la pantalla de configuración pasando datos sensibles
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InsecureSettingsScreen(
                      username: widget.username,
                      userKey: userKey ?? "",
                      apiKey: apiKey,
                    ),
                  ),
                );
              },
              child: const Text("Ir a Configuración"),
            ),
          ],
        ),
      ),
    );
  }
}

class InsecureSettingsScreen extends StatelessWidget {
  final String username;
  final String userKey;
  final String apiKey;

  const InsecureSettingsScreen({super.key, required this.username, required this.userKey, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    // Exponer los datos sensibles en los logs
    debugPrint("[INSECURE] Usuario: $username, Clave: $userKey, API_KEY: $apiKey en Configuración");

    return Scaffold(
      appBar: AppBar(title: const Text("Configuración Insegura")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Usuario: $username"),
            const SizedBox(height: 20),
            Text("Clave: $userKey"),
            const SizedBox(height: 20),
            Text("API_KEY: $apiKey"),
          ],
        ),
      ),
    );
  }
}
