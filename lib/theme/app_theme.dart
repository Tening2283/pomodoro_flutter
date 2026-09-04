import 'package:flutter/material.dart';

/// Definitions de themes de l'application.
///
/// Fournit un theme clair, un theme sombre et des variantes "contraste eleve"
/// pour l'accessibilite (critere explicite du projet).
class AppTheme {
  const AppTheme._();

  static const Color _seed = Colors.deepPurple;

  static ThemeData light({bool highContrast = false}) => _build(
        Brightness.light,
        highContrast: highContrast,
      );

  static ThemeData dark({bool highContrast = false}) => _build(
        Brightness.dark,
        highContrast: highContrast,
      );

  static ThemeData _build(Brightness brightness, {required bool highContrast}) {
    final ColorScheme scheme = highContrast
        ? (brightness == Brightness.light
            ? const ColorScheme.highContrastLight(
                primary: Color(0xFF3A0CA3),
                secondary: Color(0xFF1B4332),
              )
            : const ColorScheme.highContrastDark(
                primary: Color(0xFFD0BCFF),
                secondary: Color(0xFF95D5B2),
              ))
        : ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: highContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highContrast
              ? BorderSide(color: scheme.outline, width: 1.5)
              : BorderSide.none,
        ),
      ),
      // Cibles tactiles conformes aux recommandations d'accessibilite.
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
