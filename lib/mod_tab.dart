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

  @override
  Widget build(BuildContext context) {
    return Consumer<LoggingService>(
      builder: (context, loggingService, _) {
        return ListView.builder(
          itemCount: loggingService.logs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: SelectableText(
                loggingService.logs[index],
                style: const TextStyle(fontSize: 16),
                cursorRadius: const Radius.circular(4),
                enableInteractiveSelection: true,
                toolbarOptions: const ToolbarOptions(
                  copy: true,
                  selectAll: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
