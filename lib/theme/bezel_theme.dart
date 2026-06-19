import 'package:flutter/material.dart';
import 'bezel_palette.dart';
import 'bezel_type.dart';

class BezelTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BezelPalette.amber,
      primary: BezelPalette.amber,
      secondary: BezelPalette.green,
      surface: BezelPalette.panel,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BezelPalette.base,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: BezelPalette.engrave,
      ),
      cardTheme: CardThemeData(
        color: BezelPalette.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BezelPalette.hairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BezelPalette.baseDeep,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: BezelType.body(color: BezelPalette.engraveFaint),
        border: _border(BezelPalette.hairline),
        enabledBorder: _border(BezelPalette.hairline),
        focusedBorder: _border(BezelPalette.amber),
        errorBorder: _border(BezelPalette.alert),
        focusedErrorBorder: _border(BezelPalette.alert),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BezelPalette.panelRaised,
        contentTextStyle: BezelType.bodyStrong(color: BezelPalette.engrave),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: 1.3),
      );
}
