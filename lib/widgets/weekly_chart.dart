import 'dart:math';

import 'package:flutter/material.dart';

/// Histogramme des pomodoros des 7 derniers jours.
///
/// [counts] : 7 valeurs, index 0 = il y a 6 jours ... index 6 = aujourd'hui.
class WeeklyChart extends StatelessWidget {
  final List<int> counts;

  /// Injectable pour des tests deterministes ; par defaut la date du jour.
  final DateTime? today;

  const WeeklyChart({super.key, required this.counts, this.today});

  static const _dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reference = today ?? DateTime.now();
    final maxValue = counts.isEmpty ? 0 : counts.reduce(max);
    final total = counts.fold<int>(0, (a, b) => a + b);

    return Semantics(
      label: 'Graphique hebdomadaire : $total pomodoros sur les 7 derniers jours',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final value = index < counts.length ? counts[index] : 0;
              final ratio = maxValue > 0 ? value / maxValue : 0.0;
              final barHeight = max(ratio * 150.0, 4.0);
              final day = reference.subtract(Duration(days: 6 - index));
              final letter = _dayLetters[(day.weekday - 1) % 7];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    letter,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
