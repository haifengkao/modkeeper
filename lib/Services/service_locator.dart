import 'package:flutter/material.dart';
import 'package:modkeeper/Services/logging_service.dart';
import 'package:provider/provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  LoggingService? _loggingService;

  void log(String message) {
    _loggingService?.log(message);
  }

  void registerLoggingService(BuildContext context) {
    _loggingService = Provider.of<LoggingService>(context, listen: false);
  }

  LoggingService get loggingService => _loggingService!;
}
