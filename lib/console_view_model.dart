import 'package:flutter/foundation.dart';
import 'package:modkeeper/services/external_process_service.dart';

class ConsoleViewModel extends ChangeNotifier {
  final ExternalProcessService _weiduService = ExternalProcessService();
  String _output = '';

  String get output => _output;

  ConsoleViewModel() {
    _weiduService.output.listen((data) {
      _output += data;
      notifyListeners();
    });
  }

  void sendInput(String input) {
    _weiduService.input.add(input);
  }

  void startProcess(String executable, List<String> arguments) {
    _weiduService.startProcess(executable, arguments);
  }

  void stopProcess() {
    _weiduService.stopProcess();
  }
}