// Smoke test : verifie que l'application se construit et affiche le minuteur.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pomodoro_flutter/main.dart';
import 'package:pomodoro_flutter/services/settings_repository.dart';
import 'package:pomodoro_flutter/services/stats_repository.dart';

void main() {
  testWidgets('L\'app demarre et affiche le minuteur a 25:00', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsRepo = await SettingsRepository.create();
    final statsRepo = await StatsRepository.create();

    await tester.pumpWidget(
      PomodoroApp(settingsRepo: settingsRepo, statsRepo: statsRepo),
    );
    await tester.pumpAndSettle();

    // Le minuteur de travail par defaut affiche 25:00.
    expect(find.text('25:00'), findsOneWidget);
    // La barre de navigation contient les 4 onglets.
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Réglages'), findsOneWidget);
  });

  testWidgets('Navigation vers l\'onglet Statistiques', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsRepo = await SettingsRepository.create();
    final statsRepo = await StatsRepository.create();

    await tester.pumpWidget(
      PomodoroApp(settingsRepo: settingsRepo, statsRepo: statsRepo),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();

    expect(find.text('Progression cette semaine'), findsOneWidget);
    expect(find.text('Aucune session enregistrée'), findsOneWidget);
  });
}
