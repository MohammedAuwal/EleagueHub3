import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../data/local_live_service.dart';

class JoinMatchScreen extends ConsumerStatefulWidget {
  const JoinMatchScreen({super.key});

  @override
  ConsumerState<JoinMatchScreen> createState() =>
      _JoinMatchScreenState();
}

class _JoinMatchScreenState
    extends ConsumerState<JoinMatchScreen> {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final input = _idController.text.trim();
    if (input.isEmpty) return;

    try {
      await LocalLiveService.instance.joinViewerSession(
        liveMatchId: input,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join live session: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining live match $input...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.push('/live/view/$input', extra: false);
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width > 600;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Join Live Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : 420,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Glass(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter Live Match ID',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ask the host player for the Live Match ID, '
                        'or use the code shared with your league. '
                        'You will join the live view for that match.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _idController,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Live Match ID',
                          hintText: 'e.g. ABC123 or match-uuid',
                        ),
                        validator: (v) => (v == null ||
                                v.trim().isEmpty)
                            ? 'Enter a Live Match ID'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!
                                .validate()) {
                              _join();
                            }
                          },
                          label: const Text(
                            'JOIN LIVE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tip: The Live Match ID can be shared from the match '
                        'details screen when the host starts casting.',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
