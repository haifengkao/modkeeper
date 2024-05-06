import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:quiver/strings.dart';

class LoggingService extends ChangeNotifier {
  final List<String> _logs = [];

  List<String> get logs => _logs;

  void log(String message) {

    // avoid duplicate logs
    if (_logs.isNotEmpty && message == _logs.last) {return;}
    if (isBlank(message)) {return;}

    _logs.add(message);
    if (_logs.length > 50) {
      _logs.removeAt(0);
    }
    print(message);

    // avoid rebuild widget during widget rebuilt phase
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      notifyListeners();
    });
  }
}
