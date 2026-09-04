import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Persistance des reglages de l'application.
class SettingsRepository {
  static const String _key = 'app_settings';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  AppSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
