import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';

/// Persistance des sessions Pomodoro.
///
/// Utilise [SharedPreferences] (localStorage sur le web/PWA), ce qui garantit
/// que l'historique survit au redemarrage et reste disponible hors-ligne.
class StatsRepository {
  static const String _key = 'pomodoro_sessions';

  final SharedPreferences _prefs;

  StatsRepository(this._prefs);

  /// Fabrique asynchrone pour l'usage applicatif normal.
  static Future<StatsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StatsRepository(prefs);
  }

  List<PomodoroSession> loadSessions() {
    final raw = _prefs.getStringList(_key);
    if (raw == null) return [];
    final sessions = <PomodoroSession>[];
    for (final entry in raw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        sessions.add(PomodoroSession.fromJson(map));
      } catch (_) {
        // On ignore une entree corrompue plutot que de tout perdre.
      }
    }
    return sessions;
  }

  Future<void> saveSessions(List<PomodoroSession> sessions) async {
    final raw = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_key, raw);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
