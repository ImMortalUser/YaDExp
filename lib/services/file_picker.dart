import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilePickerService {
  static Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    }

    return null;
  }
}
