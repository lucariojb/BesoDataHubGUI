import 'package:flutter/material.dart';

class MyExpansionTile extends StatelessWidget {
  // --- Forwarded properties ---
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Color? textColor;
  final Color? collapsedTextColor;
  final Color? iconColor;
  final Color? collapsedIconColor;

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool maintainState;
  final EdgeInsetsGeometry? tilePadding; // Padding inside the tile header
  final EdgeInsetsGeometry
      childrenPadding; // Padding for the children when expanded

  final ExpansionTileController? controller;
  final ShapeBorder? shape; // Allows overriding the theme's shape
  final ShapeBorder?
      collapsedShape; // Allows overriding the theme's collapsed shape
  final Clip? clipBehavior;

  // --- Own properties ---
  /// Padding applied *around* the entire ExpansionTile widget.
  final EdgeInsetsGeometry outsidePadding;
  final bool removeDefaultIcon;

  const MyExpansionTile({
    super.key,
    required this.title,
    this.controller,
    this.leading,
    this.subtitle,
    this.backgroundColor, // If null, theme's ExpansionTileThemeData.backgroundColor is used
    this.collapsedBackgroundColor, // If null, falls back to backgroundColor, then theme
    this.textColor, // If null, theme's ExpansionTileThemeData.textColor is used
    this.collapsedTextColor, // If null, falls back to textColor, then theme
    this.trailing,
    this.initiallyExpanded = false,
    this.tilePadding, // If null, ExpansionTile uses its default/theme padding
    this.childrenPadding = EdgeInsets.zero,
    this.onExpansionChanged,
    this.children = const [],
    this.maintainState = false,
    this.iconColor, // If null, theme's ExpansionTileThemeData.iconColor is used
    this.collapsedIconColor, // If null, falls back to iconColor, then theme
    this.shape, // If null, theme's ExpansionTileThemeData.shape is used
    this.collapsedShape, // If null, falls back to shape, then theme
    this.clipBehavior,
    // Set the default for outsidePadding here
    this.outsidePadding = const EdgeInsets.only(left: 16, right: 16, top: 8),
    this.removeDefaultIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    //Assertion
    assert(removeDefaultIcon == false || trailing == null,
        'If removeDefaultIcon is true, trailing must be null.');

    // Wrap the standard ExpansionTile with a Padding widget
    // to apply the outsidePadding.
    return Padding(
      padding: outsidePadding, // Apply the padding around the tile
      child: ExpansionTile(
        key: key, // Pass key
        controller: controller,

        // --- Pass Colors ---
        // Pass the properties directly. If they are null, ExpansionTile will
        // check the ExpansionTileThemeData from Theme.of(context).
        // The ?? fallback provides a local default before the theme lookup.
        backgroundColor: backgroundColor,
        collapsedBackgroundColor: collapsedBackgroundColor ?? backgroundColor,
        textColor: textColor,
        collapsedTextColor: collapsedTextColor ?? textColor,
        iconColor: iconColor,
        collapsedIconColor: collapsedIconColor ?? iconColor,

        // --- Layout & Format ---
        // Pass shapes directly. If null, theme shape will be used.
        shape: shape,
        collapsedShape:
            collapsedShape ?? shape, // Fallback to shape before theme
        tilePadding: tilePadding, // Pass standard padding property
        childrenPadding: childrenPadding, // Pass standard children padding
        clipBehavior: clipBehavior,

        // --- Functions & State ---
        onExpansionChanged: onExpansionChanged, // Pass callback directly
        initiallyExpanded: initiallyExpanded,
        maintainState: maintainState, // Pass maintainState

        // --- Widgets & Children ---
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: removeDefaultIcon ? const SizedBox.shrink() : trailing,
        children: children,
      ),
    );
  }
}
