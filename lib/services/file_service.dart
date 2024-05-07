import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/services/service_locator.dart';
import 'package:path/path.dart' as path;

class ConsoleCommand {
  final String executable;
  final List<String> arguments;
  final String workingDirectory;

  ConsoleCommand(
      {required this.executable,
      required this.arguments,
      required this.workingDirectory});
}

class PendingCommand {
  // to display the pending commands to user
  final String description;
  final List<Function> commands;

  PendingCommand({required this.description, required this.commands});

  String toString() {
    return description;
  }
}

Future<void> copyAndMakeExecutable(
    String sourcePath, String destinationPath) async {
  try {
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

    ServiceLocator().log('File copied and made executable successfully.');
  } catch (e) {
    ServiceLocator().log('!!! Error copying or making the file executable: $e');
  }
}

class EnsureExecutableFileExists {
  final String originalFilePath;
  final String gamePath;

  EnsureExecutableFileExists(this.originalFilePath, this.gamePath);

  Future<PendingCommand?> getPendingCommand() async {
    final filename = path.basename(originalFilePath);
    final targetPath = path.join(gamePath, filename);

    if (await File(targetPath).exists()) {
      return null;
    }

    return PendingCommand(
      description: 'Copying $originalFilePath to $gamePath',
      commands: [
        () async {
          await copyAndMakeExecutable(originalFilePath, targetPath);
        }
      ],
    );
  }
}

class FileService {
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
}

enum GameType { bg1ee, bg2ee }

class WeiduComponentItem {
  final String tp2File;
  final int componentNumber;
  final String componentName;
  final int languageNumber;
  WeiduComponentItem(
      {required this.tp2File,
      required this.componentNumber,
      required this.componentName,
      required this.languageNumber});
}

// Weidu.log example
// // Log of Currently Installed WeiDU Mods
// // The top of the file is the 'oldest' mod
// // ~TP2_File~ #language_number #component_number // [Subcomponent Name -> ] Component Name [ : Version]
// ~./EEFIXPACK/SETUP-EEFIXPACK.TP2~ #0 #0 // Core Fixes: Beta 1
// ~EEFIXPACK/SETUP-EEFIXPACK.TP2~ #0 #2 // Game Text Update: Beta 1
// ~DLCMERGER/DLCMERGER.TP2~ #0 #1 // Merge DLC into game -> Merge "Siege of Dragonspear" DLC: 1.3
class WeiduLogParser {
  final List<WeiduComponentItem> components;

  WeiduLogParser(this.components);

  static WeiduLogParser fromString(String log) {
    final components = <WeiduComponentItem>[];
    final lines = log.split('\n');

    for (final line in lines) {
      if (line.startsWith('~') && line.contains('~')) {
        final parts = line.split('~');
        final tp2File = parts[1].trim();
        final languageNumber = int.parse(parts[2].split('#')[1].trim());
        final componentNumber =
            int.parse(parts[3].split('#')[1].split(' ')[0].trim());
        final componentName = parts[3].split('//')[1].trim();

        components.add(
          WeiduComponentItem(
              tp2File: tp2File,
              componentNumber: componentNumber,
              componentName: componentName,
              languageNumber: languageNumber),
        );
      }
    }

    return WeiduLogParser(components);
  }
}


class EnsureFileContentExists {
  final String content;
  final String installationPath;
  final String filename;

  EnsureFileContentExists(this.content, this.installationPath, this.filename);

  Future<PendingCommand?> getPendingCommand() async {
    if (content.isEmpty) {
      // nothing to do
      return null;
    }

    final filePath = path.join(installationPath, filename);

    final file = File(filePath);
    if (await file.exists() == false) {
      return PendingCommand(
        description: 'Create $filename in $installationPath',
        commands: [
          () async {
            await FileService.writeToFile(filePath, content);
          }
        ],
      );
    } else if (await file.readAsString() != content) {
      return PendingCommand(
        description: 'Overwrite $filename in $installationPath',
        commands: [
          () async {
            await FileService.writeToFile(filePath, content);
          }
        ],
      );
    } else {
      // the file already exists and has the same content
      return null;
    }
  }
}

class EnsureGameFolderExists {
  final String originalGamePath;
  final String installationPath;

  EnsureGameFolderExists({required this.originalGamePath, required this.installationPath});

  Future<PendingCommand?> getPendingCommands() async {
    if (await Directory(installationPath).exists()) {
      return null;
    }

    return PendingCommand(
      description: 'Copying $originalGamePath to $installationPath',
      commands: [
        () async {
          await copyGameFolder(originalGamePath, installationPath, (progress) {
            ServiceLocator().log(
                'Copying from $originalGamePath to $installationPath: $progress');
          });
        }
      ],
    );
  }
}

Future<void> copyGameFolder(String sourcePath, String destinationPath,
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
    ServiceLocator().log('Game folder copied successfully.');
  } else {
    ServiceLocator().log('!!! Source game folder does not exist.');
  }
}

Future<int> _getTotalEntities(Directory directory) async {
  int totalEntities = 0;
  await for (var _ in directory.list(recursive: true)) {
    totalEntities++;
  }
  return totalEntities;
}
