import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

/// Ecran des reglages : durees du minuteur, theme et accessibilite.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final s = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Minuteur'),
          _StepperTile(
            label: 'Durée de travail',
            value: s.workMinutes,
            unit: 'min',
            onChanged: provider.setWorkMinutes,
          ),
          _StepperTile(
            label: 'Pause courte',
            value: s.shortBreakMinutes,
            unit: 'min',
            onChanged: provider.setShortBreakMinutes,
          ),
          _StepperTile(
            label: 'Pause longue',
            value: s.longBreakMinutes,
            unit: 'min',
            onChanged: provider.setLongBreakMinutes,
          ),
          _StepperTile(
            label: 'Pause longue toutes les',
            value: s.longBreakInterval,
            unit: 'sessions',
            onChanged: provider.setLongBreakInterval,
          ),
          const Divider(height: 32),
          const _SectionHeader('Apparence'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Thème'),
            trailing: DropdownButton<ThemeMode>(
              value: s.themeMode,
              onChanged: (mode) {
                if (mode != null) provider.setThemeMode(mode);
              },
              items: const [
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text('Système')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
              ],
            ),
          ),
          const Divider(height: 32),
          const _SectionHeader('Accessibilité'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Taille du texte : ${(s.textScale * 100).round()} %',
                    style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: s.textScale,
                  min: AppSettings.minTextScale,
                  max: AppSettings.maxTextScale,
                  divisions: 8,
                  label: '${(s.textScale * 100).round()} %',
                  onChanged: provider.setTextScale,
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('Contraste élevé'),
            subtitle: const Text('Améliore la lisibilité'),
            value: s.highContrast,
            onChanged: provider.setHighContrast,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Retour sonore / vibration'),
            subtitle: const Text('À la fin de chaque session'),
            value: s.feedbackEnabled,
            onChanged: provider.setFeedbackEnabled,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('FocusFlow',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  const _StepperTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Diminuer',
            onPressed: () => onChanged(value - 1),
          ),
          SizedBox(
            width: 64,
            child: Text('$value $unit', textAlign: TextAlign.center),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Augmenter',
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
