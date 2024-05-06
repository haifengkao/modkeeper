// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_db_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModDBRaw _$ModDBRawFromJson(Map<String, dynamic> json) => ModDBRaw(
      modules: (json['modules'] as List<dynamic>)
          .map((e) => ModuleItemRaw.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModDBRawToJson(ModDBRaw instance) => <String, dynamic>{
      'modules': instance.modules,
    };
