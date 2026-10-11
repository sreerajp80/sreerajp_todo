import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/core/network/network_address_utils.dart';

void main() {
  group('isLocalNetworkAddress', () {
    test('accepts private, link-local and loopback addresses', () {
      for (final ip in [
        '10.0.0.1',
        '10.255.255.255',
        '172.16.0.1',
        '172.31.255.254',
        '192.168.1.20',
        '169.254.10.10',
        '127.0.0.1',
        ' 192.168.0.5 ',
      ]) {
        expect(isLocalNetworkAddress(ip), isTrue, reason: ip);
      }
    });

    test('rejects public addresses', () {
      for (final ip in [
        '8.8.8.8',
        '1.1.1.1',
        '172.15.255.255',
        '172.32.0.1',
        '192.169.0.1',
        '169.253.0.1',
        '100.64.0.1',
        '0.0.0.0',
        '255.255.255.255',
      ]) {
        expect(isLocalNetworkAddress(ip), isFalse, reason: ip);
      }
    });

    test('rejects host names, IPv6 and malformed input', () {
      for (final ip in [
        '',
        'localhost',
        'example.com',
        '::1',
        'fe80::1',
        '192.168.1',
        '192.168.1.1.1',
        '192.168.1.256',
        '192.168.-1.1',
        '192.168.1.1a',
        '192.168..1',
        '1000.1.1.1',
      ]) {
        expect(isLocalNetworkAddress(ip), isFalse, reason: ip);
      }
    });
  });
}
