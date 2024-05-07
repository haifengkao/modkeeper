class ConsoleCommand {
  final String executable;
  final List<String> arguments;
  final String workingDirectory;

  ConsoleCommand(
      {required this.executable,
      required this.arguments,
      required this.workingDirectory});
}
