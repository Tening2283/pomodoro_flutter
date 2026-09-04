import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';
import '../services/coach_engine.dart';

/// Coach de productivite (conversationnel, base sur des regles).
///
/// Nomme honnetement "Coach" : les reponses sont generees localement a partir
/// de vos statistiques. Point d'extension prevu pour une vraie IA (voir
/// [CoachEngine]).
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _ChatMessage {
  final String text;
  final bool fromCoach;
  _ChatMessage(this.text, {required this.fromCoach});
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CoachEngine _engine = const CoachEngine();
  final List<_ChatMessage> _messages = [];

  static const _welcome =
      'Bonjour ! 👋 Je suis votre coach de productivité. '
      'Comment puis-je vous aider à organiser votre journée ?';

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(_welcome, fromCoach: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? preset]) {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    final summary = context.read<StatsProvider>().summary;

    setState(() {
      _messages.add(_ChatMessage(text, fromCoach: false));
      _messages.add(_ChatMessage(_engine.respond(text, summary), fromCoach: true));
    });
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Coach')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Chip('Planifier ma journée', () => _send('Comment planifier ma journée ?')),
                const SizedBox(width: 8),
                _Chip('Mes statistiques', () => _send('Montre-moi mes stats')),
                const SizedBox(width: 8),
                _Chip('Conseils', () => _send('Donne-moi des conseils')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment:
                      m.fromCoach ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: m.fromCoach
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.fromCoach
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Posez votre question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    tooltip: 'Envoyer',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
