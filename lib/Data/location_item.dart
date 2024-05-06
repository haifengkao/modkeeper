
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
}



