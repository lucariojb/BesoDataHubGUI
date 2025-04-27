import 'dart:convert';

import 'package:besodatahub/Models/exec.dart'; // Correct import for ExecDefinition
import 'package:besodatahub/Models/konfig.dart';
import 'package:besodatahub/Models/konnektor.dart';
import 'package:besodatahub/Models/sql.dart';
import 'package:flutter/services.dart';

class DataService {
  //Constants
  static const String konfigTableName = "konfig";
  static const String jobFolgeTableName = "jobfolge";
  static const String konfigJsonPath = "assets/DataHubKonfigStruktur.json";

  //Cache for DataHubKonfigStruktur-json
  Map<String, dynamic>? _cachedKonfigJson;
  // Cache for loadExecsFromKonfigJson
  List<ExecDefinition>? _cachedExecDefinitions;
  // Cache for loadKonnektorOverview
  List<Konnektor>? _cachedKonnektorOverviews;

  // Init Methods
  Future<Map<String, dynamic>> loadKonfigJson(
      {bool forceReload = false}) async {
    //Load from cache if available
    if (_cachedKonfigJson != null && !forceReload) {
      return _cachedKonfigJson!;
    }

    try {
      final jsonString =
          await rootBundle.loadString(konfigJsonPath); // Load JSON file
      var decodeJson = jsonDecode(jsonString); // Decode JSON string
      _cachedKonfigJson = decodeJson;
      return _cachedKonfigJson!; // Return the loaded JSON data
    } catch (e) {
      print("Error loading JSON: $e");
      _cachedKonfigJson = {}; // Cache empty map on error
      return {}; // Return empty JSON on error
    }
  }

  Future<List<ExecDefinition>> loadExecsFromKonfigJson(
      {bool forceReload = false}) async {
    // Ensure the JSON is loaded first
    Map<String, dynamic> konfigJson =
        await loadKonfigJson(forceReload: forceReload);
    //Load from cache if available and not forced to reload
    if (_cachedExecDefinitions != null && !forceReload) {
      return _cachedExecDefinitions!;
    }

    try {
      _cachedExecDefinitions = konfigJson.keys
          .map((e) => ExecDefinition.fromPath(konfigJson[e]["EXE"]))
          .toList();
      print(
          "Loaded ${_cachedExecDefinitions!.length} ExecDefinitions from JSON.");
      return _cachedExecDefinitions!;
    } catch (e) {
      print("Error loading exec definitions from JSON: $e");
      _cachedExecDefinitions = []; // Cache empty list on error
      return []; // Return empty list on error
    }
  }

  // ----------------------------------------------------
  // Overview Methods -> Load Data to display (not edit)-
  // ----------------------------------------------------
  Future<List<Konnektor>> loadKonnektorOverview(
      {bool forceReload = false}) async {
    // Check Cache
    if (_cachedKonnektorOverviews != null && !forceReload) {
      return _cachedKonnektorOverviews!;
    }

    const String qry = """
      SELECT
          Konnektor,
          MAX(CASE
                  WHEN Typ = 'Exec' AND Schluessel = 'EXEC' AND Jobname IS NULL
                  THEN Wert
                  ELSE NULL
              END) AS Exec,
          MAX(CASE
                  WHEN Typ = 'Kommentar' AND Schluessel = 'Kommentar' AND Jobname IS NULL
                  THEN Wert
                  ELSE NULL
              END) AS Kommentar
      FROM
          konfig
      WHERE
          Konnektor IS NOT NULL
          AND Konnektor != ''
      GROUP BY
          Konnektor
      ORDER BY
          Konnektor;
      """;

    final List<dynamic> rawResult = await MySQL.runQueryAsMap(qry);

    final List<Konnektor> result = rawResult
        .map((row) => Konnektor(
              name: row["Konnektor"]?.toString() ?? 'Unknown',
              exec: ExecDefinition.fromPath(row["Exec"]?.toString() ?? ''),
              comment: row["Kommentar"]?.toString() ?? '',
              konfig: [],
            ))
        .toList();

    // Add Konfigs
    for (Konnektor konnektor in result) {
      konnektor.konfig = await loadKonfigsForKonnektorOverview(konnektor.name);
    }

    _cachedKonnektorOverviews = result;
    return result;
  }

  Future<List<Konfig>> loadKonfigsForKonnektorOverview(
      String konnektorName) async {
    final String qry = """
      SELECT Schluessel, Wert, Kommentar
      FROM konfig
      WHERE Konnektor = '$konnektorName'
      AND Typ = 'Konfig'
      AND (Jobname IS NULL OR Jobname = '');
      """;

    final List<dynamic> result = await MySQL.runQueryAsMap(qry);

    return result.map((row) => Konfig.fromMap(row)).toList();
  }

  // ----------------------------------------------------
  // Edit Methods -> Load Data to edit
  // ----------------------------------------------------
  Future<List<String>> loadKonfigSchluesselForKonnektor(String execName) async {
    Map<String, dynamic> allJsonData = await loadKonfigJson();
    List<dynamic> konfigs = allJsonData[execName]["Konnektor_Konfig"];
    return konfigs.map((e) => e["Schluessel"].toString()).toList();
  }

  /// Lädt die Definitionsdetails (Optionen, Kommentar, isRequired) für einen
  /// spezifischen Konfig-Schlüssel innerhalb eines bestimmten Executable-Typs.
  ///
  /// Gibt einen Record mit den Details zurück oder null, wenn der Eintrag nicht gefunden wurde.
  Future<(List<String>? options, String comment, bool isRequired)?>
      loadKonfigDefinitionDetails(
          String execName, String konfigSchluessel) async {
    try {
      // 1. JSON-Daten laden
      Map<String, dynamic> allJsonData = await loadKonfigJson();

      // 2. Konfigs für das spezifische Executable extrahieren (mit Null-Prüfung)
      // Passe die Pfade an deine genaue JSON-Struktur an!
      final execData = allJsonData[execName];
      if (execData == null || execData is! Map) {
        print(
            "Error: Executable '$execName' not found or invalid format in JSON.");
        return null;
      }
      // final konnektorData = execData['Konnektor'];
      // if (konnektorData == null || konnektorData is! Map) {
      //   print(
      //       "Error: 'Konnektor' section not found or invalid format for '$execName'.");
      //   return null;
      // }
      final konfigsList = execData['Konnektor_Konfig'];
      if (konfigsList == null || konfigsList is! List) {
        print(
            "Error: 'Konfig' list not found or invalid format for '$execName'.");
        return null;
      }

      // 3. Den spezifischen Konfig-Eintrag finden
      final konfigDefinition = konfigsList.firstWhere(
        (e) => e is Map && e["Schluessel"] == konfigSchluessel,
        orElse: () => null, // Wichtig: null zurückgeben, wenn nicht gefunden
      );

      // 4. Wenn der Eintrag nicht gefunden wurde, null zurückgeben
      if (konfigDefinition == null || konfigDefinition is! Map) {
        print(
            "Warning: Konfig definition for key '$konfigSchluessel' not found in '$execName'.");
        return null;
      }

      // 5. Die Werte extrahieren und Record erstellen
      // Optionen: Kann null sein oder ein String. Sicher extrahieren und splitten.
      final List<String>? optionsList;

      if (konfigDefinition["Optionen"] != null &&
          konfigDefinition["Optionen"] is List) {
        optionsList = List<String>.from(
            konfigDefinition["Optionen"].map((e) => e.toString()));
      } else {
        optionsList = null;
      } // Bleibt null, wenn leer oder nicht vorhanden

      // Kommentar: Sicher extrahieren, Standardwert ""
      final String comment = konfigDefinition["Kommentar"]?.toString() ?? "";

      final bool isRequired = konfigDefinition["isRequired"] ?? false;

      // 6. Record zurückgeben
      return (optionsList, comment, isRequired);
    } catch (e, stackTrace) {
      // Fehler beim Laden oder Parsen abfangen
      print(
          "Error loading konfig details for '$execName' / '$konfigSchluessel': $e");
      print(stackTrace);
      return null; // null zurückgeben bei Fehlern
    }
  }

  // ----------------------------------------------------
  // Job Folgen------------------------------------------
  // ----------------------------------------------------

  Future<List<Konfig>> loadKonfigsForJob(String execName) async {
    Map<String, dynamic> allJsonData = await loadKonfigJson();

    List<dynamic> konfigs = allJsonData[execName]["Job_Konfig"];

    return konfigs.map((e) => Konfig.fromMap(e)).toList();
  }

  Future<Konnektor> loadKonnektorFromName(String konnektorName) async {
    String qry = """
      SELECT * From konfig WHERE Konnektor = '$konnektorName' AND Jobname IS NULL
      """;

    List<Map<String, dynamic>> result = await MySQL.runQueryAsMap(qry);

    return Konnektor.fromSQL(result);
  }
}
