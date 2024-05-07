
//
// pub enum GithubDescriptor {
//   Release { release: Option<String>, asset: String },
//   Commit { commit: String },
//   Branch(GitBranch),
//   Tag { tag: String },
// }
// pub struct GitBranch {
//     pub branch: String,
//     #[serde(default)]
//     #[serde(with = "crate::module::refresh::RefreshConditionAsString")]
//     pub refresh: RefreshCondition,
// }

// to generate the modda install yml
import 'package:modkeeper/serialization/location_item_raw.dart';

class LocationItem {
  final String githubUser;
  final String repository;
  final String? release;
  final String? asset;
  final String? commit;
  final String? branch;
  final String? refresh;
  final String? tag;

  LocationItem({required this.githubUser, required this.repository, this.release, this.asset, this.commit, this.branch, this.refresh, this.tag});

  factory LocationItem.fromLocationItemRaw(LocationItemRaw locationItemRaw) {
    return LocationItem(
      githubUser: locationItemRaw.githubUser,
      repository: locationItemRaw.repository,
      release: locationItemRaw.release,
      asset: locationItemRaw.asset,
      commit: locationItemRaw.commit,
      branch: locationItemRaw.branch,
      refresh: locationItemRaw.refresh,
      tag: locationItemRaw.tag,
    );
  }

  LocationItemRaw toLocationItemRaw() {
    return LocationItemRaw(
      githubUser: githubUser,
      repository: repository,
      release: release,
      asset: asset,
      commit: commit,
      branch: branch,
      refresh: refresh,
      tag: tag,
    );
  }
}



