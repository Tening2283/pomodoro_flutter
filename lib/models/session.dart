import 'session_type.dart';

/// Une session Pomodoro terminee (travail ou pause).
///
/// Objet immuable, serialisable en JSON pour la persistance locale.
class PomodoroSession {
  final String task;
  final DateTime date;
  final int durationMinutes;
  final SessionType type;

  const PomodoroSession({
    required this.task,
    required this.date,
    required this.durationMinutes,
    this.type = SessionType.work,
  });

  Map<String, dynamic> toJson() => {
        'task': task,
        'date': date.toIso8601String(),
        'duration': durationMinutes,
        'type': type.storageKey,
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      task: (json['task'] as String?)?.trim().isNotEmpty == true
          ? json['task'] as String
          : 'Tache sans nom',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      // Retro-compatibilite : les anciennes sessions n'avaient pas de duree.
      durationMinutes: (json['duration'] as num?)?.round() ?? 25,
      type: SessionType.fromStorageKey(json['type'] as String?),
    );
  }

  @override
  String toString() =>
      'PomodoroSession(task: $task, date: $date, duration: $durationMinutes, type: ${type.name})';
}
