import 'package:besodatahub/Widgets/Prebuilds/simple_dialog.dart';
import 'package:flutter/material.dart';

class EditState with ChangeNotifier {
  int? _currentlyEditingIndex;
  bool _isCurrentLineEditDirty = false;

  int? get currentlyEditingIndex => _currentlyEditingIndex;
  bool get isCurrentLineEditDirty => _isCurrentLineEditDirty;

  bool tryStartEditing(int indexToEdit) {
    if (_currentlyEditingIndex != null &&
        _currentlyEditingIndex != indexToEdit &&
        _isCurrentLineEditDirty) {
      print(
          "Blocked: Cannot edit index $indexToEdit because index $_currentlyEditingIndex has unsaved changes.");
      // Optionally: show a snackbar or dialog here
      return false;
    }

    print("Allowing edit for index $indexToEdit");
    _currentlyEditingIndex = indexToEdit;
    _isCurrentLineEditDirty = false;
    notifyListeners();
    return true;
  }

  void updateDirtyStatus(bool isDirty) {
    if (_isCurrentLineEditDirty != isDirty) {
      print(
          "Updating dirty status for index $_currentlyEditingIndex to: $isDirty");
      _isCurrentLineEditDirty = isDirty;
      notifyListeners();
    }
  }

  Future<bool> cancelEditing(BuildContext context) async {
    if (_currentlyEditingIndex == null) {
      print("No editing to cancel.");
      // True because there's nothing to cancel
      return true;
    }
    if (_isCurrentLineEditDirty) {
      bool? result = await MySimpleDialog.show<bool>(
        context: context,
        title: "Änderungen verwerfen?",
        content:
            "Es gibt ungespeicherte Änderungen. Möchten Sie diese verwerfen?",
        actions: [
          ElevatedButton(
            child: const Text("Abbrechen"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: const Text("Änderungen verwerfen"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
      if (result == null || !result) {
        // Nicht Verwerden -> Dont Cancel Editing
        return false;
      }
    }

    print("Cancelling edit for index $_currentlyEditingIndex");
    _currentlyEditingIndex = null;
    _isCurrentLineEditDirty = false;
    notifyListeners();
    return true; // Return true to indicate that editing was cancelled
  }

  /// Forces the editing state to stop, regardless of the current index or dirty status.
  /// Useful for external cancellation (e.g., loading error, navigation away).
  void forceStopEditing() {
    if (_currentlyEditingIndex != null || _isCurrentLineEditDirty) {
      print(
          "Forcing stop editing. Was index: $_currentlyEditingIndex, Dirty: $_isCurrentLineEditDirty");
      _currentlyEditingIndex = null;
      _isCurrentLineEditDirty = false;
      notifyListeners();
    }
  }
}
