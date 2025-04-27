import 'package:flutter/material.dart';
// Removed global theme reference

class MyIconButton extends StatelessWidget {
  final double padding;
  final IconData icondata;
  final String? tooltip;

  /// Overrides the default icon color from the theme.
  final Color? iconColor;

  /// Overrides the default icon color when hovered/focused (from ButtonStyle overlay).
  final Color? hoveredIconColor;

  /// Size of the icon itself.
  final double? iconSize;

  /// Callback when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Explicitly set enabled state. If false, onPressed should also be null ideally.
  final bool enabled;

  /// Size of the overall tap target / visual button area.
  final double? buttonSize;

  const MyIconButton({
    super.key,
    required this.icondata,
    this.onPressed,
    this.padding = 8.0, // Default padding around the icon
    this.iconColor,
    this.hoveredIconColor, // Still less standard, overlay preferred
    this.iconSize, // Uses IconTheme default if null
    this.tooltip,
    this.enabled = true, // Default to enabled
    this.buttonSize, // Optional: constrain overall size
  });

  @override
  Widget build(BuildContext context) {
    // Get theme data and color scheme correctly
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final iconTheme = theme.iconTheme;

    // Determine the effective onPressed callback based on the enabled flag
    final VoidCallback? effectiveOnPressed = enabled ? onPressed : null;

    return IconButton(
      // --- Core Properties ---
      icon: Icon(icondata),
      onPressed: effectiveOnPressed,
      tooltip: tooltip,

      // --- Styling via ButtonStyle ---
      style: ButtonStyle(
        // --- Size Control ---
        // Use WidgetStateProperty for consistency, though value is often static here
        padding: WidgetStateProperty.all(EdgeInsets.all(padding)),
        minimumSize: buttonSize != null
            ? WidgetStateProperty.all(Size(buttonSize!, buttonSize!))
            : null,
        maximumSize: buttonSize != null
            ? WidgetStateProperty.all(Size(buttonSize!, buttonSize!))
            : null,

        // --- Colors ---
        // Icon color based on state (enabled/disabled/hovered/pressed)
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          // Use WidgetStateProperty
          (Set<WidgetState> states) {
            // Use WidgetState
            if (states.contains(WidgetState.disabled)) {
              // Use theme's disabled color
              return theme.disabledColor;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              // Use provided hovered color, or theme secondary, or default icon color
              return hoveredIconColor ??
                  colors.secondary; // Example: Use secondary on hover
            }
            // Default color: Use provided iconColor or theme's primary icon color
            return iconColor ??
                colors.primary; // Use primary as default enabled color
          },
        ),
        // Background color / Overlay for hover/focus/press feedback
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          // Use WidgetStateProperty
          (Set<WidgetState> states) {
            // Use WidgetState
            Color baseColor = iconColor ??
                colors.primary; // Start with default/provided color
            // Adjust base color if disabled FIRST
            if (states.contains(WidgetState.disabled)) {
              // Check disabled state
              baseColor = theme.disabledColor;
            }

            // Now apply overlay based on interaction states
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return baseColor.withAlpha(30); // Standard Material hover opacity
            }
            if (states.contains(WidgetState.pressed)) {
              return baseColor.withAlpha(38); // Standard Material press opacity
            }
            return null; // No overlay in default state
          },
        ),
        // Ensure the button shape is circular if desired
        shape: WidgetStateProperty.all(const CircleBorder()),
      ),
      // --- Direct Size/Color Properties ---
      iconSize: iconSize ??
          iconTheme.size, // Use parameter or theme default icon size
      color:
          iconColor, // Explicit color override (can be overridden by ButtonStyle.foregroundColor)
      disabledColor: theme
          .disabledColor, // Use theme disabled color (IconButton handles this)

      // Use constraints if precise overall button size needed
      constraints: buttonSize != null
          ? BoxConstraints.tight(Size(buttonSize!, buttonSize!))
          : const BoxConstraints(), // Use default constraints if buttonSize null
    );
  }
}
