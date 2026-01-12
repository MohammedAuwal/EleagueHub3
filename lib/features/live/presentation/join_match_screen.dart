import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/persistence/prefs_service.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import "../../leagues/data/leagues_repository_local.dart";

class JoinMatchScreen extends ConsumerStatefulWidget {
  const JoinMatchScreen({super.key});

  @override
  ConsumerState<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends ConsumerState<JoinMatchScreen> {
  final _id = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  void _join() {
    final repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    final input = _id.text.trim();
    
    // Safety check for empty input
    if (input.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining match $input...')),
    );
    context.push('/live/view/$input');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Join via Match ID')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Glass(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _id,
                    decoration: const InputDecoration(labelText: 'Match ID'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a match ID' : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) _join();
                      },
                      child: const Text('Join'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
