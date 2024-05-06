
import 'package:json_annotation/json_annotation.dart';
import 'module_item_raw.dart';
part 'modda_recipe.g.dart';
// global:
//   lang_dir: "fr_FR"
//   lang_preferences: ["#rx#^fran[cç]ais", french, english, "american english"]

@JsonSerializable()
class GlobalItem {
  static final GlobalItem enUS = GlobalItem(langDir: "en_US", langPreferences: ["#rx#^english", "american english"]);
  String langDir;
  List<String> langPreferences;

  GlobalItem({required this.langDir, required this.langPreferences});
}

@JsonSerializable()
class ModdaRecipe {

  GlobalItem global;
  List<ModuleItemRaw> modules;
  ModdaRecipe({required this.global, required this.modules});

  factory ModdaRecipe.fromJson(Map<String, dynamic> json) => _$ModdaRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$ModdaRecipeToJson(this);
}