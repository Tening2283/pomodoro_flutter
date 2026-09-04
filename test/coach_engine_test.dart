import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_flutter/services/coach_engine.dart';
import 'package:pomodoro_flutter/services/stats_calculator.dart';

void main() {
  const engine = CoachEngine();

  test('repond a une demande de planification', () {
    final r = engine.respond('Comment planifier ma journee ?', StatsSummary.empty);
    expect(r.toLowerCase(), contains('journée'));
  });

  test('personnalise la reponse stats avec le nombre du jour', () {
    const summary = StatsSummary(
      todayCount: 5,
      weekCount: 5,
      totalCount: 5,
      todayMinutes: 125,
      weekMinutes: 125,
      totalMinutes: 125,
      averagePerDay: 5,
    );
    final r = engine.respond('montre mes stats', summary);
    expect(r, contains('5 pomodoros'));
    expect(r, contains('125 minutes'));
  });

  test('retourne un message d\'aide par defaut', () {
    final r = engine.respond('blabla inconnu', StatsSummary.empty);
    expect(r.toLowerCase(), contains('aider'));
  });
}
