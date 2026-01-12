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
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final inputId = _idController.text.trim();
    final repo = LocalLeaguesRepository(ref.read(prefsServiceProvider));
    
    // We don't have a global search yet, so this is a placeholder
    // for future logic. For now, we'll just show a message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for match: $inputId')),
    );
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
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Match ID',
                      hintText: 'e.g. M-L-3307-0',
                    ),
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
