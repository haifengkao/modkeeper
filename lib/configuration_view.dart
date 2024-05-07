import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:modkeeper/services/configuration_service.dart';
import 'package:modkeeper/services/game_finder_service.dart';

class PathField {
  final String label;
  final String initialPath;
  final bool Function(String) validator;

  PathField({
    required this.label,
    required this.initialPath,
    required this.validator,
  });
}


class ConfigurationView extends StatefulWidget {
  final Function() onSaveConfiguration;

  const ConfigurationView({super.key, required this.onSaveConfiguration});

  @override
  ConfigurationViewState createState() => ConfigurationViewState();
}

class ConfigurationViewState extends State<ConfigurationView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  List<PathField> _pathFields = [];

  Future<void> initializeData() async {
    final settings = await ConfigurationService.getConfiguration();

    _pathFields = [
      PathField(
        label: bg1eeGameName,
        initialPath: settings.bg1eePath,
        validator: validateGamePath,
      ),
      PathField(
        label: bg2eeGameName,
        initialPath: settings.bg2eePath,
        validator: validateGamePath,
      ),
      PathField( // TODO: show "will create folder" if not exists
        label: gameInstallationFolderText,
        initialPath: settings.installationPath,
        validator: (any) => true,
      ),

    ];
    for (var field in _pathFields) {
      _controllers[field.label] =
          TextEditingController(text: settings.toMap()[field.label]);
    }
  }

  @override
  void initState() {
    super.initState();
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
      body: FutureBuilder(
        future: initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._pathFields.map(buildPathField),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: saveConfiguration,
                      child: const Text('Save Configuration'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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
          autovalidateMode: AutovalidateMode.onUserInteraction, // Add this line
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

    final settings = ConfigurationSetting(
      bg1eePath: _controllers[bg1eeGameName]?.text ?? '',
      bg2eePath: _controllers[bg2eeGameName]?.text ?? '',
      installationPath: _controllers[gameInstallationFolderText]?.text ?? '',
    );

    ConfigurationService.saveConfiguration(settings);
    widget.onSaveConfiguration();
  }
}


bool validateGamePath(String path) {
  return Directory(path).existsSync();
}

bool validatePath(String path) {
  return Directory(path).existsSync();
}
