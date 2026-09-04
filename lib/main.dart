import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/timer_provider.dart';
import 'services/settings_repository.dart';
import 'services/stats_repository.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement des donnees persistees avant le premier rendu.
  final settingsRepo = await SettingsRepository.create();
  final statsRepo = await StatsRepository.create();

  runApp(PomodoroApp(settingsRepo: settingsRepo, statsRepo: statsRepo));
}

/// Retour utilisateur par defaut a la fin d'une session (son + vibration).
/// Sans effet sur les plateformes qui ne le supportent pas (ex. web).
void _defaultFeedback() {
  HapticFeedback.mediumImpact();
  SystemSound.play(SystemSoundType.alert);
}

class PomodoroApp extends StatelessWidget {
  final SettingsRepository settingsRepo;
  final StatsRepository statsRepo;

  const PomodoroApp({
    super.key,
    required this.settingsRepo,
    required this.statsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsRepo)),
        ChangeNotifierProvider(create: (_) => StatsProvider(statsRepo)),
        // Le minuteur depend des reglages (durees) et des stats (enregistrement).
        ChangeNotifierProxyProvider2<SettingsProvider, StatsProvider,
            TimerProvider>(
          create: (context) => TimerProvider(
            settings: context.read<SettingsProvider>().settings,
            recordSession: context.read<StatsProvider>().addSession,
            onFeedback: _defaultFeedback,
          ),
          update: (context, settings, stats, timer) {
            timer!.updateSettings(settings.settings);
            timer.updateRecorder(stats.addSession);
            return timer;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;
          return MaterialApp(
            title: 'FocusFlow',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.light(highContrast: settings.highContrast),
            darkTheme: AppTheme.dark(highContrast: settings.highContrast),
            // Applique le facteur d'echelle du texte choisi (accessibilite).
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(settings.textScale),
                ),
                child: child!,
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
