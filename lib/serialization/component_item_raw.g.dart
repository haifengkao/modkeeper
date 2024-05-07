// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_item_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComponentItemRaw _$ComponentItemRawFromJson(Map<String, dynamic> json) =>
    ComponentItemRaw(
      componentName: json['componentName'] as String?,
      index: (json['index'] as num).toInt(),
    );

Map<String, dynamic> _$ComponentItemRawToJson(ComponentItemRaw instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('componentName', instance.componentName);
  val['index'] = instance.index;
  return val;
}
