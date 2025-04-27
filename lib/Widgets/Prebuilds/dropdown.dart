import 'package:besodatahub/Utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'textfield.dart';

class MyDropdown<T> extends StatelessWidget {
  // --- Core Dropdown Properties ---
  final List<T>? items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? hintWidget;
  final Widget? disabledHint;
  final int elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final bool isExpanded;
  final Color? dropdownColor;
  final double? menuMaxHeight;

  // --- FormField Properties ---
  final InputDecoration? decoration;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final bool? enabled;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;

  // --- Convenience Properties ---
  final Map<String, T>? itemsMap;
  final String? label;
  final String? hintText; // For InputDecoration hintText
  final bool requiredField;
  final bool fixFloatingLabel;
  final EdgeInsetsGeometry outsidePadding;

  // --- Sizing Properties ---
  final double width;
  final double? height;
  final FormFieldSizeBehavior? sizeBehavior;

  const MyDropdown({
    super.key,
    // Core Dropdown Args
    this.items,
    this.value,
    required this.onChanged,
    this.hintWidget,
    this.disabledHint,
    this.elevation = 8,
    this.style,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isExpanded = false,
    this.dropdownColor,
    this.menuMaxHeight,

    // FormField Args
    this.decoration,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.autovalidateMode,
    this.focusNode,

    // Convenience Args
    this.itemsMap,
    this.label,
    this.hintText, // InputDecoration hintText
    this.requiredField = false,
    this.fixFloatingLabel = false,
    this.outsidePadding = const EdgeInsets.only(top: 8, right: 8, left: 8),

    // Sizing Args
    this.width = 200,
    this.height,
    this.sizeBehavior = FormFieldSizeBehavior.defaultSize,
  })  : assert(items != null || itemsMap != null,
            'MyDropdown: Either items or itemsMap must be provided.'),
        assert(items == null || itemsMap == null,
            'MyDropdown: Cannot provide both items and itemsMap.'),
        assert(
          !(sizeBehavior == FormFieldSizeBehavior.relativeSize &&
              (width > 100 || (height ?? 0) > 100)),
          'Relative size behavior should not have fixed width/height greater than 100%',
        );

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<T>>? finalItems = _buildItemsList();

    if (finalItems == null || finalItems.isEmpty) {
      print("Warning: MyDropdown created with no valid items.");
      // Calculate size even for the disabled state
      return const Center(
          child: Text(
        "No items available",
        style: TextStyle(color: Colors.red),
      ));
    }

    // --- Build Core Dropdown ---
    Widget dropdownFormField = DropdownButtonFormField<T>(
      items: finalItems,
      value: value,
      hint: hintWidget,
      disabledHint: disabledHint,
      onChanged: enabled ?? true ? onChanged : null, // Check enabled flag
      onSaved: onSaved,
      validator: _getCombinedValidator(),
      autovalidateMode: autovalidateMode,
      focusNode: focusNode,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor:
          iconEnabledColor ?? Theme.of(context).colorScheme.primary,
      iconSize: iconSize,
      isExpanded: isExpanded,
      dropdownColor:
          dropdownColor ?? Theme.of(context).colorScheme.primaryContainer,
      menuMaxHeight: menuMaxHeight,
      decoration: _getProcessedInputDecoration(context),
    );

    // --- Sizing ---
    if (sizeBehavior == FormFieldSizeBehavior.defaultSize) {
      dropdownFormField = SizedBox(
        width: width,
        height: height,
        child: dropdownFormField,
      );
    } else if (sizeBehavior == FormFieldSizeBehavior.relativeSize) {
      dropdownFormField = SizedBox(
        width: width.w,
        height: height?.h,
        child: dropdownFormField,
      );
    }
    // sizeBehavior == FormFieldSizeBehavior.intrinsicSize -> No action needed

    // Add padding outside the dropdown
    if (outsidePadding != EdgeInsets.zero) {
      dropdownFormField = Padding(
        padding: outsidePadding,
        child: dropdownFormField,
      );
    }
    // Return the final widget
    return dropdownFormField;
  }

  // (Keep _buildItemsList, _getProcessedInputDecoration, _getCombinedValidator as they were - already updated)
  /// Builds the list of DropdownMenuItem<T> from either `items` or `itemsMap`.
  List<DropdownMenuItem<T>>? _buildItemsList() {
    if (items != null) {
      return items!.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child:
              Text(item.toString()), // Use the item itself as the display text
        );
      }).toList();
    }
    if (itemsMap != null) {
      return itemsMap!.entries.map((entry) {
        return DropdownMenuItem<T>(
          value: entry.value,
          child: Text(entry.key), // Use the map key as the display text
        );
      }).toList();
    }
    return null;
  }

  /// Creates the final InputDecoration by merging theme, passed decoration, and convenience props.
  InputDecoration _getProcessedInputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final themeDefaults = theme.inputDecorationTheme;
    InputDecoration baseDecoration = decoration ?? const InputDecoration();

    baseDecoration = baseDecoration.applyDefaults(themeDefaults);

    String? finalLabelText = label ?? baseDecoration.labelText;
    if (requiredField &&
        finalLabelText != null &&
        !finalLabelText.endsWith(' *')) {
      finalLabelText = '$finalLabelText *';
    }

    baseDecoration = baseDecoration.copyWith(
      labelText: finalLabelText,
      hintText: hintText ?? baseDecoration.hintText,
      floatingLabelBehavior:
          fixFloatingLabel && baseDecoration.floatingLabelBehavior == null
              ? FloatingLabelBehavior.always
              : baseDecoration.floatingLabelBehavior,
      enabled: enabled, // Reflect enabled state in decoration
    );

    // Add empty Helpertext to keep space for errortext
    if (requiredField || validator != null) {
      baseDecoration = baseDecoration.copyWith(
        helperText: '',
      );
    }

    // Return the final decoration
    return baseDecoration;
  }

  /// Combines the requiredField validator and the user-provided validator.
  String? Function(T?)? _getCombinedValidator() {
    final List<String? Function(T?)> validators = [];

    if (requiredField) {
      validators.add((T? value) {
        if (value == null) {
          // Pass label or default name to required validator
          return ValidationUtils.required(label ?? 'Selection').call(null);
        }
        return null;
      });
    }

    if (validator != null) {
      validators.add(validator!);
    }

    if (validators.isNotEmpty) {
      return (T? value) {
        for (final func in validators) {
          final error = func(value);
          if (error != null) {
            return error;
          }
        }
        return null;
      };
    }
    return null;
  }
}
