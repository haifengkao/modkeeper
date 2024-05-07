import 'dart:io';
import 'package:modkeeper/services/service_locator.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:path/path.dart' as path;

const bg1eeGameName = 'Baldur\'s Gate Enhanced Edition';
const bg2eeGameName = 'Baldur\'s Gate II Enhanced Edition';


// to find the game path when the modkeeper is started for the first time
class GameFinderService {
  // https://store.steampowered.com/app/228280/Baldurs_Gate_Enhanced_Edition/
  // https://store.steampowered.com/app/257350/Baldurs_Gate_II_Enhanced_Edition/?curator_clanid=33022128

  static final bg1ee = GameFinderService(bg1eeGameName, '228280');
  static final bg2ee = GameFinderService(bg2eeGameName, '257350');
  final String gameName;
  final String appId;

  GameFinderService(this.gameName, this.appId);

  Future<String?> gamePath() async {
    var path = await _getSteamGamePath();
    if (path != null) {
      return path;
    }

    path = await _getGOGGamePath();
    return path;
  }

  // "C:\Program Files (x86)\GOG Galaxy\Games\Baldur's Gate 3
  // C:\GOG GAMES\Baldur's Gate 3
  Future<String?> _getGOGGamePath() async {
    const drives = ['C:', 'D:', 'E:'];
    const gogPaths = [
      'GOG GAMES',
      r'Program Files (x86)\GOG GAMES',
      r'Program Files (x86)\GOG Galaxy\Games'
    ];
    if (Platform.isWindows) {
      for (final drive in drives) {
        for (final gogPath in gogPaths) {
          final gamePath = '$drive\\$gogPath\\$gameName';
          if (await checkChitin(gamePath)) {
            return gamePath;
          }
        }
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final homeDir = Platform.environment['HOME']!;
      final gamePath = '$homeDir/GOG Games/$gameName';
      if (await checkChitin(gamePath)) {
        return gamePath;
      }
    }
    return null;
  }

  Future<String?> _getSteamGamePath() async {
    if (Platform.isWindows) {
      try {
        final registry = Registry.openPath(RegistryHive.localMachine,
            path:
                'SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Steam App $appId');
        final installLocation = registry.getValueAsString('InstallLocation');

        if (installLocation != null && await checkChitin(installLocation)) {
          return installLocation;
        }
      } catch (e) {
        // Handle any errors that occur while reading the registry
        ServiceLocator().log('Error reading registry: $e');
      }
    } else if (Platform.isMacOS) {
      // /Users/<user>/Library/Application\ Support/Steam/steamapps/common/Baldur\'s\ Gate\ Enhanced\ Edition
      // /Users/<user>/Library/Application\ Support/Steam/steamapps/common/Baldur\'s\ Gate\ II\ Enhanced\ Edition/

      String homePath = Platform.environment['HOME'] ?? '';
      String appsPath = path.join(homePath, 'Library/Application Support/Steam/steamapps/common');

      // Check predefined locations on macOS
      String gamePath = path.join(appsPath, gameName);

      if (await checkChitin(gamePath)) {
        return gamePath;
      }
    } else if (Platform.isLinux) {
      // Check predefined locations on Linux
      String homeDir = Platform.environment['HOME']!;
      String gamePath =
          '$homeDir/.local/share/Steam/steamapps/common/$gameName';
      if (await checkChitin(gamePath)) {
        return gamePath;
      }
    }

    return null;
  }
}

Future<bool> checkChitin(String gamePath) {
  final chitinPath = path.join(gamePath, 'chitin.key');
  return File(chitinPath).exists();
}
