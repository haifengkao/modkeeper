import 'package:yaml/yaml.dart';
import 'package:json_annotation/json_annotation.dart';
part 'component_item_raw.g.dart';


@JsonSerializable(includeIfNull: false)
class ComponentItemRaw {
  final String? componentName;
  final int index;

  ComponentItemRaw({
    this.componentName,
    required this.index,
  });

  factory ComponentItemRaw.fromJson(Map<String, dynamic> json) => _$ComponentItemRawFromJson(json);
  Map<String, dynamic> toJson() => _$ComponentItemRawToJson(this);

  factory ComponentItemRaw.fromYaml(dynamic yaml) {
    if (yaml is String) {
      return ComponentItemRaw(index: int.parse(yaml.split('#')[0].trim()));
    } else if (yaml is YamlMap) {
      final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
      return ComponentItemRaw(
        componentName: yamlMap['component_name'],
        index: yamlMap['index'],
      );
    } else {
      throw ArgumentError('Invalid component YAML: $yaml');
    }
  }
}
