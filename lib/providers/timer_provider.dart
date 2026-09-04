import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/session.dart';
import '../models/session_type.dart';

/// Callback declenche a la fin d'une session pour l'enregistrer.
typedef SessionRecorder = Future<void> Function(PomodoroSession session);

/// Retour utilisateur (son / vibration) a la fin d'une session.
/// Injectable pour permettre des tests sans dependance materielle.
typedef FeedbackCallback = void Function();

/// Gere le cycle du minuteur Pomodoro : decompte, transitions travail/pause,
/// et enregistrement des sessions terminees.
///
/// La logique est isolee de l'UI (aucun import Flutter/material) afin de
/// pouvoir etre pilotee dans les tests avec `fake_async`.
class TimerProvider extends ChangeNotifier {
  AppSettings _settings;
  SessionRecorder _recordSession;
  final FeedbackCallback? _onFeedback;

  Timer? _timer;
  SessionType _type = SessionType.work;
  late int _secondsRemaining;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  int _completedWorkSessions = 0;
  String _currentTask = '';

  /// Incremente a chaque fin de session : l'UI l'observe pour notifier.
  int completionTick = 0;
  String completionMessage = '';

  TimerProvider({
    required AppSettings settings,
    required SessionRecorder recordSession,
    FeedbackCallback? onFeedback,
  })  : _settings = settings,
        _recordSession = recordSession,
        _onFeedback = onFeedback {
    _secondsRemaining = _durationSecondsFor(_type);
  }

  // --- Getters exposes a l'UI ---
  SessionType get type => _type;
  bool get isRunning => _isRunning;
  int get secondsRemaining => _secondsRemaining;
  int get completedWorkSessions => _completedWorkSessions;
  String get currentTask => _currentTask;

  int get _totalSecondsForCurrent => _durationSecondsFor(_type);

  double get progress {
    final total = _totalSecondsForCurrent;
    if (total <= 0) return 0;
    return (1 - _secondsRemaining / total).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Description accessible du temps restant (pour les lecteurs d'ecran).
  String get accessibleTimeLabel {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes minutes et $seconds secondes restantes, ${_type.label}';
  }

  int _durationSecondsFor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return _settings.workMinutes * 60;
      case SessionType.shortBreak:
        return _settings.shortBreakMinutes * 60;
      case SessionType.longBreak:
        return _settings.longBreakMinutes * 60;
    }
  }

  /// Reinjecte les reglages courants (appele par le ProxyProvider pendant le
  /// build : on ne notifie donc PAS ici pour eviter une exception "modification
  /// pendant la construction du widget"). Le rafraichissement se fait au prochain
  /// rebuild (ex. changement d'onglet). Si le minuteur est a l'arret et n'a pas
  /// demarre, on synchronise le temps affiche avec la nouvelle duree configuree.
  void updateSettings(AppSettings settings) {
    _settings = settings;
    if (!_isRunning && _elapsedSeconds == 0) {
      _secondsRemaining = _durationSecondsFor(_type);
    }
  }

  /// Reinjecte l'enregistreur de session (appele par le ProxyProvider).
  void updateRecorder(SessionRecorder recorder) {
    _recordSession = recorder;
  }

  void setCurrentTask(String task) {
    _currentTask = task.trim();
    notifyListeners();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _elapsedSeconds = 0;
    _secondsRemaining = _durationSecondsFor(_type);
    notifyListeners();
  }

  /// Passe a la session suivante sans l'enregistrer (bouton "Passer").
  void skip() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _elapsedSeconds = 0;
    _advanceToNextSession(record: false);
    notifyListeners();
  }

  void _tick() {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      _elapsedSeconds++;
      if (_secondsRemaining == 0) {
        _complete();
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> _complete() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_settings.feedbackEnabled) {
      _onFeedback?.call();
    }
    await _advanceToNextSession(record: true);
    notifyListeners();
  }

  Future<void> _advanceToNextSession({required bool record}) async {
    if (_type == SessionType.work) {
      if (record) {
        final minutes = (_elapsedSeconds / 60).round().clamp(1, 1 << 30);
        await _recordSession(PomodoroSession(
          task: _currentTask.isEmpty ? 'Tache sans nom' : _currentTask,
          date: DateTime.now(),
          durationMinutes: minutes,
          type: SessionType.work,
        ));
        _completedWorkSessions++;
        completionMessage = 'Session terminee ! Temps de faire une pause.';
      }
      // Determine la prochaine pause.
      final needsLongBreak = _completedWorkSessions > 0 &&
          _completedWorkSessions % _settings.longBreakInterval == 0;
      _type = needsLongBreak ? SessionType.longBreak : SessionType.shortBreak;
    } else {
      if (record) {
        completionMessage = 'Pause terminee ! Pret pour une nouvelle session ?';
      }
      _type = SessionType.work;
    }

    _elapsedSeconds = 0;
    _secondsRemaining = _durationSecondsFor(_type);
    if (record) {
      completionTick++;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
