import 'dart:async';

import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../domain/purchase_service.dart';

/// In-memory / persisted premium gate for development. Buying flips a flag in
/// [LocalStorage] after a short fake latency and broadcasts the change.
class MockPurchaseService implements PurchaseService {
  MockPurchaseService(this._storage) {
    _premium = _storage.getBool(_key) ?? false;
    _controller = StreamController<bool>.broadcast(
      onListen: () => _controller.add(_premium),
    );
  }

  static const String _key = 'premium_active';
  static const Duration _fakeLatency = Duration(milliseconds: 800);

  final LocalStorage _storage;
  late final StreamController<bool> _controller;
  bool _premium = false;

  @override
  bool get isPremium => _premium;

  @override
  Stream<bool> get premiumStream => _controller.stream;

  @override
  Future<Result<void>> buy(PurchasePlan plan) async {
    await Future<void>.delayed(_fakeLatency);
    await _setPremium(true);
    return const Ok(null);
  }

  @override
  Future<Result<void>> restore() async {
    await Future<void>.delayed(_fakeLatency);
    // Nothing to restore in the mock unless already purchased on this device.
    _controller.add(_premium);
    return const Ok(null);
  }

  Future<void> _setPremium(bool value) async {
    _premium = value;
    await _storage.setBool(_key, value: value);
    _controller.add(value);
  }

  void dispose() => _controller.close();
}
