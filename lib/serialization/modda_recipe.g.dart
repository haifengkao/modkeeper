// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modda_recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalItem _$GlobalItemFromJson(Map<String, dynamic> json) => GlobalItem(
      langDir: json['langDir'] as String,
      langPreferences: (json['langPreferences'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GlobalItemToJson(GlobalItem instance) =>
    <String, dynamic>{
      'langDir': instance.langDir,
      'langPreferences': instance.langPreferences,
    };

ModdaRecipe _$ModdaRecipeFromJson(Map<String, dynamic> json) => ModdaRecipe(
      global: GlobalItem.fromJson(json['global'] as Map<String, dynamic>),
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleItemRaw.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModdaRecipeToJson(ModdaRecipe instance) =>
    <String, dynamic>{
      'global': instance.global,
      'modules': instance.modules,
    };
