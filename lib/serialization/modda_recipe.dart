
import 'package:json_annotation/json_annotation.dart';
import 'package:modkeeper/serialization/modda_recipe.dart';
import 'module_item_raw.dart';
part 'modda_recipe.g.dart';
// global:
//   lang_dir: "fr_FR"
//   lang_preferences: ["#rx#^fran[cç]ais", french, english, "american english"]
@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class GlobalItem {
  static final GlobalItem enUS = GlobalItem(langDir: "en_US", langPreferences: ["#rx#^english", "american english"]);
  String langDir;
  List<String> langPreferences;

  GlobalItem({required this.langDir, required this.langPreferences});
  factory GlobalItem.fromJson(Map<String, dynamic> json) => _$GlobalItemFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalItemToJson(this);
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class ModdaRecipe {
  String version = "1";
  GlobalItem global;
  List<ModuleItemRaw> modules;
  ModdaRecipe({required this.global, required this.modules});

  factory ModdaRecipe.fromJson(Map<String, dynamic> json) => _$ModdaRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$ModdaRecipeToJson(this);

  factory ModdaRecipe.fromYaml(dynamic yaml) {
    final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
    return ModdaRecipe(
      global: GlobalItem(langDir: yamlMap['global']['lang_dir'], langPreferences: List<String>.from(yamlMap['global']['lang_preferences'])),
      modules: List<ModuleItemRaw>.from(yamlMap['modules'].map((e) => ModuleItemRaw.fromYaml(e))),
    );
  }
}