class PendingCommand {
  // to display the pending commands to user
  final String description;
  final List<Function> _commands;

  PendingCommand({required this.description, required List<Function> commands})
      : _commands = commands;

  Future<void> execute() async {
    for (final command in _commands) {
      await command();
    }
  }

  @override
  String toString() {
    return description;
  }
}
