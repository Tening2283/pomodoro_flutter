import 'package:flutter/material.dart';

/// Reglages de l'application, persistes localement.
///
/// Regroupe la configuration du minuteur, du theme et de l'accessibilite
/// (taille de police, contraste eleve) demandee dans les criteres du projet.
@immutable
class AppSettings {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  /// Nombre de sessions de travail avant une pause longue.
  final int longBreakInterval;

  final ThemeMode themeMode;

  /// Facteur d'echelle du texte (accessibilite). 1.0 = normal.
  final double textScale;

  /// Mode contraste eleve (accessibilite).
  final bool highContrast;

  /// Retour sonore / haptique a la fin d'une session.
  final bool feedbackEnabled;

  const AppSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.highContrast = false,
    this.feedbackEnabled = true,
  });

  static const double minTextScale = 0.8;
  static const double maxTextScale = 1.6;

  AppSettings copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    ThemeMode? themeMode,
    double? textScale,
    bool? highContrast,
    bool? feedbackEnabled,
  }) {
    return AppSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      feedbackEnabled: feedbackEnabled ?? this.feedbackEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'workMinutes': workMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'longBreakInterval': longBreakInterval,
        'themeMode': themeMode.name,
        'textScale': textScale,
        'highContrast': highContrast,
        'feedbackEnabled': feedbackEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      workMinutes: (json['workMinutes'] as num?)?.toInt() ?? 25,
      shortBreakMinutes: (json['shortBreakMinutes'] as num?)?.toInt() ?? 5,
      longBreakMinutes: (json['longBreakMinutes'] as num?)?.toInt() ?? 15,
      longBreakInterval: (json['longBreakInterval'] as num?)?.toInt() ?? 4,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      feedbackEnabled: json['feedbackEnabled'] as bool? ?? true,
    );
  }
}
