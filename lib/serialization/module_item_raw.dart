
import 'component_item_raw.dart';
import 'location_item_raw.dart';
import 'package:json_annotation/json_annotation.dart';
part 'module_item_raw.g.dart';

// the view state for the module cell
@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class ModuleItemRaw {
  // the tp2 file name. allow duplicates
  final String name;
  // the module name which is displayed to user. allow duplicates
  final String? moduleName;
  // short description of the module, which will be displayed at the top of ModInfoScreen
  final String? description;
  final List<ComponentItemRaw> components;
  final LocationItemRaw? location;

  ModuleItemRaw({
    required this.name,
    this.moduleName,
    this.description,
    required this.components,
    this.location,
  });

  factory ModuleItemRaw.fromJson(Map<String, dynamic> json) => _$ModuleItemRawFromJson(json);
  Map<String, dynamic> toJson() => _$ModuleItemRawToJson(this);

  factory ModuleItemRaw.fromYaml(dynamic yaml) {
    final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);

    List<ComponentItemRaw> components = [];
    final dynamic componentsData = yamlMap['components'];

    if (componentsData is List) {
      components = componentsData
          .map((component) => ComponentItemRaw.fromYaml(component))
          .toList();
    } else if (componentsData is String) {
      // ask does not have components
      // e.g
      //- name: infinity_ui
      //  components: ask
      //  location:
      //  github_user: Renegade0
      //  repository: InfinityUI
      //  branch: main
      //  refresh: 1week

      // Handle the case when 'components' is a single string value
      // You can customize this based on your requirements
      components = [];
    }

    return ModuleItemRaw(
      name: yamlMap['name'],
      moduleName: yamlMap['module_name'],
      description: yamlMap['description'],
      components: components,
      location: yamlMap['location'] != null
          ? LocationItemRaw.fromYaml(yamlMap['location'])
          : null,
    );
  }

}
