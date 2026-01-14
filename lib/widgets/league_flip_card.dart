import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Glass flip card
/// Fixes:
/// - mirrored/backside content issue by ensuring only the back face is flipped
/// Adds:
/// - optional qrWidget
/// - copy invite code
/// - double-tap callback (navigate to details)
class LeagueFlipCard extends StatefulWidget {
  final String leagueName;
  final String leagueCode;
  final String distribution;

  final Widget? qrWidget;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTap;
  final String? subtitle;

  const LeagueFlipCard({
    super.key,
    required this.leagueName,
    required this.leagueCode,
    required this.distribution,
    this.qrWidget,
    this.onDoubleTap,
    this.onTap,
    this.subtitle,
  });

  @override
  State<LeagueFlipCard> createState() => _LeagueFlipCardState();
}

class _LeagueFlipCardState extends State<LeagueFlipCard> {
  bool _isFront = true;

  void _flipCard() {
    setState(() => _isFront = !_isFront);
    widget.onTap?.call();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.leagueCode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      onDoubleTap: widget.onDoubleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            child: (isUnder) ? Transform(transform: Matrix4.rotationY(3.14159), alignment: Alignment.center, child: child) : child,
            builder: (context, child) {
              final angle = animation.value * pi;

              // Important fix:
              // During the switch, one widget is under the other.
              // We only rotate the "incoming/outgoing" faces correctly,
              // and we do not double-flip the back content.
              final isUnder = (child!.key != ValueKey(_isFront));
              var tilt = 0.002;
              if (isUnder) tilt = -tilt;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, tilt)
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: (isUnder) ? Transform(transform: Matrix4.rotationY(3.14159), alignment: Alignment.center, child: child) : child,
              );
            },
          );
        },
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        child: _isFront ? _buildFront() : _buildBack(),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, required Key key}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: (isUnder) ? Transform(transform: Matrix4.rotationY(3.14159), alignment: Alignment.center, child: child) : child,
        ),
      ),
    );
  }

  Widget _buildFront() {
    return _buildGlassContainer(
      key: const ValueKey(true),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined, color: Colors.amber, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            widget.leagueName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.distribution,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle!,
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 16, color: Colors.cyanAccent.withOpacity(0.8)),
              const SizedBox(width: 8),
              const Text(
                "TAP TO JOIN / SCAN QR",
                style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _buildGlassContainer(
      key: const ValueKey(false),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: widget.qrWidget ??
                      const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "INVITE CODE",
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.leagueCode,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text("COPY"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
