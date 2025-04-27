import 'package:flutter/material.dart';

/// Defines the default icon button combinations for the SimpleDialog.
enum MySimpleDialogType {
  /// Shows only a confirmation icon button (✓). Pops `true`.
  okOnly,

  /// Shows a decline icon button (X) and a confirmation icon button (✓).
  /// Decline pops `false`, Confirm pops `true`.
  yesNo,
}

// Assuming SimpleDialogType enum is defined above or imported

/// A simplified dialog widget using AlertDialog.
///
/// Provides options for predefined icon buttons (OK, Yes/No) or fully custom actions.
/// Use the static [show] method to display the dialog.
class MySimpleDialog extends StatelessWidget {
  final String title;
  final String content;
  final Widget? icon; // Optional icon for the dialog title area

  // Options for actions: Either specify a type OR provide custom actions
  final MySimpleDialogType? dialogType;
  final List<Widget>? actions;

  /// Private constructor. Use [SimpleDialog.show] to display.
  const MySimpleDialog._({
    required this.title,
    required this.content,
    this.icon,
    this.dialogType, // Nullable internally
    this.actions, // Nullable internally
  });

  /// Displays the simplified dialog.
  ///
  /// Returns:
  /// - `true` if the user confirms (taps OK or Yes icon/button).
  /// - `false` if the user declines (taps No icon/button).
  /// - `null` if the user cancels via barrier tap or a custom Cancel action pops null.
  /// - Or any value popped by custom actions.
  static Future<T?> show<T>({
    // Generic return type T
    required BuildContext context,
    required String title,
    required String content,

    /// Determines the default icon buttons if `actions` is null. Defaults to `okOnly`.
    MySimpleDialogType dialogType = MySimpleDialogType.okOnly,

    /// A list of custom widgets for the dialog actions. If provided, `dialogType` is ignored.
    List<Widget>? actions,
    Widget? icon,
    bool barrierDismissible = true, // Allow dismissing by tapping outside
  }) {
    // Ensure only one action definition method is used
    assert(!(actions != null && dialogType != MySimpleDialogType.okOnly),
        'SimpleDialog.show: Cannot provide both custom actions and a specific dialogType (other than the default okOnly if actions is null). Provide one or the other.');

    // If custom actions are given, dialogType is effectively ignored internally
    final MySimpleDialogType? effectiveDialogType =
        (actions == null) ? dialogType : null;

    return showDialog<T?>(
      // Use generic type T?
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return MySimpleDialog._(
          title: title,
          content: content,
          icon: icon,
          dialogType: effectiveDialogType, // Pass null if actions are provided
          actions: actions, // Pass custom actions
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Text(content),
      actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Increased padding slightly
      actionsAlignment: MainAxisAlignment.end,
      // Use helper to build actions based on properties
      actions: _buildActions(context),
    );
  }

  /// Builds the list of action buttons based on custom actions or dialogType.
  List<Widget> _buildActions(BuildContext context) {
    // Priority 1: Use custom actions if provided
    if (actions != null) {
      return actions!;
    }

    // Priority 2: Build default actions based on dialogType (which cannot be null here if actions is null)
    final defaultActions = <Widget>[];
    const double iconButtonPadding = 8.0; // Padding for icon buttons
    const double iconButtonSize = 28.0; // Size for the icon itself

    // --- Decline Button (X Icon) ---
    if (dialogType == MySimpleDialogType.yesNo) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.close_rounded),
          iconSize: iconButtonSize,
          tooltip: "No", // Standard tooltip
          color: Colors.red, // Explicit red color
          padding: const EdgeInsets.all(iconButtonPadding),
          // Optional: Add visual feedback
          // style: IconButton.styleFrom(
          //   foregroundColor: Colors.red,
          //   hoverColor: Colors.red.withOpacity(0.1),
          //   highlightColor: Colors.red.withOpacity(0.15),
          // ),
          onPressed: () {
            Navigator.of(context).pop(false); // Return false for No/Decline
          },
        ),
      );
    }

    // --- Confirm Button (Check Icon) ---
    // Added for both okOnly and yesNo types
    defaultActions.add(
      IconButton(
        icon: const Icon(Icons.check_rounded),
        iconSize: iconButtonSize,
        tooltip: "OK", // Standard tooltip
        color: Colors.green, // Explicit green color
        padding: const EdgeInsets.all(iconButtonPadding),
        // Optional: Add visual feedback
        // style: IconButton.styleFrom(
        //   foregroundColor: Colors.green,
        //   hoverColor: Colors.green.withOpacity(0.1),
        //   highlightColor: Colors.green.withOpacity(0.15),
        // ),
        onPressed: () {
          Navigator.of(context).pop(true); // Return true for OK/Yes/Confirm
        },
      ),
    );

    return defaultActions;
  }
}
