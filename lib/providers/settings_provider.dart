import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_repository.dart';

/// Expose et met a jour les [AppSettings], en persistant chaque changement.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  AppSettings _settings;

  SettingsProvider(this._repository) : _settings = _repository.load();

  AppSettings get settings => _settings;

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.save(next);
  }

  Future<void> setWorkMinutes(int value) =>
      _update(_settings.copyWith(workMinutes: value.clamp(1, 120)));

  Future<void> setShortBreakMinutes(int value) =>
      _update(_settings.copyWith(shortBreakMinutes: value.clamp(1, 60)));

  Future<void> setLongBreakMinutes(int value) =>
      _update(_settings.copyWith(longBreakMinutes: value.clamp(1, 60)));

  Future<void> setLongBreakInterval(int value) =>
      _update(_settings.copyWith(longBreakInterval: value.clamp(2, 8)));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  Future<void> setTextScale(double value) => _update(_settings.copyWith(
        textScale: value.clamp(AppSettings.minTextScale, AppSettings.maxTextScale),
      ));

  Future<void> setHighContrast(bool value) =>
      _update(_settings.copyWith(highContrast: value));

  Future<void> setFeedbackEnabled(bool value) =>
      _update(_settings.copyWith(feedbackEnabled: value));
}
