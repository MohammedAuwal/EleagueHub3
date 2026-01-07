import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_bubble_background.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.fab,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: fab,
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(brightness),
            ),
            child: const SizedBox.expand(),
          ),
          const Positioned.fill(child: AnimatedBubbleBackground()),
          SafeArea(child: body),
        ],
      ),
    );
  }
}
