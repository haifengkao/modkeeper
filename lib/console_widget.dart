import 'package:flutter/material.dart';
import 'package:modkeeper/console_view_model.dart';
import 'package:provider/provider.dart';

class ConsoleWidget extends StatefulWidget {
  const ConsoleWidget({super.key});

  @override
  State<ConsoleWidget> createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConsoleViewModel(),
      child: Column(
        children: [
          Expanded(
            child: Consumer<ConsoleViewModel>(
              builder: (context, viewModel, child) {
                return ListView(
                  controller: _scrollController,
                  children: [
                    Text(viewModel.output),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (value) {
                    context.read<ConsoleViewModel>().sendInput(value);
                    _inputController.clear();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your input',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ConsoleViewModel>().sendInput(_inputController.text);
                  _inputController.clear();
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}