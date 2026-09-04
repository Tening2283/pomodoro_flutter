import '../services/stats_calculator.dart';

/// Moteur de reponses du coach de productivite.
///
/// Implementation actuelle : a base de regles, deterministe et testable.
/// C'est aussi le point d'extension prevu pour brancher une vraie IA
/// (API Claude/OpenAI) : il suffira de fournir une autre implementation de
/// [CoachEngine.respond] renvoyant un Future, sans toucher a l'UI.
class CoachEngine {
  const CoachEngine();

  String respond(String userMessage, StatsSummary stats) {
    final msg = userMessage.toLowerCase();

    if (_matches(msg, ['planif', 'organis', 'journée', 'journee'])) {
      return "📅 Pour une journée productive :\n\n"
          "1. Commencez par 2 pomodoros sur votre tâche prioritaire\n"
          "2. Faites une pause longue de 15 min\n"
          "3. Enchaînez 2-3 pomodoros selon votre énergie\n"
          "4. Gardez la fin de journée pour les tâches légères\n\n"
          "Quel est votre objectif principal aujourd'hui ?";
    }

    if (_matches(msg, ['stat', 'progrès', 'progres', 'performance', 'bilan'])) {
      final count = stats.todayCount;
      final encouragement = count >= 8
          ? '🎉 Excellent, vous êtes très productif aujourd\'hui !'
          : count >= 4
              ? '👍 Bon travail, continuez sur cette lancée !'
              : '💪 Chaque pomodoro compte, courage !';
      return "📊 Votre bilan :\n\n"
          "Vous avez complété $count pomodoros aujourd'hui "
          "(${stats.todayMinutes} minutes de focus).\n\n$encouragement";
    }

    if (_matches(msg, ['conseil', 'aide', 'améliorer', 'ameliorer', 'concentr'])) {
      return "💡 Mes meilleurs conseils :\n\n"
          "1. Éliminez les distractions (notifications off)\n"
          "2. Préparez votre espace avant de commencer\n"
          "3. Hydratez-vous régulièrement\n"
          "4. Bougez pendant les pauses\n"
          "5. Notez vos accomplissements";
    }

    if (_matches(msg, ['pause', 'repos'])) {
      return "☕ Bien utiliser ses pauses :\n\n"
          "• Levez-vous et marchez\n"
          "• Reposez vos yeux (regardez au loin)\n"
          "• Hydratez-vous\n"
          "• Étirez-vous légèrement\n"
          "• Évitez les écrans";
    }

    if (_matches(msg, ['bonjour', 'salut', 'hello', 'coucou'])) {
      return "Bonjour ! 😊 Je suis là pour vous aider à rester concentré. "
          "Que voulez-vous accomplir aujourd'hui ?";
    }

    if (_matches(msg, ['merci'])) {
      return "Avec plaisir ! 😊 Bonne session de travail 🎯";
    }

    return "Je peux vous aider sur :\n\n"
        "• 📅 La planification de votre journée\n"
        "• 📊 L'analyse de vos statistiques\n"
        "• 💡 Des techniques de concentration\n"
        "• ☕ L'optimisation de vos pauses\n\n"
        "Que souhaitez-vous savoir ?";
  }

  bool _matches(String message, List<String> keywords) =>
      keywords.any(message.contains);
}
