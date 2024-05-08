
import 'dart:io';

import 'package:modkeeper/services/file_service.dart';
import 'package:yaml/yaml.dart';
import 'package:modkeeper/services/game_finder_service.dart';
import 'package:modkeeper/services/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:yaml_writer/yaml_writer.dart';

const configFilename = 'modkeeper_config.yml';
const gameInstallationFolderText = 'Game Installation Folder';

// the configuration setting, the value might be empty or invalid
class ConfigurationSetting {
  // the path to unmodded bg1 game
  final String bg1eePath;
  // the path to unmodded bg2 game
  final String bg2eePath;

  final String installationPath;

  ConfigurationSetting({required this.bg1eePath, required this.bg2eePath, required this.installationPath});
  // the path to modded bg1 game, ensure the path is never empty. I don't want to remove the root folder during reinstall
  String get bg1eeInstallationPath => path.join(installationPath, bg1eeGameName);
  // the path to modded bg2 game
  String get bg2eeInstallationPath => path.join(installationPath, bg2eeGameName);
  String get modDownloadPath => path.join(installationPath, 'ModDownloads');
  String get modInstallPath => path.join(installationPath, 'ModInstalls');
  String get weiduPath => path.join(installationPath, FileService.getWeiduFilename());

  Map<String, String> toMap() {
    return {
      bg1eeGameName: bg1eePath,
      bg2eeGameName: bg2eePath,
      gameInstallationFolderText: installationPath,
    };
  }

  // archive_cache: ../ModDownloads
  // extract_location: ../ModInstalls
  // weidu_path: ../weidu
  String generateModdaConfigYml() {
    final Map<String, String> moddaConfig = {
      'archive_cache': "../ModDownloads",
      'extract_location': "../ModInstalls",
      'weidu_path': "../weidu",
    };

    // Convert the configuration to YAML
    String yamlString = YamlWriter().write(moddaConfig);
    return yamlString;
  }

  // example
  // Baldur's Gate Enhanced Edition: "/Users/<user>/Library/Application Support/Steam/steamapps/common/Baldur's Gate Enhanced Edition"
  // Baldur's Gate II Enhanced Edition: "/Users/<user>/Library/Application Support/Steam/steamapps/common/Baldur's Gate II Enhanced Edition"
  // Game Installation Folder: '/Users/<user>/Library/Application Support/com.example.modkeeper/ModKeeper'
  String generateModKeeperConfigYml() {
    final pathValues = toMap();

    // Convert the configuration to YAML
    String yamlString = YamlWriter().write(pathValues);
    return yamlString;
  }
}

Map<String, String> getConfigMap(String yaml) {
  dynamic yamlMap = loadYaml(yaml);
  if (yamlMap is! Map) {
    throw ArgumentError('Invalid configuration file: $yaml');
  }

  return Map<String, String>.from(yamlMap);
}

class ConfigurationService {

  static Future<ConfigurationSetting> getConfiguration() async {
    if (await isConfigFileExists()) {
      final configFile = await getConfigFile();
      final configString = await configFile.readAsString();
      final configMap = getConfigMap(configString);
      return ConfigurationSetting(
        bg1eePath: configMap[bg1eeGameName] ?? '',
        bg2eePath: configMap[bg2eeGameName] ?? '',
        installationPath: configMap[gameInstallationFolderText] ?? '',
      );
    } else {
      // try to fill the default value
      return ConfigurationSetting(
        bg1eePath: await GameFinderService.bg1ee.gamePath() ?? '',
        bg2eePath: await GameFinderService.bg2ee.gamePath() ?? '',
        installationPath: await getDefaultInstallationPath(),
      );
    }

  }


  static Future<bool> isConfigFileExists() async {
    final configFile = await getConfigFile();
    return await configFile.exists();
  }

  static void saveConfiguration(ConfigurationSetting setting) {

    final yamlString = setting.generateModKeeperConfigYml();

    // Get the path to the configuration file
    Future<String> configFilePath = getConfigFilePath();

    // Write the YAML string to the configuration file
    configFilePath.then((path) {
      File(path).writeAsStringSync(yamlString);
    });
  }

}

Future<String> getDefaultInstallationPath() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  return path.join(appDocDir.path, 'ModKeeper');
}

Future<String> getConfigFilePath() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  String configFilePath = path.join(appDocDir.path, configFilename);
  return configFilePath;
}

Future<File> getConfigFile() async {
  final filePath = await getConfigFilePath();
  final file = File(filePath);

  if (!await file.exists()) {
    ServiceLocator().log('Config file not found at $filePath');
  } else {
    ServiceLocator().log('Config file found at $filePath');
  }
  return file;
}
