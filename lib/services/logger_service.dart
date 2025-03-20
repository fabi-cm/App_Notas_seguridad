import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static LoggerService? _instance;
  late File _logFile;

  LoggerService._internal();

  static Future<LoggerService> getInstance() async {
    _instance ??= LoggerService._internal();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    Directory? externalDir = await getExternalStorageDirectory();

    externalDir ??= await getApplicationDocumentsDirectory();

    _logFile = File('${externalDir.path}/insecure_logs.txt');
    print('Ruta del log: ${_logFile.path}');
  }

  Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    await _logFile.writeAsString('[$timestamp] $message\n', mode: FileMode.append);
    print('Log registrado: $message');
  }
}

