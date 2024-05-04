import 'package:flutter/material.dart';

class LoggingService extends ChangeNotifier {
  final List<String> _logs = [];

  List<String> get logs => _logs;

  void log(String message) {
    _logs.add(message);
    if (_logs.length > 10) {
      _logs.removeAt(0);
    }
    print(message);
    notifyListeners();
  }
}
