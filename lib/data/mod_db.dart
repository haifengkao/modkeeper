import 'package:modkeeper/serialization/mod_db_raw.dart';
import 'package:modkeeper/serialization/modda_recipe.dart';
import 'package:modkeeper/serialization/module_item_raw.dart';
import 'module_view_item.dart';
import 'component_view_item.dart';
import 'package:yaml_writer/yaml_writer.dart';
import 'location_item.dart';

// the repository of modules
class ModDB {
  final List<ModuleViewItem> moduleViewItems;

  // the tp2 file with the same name will use same locationItem
  final Map<String, LocationItem> locationItemMap;

  ModDB({required this.moduleViewItems, required this.locationItemMap});

  factory ModDB.fromModDBRaw(ModDBRaw modDBRaw) {
    return ModDB.fromModuleItemRaws(modDBRaw.modules);
  }

  factory ModDB.fromModuleItemRaws(List<ModuleItemRaw> moduleItemRaws) {
    final locationItemMap = <String, LocationItem>{};

    final List<ModuleViewItem> modules = moduleItemRaws.asMap().entries.map(
      (entry) {
        final moduleItemRaw = entry.value;
        final modOrder = entry.key;
        final moduleViewItem = ModuleViewItem.fromModuleItemRaw(modOrder, moduleItemRaw);
        if (locationItemMap[moduleItemRaw.name] == null && moduleItemRaw.location != null) {
          locationItemMap[moduleItemRaw.name] = LocationItem.fromLocationItemRaw(moduleItemRaw.location!);
        }
        return moduleViewItem;
      }
    ).toList();

    return ModDB(moduleViewItems: modules, locationItemMap: locationItemMap);
  }

  bool get isEmpty => moduleViewItems.isEmpty;

  ModdaRecipe _toModdaRecipe() {

    final List<ModuleItemRaw> moduleItemRaws = moduleViewItems.map (
      (moduleViewItem) => ModuleItemRaw(
        name: moduleViewItem.name,
        moduleName: moduleViewItem.moduleName,
        description: moduleViewItem.description,
        components: moduleViewItem.components.map (
          (componentViewItem) => componentViewItem.toComponentItemRaw()
        ).toList(),
        location: locationItemMap[moduleViewItem.name]?.toLocationItemRaw(),
      )
    ).toList();

    return ModdaRecipe(global: GlobalItem.enUS, modules: moduleItemRaws);
  }

  String toModdaRecipeYamlString() {
    final yamlWriter = YamlWriter();
    final moddaRecipe = _toModdaRecipe();
    return yamlWriter.write(moddaRecipe);
  }
  void selectComponent(ModuleViewItem module, ComponentViewItem component, bool enabled) {
    assert(moduleViewItems.contains(module));

    moduleViewItems[module.modOrder] = moduleViewItems[module.modOrder].selectingComponent(component, enabled);

  }

  void selectWholeModule(ModuleViewItem module, bool enabled) {
   assert(moduleViewItems.contains(module));

    moduleViewItems[module.modOrder] = moduleViewItems[module.modOrder].selectingAllComponents(enabled);
  }
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
        moduleViewItems.where((module) => beforeEETMods.contains(module.name)).toList();
    return ModDB(
        moduleViewItems: bg1eetModules,
        locationItemMap: locationItemMap);
  }

  ModDB get bg2eetModules {
    // eefixpack exists for all infinity engine games
    final bg2eetModules = moduleViewItems.where((module) =>
        !beforeEETMods.contains(module.name) || module.name == 'eefixpack').toList();
    return ModDB(
        moduleViewItems: bg2eetModules,
        locationItemMap: locationItemMap
    );
  }

  ModDB get selectedModules {
    final selectedModules = moduleViewItems
        .where((module) =>
            module.components.any((component) => component.isSelected))
        .toList();
    return ModDB(
        moduleViewItems: selectedModules,
        locationItemMap: locationItemMap // I am too lazy to filter locationItemMap
    );
  }
}
