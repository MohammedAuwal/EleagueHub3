import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    _isScanned = true;
    
    // Using GoRouter's pop to return the value
    context.pop(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Feed
          MobileScanner(
            onDetect: _onDetect,
          ),

          // 2. The Glass "Hole" Overlay
          // We use BackdropFilter for the blur, but we must exclude the center
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          // 3. Punching a hole in the blur for the scanner view
          Center(
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.dstOut,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // 4. Scanner Frame Decoration
          Center(
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          // 5. UI Controls
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => context.pop(),
            ),
          ),

          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Center the QR code within the frame',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(10) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(10) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(10) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(10) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
