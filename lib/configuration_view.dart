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
  List<PathField> pathFields = defaultPathSettings;

  Map<String, String> pathValues = {};
  Map<String, String> pathStatuses = {};

  @override
  void initState() {
    super.initState();
    for (var field in defaultPathSettings) {
      pathValues[field.label] = field.initialPath;
      pathStatuses[field.label] = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...defaultPathSettings.map((field) => buildPathField(field)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveConfiguration,
              child: const Text('Save Configuration'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPathField(PathField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: pathValues[field.label]),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select path',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () => selectPath(field),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              pathStatuses[field.label]!,
              style: TextStyle(
                color: pathStatuses[field.label] == 'Valid' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> selectPath(PathField field) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        pathValues[field.label] = selectedDirectory;
        pathStatuses[field.label] = field.validator(selectedDirectory) ? 'Valid' : 'Invalid';
      });
    }
  }


  void saveConfiguration() {
    widget.onSaveConfiguration(pathValues);
    Navigator.pop(context);
  }
}

bool validateGamePath(String path) {
  // Add your logic to validate the game path
  // For example, check if the path contains the necessary game files
  return Directory(path).existsSync();
}

bool validatePath(String path) {
  return Directory(path).existsSync();
}
