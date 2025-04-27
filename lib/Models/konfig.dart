// --- Konfig Class (Mostly unchanged, added null check) ---
import 'dart:convert';

class Konfig {
  final String name; // Schluessel
  String value; // Wert
  String? comment; // Kommentar
  List<String>? optionen; // Optionen
  bool? isRequired; // Not loaded/saved currently, consider if needed

  Konfig({
    required this.name,
    required this.value,
    this.comment,
    this.optionen,
    this.isRequired = false,
  });

  factory Konfig.fromMap(Map<String, dynamic> data) {
    // Added null checks and default values
    return Konfig(
      name: data["Schluessel"]?.toString() ?? 'Unknown Key',
      value: data["Wert"]?.toString() ?? '',
      comment: data["Kommentar"]?.toString() ?? '',
      optionen: data["Optionen"] ?? [],
      isRequired: data["isRequired"] ?? false,
    );
  }

  // Keep if you need JSON string parsing, otherwise remove
  factory Konfig.fromJSON(String data) {
    Map<String, dynamic> jsonData = jsonDecode(data);
    return Konfig.fromMap(jsonData);
  }

  Map<String, dynamic> toMap() {
    // Only include fields that are actually stored in this simple format
    return {
      "Schluessel": name,
      "Wert": value,
    };
  }

  // Add this method inside the Konfig class
  Konfig copy() {
    return Konfig(
      name: name,
      comment: comment,
      value: value,
      optionen: List<String>.from(optionen ?? []),
      isRequired: isRequired,
    );
  }

  @override
  int get hashCode => Object.hash(name, value, comment);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Konfig) return false;
    return name == other.name &&
        value == other.value &&
        comment == other.comment;
  }

  @override
  String toString() {
    return 'Konfig(Name: $name, Value: $value)';
  }
}
