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

Map<String, dynamic> _$ComponentItemRawToJson(ComponentItemRaw instance) =>
    <String, dynamic>{
      'componentName': instance.componentName,
      'index': instance.index,
    };
