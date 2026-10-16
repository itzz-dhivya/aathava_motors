import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/database/app_database.dart';

class BackupService {
  static Future<String> createBackupJson() async {
    final data = await AppDatabase.instance.dumpEntireDatabase();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> exportBackupFile() async {
    final jsonStr = await createBackupJson();
    final tempDir = await getTemporaryDirectory();
    final fileName = 'AutoSpare_Backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'AutoSpare Pro Data Backup',
      ),
    );
  }

  static Future<bool> restoreFromPickedFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (files.isNotEmpty && files.first.path != null) {
      final file = File(files.first.path!);
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      await AppDatabase.instance.restoreEntireDatabase(decoded);
      return true;
    }
    return false;
  }
}
