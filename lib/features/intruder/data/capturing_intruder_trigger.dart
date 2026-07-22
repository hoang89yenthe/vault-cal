import 'dart:async';

import '../../../core/storage/local_storage.dart';
import '../../purchases/domain/purchase_service.dart';
import '../data/services/selfie_capture_service.dart';
import '../domain/intruder_trigger.dart';
import '../domain/repositories/intruder_repository.dart';

/// Fires on repeated wrong PINs: if the premium Intruder Selfie feature is
/// enabled, captures a front-camera photo and records the event. Fully
/// fire-and-forget — never blocks or reveals the unlock flow.
class CapturingIntruderTrigger implements IntruderTrigger {
  CapturingIntruderTrigger(
    this._storage,
    this._purchases,
    this._capture,
    this._repository,
  );

  static const String _intruderKey = 'settings_intruder';

  final LocalStorage _storage;
  final PurchaseService _purchases;
  final SelfieCaptureService _capture;
  final IntruderRepository _repository;

  @override
  void onFailedAttempts(int attemptCount) {
    final enabled = _storage.getBool(_intruderKey) ?? false;
    if (!enabled || !_purchases.isPremium) return;
    // Detached so it can never block the PIN screen.
    unawaited(_run(attemptCount));
  }

  Future<void> _run(int attemptCount) async {
    final photo = await _capture.capture();
    await _repository.record(attemptCount: attemptCount, photo: photo);
  }
}
