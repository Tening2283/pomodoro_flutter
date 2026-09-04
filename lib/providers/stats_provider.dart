import 'package:flutter/foundation.dart';

import '../models/session.dart';
import '../services/stats_calculator.dart';
import '../services/stats_repository.dart';

/// Source de verite reactive pour l'historique des sessions et les statistiques.
///
/// L'ecran Statistiques `watch`e ce provider : il se met a jour en temps reel
/// des qu'une session est ajoutee (corrige l'ancien bug ou les stats ne se
/// rafraichissaient qu'au changement d'onglet).
class StatsProvider extends ChangeNotifier {
  final StatsRepository _repository;
  List<PomodoroSession> _sessions;

  StatsProvider(this._repository) : _sessions = _repository.loadSessions();

  List<PomodoroSession> get sessions => List.unmodifiable(_sessions);

  StatsSummary get summary => StatsCalculator.summarize(_sessions);

  List<int> get weeklyCounts => StatsCalculator.weeklyCounts(_sessions);

  List<PomodoroSession> recent({int limit = 10}) =>
      StatsCalculator.recent(_sessions, limit: limit);

  Future<void> addSession(PomodoroSession session) async {
    _sessions = [..._sessions, session];
    notifyListeners();
    await _repository.saveSessions(_sessions);
  }

  Future<void> clearAll() async {
    _sessions = [];
    notifyListeners();
    await _repository.clear();
  }
}
