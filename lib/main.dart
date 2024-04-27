import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  runApp(const MyApp());
}

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ModKeeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<ModuleItem>>(
        future: loadModDbContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final modules = snapshot.data!;
            return ExpandableListScreen(modules: modules);
          }
        },
      ),
    );
  }
}

Future<List<ModuleItem>> loadModDbContent() async {
  final yamlString = await rootBundle.loadString('assets/default_mod_db.yml');
  final yamlMap = loadYaml(yamlString);
  final modules = (yamlMap['modules'] as List<dynamic>)
      .map((module) => ModuleItem.fromYaml(module))
      .toList();
  return modules;
}

 void copyToBeInstalledYaml(List<ModuleItem> selectedModules) {
    final file = File('toBeInstalled.yml');
    final buffer = StringBuffer();
    buffer.writeln('modules:');

    for (final module in selectedModules) {
      buffer.writeln('  - name: ${module.name}');
      buffer.writeln('    components:');
      for (final component in module.components) {
        if (component.isSelected) {
          buffer.writeln('      - component_name: ${component.componentName}');
          buffer.writeln('        index: ${component.index}');
        }
      }
    }

    file.writeAsStringSync(buffer.toString());
  }

class ExpandableListScreen extends StatefulWidget {
  final List<ModuleItem> modules;

  const ExpandableListScreen({super.key, required this.modules});

  @override
  ExpandableListScreenState createState() => ExpandableListScreenState();
}

class ExpandableListScreenState extends State<ExpandableListScreen> {
  List<ModuleItem> get selectedModules =>
      widget.modules.where((module) => module.components.any((component) => component.isSelected)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable List'),
      ),
      body: ListView.builder(
        itemCount: widget.modules.length,
        itemBuilder: (context, index) {
          final module = widget.modules[index];
          return ExpandableListItem(module: module);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          copyToBeInstalledYaml(selectedModules);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

class ExpandableListItem extends StatefulWidget {
  final ModuleItem module;

  const ExpandableListItem({super.key, required this.module});

  @override
  ExpandableListItemState createState() => ExpandableListItemState();
}

class ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      ListTile(
        title: Text(widget.module.name),
        onTap: _toggleExpansion,
      ),
      SizeTransition(
        sizeFactor: _animation,
        axisAlignment: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: widget.module.components.map((component) {
              return CheckboxListTile(
                title: Text(component.componentName ?? ''),
                value: component.isSelected,
                onChanged: (value) {
                  setState(() {
                    component.isSelected = value!;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}
}
