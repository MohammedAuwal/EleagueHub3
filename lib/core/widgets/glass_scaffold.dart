import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Base scaffold used across the app
/// Provides gradient background + safe glass layering
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBody = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Gradient background layer
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient(brightness),
              ),
            ),
          ),

          // Main content
          SafeArea(
            top: appBar == null,
            bottom: true,
            child: body,
          ),
        ],
      ),
    );
  }
}
