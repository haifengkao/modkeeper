import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:yaml/yaml.dart';

import 'component_item.dart';
import 'location_item.dart';

class ModuleItem {
  final String name;
  final String? description;
  final List<ComponentItem> components;
  final LocationItem? location;

  ModuleItem({
    required this.name,
    this.description,
    required this.components,
    this.location,
  });

  factory ModuleItem.fromYaml(dynamic yaml) {
    final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);

    List<ComponentItem> components = [];
    final dynamic componentsData = yamlMap['components'];

    if (componentsData is List) {
      components = componentsData
          .map((component) => ComponentItem.fromYaml(component))
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

    return ModuleItem(
      name: yamlMap['name'],
      description: yamlMap['description'],
      components: components,
      location: yamlMap['location'] != null
          ? LocationItem.fromYaml(yamlMap['location'])
          : null,
    );
  }
}
