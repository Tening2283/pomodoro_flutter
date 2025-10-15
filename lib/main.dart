import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PomodoroScreen(),
    const StatisticsScreen(),
    const AIAssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistiques',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'IA Assistant',
          ),
        ],
      ),
    );
  }
}

// Écran Pomodoro
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({Key? key}) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  int _secondsCompleted = 0; // secondes écoulées pour le pomodoro actuel

  bool _isRunning = false;
  bool _isWorkSession = true;
  int _completedPomodoros = 0;
  int _dailyPomodoros = 0;
  final int _workDuration = 25 * 60;
  final int _shortBreakDuration = 5 * 60;
  final int _longBreakDuration = 15 * 60;

  String _currentTask = "";
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_currentTask.isEmpty) _currentTask = "Tâche sans nom"; // sécurité

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          _secondsCompleted++; // compteur en temps réel
        } else {
          _onTimerComplete();
        }
      });
    });
  }


  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _secondsRemaining = _isWorkSession ? _workDuration : _shortBreakDuration;
    });
    _timer?.cancel();
  }

  void _onTimerComplete() {
    _timer?.cancel();

    // sauvegarde la durée réelle du pomodoro
    PomodoroStats.addSession(
      _currentTask,
      durationMinutes: (_secondsCompleted / 60).ceil(), // minutes arrondies
    );

    _secondsCompleted = 0; // reset pour le prochain pomodoro

    if (_isWorkSession) {
      setState(() {
        _completedPomodoros++;
        _dailyPomodoros++;
        if (_completedPomodoros % 4 == 0) {
          _secondsRemaining = _longBreakDuration;
        } else {
          _secondsRemaining = _shortBreakDuration;
        }
        _isWorkSession = false;
        _isRunning = false;
      });
      _showNotification("Session terminée !", "Temps de faire une pause 🎉");
    } else {
      setState(() {
        _secondsRemaining = _workDuration;
        _isWorkSession = true;
        _isRunning = false;
      });
      _showNotification("Pause terminée !", "Prêt pour une nouvelle session ? 💪");
    }
  }


  void _showNotification(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_secondsRemaining / (_isWorkSession ? _workDuration : (_completedPomodoros % 4 == 0 ? _longBreakDuration : _shortBreakDuration)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isWorkSession ? Colors.deepPurple.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWorkSession ? '🎯 Session de travail' : '☕ Pause',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _isWorkSession ? Colors.deepPurple : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 40),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isWorkSession ? Colors.deepPurple : Colors.green,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_completedPomodoros pomodoros complétés',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),

            if (_currentTask.isEmpty && !_isRunning)
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'Sur quoi travaillez-vous ?',
                  prefixIcon: const Icon(Icons.task_alt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _currentTask = value;
                  });
                },
              )
            else if (_currentTask.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentTask,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isRunning)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          setState(() {
                            _taskController.text = _currentTask;
                            _currentTask = "";
                          });
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_arrow, size: 28),
                        SizedBox(width: 8),
                        Text('Démarrer', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.pause, size: 28),
                        SizedBox(width: 8),
                        Text('Pause', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.refresh, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Écran Statistiques
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final stats = PomodoroStats.getStats();
    final recentSessions = (PomodoroStats.getStats()['recentSessions'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final totalCount = stats['totalCount'] as int;

    final todayCount = stats['todayCount'] as int;
    final weekCount = stats['weekCount'] as int;

    final todayMinutes = stats['todayMinutes'] as int;
    final weekMinutes = stats['weekMinutes'] as int;
    final totalMinutes = recentSessions.fold<int>(0, (int sum, dynamic s) {
      final duration = (s as Map<String, dynamic>)['duration'] as int? ?? 25;
      return sum + duration;
    });

    double avgPerDayDouble = 0.0;
    if (totalCount > 0 && recentSessions.isNotEmpty) {
      final oldest = DateTime.parse(recentSessions.last['date']).toLocal();
      final days = DateTime.now()
          .difference(DateTime(oldest.year, oldest.month, oldest.day))
          .inDays + 1;
      avgPerDayDouble = totalCount / max(1, days);
    }

    final avgPerDay = avgPerDayDouble.toStringAsFixed(1);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
        elevation: 0,
      ),
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
                _StatCard(
                  title: "Aujourd'hui",
                  value: '$todayCount',
                  subtitle: '$todayMinutes min',
                  icon: Icons.today,
                  color: Colors.deepPurple,
                ),
                _StatCard(
                  title: "Aujourd'hui",
                  value: '$todayCount',
                  subtitle: '$todayMinutes min',
                  icon: Icons.today,
                  color: Colors.deepPurple,
                ),
                _StatCard(
                  title: 'Cette semaine',
                  value: '$weekCount',
                  subtitle: '$weekMinutes min',
                  icon: Icons.date_range,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Total',
                  value: '$totalCount',
                  subtitle: '$totalMinutes min',
                  icon: Icons.emoji_events,
                  color: Colors.orange,
                ),

              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Progression cette semaine',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _WeeklyChart(),
            const SizedBox(height: 32),

            const Text(
              'Sessions récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (recentSessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune session enregistrée',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: min(10, recentSessions.length),
                itemBuilder: (context, index) {
                  final session = recentSessions[index];
                  final date = DateTime.parse(session['date']);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.withOpacity(0.1),
                        child: const Icon(Icons.check, color: Colors.deepPurple),
                      ),
                      title: Text(session['task']),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Text(
                        '25 min',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weekData = PomodoroStats.getWeeklyData();
    final maxValue = weekData.isEmpty ? 1.0 : weekData.reduce(max).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weekData[index];
                final height = maxValue > 0 ? (value / maxValue) * 150 : 0;
                final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

                return Column(
                  children: [
                    Text(
                      '$value',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: max(height.toDouble(), 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.deepPurple, Colors.deepPurple.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Écran IA Assistant
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addAIMessage("Bonjour ! 👋 Je suis votre assistant de planification. Comment puis-je vous aider à organiser votre journée ?");
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addAIMessage(String message) {
    setState(() {
      _messages.add({'type': 'ai', 'text': message});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({'type': 'user', 'text': message});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _getAIResponse(text);
      _addAIMessage(response);
    });
  }

  String _getAIResponse(String userMessage) {
    final msg = userMessage.toLowerCase();
    final stats = PomodoroStats.getStats();
    final todayCount = stats['todayCount'] as int;

    if (msg.contains('planif') || msg.contains('organis') || msg.contains('journée')) {
      return "📅 Pour une journée productive, je vous suggère :\n\n1. Commencez par 2 pomodoros (50 min) sur votre tâche prioritaire\n2. Faites une pause longue de 15 min\n3. Continuez avec 2-3 pomodoros selon votre énergie\n4. Réservez la fin de journée pour les tâches moins exigeantes\n\nQuel est votre objectif principal aujourd'hui ?";
    }

    if (msg.contains('stats') || msg.contains('progrès') || msg.contains('performance')) {
      return "📊 Voici votre bilan :\n\nVous avez complété $todayCount pomodoros aujourd'hui (${todayCount * 25} minutes de focus).\n\n${todayCount >= 8 ? '🎉 Excellent ! Vous êtes très productif aujourd\'hui !' : todayCount >= 4 ? '👍 Bon travail ! Continuez sur cette lancée !' : '💪 Courage ! Chaque pomodoro compte !'}\n\nVoulez-vous des conseils pour améliorer votre concentration ?";
    }

    if (msg.contains('conseil') || msg.contains('aide') || msg.contains('améliorer')) {
      return "💡 Voici mes meilleurs conseils :\n\n1. Éliminez les distractions (mode avion, notifications off)\n2. Préparez votre espace de travail avant de commencer\n3. Hydratez-vous régulièrement\n4. Utilisez les pauses pour bouger\n5. Notez vos accomplissements\n\nQuelle difficulté rencontrez-vous le plus souvent ?";
    }

    if (msg.contains('pause') || msg.contains('repos')) {
      return "☕ Les pauses sont essentielles ! Voici comment les optimiser :\n\n• Levez-vous et marchez\n• Regardez au loin (repos des yeux)\n• Hydratez-vous\n• Faites des étirements légers\n• Évitez les écrans\n\nLa technique Pomodoro fonctionne car elle respecte votre rythme naturel de concentration.";
    }

    if (msg.contains('bonjour') || msg.contains('salut') || msg.contains('hello')) {
      return "Bonjour ! 😊 Je suis là pour vous aider à maximiser votre productivité. Que voulez-vous accomplir aujourd'hui ?";
    }

    if (msg.contains('merci')) {
      return "Avec plaisir ! 😊 N'hésitez pas si vous avez d'autres questions. Bonne session de travail ! 🎯";
    }

    return "Je comprends votre question. Pour mieux vous aider, je peux vous conseiller sur :\n\n• 📅 La planification de votre journée\n• 📊 L'analyse de vos statistiques\n• 💡 Des techniques de concentration\n• ☕ L'optimisation de vos pauses\n\nQue souhaitez-vous savoir ?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickActionChip(
                    label: 'Planifier ma journée',
                    onTap: () {
                      _messageController.text = 'Comment planifier ma journée ?';
                      _sendMessage();
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickActionChip(
                    label: 'Mes statistiques',
                    onTap: () {
                      _messageController.text = 'Montre-moi mes stats';
                      _sendMessage();
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickActionChip(
                    label: 'Conseils productivité',
                    onTap: () {
                      _messageController.text = 'Donne-moi des conseils';
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isAI = message['type'] == 'ai';

                return Align(
                  alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isAI
                          ? Colors.grey[200]
                          : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isAI ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.deepPurple.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.deepPurple),
      ),
    );
  }
}

// Classe pour gérer les statistiques (version corrigée + plus robuste)
class PomodoroStats {
  static final List<Map<String, dynamic>> _sessions = [];

  // Ajoute une session avec durée (en minutes)
  static void addSession(String task, {int durationMinutes = 25}) {
    _sessions.add({
      'task': task,
      'date': DateTime.now().toIso8601String(),
      'duration': durationMinutes,
    });
  }

  // Compare si deux dates sont le même jour
  static bool _isSameDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  // Stats principales
  static Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6)); // 7 jours incluant aujourd'hui

    int todayCount = 0;
    int weekCount = 0;
    int todayMinutes = 0;
    int weekMinutes = 0;

    for (var session in _sessions) {
      final sessionDate = DateTime.parse(session['date']).toLocal();
      final sessionDay = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      final duration = session['duration'] as int? ?? 25;

      if (_isSameDay(sessionDay, today)) {
        todayCount++;
        todayMinutes += duration;
      }

      if (!sessionDay.isBefore(weekAgo) && !sessionDay.isAfter(today)) {
        weekCount++;
        weekMinutes += duration;
      }
    }

    return {
      'todayCount': todayCount,
      'weekCount': weekCount,
      'totalCount': _sessions.length,
      'todayMinutes': todayMinutes,
      'weekMinutes': weekMinutes,
      'recentSessions': List.from(_sessions.reversed),
    };
  }

  // Données pour le graphique (7 derniers jours)
  static List<int> getWeeklyData() {
    final now = DateTime.now();
    final List<int> weekData = List.filled(7, 0);

    for (var session in _sessions) {
      final sessionDate = DateTime.parse(session['date']).toLocal();
      final diffDays = DateTime(now.year, now.month, now.day).difference(
          DateTime(sessionDate.year, sessionDate.month, sessionDate.day)
      ).inDays;

      if (diffDays >= 0 && diffDays < 7) {
        weekData[6 - diffDays] += session['duration'] as int? ?? 25;
      }
    }

    return weekData;
  }
}

