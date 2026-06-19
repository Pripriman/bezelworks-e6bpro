import 'package:flutter/material.dart';

class BezelPalette {
  static const Color base = Color(0xFF1B1E22);
  static const Color baseDeep = Color(0xFF141619);
  static const Color panel = Color(0xFF24282D);
  static const Color panelRaised = Color(0xFF2E333A);
  static const Color hairline = Color(0xFF3C424A);

  static const Color brushed = Color(0xFF9DA4AC);
  static const Color brushedLight = Color(0xFFC7CDD4);
  static const Color brushedDark = Color(0xFF6A7079);

  static const Color engrave = Color(0xFFEDEFF2);
  static const Color engraveSoft = Color(0xFFB4BAC2);
  static const Color engraveFaint = Color(0xFF7C828B);

  static const Color amber = Color(0xFFE7A33E);
  static const Color amberDeep = Color(0xFFC8801A);
  static const Color amberWash = Color(0xFF332514);

  static const Color green = Color(0xFF54C98A);
  static const Color greenDeep = Color(0xFF2E9E66);
  static const Color greenWash = Color(0xFF13271D);

  static const Color cyan = Color(0xFF49B6C9);
  static const Color alert = Color(0xFFD9554C);
  static const Color alertWash = Color(0xFF2E1714);

  static const LinearGradient brushedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF31363D), Color(0xFF1E2126)],
  );

  static const LinearGradient dialGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB7BEC6), Color(0xFF7C838C)],
  );

  static const LinearGradient consoleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1F23), Color(0xFF101214)],
  );
}
