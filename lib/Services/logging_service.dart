import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoggingService extends ChangeNotifier {
  final List<String> _logs = [];

  List<String> get logs => _logs;

  void log(String message) {
    _logs.add(message);
    if (_logs.length > 10) {
      _logs.removeAt(0);
    }
    print(message);

    // avoid rebuild widget during widget rebuilt phase
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      notifyListeners();
    });
  }
}
