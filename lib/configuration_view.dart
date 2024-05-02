import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PathField {
  final String label;
  final String initialPath;
  final bool Function(String) validator;

  PathField({
    required this.label,
    this.initialPath = '',
    required this.validator,
  });
}

class ConfigurationView extends StatefulWidget {
  final Function(Map<String, String>) onSaveConfiguration;

  const ConfigurationView({super.key, required this.onSaveConfiguration});

  @override
  ConfigurationViewState createState() => ConfigurationViewState();
}

List<PathField> defaultPathSettings = [
  PathField(
    label: 'Baldur\'s Gate Enhanced Edition',
    validator: validateGamePath,
  ),
  PathField(
    label: 'Baldur\'s Gate II Enhanced Edition',
    validator: validateGamePath,
  ),
  PathField(
    label: 'Weidu Executable',
    validator: validatePath,
  ),
  PathField(
    label: 'Mod Download Folder',
    validator: validatePath,
  ),
  PathField(
    label: 'Mod Installation Folder',
    validator: validatePath,
  ),
];

class ConfigurationViewState extends State<ConfigurationView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var field in defaultPathSettings) {
      _controllers[field.label] = TextEditingController(text: field.initialPath);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...defaultPathSettings.map(buildPathField),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveConfiguration,
                child: const Text('Save Configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPathField(PathField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            field.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextFormField(
          controller: _controllers[field.label],
          readOnly: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Select path',
            suffixIcon: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () => selectPath(field),
            ),
          ),
          validator: (value) {
            if (value == null || !field.validator(value)) {
              return 'Invalid Path';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,  // Add this line
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> selectPath(PathField field) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _controllers[field.label]?.text = selectedDirectory;
      });
    }
  }

  void saveConfiguration() {
    // don't validate at all
    // it's better let user try this app without proper settings
    // if (_formKey.currentState!.validate()) {
      Map<String, String> pathValues = {for (var field in defaultPathSettings) field.label: _controllers[field.label]!.text};
      widget.onSaveConfiguration(pathValues);
  }
}

bool validateGamePath(String path) {
  return Directory(path).existsSync();
}

bool validatePath(String path) {
  return Directory(path).existsSync();
}