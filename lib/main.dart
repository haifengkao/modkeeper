import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:modkeeper/module_selection_screen.dart';
import 'package:modkeeper/utilities.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'module_item.dart';
import 'package:path/path.dart' as path;
import 'configuration_view.dart';
import 'package:path_provider/path_provider.dart';

class ModTab {
  final String title;
  final Widget Function() buildView;

  ModTab({required this.title, required this.buildView});
}

List<ModTab> _modTabs = [
  ModTab(
    title: 'Logs',
    buildView: () => const Center(child: Text('Installation Logs')),
  ),
  ModTab(
    title: 'Mod Info',
    buildView: () => const Center(child: Text('Mod Info')),
  ),
  ModTab(
    title: 'Mod Conflicts',
    buildView: () => const Center(child: Text('Mod Conflicts')),
  ),
];

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

  Widget createTabView() {
    return DefaultTabController(
      length: _modTabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: _modTabs.map((tab) => Tab(text: tab.title)).toList(),
          ),
        ),
        body: TabBarView(
          children: _modTabs.map((tab) => tab.buildView()).toList(),
        ),
      ),
    );
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

  Widget createRightToolbar() {
    const iconSize = 40.0;
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const Spacer(), // Add a spacer widget here
          IconButton(
            icon: const Icon(Icons.settings, size: iconSize),
            onPressed: () {
              setState(() {
                showConfigurationView = !showConfigurationView;
              });
            },
          ),
          const Spacer(), // Add a spacer widget here
          const Spacer(), // Add a spacer widget here
          IconButton(
            icon: const Icon(Icons.play_arrow, size: iconSize),
            onPressed: () {
              // Handle install (save) button press
              copyToBeInstalledYaml([]);
            },
          ),
          const Spacer(), // Add a spacer widget here
        ],
      ),
    );
  }

  Widget resizeableContainer() {
    return ResizableContainer(
      direction: Axis.horizontal,
      dividerWidth: 10,
      dividerColor: Colors.grey[300],
      children: [
        ResizableChildData(
          startingRatio: 0.3,
          minSize: 200,
          child: futureLoadingWidget,
        ),
        ResizableChildData(
          startingRatio: 0.65,
          child: createTabView()
        ),
        ResizableChildData(
            startingRatio: 0.05,
            child: createRightToolbar()
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ModKeeper'),
          backgroundColor: Theme.of(context).primaryColorLight
        ),
        body: Stack(
          children: [
              resizeableContainer(),
              if (showConfigurationView) createConfigurationView(),
          ],
        )
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
