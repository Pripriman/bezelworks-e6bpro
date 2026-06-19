import 'package:flutter/material.dart';
import 'bezel_palette.dart';

class BezelType {
  static TextStyle _t(
    FontWeight weight,
    double size, {
    double? height,
    double? spacing,
    Color? color,
  }) {
    return TextStyle(
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color ?? BezelPalette.engrave,
    );
  }

  static TextStyle display({Color? color}) =>
      _t(FontWeight.w700, 27, height: 1.1, spacing: 1.2, color: color);
  static TextStyle title({Color? color}) =>
      _t(FontWeight.w700, 21, height: 1.16, spacing: 0.6, color: color);
  static TextStyle heading({Color? color}) =>
      _t(FontWeight.w600, 16, height: 1.2, spacing: 0.4, color: color);
  static TextStyle body({Color? color}) => _t(FontWeight.w400, 14.5,
      height: 1.44, color: color ?? BezelPalette.engraveSoft);
  static TextStyle bodyStrong({Color? color}) =>
      _t(FontWeight.w600, 14.5, height: 1.44, color: color);
  static TextStyle label({Color? color}) => _t(FontWeight.w700, 11.5,
      spacing: 1.6, color: color ?? BezelPalette.engraveFaint);
  static TextStyle caption({Color? color}) => _t(FontWeight.w500, 11.5,
      spacing: 0.6, color: color ?? BezelPalette.engraveFaint);

  static TextStyle readout(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: weight ?? FontWeight.w700,
        fontSize: size,
        height: 1.0,
        letterSpacing: 1.0,
        color: color ?? BezelPalette.engrave,
      );

  static TextStyle engraved(double size, {Color? color, double spacing = 2.4}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: 1.0,
        letterSpacing: spacing,
        color: color ?? BezelPalette.brushedLight,
      );
}
