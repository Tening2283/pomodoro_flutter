# ⏱️ FocusFlow — Pomodoro (Flutter / PWA)

Application de productivité basée sur la méthode **Pomodoro**, développée en
**Flutter**. Minuteur de focus configurable, **statistiques persistantes**,
**coach** de productivité, le tout dans une **PWA installable et utilisable
hors-ligne**, avec une attention particulière portée à l'**accessibilité**.

> Ce dépôt est un projet personnel repris et modernisé : passage d'un prototype
> mono-fichier à une **architecture en couches testée**, ajout de la
> **persistance**, du **support PWA/offline** et de l'**accessibilité**.

---

## ✨ Fonctionnalités

- **Minuteur Pomodoro** : sessions de travail, pauses courtes et longues, avec
  enchaînement automatique et durées **entièrement configurables**.
- **Statistiques persistantes** : nombre de pomodoros et minutes de focus du
  jour / de la semaine / au total, moyenne quotidienne, graphique hebdomadaire
  et historique des sessions. Les données **survivent au redémarrage** (et
  fonctionnent hors-ligne).
- **Coach de productivité** : assistant conversationnel qui répond selon vos
  statistiques (basé sur des règles — voir la note d'honnêteté plus bas).
- **PWA** : installable sur Android/iOS/desktop, chargement hors-ligne via
  service worker.
- **Accessibilité** : taille de police réglable, mode **contraste élevé**,
  thème clair/sombre/système, labels pour lecteurs d'écran et **navigation au
  clavier** (Espace = démarrer/pause, R = réinitialiser).

> **Note d'honnêteté :** le « Coach » est actuellement à base de règles, pas un
> modèle d'IA. Le code est structuré ([`CoachEngine`](lib/services/coach_engine.dart))
> pour brancher une vraie API (Claude/OpenAI) sans toucher à l'interface.

---

## 🏛️ Architecture

Le code est organisé en couches pour la lisibilité et la testabilité. Voir
[ARCHITECTURE.md](ARCHITECTURE.md) pour le détail.

```
lib/
├── models/       # Données immuables (Session, AppSettings) + (dé)sérialisation
├── services/     # Persistance (SharedPreferences) + logique pure (calcul stats, coach)
├── providers/    # Gestion d'état (ChangeNotifier / Provider)
├── screens/      # Écrans (Pomodoro, Statistiques, Coach, Réglages)
├── widgets/      # Composants réutilisables (StatCard, WeeklyChart)
├── theme/        # Thèmes clair/sombre + contraste élevé
└── main.dart     # Point d'entrée, injection des dépendances
```

- **Gestion d'état** : [`provider`](https://pub.dev/packages/provider)
  (`ChangeNotifier`, `ChangeNotifierProxyProvider`).
- **Persistance** : [`shared_preferences`](https://pub.dev/packages/shared_preferences)
  (compatible web/PWA via `localStorage`).
- **Logique métier isolée de l'UI** (`StatsCalculator`, `CoachEngine`,
  `TimerProvider`) → couverte par des tests unitaires rapides.

---

## 🧪 Tests

19 tests couvrent la logique métier et l'interface :

```bash
flutter test
```

- Calcul des statistiques (`StatsCalculator`) — fenêtres jour/semaine, moyenne,
  exclusion des pauses.
- Cycle du minuteur (`TimerProvider`) — décompte, enregistrement des sessions,
  transitions travail → pause courte/longue.
- Sérialisation des modèles + rétro-compatibilité des anciennes données.
- Moteur du coach (`CoachEngine`).
- Tests de widgets (démarrage de l'app, navigation).

Une **fiche de recette** manuelle est disponible dans [RECETTE.md](RECETTE.md).

---

## 🚀 Lancer le projet

```bash
flutter pub get
```

**Mobile :**

```bash
flutter run
```

**Web / PWA :**

```bash
flutter run -d chrome
```

---

## 🛠️ Build

**PWA (web) :**

```bash
flutter build web --release
```

Le résultat dans `build/web/` est une PWA (manifeste + service worker)
installable et utilisable hors-ligne.

**Android :**

```bash
flutter build apk --release
```

---

## 🧭 Choix techniques notables

| Sujet | Choix | Raison |
|---|---|---|
| État | `provider` | Standard, simple à expliquer, testable |
| Persistance | `shared_preferences` | Multiplateforme **y compris web/PWA** |
| Logique stats | Fonctions pures | Testables sans dépendance à Flutter |
| Accessibilité | `Semantics`, `TextScaler`, contraste | Critères d'inclusion explicites |
| Timer | Isolé de l'UI | Testable avec le temps simulé |

---

## 📄 Licence

Projet sous licence MIT.

👨‍💻 Développé avec Flutter.
