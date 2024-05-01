import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modkeeper/module_selection_screen.dart';
import 'package:modkeeper/utilities.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'module_item.dart';
import 'package:path/path.dart' as path;
import 'configuration_view.dart';
import 'package:path_provider/path_provider.dart';

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

  var futureLoadingWidget = FutureLoadingWidget<List<ModuleItem>>(
    future: loadModDbContent(),
    dataBuilder: (context, modules) => ModuleSelectionScreen(modules: modules),
  );
  @override
  void initState() {
    super.initState();
    checkConfigFile();
  }

  Future<void> checkConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final configFile = File('${directory.path}/config.yml');
    if (!await configFile.exists()) {
      setState(() {
        showConfigurationView = true;
      });
    }
  }

  Widget createConfigurationView() {
    return ConfigurationView(
      onSaveConfiguration: (settings) {
        setState(() {
          configurationSettings = settings;
          showConfigurationView = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModKeeper'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, size: 40),
            onPressed: () {
              setState(() {
                showConfigurationView = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          futureLoadingWidget,
          if (showConfigurationView) createConfigurationView(),
        ],
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
