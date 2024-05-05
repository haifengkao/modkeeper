import 'dart:async';
import 'dart:io';
import 'dart:convert';

class ExternalProcessService {
  Process? _process;
  final StreamController<String> _outputController = StreamController<String>();
  final StreamController<String> _inputController = StreamController<String>();

  Stream<String> get output => _outputController.stream;
  StreamSink<String> get input => _inputController.sink;

  Future<void> startProcess(String executable, List<String> arguments) async {
    _process = await Process.start(executable, arguments);

    _process?.stdout.transform(utf8.decoder).listen((data) {
      _outputController.add(data);
    });

    _process?.stderr.transform(utf8.decoder).listen((data) {
      _outputController.add(data);
    });

    _inputController.stream.listen((input) {
      _process?.stdin.writeln(input);
    });

    _process?.exitCode.then((exitCode) {
      _outputController.add('Process terminated with code $exitCode.');
      stopProcess();
    });
  }

  Future<void> stopProcess() async {
    await _process?.exitCode;
    await _outputController.close();
    await _inputController.close();
  }
}