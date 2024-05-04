import 'package:yaml/yaml.dart';
import 'package:modkeeper/data/module_item.dart';

class ModDB {
  final List<ModuleItem> modules;

  ModDB({required this.modules});

  factory ModDB.fromYaml(dynamic yaml) {
    if (yaml is YamlMap) {
      final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
      final modules = (yamlMap['modules'] as List<dynamic>)
          .map((module) => ModuleItem.fromYaml(module))
          .toList();
      return ModDB(modules: modules);
    } else {
      throw ArgumentError('Invalid mod database YAML: $yaml');
    }
  }
}
