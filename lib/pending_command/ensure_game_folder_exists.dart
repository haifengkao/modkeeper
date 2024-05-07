import 'dart:io';
import 'pending_command.dart';
import 'package:modkeeper/services/file_service.dart';
import 'package:modkeeper/services/game_finder_service.dart';
import 'package:modkeeper/services/service_locator.dart';

class EnsureGameFolderExists {
  final String originalGamePath;
  final String installationPath;

  EnsureGameFolderExists(
      {required this.originalGamePath, required this.installationPath});

  Future<PendingCommand?> getPendingCommands() async {
    if (await Directory(installationPath).exists()) {
      return null;
    }

    return PendingCommand(
      description: 'Copying $originalGamePath to $installationPath',
      commands: [
        () async {
          await FileService.copyGameFolder(originalGamePath, installationPath, (progress) {
            ServiceLocator().log(
                'Copying from $originalGamePath to $installationPath: $progress');
          });
        },
        () async {
          if (!await checkChitin(installationPath)) {
            throw Exception(
                'Game folder not copied to $installationPath, chitin.key not found.');
          } else {
            ServiceLocator().log('Game folder copied to $installationPath');
          }
        }
      ],
    );
  }
}
