import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/expandable_list_screen.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'module_item.dart';

void main() {
  runApp(const MyApp());
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
