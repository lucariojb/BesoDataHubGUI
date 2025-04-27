import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

ThemeData get themeData => _themeData;

//Constants
const double borderRadius = 8;
const double borderWidth = 1;

final ColorScheme _colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFFC00017),
  primary: const Color(0xFFC00017),
  surface: const Color(0xFF003334),
  primaryContainer: const Color(0xFFD3D3D3),
  error: const Color(0xFFF57C00),
  surfaceTint: Colors.transparent,
  brightness: Brightness.light,
);

const String fontfamily = 'Calibri';
final TextTheme _textTheme = TextTheme(
  bodySmall: TextStyle(
    fontFamily: fontfamily,
    color: _colorScheme.onPrimaryContainer,
    fontSize: 2.0.sp,
  ),
  bodyMedium: TextStyle(
    fontFamily: fontfamily,
    color: _colorScheme.onPrimaryContainer,
    fontSize: 2.5.sp,
  ),
  headlineMedium: TextStyle(
    fontFamily: fontfamily,
    color: _colorScheme.primary,
    fontSize: 3.5.sp,
    fontWeight: FontWeight.bold,
  ),
  labelMedium: TextStyle(
    fontFamily: fontfamily,
    color: _colorScheme.primary,
    fontSize: 2.5.sp,
  ),
);

final ExpansionTileThemeData expansionTileTheme = ExpansionTileThemeData(
  // --- Colors (using the theme's colorScheme) ---
  backgroundColor: _colorScheme.primaryContainer, // Your previous default
  collapsedBackgroundColor:
      _colorScheme.primaryContainer, // Your previous default
  textColor: _colorScheme.onSurface, // Your previous default text color
  collapsedTextColor:
      _colorScheme.onSurface, // Your previous default collapsed text color
  iconColor: _colorScheme.primary, // Your previous default icon color
  collapsedIconColor:
      _colorScheme.primary, // Your previous default collapsed icon color

  // --- Shapes (copied from your previous MyExpansionTile) ---
  shape: RoundedRectangleBorder(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(16),
    ),
    // Use the theme's outline color
    side: BorderSide(
        style: BorderStyle.solid, color: _colorScheme.outline, width: 1),
  ),
  collapsedShape: RoundedRectangleBorder(
    // Keep identical if that was the intent
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(16),
    ),
    // Use the theme's outline color
    side: BorderSide(
        style: BorderStyle.solid, color: _colorScheme.outline, width: 1),
  ),

  // --- Optional: Define default padding if desired ---
  // tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  // childrenPadding: EdgeInsets.symmetric(vertical: 8.0),
);

//Input Decoration
final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
  //Color
  filled: true,
  fillColor: _colorScheme.primaryContainer,
  //Borders
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(
      color: _colorScheme.outline,
      width: borderWidth,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(
      color: _colorScheme.primary,
      width: borderWidth * 2,
    ),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(
      color: _colorScheme.outline.withAlpha(100),
      width: borderWidth,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(
      color: _colorScheme.error,
      width: borderWidth * 2,
    ),
  ),
  //Label
  labelStyle: TextStyle(
    fontFamily: fontfamily,
    color: _colorScheme.primary,
    fontSize: 2.5.sp,
  ),
  //Error Message
  errorMaxLines: 1,
  helperMaxLines: 1,
);

final ThemeData _themeData = ThemeData(
  colorScheme: _colorScheme,
  textTheme: _textTheme,
  inputDecorationTheme: _inputDecorationTheme,
  expansionTileTheme: expansionTileTheme,
  useMaterial3: true,
);
