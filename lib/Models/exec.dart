class ExecDefinition {
  final String name;
  final String path;

  ExecDefinition({
    required this.name,
    required this.path,
  });

  factory ExecDefinition.fromPath(String path) {
    return ExecDefinition(
      name: path
          .split(r'\')
          .last
          .replaceAll(RegExp(r'\.exe$', caseSensitive: false), ''),
      path: path,
    );
  }

  @override
  String toString() => 'ExecDefinition(name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == path;

  @override
  int get hashCode => name.hashCode;
}
