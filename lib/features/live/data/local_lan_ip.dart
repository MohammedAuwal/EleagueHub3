import 'dart:io';

class LocalLanIp {
  static Future<String?> findLocalIpv4() async {
    try {
      final ifaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );

      for (final iface in ifaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (_isPrivateV4(ip)) return ip;
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  static bool _isPrivateV4(String ip) {
    // 10.0.0.0/8
    if (ip.startsWith('10.')) return true;

    // 192.168.0.0/16
    if (ip.startsWith('192.168.')) return true;

    // 172.16.0.0 - 172.31.255.255
    if (ip.startsWith('172.')) {
      final parts = ip.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]) ?? -1;
        if (second >= 16 && second <= 31) return true;
      }
    }

    return false;
  }
}
