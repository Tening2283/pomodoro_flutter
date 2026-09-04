import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_flutter/models/app_settings.dart';
import 'package:pomodoro_flutter/models/session.dart';
import 'package:pomodoro_flutter/models/session_type.dart';
import 'package:pomodoro_flutter/providers/timer_provider.dart';

void main() {
  // Les timers crees dans une zone testWidgets sont simules : `tester.pump`
  // avance l'horloge et declenche les ticks. Pas besoin de vrai delai.

  TimerProvider build(List<PomodoroSession> sink,
          {AppSettings settings = const AppSettings(workMinutes: 1)}) =>
      TimerProvider(
        settings: settings,
        recordSession: (s) async => sink.add(s),
        onFeedback: null,
      );

  testWidgets('decompte a chaque seconde', (tester) async {
    final recorded = <PomodoroSession>[];
    final timer = build(recorded);
    await tester.pumpWidget(const SizedBox());

    expect(timer.secondsRemaining, 60);
    timer.start();
    await tester.pump(const Duration(seconds: 3));
    expect(timer.secondsRemaining, 57);
    timer.dispose();
  });

  testWidgets('enregistre la session de travail terminee et passe en pause',
      (tester) async {
    final recorded = <PomodoroSession>[];
    final timer = build(recorded);
    await tester.pumpWidget(const SizedBox());

    timer.setCurrentTask('Ecrire les tests');
    timer.start();
    await tester.pump(const Duration(seconds: 60));

    expect(recorded.length, 1);
    expect(recorded.first.task, 'Ecrire les tests');
    expect(recorded.first.type, SessionType.work);
    expect(timer.type, SessionType.shortBreak);
    expect(timer.completedWorkSessions, 1);
    expect(timer.isRunning, isFalse);
    timer.dispose();
  });

  testWidgets('pause longue apres l\'intervalle configure', (tester) async {
    final recorded = <PomodoroSession>[];
    final timer = build(
      recorded,
      settings: const AppSettings(workMinutes: 1, longBreakInterval: 2),
    );
    await tester.pumpWidget(const SizedBox());

    // 1ere session de travail -> pause courte
    timer.start();
    await tester.pump(const Duration(seconds: 60));
    expect(timer.type, SessionType.shortBreak);

    // passe la pause, 2eme session de travail -> pause longue
    timer.skip();
    expect(timer.type, SessionType.work);
    timer.start();
    await tester.pump(const Duration(seconds: 60));
    expect(timer.type, SessionType.longBreak);
    timer.dispose();
  });

  testWidgets('reset remet la duree complete', (tester) async {
    final recorded = <PomodoroSession>[];
    final timer = build(recorded);
    await tester.pumpWidget(const SizedBox());

    timer.start();
    await tester.pump(const Duration(seconds: 10));
    expect(timer.secondsRemaining, 50);
    timer.reset();
    expect(timer.secondsRemaining, 60);
    expect(timer.isRunning, isFalse);
    timer.dispose();
  });

  testWidgets('ne compte pas la pause comme un pomodoro', (tester) async {
    final recorded = <PomodoroSession>[];
    final timer = build(
      recorded,
      settings: const AppSettings(workMinutes: 1, shortBreakMinutes: 1),
    );
    await tester.pumpWidget(const SizedBox());

    // termine le travail (1 enregistrement) puis la pause (aucun ajout)
    timer.start();
    await tester.pump(const Duration(seconds: 60)); // travail
    timer.start();
    await tester.pump(const Duration(seconds: 60)); // pause courte
    expect(recorded.length, 1);
    expect(timer.type, SessionType.work);
    timer.dispose();
  });
}
