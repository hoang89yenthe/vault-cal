import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// PBKDF2-HMAC-SHA256 hashing for the secret code and PINs.
///
/// Format stored in secure storage: `pbkdf2$<iterations>$<saltB64>$<hashB64>`.
class PinHasher {
  // ignore: prefer_initializing_formals
  PinHasher({int iterations = 150000}) : _iterations = iterations;

  final int _iterations;
  static const int _saltLength = 16;
  static const int _hashLength = 32;

  Future<String> hash(String code) async {
    final salt = _randomBytes(_saltLength);
    final derived = await _derive(code, salt);
    return 'pbkdf2\$$_iterations\$${base64.encode(salt)}\$${base64.encode(derived)}';
  }

  Future<bool> verify(String code, String stored) async {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2') return false;
    final iterations = int.tryParse(parts[1]);
    if (iterations == null) return false;
    final salt = base64.decode(parts[2]);
    final expected = base64.decode(parts[3]);
    final derived = await _derive(code, salt, iterations: iterations);
    return _constantTimeEquals(derived, expected);
  }

  Future<Uint8List> _derive(
    String code,
    List<int> salt, {
    int? iterations,
  }) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations ?? _iterations,
      bits: _hashLength * 8,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(code)),
      nonce: salt,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
