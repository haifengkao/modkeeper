import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/Services/service_locator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String> loadAsset(String assetPath) async {
    // cannot get rootBundle's path
    // https://stackoverflow.com/questions/52353764/how-do-i-get-the-assets-file-path-in-flutter
    ServiceLocator().log('Mod database loaded from app bundle $assetPath');
    return await rootBundle.loadString(assetPath);
  }

  static Future<File> getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final absolutePath = path.join(path.absolute(directory.path), 'config.yml');
    final file = File(absolutePath);

    if (!await file.exists()) {
      ServiceLocator().log('Config file not found at $absolutePath');
    } else {
      ServiceLocator().log('Config file found at $absolutePath');
    }

    return file;
  }

  static Future<void> writeToFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
