import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/session_type.dart';
import '../providers/timer_provider.dart';

/// Ecran principal du minuteur Pomodoro.
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final TextEditingController _taskController = TextEditingController();
  late TimerProvider _timer;
  int _lastCompletionTick = 0;

  @override
  void initState() {
    super.initState();
    _timer = context.read<TimerProvider>();
    _lastCompletionTick = _timer.completionTick;
    _timer.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimerChanged);
    _taskController.dispose();
    super.dispose();
  }

  /// Affiche une notification quand une session vient de se terminer.
  void _onTimerChanged() {
    if (_timer.completionTick != _lastCompletionTick) {
      _lastCompletionTick = _timer.completionTick;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(_timer.completionMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ));
    }
  }

  void _toggleTimer() {
    if (_timer.isRunning) {
      _timer.pause();
    } else {
      _timer.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timer = context.watch<TimerProvider>();
    final isWork = timer.type == SessionType.work;
    final accent =
        isWork ? theme.colorScheme.primary : theme.colorScheme.tertiary;

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      // Raccourcis clavier (accessibilite / navigation clavier) :
      // Espace = demarrer/pause, R = reinitialiser.
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): _toggleTimer,
          const SingleActivator(LogicalKeyboardKey.keyR): _timer.reset,
        },
        child: Focus(
          autofocus: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _SessionBadge(type: timer.type, accent: accent),
                const SizedBox(height: 40),
                _TimerDial(
                  progress: timer.progress,
                  time: timer.formattedTime,
                  accent: accent,
                  completedPomodoros: timer.completedWorkSessions,
                  semanticsLabel: timer.accessibleTimeLabel,
                ),
                const SizedBox(height: 50),
                _TaskField(
                  controller: _taskController,
                  currentTask: timer.currentTask,
                  isRunning: timer.isRunning,
                  onSubmit: (v) => timer.setCurrentTask(v),
                  onEdit: () {
                    _taskController.text = timer.currentTask;
                    timer.setCurrentTask('');
                  },
                ),
                const SizedBox(height: 30),
                _Controls(
                  isRunning: timer.isRunning,
                  onToggle: _toggleTimer,
                  onReset: timer.reset,
                  onSkip: timer.skip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionBadge extends StatelessWidget {
  final SessionType type;
  final Color accent;
  const _SessionBadge({required this.type, required this.accent});

  @override
  Widget build(BuildContext context) {
    final emoji = type == SessionType.work ? '🎯' : '☕';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji ${type.label}',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  final double progress;
  final String time;
  final Color accent;
  final int completedPomodoros;
  final String semanticsLabel;

  const _TimerDial({
    required this.progress,
    required this.time,
    required this.accent,
    required this.completedPomodoros,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedPomodoros pomodoros complétés',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskField extends StatelessWidget {
  final TextEditingController controller;
  final String currentTask;
  final bool isRunning;
  final ValueChanged<String> onSubmit;
  final VoidCallback onEdit;

  const _TaskField({
    required this.controller,
    required this.currentTask,
    required this.isRunning,
    required this.onSubmit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (currentTask.isEmpty && !isRunning) {
      return TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Sur quoi travaillez-vous ?',
          prefixIcon: const Icon(Icons.task_alt),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: onSubmit,
      );
    }
    if (currentTask.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.task_alt, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentTask,
              style: theme.textTheme.titleMedium,
            ),
          ),
          if (!isRunning)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Modifier la tâche',
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const _Controls({
    required this.isRunning,
    required this.onToggle,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
          child: Semantics(
            label: 'Réinitialiser',
            button: true,
            child: const Icon(Icons.refresh, size: 28),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 28),
              const SizedBox(width: 8),
              Text(isRunning ? 'Pause' : 'Démarrer',
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: onSkip,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
          child: Semantics(
            label: 'Passer à la session suivante',
            button: true,
            child: const Icon(Icons.skip_next, size: 28),
          ),
        ),
      ],
    );
  }
}
