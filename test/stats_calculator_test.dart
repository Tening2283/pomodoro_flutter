import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_flutter/models/session.dart';
import 'package:pomodoro_flutter/models/session_type.dart';
import 'package:pomodoro_flutter/services/stats_calculator.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  PomodoroSession work(DateTime date, {int minutes = 25}) => PomodoroSession(
      task: 'Tache', date: date, durationMinutes: minutes, type: SessionType.work);

  PomodoroSession pause(DateTime date) => PomodoroSession(
      task: 'Pause', date: date, durationMinutes: 5, type: SessionType.shortBreak);

  group('StatsCalculator.summarize', () {
    test('retourne des zeros sans session', () {
      final s = StatsCalculator.summarize([], now: now);
      expect(s.totalCount, 0);
      expect(s.todayMinutes, 0);
      expect(s.averagePerDay, 0);
    });

    test('compte les sessions du jour et ignore les pauses', () {
      final s = StatsCalculator.summarize(
        [work(now), work(now), pause(now)],
        now: now,
      );
      expect(s.todayCount, 2);
      expect(s.totalCount, 2); // la pause n'est pas un pomodoro
      expect(s.todayMinutes, 50);
    });

    test('additionne les durees reelles (et non 25 en dur)', () {
      final s = StatsCalculator.summarize(
        [work(now, minutes: 30), work(now, minutes: 10)],
        now: now,
      );
      expect(s.totalMinutes, 40);
    });

    test('calcule la fenetre de 7 jours', () {
      final s = StatsCalculator.summarize(
        [
          work(now),
          work(now.subtract(const Duration(days: 6))), // dans la semaine
          work(now.subtract(const Duration(days: 8))), // hors semaine
        ],
        now: now,
      );
      expect(s.weekCount, 2);
      expect(s.totalCount, 3);
    });

    test('calcule la moyenne quotidienne', () {
      final s = StatsCalculator.summarize(
        [work(now), work(now.subtract(const Duration(days: 1)))],
        now: now,
      );
      // 2 sessions sur 2 jours => 1.0 / jour
      expect(s.averagePerDay, 1.0);
    });
  });

  group('StatsCalculator.weeklyCounts', () {
    test('place les sessions au bon index (6 = aujourd\'hui)', () {
      final counts = StatsCalculator.weeklyCounts(
        [work(now), work(now.subtract(const Duration(days: 3)))],
        now: now,
      );
      expect(counts.length, 7);
      expect(counts[6], 1);
      expect(counts[3], 1);
      expect(counts.reduce((a, b) => a + b), 2);
    });
  });

  group('StatsCalculator.recent', () {
    test('trie du plus recent au plus ancien et limite', () {
      final sessions = [
        work(now.subtract(const Duration(days: 2))),
        work(now),
        work(now.subtract(const Duration(days: 1))),
      ];
      final recent = StatsCalculator.recent(sessions, limit: 2);
      expect(recent.length, 2);
      expect(recent.first.date, now);
    });
  });
}
