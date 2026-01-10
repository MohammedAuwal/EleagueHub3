import 'package:flutter/material.dart';

/// Draws the connector lines between tournament rounds.
class BracketPainter extends CustomPainter {
  final int matchCount;
  final bool isLeftToRight;

  BracketPainter({required this.matchCount, this.isLeftToRight = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double xStart = isLeftToRight ? 0 : size.width;
    double xEnd = isLeftToRight ? size.width : 0;
    double xMid = size.width / 2;

    for (int i = 0; i < matchCount; i++) {
      // Logic for vertical spacing and horizontal "forks"
      double y = (size.height / matchCount) * (i + 0.5);
      
      canvas.drawLine(Offset(xStart, y), Offset(xMid, y), paint);
      // Connect top and bottom matches to a single point in the next round
      if (i % 2 == 0) {
        double nextY = (size.height / matchCount) * (i + 1);
        canvas.drawLine(Offset(xMid, y), Offset(xMid, nextY + (size.height / matchCount) * 0.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
