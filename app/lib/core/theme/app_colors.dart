import 'package:flutter/material.dart';

/// Warm paper journal palette — light & dark variants
class AppColors {
  AppColors._();

  // ── Light (Parchment) ──────────────────────────────────────
  static const Color bgLight = Color(0xFFF5EFE0);         // warm cream
  static const Color surfaceLight = Color(0xFFFBF8F1);    // near-white cream
  static const Color surfaceAltLight = Color(0xFFF0E9D5); // slightly deeper cream
  static const Color inkDarkLight = Color(0xFF2C1A10);    // deep ink-brown (primary text)
  static const Color inkMedLight = Color(0xFF7A5C3E);     // warm brown (secondary text)
  static const Color inkLightLight = Color(0xFFB09878);   // pale ochre (hint text)
  static const Color ruleLineLight = Color(0xFFDDD0B4);   // notebook rule line
  static const Color dividerLight = Color(0xFFCCC0A0);    // divider
  static const Color accentLight = Color(0xFF8B4A1E);     // wax-seal sienna
  static const Color goldLight = Color(0xFFBF932A);       // antique gold
  static const Color planColorLight = Color(0xFF3F6B8A);  // dusty ink-blue (plan)
  static const Color actualColorLight = Color(0xFF4A7A5A);// sage green (actual)
  static const Color priorityALight = Color(0xFFC24B3D);  // warm red
  static const Color priorityBLight = Color(0xFFB87A2A);  // amber
  static const Color priorityCLight = Color(0xFF5A7A5A);  // sage

  // ── Dark (Aged Wood) ───────────────────────────────────────
  static const Color bgDark = Color(0xFF1C1410);          // dark burnt wood
  static const Color surfaceDark = Color(0xFF262018);     // dark warm surface
  static const Color surfaceAltDark = Color(0xFF312920);  // slightly lighter
  static const Color inkDarkDark = Color(0xFFEDE3CC);     // parchment text
  static const Color inkMedDark = Color(0xFFBDA880);      // warm tan
  static const Color inkLightDark = Color(0xFF8A7560);    // muted ochre
  static const Color ruleLineDark = Color(0xFF3D3025);    // dark rule line
  static const Color dividerDark = Color(0xFF4A3C2C);     // dark divider
  static const Color accentDark = Color(0xFFCB7A3E);      // warm copper
  static const Color goldDark = Color(0xFFD4A84A);        // warm gold
  static const Color planColorDark = Color(0xFF5B8FB0);   // softer blue
  static const Color actualColorDark = Color(0xFF6BA87A); // softer sage
  static const Color priorityADark = Color(0xFFD4665A);
  static const Color priorityBDark = Color(0xFFCCA050);
  static const Color priorityCDark = Color(0xFF7AB07A);

  // ── Priority labels (theme-agnostic helper) ────────────────
  static Color priorityColor(String p, bool dark) {
    switch (p) {
      case 'A':
        return dark ? priorityADark : priorityALight;
      case 'B':
        return dark ? priorityBDark : priorityBLight;
      case 'C':
        return dark ? priorityCDark : priorityCLight;
      default:
        return dark ? inkLightDark : inkLightLight;
    }
  }
}
