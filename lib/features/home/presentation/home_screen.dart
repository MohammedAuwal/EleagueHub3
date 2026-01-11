import 'package:flutter/material.dart';
import 'home_shell.dart';

/// HomeScreen: Entry point for the Home feature
/// Simply renders the HomeShell with bottom navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeShell();
  }
}
