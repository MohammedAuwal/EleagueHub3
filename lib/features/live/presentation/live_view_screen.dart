import 'package:flutter/material.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({
    super.key,
    required this.matchId,
    required this.isHost,
  });

  /// Live Match ID that viewers joined with (or host started for).
  final String matchId;

  /// Whether this device is the host (caster) or a viewer.
  final bool isHost;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  final _chat = TextEditingController();
  final _messages = <String>['Welcome to the live match.'];

  int _viewers = 96; // TODO: replace with real viewer count from backend.

  @override
  void dispose() {
    _chat.dispose();
    // In the future, call LocalLiveService.stopHostSession/leaveViewerSession here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width > 700;

    return GlassScaffold(
      appBar: AppBar(
        title: Text(
          widget.isHost
              ? 'Host Live • ${widget.matchId}'
              : 'Live Match • ${widget.matchId}',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? _buildWideLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  /// Layout for tablets / large screens: stream on the left, chat on the right.
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                child: _buildStreamArea(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _ChatOverlay(
            messages: _messages,
            chatController: _chat,
            onSend: _send,
            onReaction: _react,
          ),
        ),
      ],
    );
  }

  /// Layout for phones: stream on top, chat overlay at the bottom.
  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 180),
          child: _buildStreamArea(context),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _ChatOverlay(
            messages: _messages,
            chatController: _chat,
            onSend: _send,
            onReaction: _react,
          ),
        ),
      ],
    );
  }

  Widget _buildStreamArea(BuildContext context) {
    return Glass(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Placeholder for actual media stream / screen cast.
          Center(
            child: Text(
              widget.isHost
                  ? 'Host view\n\nTODO: integrate real screen/RTC streaming here.'
                  : 'Viewer view\n\nTODO: show real stream from host.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
          // Viewer count + live badge (top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Glass(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 999,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_viewers',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Match ID / info (top-left)
          Positioned(
            top: 8,
            left: 8,
            child: Glass(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 999,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.tag,
                    size: 14,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.matchId,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
      _viewers += 1; // mock increment for now
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
                final msg =
                    messages[messages.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
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
                ('Clutch',
                    Icons.local_fire_department_outlined),
              ].map(
                (e) => Padding(
                  padding:
                      const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () => onReaction(e.$1),
                    icon: Icon(e.$2, size: 20),
                    color: Colors.cyanAccent,
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
                  style: const TextStyle(color: Colors.white),
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
