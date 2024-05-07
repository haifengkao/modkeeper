import 'package:json_annotation/json_annotation.dart';
import 'module_item_raw.dart';

import 'package:yaml/yaml.dart';
part 'mod_db_raw.g.dart';

// the view state for ModuleSelectionScreen
@JsonSerializable()
class ModDBRaw {
  // LinkedHashMap will keep the order of insertion
  List<ModuleItemRaw> modules;

  ModDBRaw({required this.modules});
  factory ModDBRaw.fromJson(Map<String, dynamic> json) =>
      _$ModDBRawFromJson(json);
  Map<String, dynamic> toJson() => _$ModDBRawToJson(this);

  factory ModDBRaw.fromYaml(dynamic yaml) {
    if (yaml is YamlMap) {
      final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
      List<ModuleItemRaw> modules = [];
      final dynamic modulesData = yamlMap['modules'];

      if (modulesData is List) {
        modules = modulesData
            .map((module) => ModuleItemRaw.fromYaml(module))
            .toList();
      } else if (modulesData is String) {
        // ask does not have modules
        // e.g
        // modules: ask
        //   location:
        //   github_user: Renegade0
        //   repository: InfinityUI
        //   branch: main
        //   refresh: 1week

        // Handle the case when 'modules' is a single string value
        // You can customize this based on your requirements
        modules = [];
      }

      return ModDBRaw(modules: modules);
    } else {
      throw ArgumentError('Invalid mod database YAML: $yaml');
    }
  }

}
