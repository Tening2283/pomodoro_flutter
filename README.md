# ⏱️ Pomodoro Flutter - Application de Productivité

**Pomodoro Flutter** est une application Flutter de productivité intégrant la méthode **Pomodoro**, des **statistiques de focus** et un **assistant IA** pour planifier votre journée efficacement.

---

## 📱 Fonctionnalités

### 🕒 Pomodoro Timer
- Sessions de travail de **25 minutes** et **pauses courtes/longues**.  
- Gestion des tâches en cours avec possibilité de **les nommer, modifier et suivre** leur avancement.

### 📈 Statistiques de Focus
- Suivi des pomodoros réalisés **aujourd'hui, cette semaine et au total**.  
- **Graphique hebdomadaire** pour visualiser la progression.  
- **Moyenne quotidienne** de pomodoros calculée automatiquement.

### 🤖 Assistant IA
- Répond aux **questions sur la planification**, les statistiques et les **conseils de productivité**.  
- Fournit des **messages personnalisés** selon vos sessions Pomodoro.

---

## 💻 Structure du projet

```
pomodoro_flutter/
├── android/       # Projet Android
├── ios/           # Projet iOS
├── lib/           # Code source Flutter
├── web/           # Version web
├── linux/         # Version Linux
├── macos/         # Version macOS
├── windows/       # Version Windows
├── test/          # Tests unitaires
├── build/         # Dossier de build
```

---

## 🚀 Installation

### 1. Cloner le projet
```bash
git clone https://github.com/Tening2283/pomodoro_flutter.git
cd pomodoro_flutter
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Exécuter l'application

#### 📱 Mobile :
```bash
flutter run
```

#### 🌐 Web :
```bash
flutter run -d chrome
```

---

## 🛠️ Build

### Android :
```bash
flutter build apk
```

### iOS :
```bash
flutter build ios
```

### Web :
```bash
flutter build web
```

---

## 📊 Statistiques

Les statistiques sont gérées dans la classe **`PomodoroStats`** :

| Méthode | Description |
|----------|--------------|
| `addSession(task)` | Ajoute une session terminée |
| `getStats()` | Récupère les statistiques globales et récentes |
| `getWeeklyData()` | Retourne le nombre de pomodoros par jour pour la semaine |

---

## ✨ Contribution

Les contributions sont **les bienvenues** !

1. Fork le projet  
2. Crée une branche pour ta fonctionnalité :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```
3. Commit tes modifications :
   ```bash
   git commit -m "Ajout d'une nouvelle fonctionnalité"
   ```
4. Push et ouvre une **Pull Request**

---

## 📄 Licence

Ce projet est sous **licence MIT**.  
Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

👨‍💻 Développé avec ❤️ en Flutter.
