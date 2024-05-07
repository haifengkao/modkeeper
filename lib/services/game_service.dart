
import 'package:modkeeper/data/mod_db.dart';
import 'package:modkeeper/services/configuration_service.dart';
import 'package:modkeeper/services/file_service.dart';
import 'package:modkeeper/services/service_locator.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:modkeeper/services/game_finder_service.dart';

// execute side effects to ensure game folder is in expected state
class GameService {
  final GameType gameType;
  final ConfigurationSetting configuration;
  final ModDB modDB;

  String get originalGamePath {
    switch (gameType) {
      case GameType.bg1ee:
        return configuration.bg1eePath;
      case GameType.bg2ee:
        return configuration.bg2eePath;
    }
  }

  ModDB get currentModDB {
    switch (gameType) {
      case GameType.bg1ee:
        return modDB.bg1eetModules;
      case GameType.bg2ee:
        return modDB.bg2eetModules;
    }
  }

  String get installationPath {
    return configuration.installationPath;
  }

  String get gameInstallationPath {
    switch (gameType) {
      case GameType.bg1ee:
        return configuration.bg1eeInstallationPath;
      case GameType.bg2ee:
        return configuration.bg2eeInstallationPath;
    }
  }

  GameService(
      {required this.gameType,
        required this.configuration,
        required this.modDB});

  Future<List<PendingCommand>> run() async {
    if (currentModDB.isEmpty) {
      // no mods to install
      return [];
    }

    return await ensureTheGameFolderIsExpected();
  }

  Future<bool> isGameFolderClean(String gamePath) async {
    final weiduLogPath = path.join(gamePath, 'weidu.log');
    final weiduLog = File(weiduLogPath);
    if (await weiduLog.exists()) {
      final log = await weiduLog.readAsString();
      final parser = WeiduLogParser.fromString(log);
      return parser.components.isEmpty;
    }
    return true;
  }

  // if the game folder is valid, check the required files exits
  Future<List<PendingCommand>> ensureTheGameFolderIsExpected() async {
    if (false == await checkChitin(originalGamePath)) {
      ServiceLocator()
          .log('!!! Game folder $originalGamePath/chitin.key does not exist');
      return [];
    }

    if (false == await isGameFolderClean(originalGamePath)) {
      ServiceLocator()
          .log('!!! Game folder $originalGamePath should be unmodded');
      return [];
    }

    var commands = <PendingCommand>[];
    PendingCommand? command;

    command = await EnsureGameFolderExists(originalGamePath: originalGamePath, installationPath:gameInstallationPath)
        .getPendingCommands();
    if (command == null) {
      // the game folder already exists
      if (false == await isGameFolderClean(gameInstallationPath)) {
        ServiceLocator().log(
            '!! $gameInstallationPath is modded. Please use unmodded one to avoid bugs. Just remove the folder and click run button again. Ignore this message if you are just testing mods.');
      }
    } else {
      commands.add(command);
    }

    final weiduPath = FileService.getWeiduPath();

    // copy weidu to the base installation folder (parent of game folder)
    command = await EnsureExecutableFileExists(weiduPath, installationPath)
        .getPendingCommand();
    if (command != null) {
      commands.add(command);
    }

    final moddaPath = FileService.getModdaPath();

    if (moddaPath == null) {
      ServiceLocator()
          .log('!!! Modda path not found for ${Platform.operatingSystem}');
      return commands;
    }

    command = await EnsureExecutableFileExists(moddaPath, gameInstallationPath)
        .getPendingCommand();
    if (command != null) {
      commands.add(command);
    }

    // generate and copy content to modda.yml
    command = await EnsureFileContentExists(
        configuration.generateModdaConfigYml(),
        gameInstallationPath,
        'modda.yml')
        .getPendingCommand();
    if (command != null) {
      commands.add(command);
    }

    // generate modkeeper-eet-bg1.yml or modkeeper-eet-bg2.yml
    command = await EnsureFileContentExists(
        currentModDB.selectedModules.toModdaRecipeYamlString(),
        gameInstallationPath,
        'modkeeper-eet-$gameType.yml')
        .getPendingCommand();
    if (command != null) {
      commands.add(command);
    }

    return commands;
  }
}
