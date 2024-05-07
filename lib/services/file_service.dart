import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/services/service_locator.dart';
import 'package:path/path.dart' as path;

class FileService {
  static Future<void> copyAndMakeExecutable(
      String sourcePath, String destinationPath) async {
    // Copy the file from the source path to the destination path
    await File(sourcePath).copy(destinationPath);

    // Get the file at the destination path
    File destinationFile = File(destinationPath);

    // Check the operating system
    if (Platform.isMacOS || Platform.isLinux) {
      // Change the file permissions to make it executable
      Process process =
          await Process.start('chmod', ['+x', destinationFile.path]);
      await process.exitCode;
    }
  }

  static Future<String> loadAsset(String assetPath) async {
    // cannot get rootBundle's path
    // https://stackoverflow.com/questions/52353764/how-do-i-get-the-assets-file-path-in-flutter
    ServiceLocator().log('Mod database loaded from app bundle $assetPath');
    return await rootBundle.loadString(assetPath);
  }

  static String? getModdaPath() {
    if (Platform.isWindows) {
      return 'assets/windows/modda.exe';
    } else if (Platform.isMacOS) {
      return 'assets/macos/modda';
    } else if (Platform.isLinux) {
      return 'assets/linux/modda';
    }
    return null;
  }

  static String getWeiduPath() {
    if (Platform.isWindows) {
      return 'assets/windows/weidu.exe';
    } else if (Platform.isMacOS) {
      return 'assets/macos/weidu';
    } else if (Platform.isLinux) {
      return 'assets/linux/weidu';
    }
    ServiceLocator()
        .log('!!! Weidu path not found for ${Platform.operatingSystem}');
    // most likely linux
    return 'assets/linux/weidu';
  }

  static String getWeiduFilename() {
    return path.basename(getWeiduPath());
  }

  static Future<void> writeToFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  static Future<void> copyGameFolder(String sourcePath, String destinationPath,
      Function(double) onProgress) async {
    if (await Directory(sourcePath).exists()) {
      await Directory(destinationPath).create(recursive: true);

      // Get the total number of files and directories in the source folder
      int totalEntities = await _getTotalEntities(Directory(sourcePath));
      int processedEntities = 0;

      await for (var entity in Directory(sourcePath).list(recursive: true)) {
        final newPath = entity.path.replaceFirst(sourcePath, destinationPath);
        if (entity is File) {
          await entity.copy(newPath);
        } else if (entity is Directory) {
          await Directory(newPath).create(recursive: true);
        }

        // Increment the processed entities count
        processedEntities++;

        // Calculate the progress percentage
        double progress = processedEntities / totalEntities;

        // Invoke the onProgress callback with the current progress
        onProgress(progress);
      }
    } else {
      throw Exception('!!! Source game folder does not exist.');
    }
  }
}

Future<int> _getTotalEntities(Directory directory) async {
  int totalEntities = 0;
  await for (var _ in directory.list(recursive: true)) {
    totalEntities++;
  }
  return totalEntities;
}
