import 'package:flutter/material.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key, required this.matchId});

  final String matchId;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _chat = TextEditingController();
  final _messages = <String>['Welcome to live chat (mock).'];

  int _viewers = 96;

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: Text('Live • ${widget.matchId}')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
            child: Glass(
              child: Center(
                child: Text(
                  'Live viewing placeholder\n\nTODO(backend): stream/RTC + real-time state',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Glass(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: 999,
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('$_viewers'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _ChatOverlay(
              messages: _messages,
              chatController: _chat,
              onSend: _send,
              onReaction: _react,
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final txt = _chat.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add('You: $txt');
      _chat.clear();
    });
  }

  void _react(String emojiLike) {
    setState(() {
      _messages.add('Reaction: $emojiLike');
      _viewers += 1; // mock
    });
  }
}

class _ChatOverlay extends StatelessWidget {
  const _ChatOverlay({
    required this.messages,
    required this.chatController,
    required this.onSend,
    required this.onReaction,
  });

  final List<String> messages;
  final TextEditingController chatController;
  final VoidCallback onSend;
  final void Function(String) onReaction;

  @override
  Widget build(BuildContext context) {
    return Glass(
      padding: const EdgeInsets.all(12),
      borderRadius: 22,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[messages.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(msg),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...[
                ('GG', Icons.emoji_events_outlined),
                ('Wow', Icons.flash_on_outlined),
                ('Clutch', Icons.local_fire_department_outlined),
              ].map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => onReaction(e.$1),
                    icon: Icon(e.$2, size: 20),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSend,
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
