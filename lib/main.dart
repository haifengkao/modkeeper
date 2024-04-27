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

  factory ModuleItem.fromYaml(Map<String, dynamic> yaml) {
    return ModuleItem(
      name: yaml['name'],
      description: yaml['description'],
      components: (yaml['components'] as List<dynamic>)
          .map((component) => ComponentItem.fromYaml(component))
          .toList(),
      location: yaml['location'] != null
          ? LocationItem.fromYaml(yaml['location'])
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
    } else if (yaml is Map<String, dynamic>) {
      return ComponentItem(
        componentName: yaml['component_name'],
        index: yaml['index'],
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

  factory LocationItem.fromYaml(Map<String, dynamic> yaml) {
    return LocationItem(
      githubUser: yaml['github_user'],
      repository: yaml['repository'],
      branch: yaml['branch'],
      release: yaml['release'],
      asset: yaml['asset'],
      refresh: yaml['refresh'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            return CircularProgressIndicator();
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

  const ExpandableListScreen({required this.modules});

  @override
  _ExpandableListScreenState createState() => _ExpandableListScreenState();
}

class _ExpandableListScreenState extends State<ExpandableListScreen> {
  List<ModuleItem> get selectedModules =>
      widget.modules.where((module) => module.components.any((component) => component.isSelected)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expandable List'),
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
        child: Icon(Icons.save),
      ),
    );
  }
}

class ExpandableListItem extends StatefulWidget {
  final ModuleItem module;

  const ExpandableListItem({required this.module});

  @override
  _ExpandableListItemState createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
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
