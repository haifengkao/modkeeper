import 'package:json_annotation/json_annotation.dart';

part 'location_item_raw.g.dart';

@JsonSerializable(includeIfNull: false)
class LocationItemRaw {
  final String githubUser;
  final String repository;
  final String? release;
  final String? asset;
  final String? commit;
  final String? branch;
  final String? refresh;
  final String? tag;

  LocationItemRaw({required this.githubUser, required this.repository, this.release, this.asset, this.commit, this.branch, this.refresh, this.tag});

  factory LocationItemRaw.fromJson(Map<String, dynamic> json) => _$LocationItemRawFromJson(json);
  Map<String, dynamic> toJson() => _$LocationItemRawToJson(this);

  factory LocationItemRaw.fromYaml(dynamic yaml) {
    final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
    return LocationItemRaw(
      githubUser: yamlMap['github_user'],
      repository: yamlMap['repository'],
      branch: yamlMap['branch'],
      release: yamlMap['release'],
      asset: yamlMap['asset'],
      refresh: yamlMap['refresh'],
    );
  }
}



