Pomodoro Flutter - Application de Productivité

Pomodoro Flutter est une application Flutter de productivité intégrant la méthode Pomodoro, des statistiques de focus et un assistant IA pour planifier votre journée.

📱 Fonctionnalités

Pomodoro Timer

Sessions de travail de 25 minutes et pauses courtes/longues.

Gestion des tâches en cours avec possibilité de les nommer et modifier.

Statistiques de Focus

Suivi des pomodoros réalisés aujourd'hui, cette semaine et au total.

Graphique hebdomadaire pour visualiser la progression.

Moyenne quotidienne de pomodoros.

Assistant IA

Répond aux questions sur la planification, les statistiques et les conseils de productivité.

Messages personnalisés en fonction de vos sessions Pomodoro.

💻 Structure du projet
pomodoro_flutter/
├── android/          # Projet Android
├── ios/              # Projet iOS
├── lib/              # Code source Flutter
├── web/              # Version web
├── linux/            # Version Linux
├── macos/            # Version macOS
├── windows/          # Version Windows
├── test/             # Tests unitaires
├── build/            # Dossier de build

🚀 Installation

Cloner le projet

git clone https://github.com/Tening2283/pomodoro_flutter.git
cd pomodoro_flutter


Installer les dépendances

flutter pub get


Exécuter l'application

Mobile :

flutter run


Web :

flutter run -d chrome

🛠️ Build

Build Android

flutter build apk


Build iOS

flutter build ios


Build Web

flutter build web


📊 Statistiques

Les statistiques sont gérées dans la classe PomodoroStats :

addSession(task) : ajoute une session terminée.

getStats() : récupère les statistiques globales et récentes.

getWeeklyData() : retourne le nombre de pomodoros par jour pour la semaine.

✨ Contribution

Les contributions sont les bienvenues !

Fork le projet

Crée une branche pour ta fonctionnalité (git checkout -b feature/ma-fonctionnalite)

Commit tes modifications (git commit -m "Ajout d'une nouvelle fonctionnalité")

Push et ouvre un pull request

📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.