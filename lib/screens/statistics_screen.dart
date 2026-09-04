import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';

/// Ecran des statistiques de focus. `watch`e [StatsProvider] : se met a jour
/// en temps reel des qu'une session est enregistree.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = context.watch<StatsProvider>();
    final summary = stats.summary;
    final recent = stats.recent();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: "Aujourd'hui",
                  value: '${summary.todayCount}',
                  subtitle: '${summary.todayMinutes} min',
                  icon: Icons.today,
                  color: theme.colorScheme.primary,
                ),
                StatCard(
                  title: 'Cette semaine',
                  value: '${summary.weekCount}',
                  subtitle: '${summary.weekMinutes} min',
                  icon: Icons.date_range,
                  color: Colors.blue,
                ),
                StatCard(
                  title: 'Total',
                  value: '${summary.totalCount}',
                  subtitle: '${summary.totalMinutes} min',
                  icon: Icons.emoji_events,
                  color: Colors.orange,
                ),
                // Ancienne carte "Aujourd'hui" dupliquee -> remplacee par la
                // moyenne quotidienne, plus utile.
                StatCard(
                  title: 'Moyenne / jour',
                  value: summary.averagePerDay.toStringAsFixed(1),
                  subtitle: 'pomodoros',
                  icon: Icons.trending_up,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Progression cette semaine',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            WeeklyChart(counts: stats.weeklyCounts),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sessions récentes',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (recent.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _confirmClear(context, stats),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Effacer'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const _EmptyState()
            else
              ...recent.map((s) => _SessionTile(session: s)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, StatsProvider stats) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique ?'),
        content: const Text(
            'Toutes les sessions enregistrées seront définitivement supprimées.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Effacer')),
        ],
      ),
    );
    if (confirmed == true) {
      await stats.clearAll();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Aucune session enregistrée',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final PomodoroSession session;
  const _SessionTile({required this.session});

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date à $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.check, color: theme.colorScheme.primary),
        ),
        title: Text(session.task),
        subtitle: Text(_formatDate(session.date)),
        // Corrige l'ancien "25 min" code en dur : vraie duree enregistree.
        trailing: Text('${session.durationMinutes} min',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
