import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_flutter/models/session.dart';
import 'package:pomodoro_flutter/models/session_type.dart';

void main() {
  group('PomodoroSession serialisation', () {
    test('aller-retour JSON conserve les donnees', () {
      final original = PomodoroSession(
        task: 'Rediger le rapport',
        date: DateTime(2026, 9, 3, 14, 30),
        durationMinutes: 30,
        type: SessionType.work,
      );
      final restored = PomodoroSession.fromJson(original.toJson());
      expect(restored.task, original.task);
      expect(restored.date, original.date);
      expect(restored.durationMinutes, 30);
      expect(restored.type, SessionType.work);
    });

    test('applique des valeurs par defaut sur un JSON ancien/incomplet', () {
      final restored = PomodoroSession.fromJson({
        'date': DateTime(2026, 1, 1).toIso8601String(),
      });
      expect(restored.durationMinutes, 25); // retro-compatibilite
      expect(restored.type, SessionType.work);
      expect(restored.task, 'Tache sans nom');
    });
  });
}
