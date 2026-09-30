/// Returns true only when [ip] is an IPv4 address on the local network.
///
/// Wi-Fi sync is the only feature that opens sockets. It may talk only to
/// the user's own devices, so every address it connects to or accepts must
/// pass this check. Allowed ranges:
///
/// - `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (private networks)
/// - `169.254.0.0/16` (link-local)
/// - `127.0.0.0/8` (loopback)
///
/// Host names, IPv6 and malformed input return false, so nothing is ever
/// resolved through DNS.
bool isLocalNetworkAddress(String ip) {
  final parts = ip.trim().split('.');
  if (parts.length != 4) return false;

  final octets = <int>[];
  for (final part in parts) {
    if (!RegExp(r'^\d{1,3}$').hasMatch(part)) return false;
    final value = int.parse(part);
    if (value > 255) return false;
    octets.add(value);
  }

  final a = octets[0];
  final b = octets[1];
  if (a == 10) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  if (a == 192 && b == 168) return true;
  if (a == 169 && b == 254) return true;
  if (a == 127) return true;
  return false;
}
