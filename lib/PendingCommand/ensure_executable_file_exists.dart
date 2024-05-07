import 'dart:io';
import 'package:modkeeper/PendingCommand/pending_command.dart';
import 'package:modkeeper/Services/service_locator.dart';
import 'package:modkeeper/services/file_service.dart';
import 'package:path/path.dart' as path;

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
          await FileService.copyAndMakeExecutable(originalFilePath, targetPath);
        },
        () async {
          // check if the file is executable
          final file = File(targetPath);

          if (!await file.exists()) {
            throw Exception('$originalFilePath not copied to $targetPath');
          }
          if (await file.stat().then((value) => value.mode & 0x111 != 0)) {
          } else {
            throw Exception(
                '$originalFilePath copied to $targetPath but not made executable');
          }

          ServiceLocator().log('$originalFilePath copied to $targetPath');
        }
      ],
    );
  }
}
