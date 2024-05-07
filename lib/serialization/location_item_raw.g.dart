// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_item_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationItemRaw _$LocationItemRawFromJson(Map<String, dynamic> json) =>
    LocationItemRaw(
      githubUser: json['githubUser'] as String,
      repository: json['repository'] as String,
      release: json['release'] as String?,
      asset: json['asset'] as String?,
      commit: json['commit'] as String?,
      branch: json['branch'] as String?,
      refresh: json['refresh'] as String?,
      tag: json['tag'] as String?,
    );

Map<String, dynamic> _$LocationItemRawToJson(LocationItemRaw instance) =>
    <String, dynamic>{
      'githubUser': instance.githubUser,
      'repository': instance.repository,
      'release': instance.release,
      'asset': instance.asset,
      'commit': instance.commit,
      'branch': instance.branch,
      'refresh': instance.refresh,
      'tag': instance.tag,
    };
