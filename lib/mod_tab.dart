import 'package:flutter/material.dart';
import 'package:modkeeper/services/logging_service.dart';
import 'package:provider/provider.dart';

class ModTab {
  final String title;
  final Widget Function() buildView;

  ModTab({required this.title, required this.buildView});
}

List<ModTab> modTabs = [
  ModTab(
    title: 'Logs',
    buildView: () => const LoggingWidget(),
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

class LoggingWidget extends StatelessWidget {
  const LoggingWidget({super.key});

  ListView mainView(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: context.watch<LoggingService>().logs.length,
      itemBuilder: (context, index) {
        return SelectableText(
            context.watch<LoggingService>().logs[index],
            cursorRadius: const Radius.circular(4),
            enableInteractiveSelection: true,
            toolbarOptions: const ToolbarOptions(
              copy: true,
              selectAll: true,
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoggingService>(
      builder: (context, loggingService, _) {
        return mainView(context);
      },
    );
  }
}
