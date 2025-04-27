import 'package:besodatahub/Models/exec.dart';
import 'package:besodatahub/Models/konfig.dart';
import 'package:flutter/foundation.dart';

class Konnektor {
  String name;
  String? comment;
  final ExecDefinition exec; // The executable name (e.g., "MyTool.exe")
  List<Konfig> konfig; // Make modifiable

  Konnektor({
    required this.name,
    required this.exec,
    this.comment,
    required this.konfig, // Start empty, load on demand
  });

// Add this method inside the Konnektor class
  Konnektor copy() {
    return Konnektor(
      name: name,
      exec: exec,
      comment: comment,
      // Create a deep copy of the konfig list
      konfig: konfig.map((k) => k.copy()).toList(),
    );
  }

  @override
  int get hashCode => Object.hash(name, exec, comment, Object.hashAll(konfig));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Konnektor) return false;
    return name == other.name &&
        exec == other.exec &&
        comment == other.comment &&
        listEquals(konfig, other.konfig);
  }

  @override
  String toString() {
    return 'Konnektor(Name: $name, Comment: $comment, Exec: $exec, Konfigs Loaded: ${konfig.length}';
  }

  // Method to generate the list of maps for saving (used by DataService)
  List<Map<String, dynamic>> generateSaveData() {
    List<Map<String, dynamic>> dataToSave = [];

    // Konfigs (Type='Konfig')
    for (Konfig k in konfig) {
      dataToSave.add({
        ...k.toMap(),
        "Konnektor": name,
        "Typ": "Konfig",
        "Jobname": null,
      });
    }

    // Exec (Type='Exec')
    dataToSave.add({
      "Konnektor": name,
      "Schluessel": "EXEC",
      "Wert": exec,
      "Typ": "Exec",
      "Jobname": null,
    });

    // Comment (Type='Comment') - Optional
    if (comment != null && comment!.isNotEmpty) {
      dataToSave.add({
        "Konnektor": name,
        "Schluessel": "Kommentar",
        "Wert": comment,
        "Typ": "Comment",
        "Jobname": null,
      });
    }

    return dataToSave;
  }

  factory Konnektor.fromSQL(List<Map<String, dynamic>> data) {
    Map<String, dynamic> execRow = data.firstWhere(
      (row) => row["Typ"] == "Exec",
      orElse: () => {},
    );
    List<Map<String, dynamic>> konfigRows = data
        .where(
          (row) => row["Typ"] == "Konfig",
        )
        .toList();

    return Konnektor(
      name: data[0]["Konnektor"].toString(),
      exec: ExecDefinition.fromPath(execRow["Wert"].toString()),
      comment: execRow["Kommentar"]?.toString() ?? '',
      konfig: konfigRows.map((e) => Konfig.fromMap(e)).toList(),
    );
  }
}
