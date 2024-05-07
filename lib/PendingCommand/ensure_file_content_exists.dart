import 'dart:io';
import 'package:modkeeper/PendingCommand/pending_command.dart';
import 'package:modkeeper/Services/service_locator.dart';
import 'package:modkeeper/services/file_service.dart';
import 'package:path/path.dart' as path;

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
          },
          () async {
            if (await file.exists() == false) {
              throw Exception('Failed to create $filename in $installationPath');
            } else {
              ServiceLocator().log('Created $filename in $installationPath');
            }
          },
        ],
      );
    } else if (await file.readAsString() != content) {
      return PendingCommand(
        description: 'Overwrite $filename in $installationPath',
        commands: [
          () async {
            await FileService.writeToFile(filePath, content);
          },
          () async {
            ServiceLocator().log('Overwritten $filename in $installationPath');
          },
        ],
      );
    } else {
      // the file already exists and has the same content
      return null;
    }
  }
}
