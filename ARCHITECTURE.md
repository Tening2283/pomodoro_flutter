# Architecture

Ce document décrit l'organisation du code de **FocusFlow**.

## Vue d'ensemble

L'application suit une **architecture en couches** : chaque couche a une
responsabilité unique et ne dépend que de la couche en dessous. L'objectif est
la **lisibilité**, la **testabilité** et la **facilité de reprise** (un critère
important pour un projet destiné à être maintenu par une autre équipe).

```
┌─────────────────────────────────────────────┐
│  screens/ + widgets/   (UI Flutter)          │  ← ne contient pas de logique métier
├─────────────────────────────────────────────┤
│  providers/            (état, ChangeNotifier) │  ← orchestre, notifie l'UI
├─────────────────────────────────────────────┤
│  services/             (logique + persistance)│  ← pur Dart, testable
├─────────────────────────────────────────────┤
│  models/               (données immuables)    │
└─────────────────────────────────────────────┘
```

## Les couches

### `models/`
Objets de données immuables, sans logique d'UI.
- `PomodoroSession` : une session terminée (tâche, date, durée, type) +
  (dé)sérialisation JSON avec **rétro-compatibilité** des anciennes données.
- `SessionType` : enum travail / pause courte / pause longue.
- `AppSettings` : réglages (durées, thème, accessibilité) avec `copyWith`.

### `services/`
Logique métier et persistance, **sans dépendance à l'UI Flutter** (donc
facilement testable).
- `StatsRepository` / `SettingsRepository` : persistance via
  `shared_preferences` (fonctionne sur web/PWA via `localStorage`).
- `StatsCalculator` : **fonctions pures** de calcul des statistiques (jour,
  semaine, moyenne, graphique). `now` est injectable → tests déterministes.
- `CoachEngine` : génération des réponses du coach (à base de règles pour
  l'instant ; point d'extension pour une vraie IA).

### `providers/`
Gestion d'état avec `ChangeNotifier` (package `provider`).
- `SettingsProvider` : expose et persiste les réglages.
- `StatsProvider` : source de vérité réactive de l'historique ; l'écran
  Statistiques `watch`e ce provider et se met à jour **en temps réel**.
- `TimerProvider` : cycle du minuteur (décompte, transitions, enregistrement).
  Volontairement **sans import Flutter/material** → pilotable dans les tests
  avec le temps simulé.

### `screens/` et `widgets/`
Interface uniquement. Les écrans lisent l'état via `context.watch` et délèguent
les actions aux providers.

## Injection des dépendances

Dans `main.dart`, les repositories sont créés au démarrage (après chargement des
données persistées), puis fournis via `MultiProvider`. Le `TimerProvider`
dépend des réglages (durées) et des stats (enregistrement des sessions), câblés
via `ChangeNotifierProxyProvider2`.

## Décisions clés

- **Logique pure séparée de l'UI** : `StatsCalculator` et `CoachEngine` sont du
  Dart pur → tests rapides et fiables.
- **Persistance compatible PWA** : `shared_preferences` plutôt qu'une base
  native, pour garantir le fonctionnement hors-ligne sur le web.
- **Le minuteur ne connaît pas Flutter** : il reçoit un *callback*
  d'enregistrement, ce qui le rend testable et découplé.
- **Seules les sessions de travail comptent** comme pomodoros ; les pauses sont
  ignorées dans les statistiques (corrige un bug de la version initiale).
