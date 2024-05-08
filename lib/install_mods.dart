
import 'package:modkeeper/data/mod_db.dart';
import 'package:modkeeper/services/configuration_service.dart';
import 'package:modkeeper/services/game_service.dart';
import 'package:modkeeper/services/service_locator.dart';


Future<void> installMods(ModDB modDB) async {
  try {
    // Get the configuration
    final configuration = await ConfigurationService.getConfiguration();

    // Create an instance of GameService
    final bg1GameService = GameService(
      gameType: GameType.bg1ee,
      configuration: configuration,
      modDB: modDB,
    );

    final pendingCommands1 = await bg1GameService.run();

    // Create an instance of GameService
    final bg2GameService = GameService(
      gameType: GameType.bg2ee,
      configuration: configuration,
      modDB: modDB,
    );

    final pendingCommands2 = await bg2GameService.run();

    final pendingCommands = pendingCommands1 + pendingCommands2;
    ServiceLocator().loggingService.log("will execute: $pendingCommands");

    // Execute the pending commands
    for (final command in pendingCommands) {
      await command.execute();
    }
  }
  catch (e) {
    ServiceLocator().loggingService.log("install error: $e");
  }
}
