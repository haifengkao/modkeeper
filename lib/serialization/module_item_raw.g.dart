// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_item_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModuleItemRaw _$ModuleItemRawFromJson(Map<String, dynamic> json) =>
    ModuleItemRaw(
      name: json['name'] as String,
      moduleName: json['moduleName'] as String?,
      description: json['description'] as String?,
      components: (json['components'] as List<dynamic>)
          .map((e) => ComponentItemRaw.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] == null
          ? null
          : LocationItemRaw.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ModuleItemRawToJson(ModuleItemRaw instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('moduleName', instance.moduleName);
  writeNotNull('description', instance.description);
  val['components'] = instance.components;
  writeNotNull('location', instance.location);
  return val;
}
