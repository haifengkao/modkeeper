import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:modkeeper/serialization/mod_db_raw.dart';
import 'package:modkeeper/services/configuration_service.dart';
import 'package:modkeeper/services/file_service.dart';
import 'package:modkeeper/services/game_service.dart';
import 'package:modkeeper/services/logging_service.dart';
import 'package:modkeeper/data/mod_db.dart';
import 'package:modkeeper/console_widget.dart';
import 'package:modkeeper/mod_tab.dart';
import 'package:modkeeper/module_selection_screen.dart';
import 'package:modkeeper/services/service_locator.dart';
import 'package:yaml/yaml.dart';
import 'package:modkeeper/services/external_process_service.dart';
import 'configuration_view.dart';
import 'package:provider/provider.dart';
import 'package:modkeeper/utilities/utilities.dart';

import 'mod_db_notifier.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoggingService()),
        Provider(create: (context) => ExternalProcessService()),
        Provider(create: (context) => ConfigurationService())
      ],
      child: Builder(
        builder: (context) {
          ServiceLocator().registerLoggingService(context); // logging service is shared by whole app
          return app(context);
        },
      ),
    );
  }
}

class MyHomePageViewState {
  bool showConfigurationView;
  ModDB modDB;
  MyHomePageViewState({required this.showConfigurationView, required this.modDB});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  MyHomePageViewState? _state;

  @override
  void initState() {
    super.initState();
  }


  Scaffold homePageView(BuildContext context, MyHomePageViewState viewState) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModKeeper'),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: Stack(
        children: [
          verticalResizeableContainer(viewState.modDB),
          if (viewState.showConfigurationView) createConfigurationView(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureLoadingWidget<MyHomePageViewState>(
      future: loadHomePageViewState(),
      dataBuilder: (context, viewState) {
        return ChangeNotifierProvider(
          create: (context) => ModDBNotifier(viewState.modDB),
          child: homePageView(context, viewState)
        );
      },
    );
  }

  // ...

  Widget verticalResizeableContainer(ModDB modDB) {
    return ResizableContainer(
      direction: Axis.vertical,
      dividerWidth: 10,
      dividerColor: Colors.grey[300],
      children: [
        ResizableChildData(
          startingRatio: 0.7,
          minSize: 500,
          child: horizontalResizeableContainer(modDB),
        ),
        ResizableChildData(startingRatio: 0.3, child: createConsoleView()),
      ],
    );
  }

  Widget horizontalResizeableContainer(ModDB modDB) {
    return ResizableContainer(
      direction: Axis.horizontal,
      dividerWidth: 10,
      dividerColor: Colors.grey[300],
      children: [
        const ResizableChildData(
          startingRatio: 0.3,
          minSize: 200,
          child: ModuleSelectionScreen(),
        ),
        ResizableChildData(startingRatio: 0.65, child: createTabView()),
        ResizableChildData(
          startingRatio: 0.05,
          child: createRightToolbar(modDB),
        ),
      ],
    );
  }

  Widget createRightToolbar(ModDB modDB) {
    const iconSize = 40.0;
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, size: iconSize),
            onPressed: () {
              setState(() {
                _state?.showConfigurationView = !(_state?.showConfigurationView ?? true);
              });
            },
          ),
          const Spacer(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: iconSize),
            onPressed: () async {
              try {
                // Get the configuration
                final configuration = await ConfigurationService.getConfiguration();

                // Create an instance of GameService
                final bg1GameService = GameService(
                  gameType: GameType.bg1ee,
                  configuration: configuration,
                  modDB: modDB,
                );

                final pendingCommands = await bg1GameService.run();
              }
              catch (e) {
                print(e);
              }
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
  Widget createConsoleView() {
    return const ConsoleWidget();
  }

  Widget createConfigurationView() {
    return ConfigurationView(
      onSaveConfiguration: () {
        setState(() {
          _state?.showConfigurationView = false;
        });
      },
    );
  }

}

Future<MyHomePageViewState> loadHomePageViewState() async {
  final modDB = await loadModDbContent();
  final showConfigurationView = !await ConfigurationService.isConfigFileExists();
  return MyHomePageViewState(showConfigurationView: showConfigurationView, modDB: modDB);
}

Future<ModDB> loadModDbContent() async {
  final yamlString = await FileService.loadAsset('assets/default_mod_db.yml');
  final modDBRaw = ModDBRaw.fromYaml(loadYaml(yamlString));
  final modDB = ModDB.fromModDBRaw(modDBRaw);
  return modDB;
}


extension OtherViewExtension on MyHomePageState {
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

}