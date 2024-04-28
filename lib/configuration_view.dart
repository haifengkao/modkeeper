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

  ConfigurationView({required this.onSaveConfiguration});

  @override
  _ConfigurationViewState createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  List<PathField> pathFields = [
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

  Map<String, String> pathValues = {};
  Map<String, String> pathStatuses = {};

  @override
  void initState() {
    super.initState();
    for (var field in pathFields) {
      pathValues[field.label] = field.initialPath;
      pathStatuses[field.label] = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...pathFields.map((field) => buildPathField(field)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveConfiguration,
              child: Text('Save Configuration'),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: pathValues[field.label]),
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select path',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: () => selectPath(field),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              pathStatuses[field.label]!,
              style: TextStyle(
                color: pathStatuses[field.label] == 'Valid' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
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

  bool validateGamePath(String path) {
    // Add your logic to validate the game path
    // For example, check if the path contains the necessary game files
    return Directory(path).existsSync();
  }

  bool validatePath(String path) {
    return Directory(path).existsSync();
  }

  void saveConfiguration() {
    widget.onSaveConfiguration(pathValues);
    Navigator.pop(context);
  }
}