import 'dart:collection';
import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';
import 'package:modkeeper/data/module_item.dart';
import 'package:yaml_writer/yaml_writer.dart';

// the view state for ModuleSelectionScreen
class ModDB {
  // LinkedHashMap will keep the order of insertion
  final LinkedHashMap<String, ModuleItem> moduleMap;
  List<ModuleItem> get modules => moduleMap.values.toList();

  ModDB({required this.moduleMap});
}

// EET Mod Install Order Guide
// https://docs.google.com/spreadsheets/d/1tt4f-rKqkbk8ds694eJ1YcOjraZ2pISkkobqZ5yRcvI/edit#gid=676921267
//                      Mod Name: Project Infinity                                   Install Before: dlcmerger, EET
// dlcmerger            Mod Name: DLC Merger                                         Install Before: EET, all BG1 Mods
// bg1ub                Mod Name: BG1 Unfinished Business                            Install Before: EET
// darkhorizonsbgee     Mod Name: Dark Horizons                                      Install Before: EET
// drizztsaga           Mod Name: Drizzt Saga                                        Install Before: EET
// soa                  Mod Name: The Stone of Askavar                               Install Before: EET
// karatur              Mod Name: T’was a Slow Boat from Karatur                     Install Before: EET
// saradas_magic        Mod Name: Saradas Magic                                      Install Before: EET
// bg1npc               Mod Name: BG1 NPC Project                                    Install Before: BG1 friendship mods, ajantisbg1, PPE (can install before EET)
// margarita            Mod Name: Margarita Zelleod                                  Install Before: EET
// k9sharteelnpc        Mod Name: Sharteel NPC mod for SoD                           Install Before: EET
// tenyathermidor       Mod Name: Tenya Thermidor                                    Install Before: EET
// sirene               Mod Name: Sirene NPC                                         Install Before: EET
// drake                Mod Name: Drake NPC                                          Install Before: EET
// verrsza              Mod Name: Verr'Sza (BG1EE)                                   Install Before: EET
// garrick-tt           Mod Name: Garrick: Tales of a Troubadour                     Install Before: EET
// k9roughworld         Mod Name: Rough World                                        Install Before: EET
// eefixpack            Mod Name: EE Fixpack (Alpha)                                 Install Before: EET

const Set<String> beforeEETMods = {
  "dlcmerger", // should be the first bg1 mod
  "bg1ub",
  "darkhorizonsbgee",
  "drizztsaga",
  "soa",
  "karatur",
  "saradas_magic",
  // "bg1npc", install it on BG2 for better mod order compatibility
  "margarita",
  "k9sharteelnpc",
  "tenyathermidor",
  "sirene",
  "drake",
  "verrsza",
  "garrick-tt",
  "k9roughworld",
  "eefixpack",
};

extension ModDBExtension on ModDB {
  ModDB get bg1eetModules {
    final bg1eetModules =
        moduleMap.values.where((module) => beforeEETMods.contains(module.name));
    return ModDB(
        moduleMap: LinkedHashMap.fromIterable(bg1eetModules,
            key: (module) => module.name));
  }

  ModDB get bg2eetModules {
    // eefixpack exists for all infinity engine games
    final bg2eetModules = moduleMap.values.where((module) =>
        !beforeEETMods.contains(module.name) || module.name == 'eefixpack');
    return ModDB(
        moduleMap: LinkedHashMap.fromIterable(bg2eetModules,
            key: (module) => module.name));
  }

  ModDB get selectedModules {
    final selectedModules = moduleMap.values
        .where((module) =>
            module.components.any((component) => component.isSelected))
        .toList();
    return ModDB(
        moduleMap: LinkedHashMap.fromIterable(selectedModules,
            key: (module) => module.name));
  }
}
