import '../storage/secure_storage.dart';

/// Persistent, escalating lockout for wrong PIN attempts. State lives in secure
/// storage so it survives app restarts (an attacker can't reset the counter by
/// force-quitting), and the delay grows the more attempts are made — capping
/// brute force of the 10 000-combination PIN space.
class LockoutService {
  LockoutService(this._storage);

  final SecureStorage _storage;

  static const String _kCount = 'pin_fail_count';
  static const String _kUntil = 'pin_lock_until';

  int Function() _now = () => DateTime.now().millisecondsSinceEpoch;

  /// Test seam.
  // ignore: use_setters_to_change_properties
  void debugSetClock(int Function() now) => _now = now;

  /// Remaining lockout, or null if attempts are currently allowed.
  Future<Duration?> lockRemaining() async {
    final until = int.tryParse(await _storage.read(_kUntil) ?? '');
    if (until == null) return null;
    final remain = until - _now();
    return remain > 0 ? Duration(milliseconds: remain) : null;
  }

  /// Records a wrong attempt and returns the new consecutive-failure count.
  Future<int> recordFailure() async {
    final count = (int.tryParse(await _storage.read(_kCount) ?? '') ?? 0) + 1;
    await _storage.write(_kCount, '$count');
    final backoff = _backoffFor(count);
    if (backoff != null) {
      await _storage.write(_kUntil, '${_now() + backoff.inMilliseconds}');
    }
    return count;
  }

  /// Clears all lockout state after a successful unlock.
  Future<void> reset() async {
    await _storage.delete(_kCount);
    await _storage.delete(_kUntil);
  }

  Duration? _backoffFor(int count) {
    if (count < 5) return null;
    if (count < 10) return const Duration(seconds: 30);
    if (count < 15) return const Duration(minutes: 5);
    if (count < 20) return const Duration(minutes: 30);
    return const Duration(hours: 1);
  }
}
