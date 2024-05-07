import 'package:flutter/material.dart';
import 'package:modkeeper/services/external_process_service.dart';
import 'package:provider/provider.dart';

class ConsoleWidget extends StatefulWidget {
  const ConsoleWidget({super.key});

  @override
  State<ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Column mainView(ExternalProcessService weiduService) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<String>(
            stream: weiduService.output,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  controller: _scrollController,
                  children: [
                    Text(snapshot.data!),
                  ],
                );
              }
              return Container();
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                onSubmitted: (value) {
                  weiduService.input.add(value);
                  _inputController.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your input',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                weiduService.input.add(_inputController.text);
                _inputController.clear();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final weiduService = Provider.of<ExternalProcessService>(context);

    return mainView(weiduService);
  }
}