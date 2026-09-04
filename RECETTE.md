# Fiche de recette — FocusFlow

Plan de tests **fonctionnels manuels** (recette) de l'application. À compléter à
chaque campagne de test.

- **Version testée :** 1.0.0
- **Testeur :** ______________
- **Date :** ______________
- **Plateformes :** ☐ Android  ☐ iOS  ☐ Web/PWA  ☐ Desktop

Légende statut : ✅ OK · ❌ KO · ⚠️ Réserve · ⬜ Non testé

---

## 1. Minuteur

| # | Cas de test | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| 1.1 | Démarrer une session | Saisir une tâche, appuyer sur « Démarrer » | Le décompte diminue chaque seconde ; le cercle de progression avance | ⬜ |
| 1.2 | Mettre en pause | Pendant le décompte, appuyer sur « Pause » | Le décompte s'arrête sur la valeur courante | ⬜ |
| 1.3 | Réinitialiser | Appuyer sur le bouton de réinitialisation | Le temps revient à la durée configurée | ⬜ |
| 1.4 | Fin de session travail | Laisser une session de travail se terminer | Notification affichée ; passage en pause ; +1 pomodoro | ⬜ |
| 1.5 | Pause longue | Terminer N sessions (N = intervalle configuré) | La N-ième déclenche une **pause longue** | ⬜ |
| 1.6 | Passer une session | Appuyer sur « Passer » | Passage à la session suivante **sans** l'enregistrer | ⬜ |
| 1.7 | Raccourcis clavier (web) | Appuyer sur Espace, puis R | Espace = démarrer/pause ; R = réinitialiser | ⬜ |

## 2. Statistiques

| # | Cas de test | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| 2.1 | Mise à jour temps réel | Terminer une session puis ouvrir l'onglet Stats | Les compteurs et le graphique reflètent la session | ⬜ |
| 2.2 | Durée réelle | Vérifier une session dans l'historique | La durée affichée correspond à la durée réelle (pas « 25 min » figé) | ⬜ |
| 2.3 | Moyenne / jour | Vérifier la carte « Moyenne / jour » | Valeur cohérente (pomodoros / nb de jours) | ⬜ |
| 2.4 | Effacer l'historique | Bouton « Effacer » → confirmer | L'historique est vidé après confirmation | ⬜ |

## 3. Persistance (hors-ligne)

| # | Cas de test | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| 3.1 | Survie au redémarrage | Terminer des sessions, fermer puis rouvrir l'app | Les statistiques sont conservées | ⬜ |
| 3.2 | Réglages persistés | Modifier une durée, redémarrer | La durée modifiée est conservée | ⬜ |
| 3.3 | Mode hors-ligne (PWA) | Charger l'app, couper le réseau, recharger | L'app se charge et reste utilisable | ⬜ |

## 4. Accessibilité

| # | Cas de test | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| 4.1 | Taille du texte | Régler le curseur de taille de police | Tout le texte s'adapte sans être tronqué | ⬜ |
| 4.2 | Contraste élevé | Activer le mode contraste élevé | Contours renforcés, meilleure lisibilité | ⬜ |
| 4.3 | Thème | Basculer clair / sombre / système | Le thème change immédiatement | ⬜ |
| 4.4 | Lecteur d'écran | Activer TalkBack/VoiceOver sur le minuteur | Le temps restant et les boutons sont annoncés | ⬜ |
| 4.5 | Navigation clavier | Naviguer à la touche Tab (web) | Le focus est visible et parcourt les contrôles | ⬜ |

## 5. PWA / installation

| # | Cas de test | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| 5.1 | Installation | Ouvrir dans Chrome/Edge → « Installer » | L'app s'installe et s'ouvre en fenêtre autonome | ⬜ |
| 5.2 | Icône & nom | Vérifier l'icône et le nom installés | « FocusFlow », icône correcte | ⬜ |

---

## Anomalies relevées

| # | Description | Gravité | Statut |
|---|---|---|---|
|  |  |  |  |
