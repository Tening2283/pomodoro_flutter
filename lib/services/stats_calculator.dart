import 'dart:math';

import '../models/session.dart';
import '../models/session_type.dart';

/// Resultat agrege des statistiques de focus.
class StatsSummary {
  final int todayCount;
  final int weekCount;
  final int totalCount;
  final int todayMinutes;
  final int weekMinutes;
  final int totalMinutes;
  final double averagePerDay;

  const StatsSummary({
    required this.todayCount,
    required this.weekCount,
    required this.totalCount,
    required this.todayMinutes,
    required this.weekMinutes,
    required this.totalMinutes,
    required this.averagePerDay,
  });

  static const empty = StatsSummary(
    todayCount: 0,
    weekCount: 0,
    totalCount: 0,
    todayMinutes: 0,
    weekMinutes: 0,
    totalMinutes: 0,
    averagePerDay: 0,
  );
}

/// Fonctions pures de calcul des statistiques.
///
/// Volontairement sans dependance a Flutter afin d'etre couvertes par des
/// tests unitaires rapides. Seules les sessions de travail sont comptees comme
/// "pomodoros" ; les pauses ne le sont pas.
class StatsCalculator {
  const StatsCalculator._();

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dayOf(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Calcule le resume. [now] est injectable pour rendre les tests deterministes.
  static StatsSummary summarize(List<PomodoroSession> sessions, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = _dayOf(reference);
    final weekStart = today.subtract(const Duration(days: 6));

    final work = sessions.where((s) => s.type == SessionType.work).toList();

    int todayCount = 0, weekCount = 0;
    int todayMinutes = 0, weekMinutes = 0, totalMinutes = 0;

    for (final s in work) {
      final day = _dayOf(s.date);
      totalMinutes += s.durationMinutes;

      if (_isSameDay(day, today)) {
        todayCount++;
        todayMinutes += s.durationMinutes;
      }
      if (!day.isBefore(weekStart) && !day.isAfter(today)) {
        weekCount++;
        weekMinutes += s.durationMinutes;
      }
    }

    double averagePerDay = 0;
    if (work.isNotEmpty) {
      final oldest = _dayOf(
        work.map((s) => s.date).reduce((a, b) => a.isBefore(b) ? a : b),
      );
      final spanDays = today.difference(oldest).inDays + 1;
      averagePerDay = work.length / max(1, spanDays);
    }

    return StatsSummary(
      todayCount: todayCount,
      weekCount: weekCount,
      totalCount: work.length,
      todayMinutes: todayMinutes,
      weekMinutes: weekMinutes,
      totalMinutes: totalMinutes,
      averagePerDay: averagePerDay,
    );
  }

  /// Nombre de pomodoros par jour sur les 7 derniers jours (index 0 = il y a 6
  /// jours, index 6 = aujourd'hui).
  static List<int> weeklyCounts(List<PomodoroSession> sessions, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = _dayOf(reference);
    final result = List<int>.filled(7, 0);

    for (final s in sessions) {
      if (s.type != SessionType.work) continue;
      final diff = today.difference(_dayOf(s.date)).inDays;
      if (diff >= 0 && diff < 7) {
        result[6 - diff] += 1;
      }
    }
    return result;
  }

  /// Sessions les plus recentes en premier.
  static List<PomodoroSession> recent(List<PomodoroSession> sessions, {int limit = 10}) {
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}
