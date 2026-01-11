import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/glass_scaffold.dart';
import '../../leagues/data/leagues_repository_mock.dart';

class JoinMatchScreen extends StatefulWidget {
  const JoinMatchScreen({super.key});

  @override
  State<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends State<JoinMatchScreen> {
  final _id = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _repo = LeaguesRepositoryMock();

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  void _join() {
    final input = _id.text.trim();
    // Check if match exists
    final exists = _repo.fixtures('').any((f) => f.matchId == input);
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Match ID')),
      );
      return;
    }

    // Navigate to match view
    context.push('/live/view/$input');
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Join via Match ID')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                      decoration: const InputDecoration(
                        labelText: 'Match ID',
                        hintText: 'e.g. M-L-3307-0',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a match ID'
                          : null,
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
      ),
    );
  }
}
