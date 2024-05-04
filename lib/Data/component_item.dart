import 'package:yaml/yaml.dart';

class ComponentItem {
  final String? componentName;
  final int index;
  bool isSelected;

  ComponentItem({
    this.componentName,
    required this.index,
    this.isSelected = false,
  });

  factory ComponentItem.fromYaml(dynamic yaml) {
    if (yaml is String) {
      return ComponentItem(index: int.parse(yaml.split('#')[0].trim()));
    } else if (yaml is YamlMap) {
      final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
      return ComponentItem(
        componentName: yamlMap['component_name'],
        index: yamlMap['index'],
      );
    } else {
      throw ArgumentError('Invalid component YAML: $yaml');
    }
  }
}
