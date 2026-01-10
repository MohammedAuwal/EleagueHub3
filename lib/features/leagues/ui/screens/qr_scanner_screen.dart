import 'package:flutter/material.dart';
import 'dart:ui';

/// A high-end QR Scanner with a Glassmorphism overlay for eSportlyic.
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. The Camera Layer (Placeholder for MobileScanner)
          Container(
            color: Colors.black,
            child: const Center(
              child: Text("Camera Feed Here", style: TextStyle(color: Colors.white24)),
            ),
          ),
          
          // 2. The Glassmorphism Overlay
          _buildGlassOverlay(context),

          // 3. Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassOverlay(BuildContext context) {
    return Stack(
      children: [
        // Frosted background with a hole in the middle
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Blurred edges
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.transparent),
        ),

        // Scanning Frame Borders
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                _buildCorner(0, 0), // Top Left
                _buildCorner(0, 1), // Top Right
                _buildCorner(1, 0), // Bottom Left
                _buildCorner(1, 1), // Bottom Right
              ],
            ),
          ),
        ),

        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Text(
              "Align QR code within the frame",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(double top, double left) {
    return Positioned(
      top: top == 0 ? -2 : null,
      bottom: top == 1 ? -2 : null,
      left: left == 0 ? -2 : null,
      right: left == 1 ? -2 : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0 ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            bottom: top == 1 ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            left: left == 0 ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
            right: left == 1 ? const BorderSide(color: Colors.cyanAccent, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
