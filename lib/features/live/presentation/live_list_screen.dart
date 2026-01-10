import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LiveListScreen extends StatelessWidget {
  const LiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Matches")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/live/join'),
          child: const Text("Join Match"),
        ),
      ),
    );
  }
}
