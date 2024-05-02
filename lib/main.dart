import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:modkeeper/mod_tab.dart';
import 'package:modkeeper/module_selection_screen.dart';
import 'package:modkeeper/utilities.dart';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'module_item.dart';
import 'package:path/path.dart' as path;
import 'configuration_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  LoggingService? _loggingService;

  void log(String message) {
    _loggingService?.log(message);
  }

  void registerLoggingService(BuildContext context) {
    _loggingService = Provider.of<LoggingService>(context, listen: false);
  }

  LoggingService get loggingService => _loggingService!;
}

class LoggingService extends ChangeNotifier {
  List<String> _logs = [];

  List<String> get logs => _logs;

  void log(String message) {
    _logs.add(message);
    if (_logs.length > 10) {
      _logs.removeAt(0);
    }
    print(message);
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  MaterialApp app(BuildContext context) {
    return MaterialApp(
      title: 'ModKeeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoggingService(),
      child: Builder(
        builder: (context) {
          ServiceLocator().registerLoggingService(context);
          return app(context);
        },
      ),
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
    final configFile = await FileService.getConfigFile();
    if (!await configFile.exists()) {
      setState(() {
        showConfigurationView = true;
      });
    }
  }

  Widget createTabView() {
    return DefaultTabController(
      length: modTabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: modTabs.map((tab) => Tab(text: tab.title)).toList(),
          ),
        ),
        body: TabBarView(
          children: modTabs.map((tab) => tab.buildView()).toList(),
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
        ResizableChildData(startingRatio: 0.65, child: createTabView()),
        ResizableChildData(startingRatio: 0.05, child: createRightToolbar()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('ModKeeper'),
            backgroundColor: Theme.of(context).primaryColorLight),
        body: Stack(
          children: [
            resizeableContainer(),
            if (showConfigurationView) createConfigurationView(),
          ],
        ));
  }
}

class FileService {
  static Future<String> loadAsset(String assetPath) async {
    // cannot get rootBundle's path
    // https://stackoverflow.com/questions/52353764/how-do-i-get-the-assets-file-path-in-flutter
    ServiceLocator().log('Mod database loaded from app bundle $assetPath');
    return await rootBundle.loadString(assetPath);
  }

  static Future<File> getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final absolutePath = path.join(path.absolute(directory.path), 'config.yml');
    final file =  File(absolutePath);

    if (!await file.exists()) {
      ServiceLocator().log('Config file not found at $absolutePath');
    } else {
      ServiceLocator().log('Config file found at $absolutePath');
    }

    return file;
  }

  static Future<void> writeToFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}

class ModDB {
  final List<ModuleItem> modules;

  ModDB({required this.modules});

  factory ModDB.fromYaml(dynamic yaml) {
    if (yaml is YamlMap) {
      final Map<String, dynamic> yamlMap = Map<String, dynamic>.from(yaml);
      final modules = (yamlMap['modules'] as List<dynamic>)
          .map((module) => ModuleItem.fromYaml(module))
          .toList();
      return ModDB(modules: modules);
    } else {
      throw ArgumentError('Invalid mod database YAML: $yaml');
    }
  }
}

Future<List<ModuleItem>> loadModDbContent() async {
  final yamlString = await FileService.loadAsset('assets/default_mod_db.yml');
  final modDB = ModDB.fromYaml(loadYaml(yamlString));
  return modDB.modules;
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
  final absolutePath = path.absolute(file
      .path); // Get the absolute path using the `absolute` function from the `path` package
  print(
      "toBeInstalled.yml has been created. $absolutePath"); // Print the absolute path
}
