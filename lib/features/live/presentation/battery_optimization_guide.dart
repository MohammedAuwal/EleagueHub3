import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/glass.dart';

class BatteryOptimizationGuide {
  static const _ch = MethodChannel('local_live');

  static Future<Map<String, dynamic>> _deviceInfo() async {
    if (!Platform.isAndroid) return {};
    final res = await _ch.invokeMethod('getDeviceInfo');
    if (res is Map) return res.cast<String, dynamic>();
    return {};
  }

  static Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    await _ch.invokeMethod('openBatteryOptimizationSettings');
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;
    await _ch.invokeMethod('requestIgnoreBatteryOptimizations');
  }

  static Future<void> openAppDetailsSettings() async {
    if (!Platform.isAndroid) return;
    await _ch.invokeMethod('openAppDetailsSettings');
  }

  static Future<void> show(BuildContext context) async {
    final info = await _deviceInfo();
    final manufacturer = (info['manufacturer'] ?? '').toString().toLowerCase();
    final brand = (info['brand'] ?? '').toString().toLowerCase();
    final model = (info['model'] ?? '').toString();

    final vendor = (manufacturer.isNotEmpty ? manufacturer : brand);

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 12,
            top: 12,
          ),
          child: Glass(
            borderRadius: 22,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Fix Background Streaming (Battery Optimization)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Device: ${vendor.isEmpty ? 'Android' : vendor.toUpperCase()} ${model.isNotEmpty ? "• $model" : ""}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If your stream stops when you open the game, your phone is killing the app in background.\n'
                    'Do these steps once:',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 12),

                  _StepsBox(text: _stepsForVendor(vendor)),

                  const SizedBox(height: 12),
                  const Text(
                    'Quick buttons:',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  FilledButton.icon(
                    onPressed: requestIgnoreBatteryOptimizations,
                    icon: const Icon(Icons.battery_saver),
                    label: const Text('REQUEST “IGNORE BATTERY OPTIMIZATION”'),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: openBatteryOptimizationSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('OPEN BATTERY OPTIMIZATION SETTINGS'),
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: openAppDetailsSettings,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('OPEN APP SETTINGS (AUTO-START / BACKGROUND)'),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Colors.white10),

                  const Text(
                    'Notes:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• Some games block screen capture (protected content). In that case viewers may see black screen.\n'
                    '• Keep the streaming notification ON while broadcasting.\n'
                    '• For best results, don’t “Force stop” the app during a live stream.',
                    style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
                  ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(color: Colors.cyanAccent)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _stepsForVendor(String vendor) {
    vendor = vendor.toLowerCase();

    // Many Tecno/Infinix are Transsion (XOS/HiOS); Oppo/Realme/OnePlus share similar flows.
    if (vendor.contains('samsung')) {
      return '''
Samsung:
1) Settings → Battery and device care → Battery
2) Background usage limits → Never sleeping apps → add this app
3) Also check: Settings → Apps → (this app) → Battery → Allow background activity
''';
    }

    if (vendor.contains('huawei') || vendor.contains('honor')) {
      return '''
Huawei / Honor:
1) Settings → Battery → App launch
2) Find this app → set to “Manage manually”
3) Enable: Auto-launch, Secondary launch, Run in background
''';
    }

    if (vendor.contains('oppo') || vendor.contains('realme') || vendor.contains('oneplus')) {
      return '''
OPPO / realme / OnePlus:
1) Settings → Battery → More battery settings / App battery management
2) Find this app → Allow background activity
3) Also enable Auto-launch (often in: Settings → Apps → Auto-start)
''';
    }

    if (vendor.contains('infinix') || vendor.contains('tecno') || vendor.contains('itel') || vendor.contains('transsion')) {
      return '''
Infinix / Tecno / itel (HiOS/XOS):
1) Settings → Battery / Power Marathon → turn OFF aggressive saving for this app
2) Settings → Apps → (this app) → Battery → Allow background activity
3) Enable Auto-start / Background launch if available
4) Also whitelist the app in “Phone Master” / “Device Manager”
''';
    }

    // Generic fallback
    return '''
Generic Android:
1) Settings → Battery → Battery optimization
2) Find this app → set to “Don’t optimize”
3) Settings → Apps → (this app) → Battery → Allow background activity
4) If you have Auto-start settings, enable it for this app
''';
  }
}

class _StepsBox extends StatelessWidget {
  const _StepsBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text.trim(),
        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
      ),
    );
  }
}
