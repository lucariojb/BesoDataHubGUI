import 'package:besodatahub/Utils/validation.dart'; // Adjust path if needed
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart'; // Assuming sizer is used for relative units

enum FormFieldSizeBehavior {
  /// Use the default size behavior (width: 200) or absolute values.
  defaultSize,

  /// Use the relative size behavior (width: 80% of screen width, height: 50% of screen height).
  relativeSize,

  /// Use the intrinsic size behavior (No fixed size, let the field size itself).
  intrinsicSize,
}

class MyTextField extends StatelessWidget {
  // --- Forwarded Properties (Commonly used) ---
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration; // Allow full override
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool? enabled;
  final String? Function(String?)? validator; // User's custom validator
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final TextStyle? style;
  final bool readOnly;
  final bool autofocus;
  final TextAlign textAlign;

  // --- Own Custom Properties ---
  /// Fixed width for the text field container. Overrides relativeWidth.
  final double width;

  /// Fixed height for the text field container. Overrides relativeHeight.
  final double? height;

  /// Size behavior for the text field. Can be default, relative, or intrinsic.
  final FormFieldSizeBehavior sizeBehavior;

  /// Padding around the text field. Default is 8 pixels on all sides but the bottom.
  /// Set to EdgeInsets.zero to remove all padding.
  final EdgeInsets outsidePadding;

  /// If true, adds a required validator and appends '*' to the label.
  final bool requiredField;

  /// If true, forces the InputDecoration's label to always float above the field.
  final bool fixFloatingLabel;

  /// Convenience property for InputDecoration's labelText.
  final String? label;

  /// Convenience property for InputDecoration's hintText.
  final String? hintText;

  const MyTextField({
    super.key,
    // Common props
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.enabled,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.style,
    this.readOnly = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.maxLines, // Allow null for default single/multi-line behavior

    // Custom props
    this.requiredField = false,
    this.fixFloatingLabel = false,
    this.label,
    this.hintText,
    this.width = 200,
    this.height,
    this.sizeBehavior = FormFieldSizeBehavior.defaultSize,
    this.outsidePadding = const EdgeInsets.only(top: 8, right: 8, left: 8),
  }) : assert(
          !(sizeBehavior == FormFieldSizeBehavior.relativeSize &&
              (width > 100 || (height ?? 0) > 100)),
          'Relative size behavior should not have fixed width/height greater than 100%',
        );

  @override
  Widget build(BuildContext context) {
    // --- Validator Logic ---
    // Combine user validator with requiredField logic
    String? combinedValidator(String? value) {
      // Run required check first if applicable
      if (requiredField) {
        // Pass the label as fieldName for better error message
        final requiredError = ValidationUtils.required(label ?? 'Field')(value);
        if (requiredError != null) {
          return requiredError;
        }
      }
      // Then run the user's validator if provided
      return validator?.call(value);
    }

    // --- TextStyle Logic ---
    TextStyle? style = this.style ?? Theme.of(context).textTheme.bodyMedium;
    if (readOnly) {
      // If readOnly, apply a disabled style
      style = style?.copyWith(
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      );
    }

    // --- FormField Logic ---
    Widget resultWidget = TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration:
          _getProcessedInputDecoration(context), // Use processed decoration
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      validator: combinedValidator, // Use combined validator
      onChanged: onChanged,
      onSaved: onSaved,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: style,
      // Readonly also disables the field visually
      readOnly: readOnly,
      autofocus: autofocus,
      textAlign: textAlign,
      // Tseting shit
    );

    // --- Sizing Logic ---
    if (sizeBehavior == FormFieldSizeBehavior.relativeSize) {
      resultWidget = SizedBox(
        width: width.w,
        height: height?.h,
        child: resultWidget,
      );
    } else if (sizeBehavior == FormFieldSizeBehavior.defaultSize) {
      // Use default size behavior (fixed width and height)
      resultWidget = SizedBox(
        width: width,
        height: height,
        child: resultWidget,
      );
    }
    // sizedBehavior == FormFieldSizeBehavior.intrinsicSize needs no extra handling

    //Apply Outside Padding
    resultWidget = Padding(
      padding: outsidePadding,
      child: resultWidget,
    );

    // --- Return the final widget ---
    return resultWidget;
  }

  /// Creates the final InputDecoration by merging theme, passed decoration, and convenience props.
  InputDecoration _getProcessedInputDecoration(BuildContext context) {
    // Get theme defaults using the current BuildContext
    final theme = Theme.of(context);
    final themeDefaults = theme.inputDecorationTheme;

    // Start with the user-provided decoration or an empty one
    InputDecoration baseDecoration = decoration ?? const InputDecoration();

    // Apply theme defaults. Explicit values in 'baseDecoration' take precedence.
    baseDecoration = baseDecoration.applyDefaults(themeDefaults);

    // Determine the final label text.
    // Use 'label' property if provided, otherwise use label from 'baseDecoration'.
    // Add required indicator '*' if applicable.
    String? finalLabelText = label ?? baseDecoration.labelText;
    if (requiredField &&
        finalLabelText != null &&
        !finalLabelText.endsWith(' *')) {
      finalLabelText = '$finalLabelText *';
    }

    // Apply convenience props and custom logic using copyWith.
    // This overrides values from 'baseDecoration' AND 'themeDefaults' if convenience props are set.
    baseDecoration = baseDecoration.copyWith(
      labelText: finalLabelText, // Use the processed label text
      // Apply hintText: Use provided 'hintText' if not null, otherwise keep existing from base/theme.
      hintText: hintText ?? baseDecoration.hintText,
      // Apply fixFloatingLabel: Only set if not already defined in baseDecoration.
      floatingLabelBehavior:
          fixFloatingLabel && baseDecoration.floatingLabelBehavior == null
              ? FloatingLabelBehavior.always
              : baseDecoration.floatingLabelBehavior, // Keep existing otherwise
    );
    // Readonly also disables the field visually
    if (readOnly) {
      final inputTheme = theme.inputDecorationTheme;
      baseDecoration = baseDecoration.copyWith(
        border: inputTheme.disabledBorder,
        focusedBorder: inputTheme.disabledBorder,
        enabledBorder: inputTheme.disabledBorder,
      );
    }

    // Adjust labelStyle for disabled state
    if (enabled == false || readOnly) {
      if (decoration?.labelStyle != null) {
        baseDecoration = baseDecoration.copyWith(
          labelStyle: decoration?.labelStyle?.copyWith(
            color: Colors.grey.shade600,
          ),
        );
      } else {
        // If no custom labelStyle is provided, use the theme's disabled style
        baseDecoration = baseDecoration.copyWith(
          labelStyle: theme.inputDecorationTheme.labelStyle?.copyWith(
            color: Colors.grey.shade600,
          ),
        );
      }
    }

    // Add empty Helpertext to keep space for errortext
    if (requiredField || validator != null) {
      baseDecoration = baseDecoration.copyWith(
        helperText: '',
      );
    }

    // Return the final decoration
    return baseDecoration;
  }
}
