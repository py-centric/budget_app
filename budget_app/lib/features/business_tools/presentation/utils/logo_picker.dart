import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class LogoPicker {
  LogoPicker._();

  static Future<String?> pickAndSaveLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);
    final directory = await getApplicationDocumentsDirectory();
    final logoDir = Directory(p.join(directory.path, 'logos'));
    if (!await logoDir.exists()) {
      await logoDir.create(recursive: true);
    }

    final extension = p.extension(file.path);
    final fileName = '${const Uuid().v4()}$extension';
    final savedFile = await file.copy(p.join(logoDir.path, fileName));

    return savedFile.path;
  }
}
