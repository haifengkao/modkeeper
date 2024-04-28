import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/module_selection_screen.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'module_item.dart';
import 'package:path/path.dart' as path;
import 'configuration_view.dart';

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
      home: const MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool showConfigurationView = false;
  Map<String, String> configurationSettings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModKeeper'),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<ModuleItem>>(
            future: loadModDbContent(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final modules = snapshot.data!;
                return ModuleSelectionScreen(modules: modules);
              }
            },
          ),
          Visibility(
            visible: showConfigurationView,
            child: ConfigurationView(
              onSaveConfiguration: (settings) {
                setState(() {
                  configurationSettings = settings;
                  showConfigurationView = false;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showConfigurationView = true;
          });
        },
        child: const Icon(Icons.settings),
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
  final absolutePath = path.absolute(file.path); // Get the absolute path using the `absolute` function from the `path` package
  print("toBeInstalled.yml has been created. $absolutePath"); // Print the absolute path
}
