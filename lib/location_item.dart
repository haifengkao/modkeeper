
class LocationItem {
  final String githubUser;
  final String repository;
  final String? branch;
  final String? release;
  final String? asset;
  final String? refresh;

  LocationItem({
    required this.githubUser,
    required this.repository,
    this.branch,
    this.release,
    this.asset,
    this.refresh,
  });

  factory LocationItem.fromYaml(dynamic yaml) {
    final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
    return LocationItem(
      githubUser: yamlMap['github_user'],
      repository: yamlMap['repository'],
      branch: yamlMap['branch'],
      release: yamlMap['release'],
      asset: yamlMap['asset'],
      refresh: yamlMap['refresh'],
    );
  }
}

