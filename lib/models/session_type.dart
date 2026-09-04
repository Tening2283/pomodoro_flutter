/// Type d'une session du minuteur Pomodoro.
///
/// Seules les sessions [SessionType.work] comptent comme des "pomodoros"
/// dans les statistiques ; les pauses sont enregistrees pour l'historique.
enum SessionType {
  work,
  shortBreak,
  longBreak;

  /// Libelle lisible affiche a l'utilisateur.
  String get label {
    switch (this) {
      case SessionType.work:
        return 'Session de travail';
      case SessionType.shortBreak:
        return 'Pause courte';
      case SessionType.longBreak:
        return 'Pause longue';
    }
  }

  bool get isBreak => this != SessionType.work;

  /// Valeur stable pour la (de)serialisation JSON.
  String get storageKey => name;

  static SessionType fromStorageKey(String? key) {
    return SessionType.values.firstWhere(
      (t) => t.storageKey == key,
      orElse: () => SessionType.work,
    );
  }
}
