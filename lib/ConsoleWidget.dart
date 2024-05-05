import 'package:flutter/material.dart';
import 'package:modkeeper/Services/external_process_service.dart';

class ConsoleWidget extends StatefulWidget {
  final ExternalProcessService weiduService;

  const ConsoleWidget({super.key, required this.weiduService});

  @override
  _ConsoleWidgetState createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    widget.weiduService.stopProcess();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<String>(
            stream: widget.weiduService.output,
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
                  widget.weiduService.input.add(value);
                  _inputController.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your input',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.weiduService.input.add(_inputController.text);
                _inputController.clear();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
}