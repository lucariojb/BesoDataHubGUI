import 'package:besodatahub/Models/konfig.dart';
import 'package:flutter/foundation.dart';

class Job {
  final String name;
  final String konnektor;
  final List<Konfig> konfig;
  final List<Konfig> overrideKonnektorKonfig;
  String uniqueName; // Unique Name for Job in Jobfolge
  String comment;
  int schritt;
  int statusPosition;
  String statusFilter;
  String endStatus;

  Job({
    required this.name,
    required this.konnektor,
    required this.konfig,
    this.overrideKonnektorKonfig = const [],
    this.uniqueName = "",
    this.comment = "",
    this.schritt = 0,
    this.statusPosition = 0,
    this.statusFilter = "",
    this.endStatus = "",
  });

  // Add this method inside the Job class
  Job copy() {
    return Job(
      name: name,
      konnektor: konnektor,
      konfig: konfig.map((k) => k.copy()).toList(),
    );
  }

  @override
  String toString() => 'Job(Name: $name, Konfigs Loaded: ${konfig.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Job &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listEquals(
              konfig, other.konfig); // Equality depends on loaded konfigs

  @override
  int get hashCode => Object.hash(name, Object.hashAll(konfig));
}
