import '../../../core/utils/result.dart';

enum PurchasePlan { yearly, lifetime }

/// Premium entitlement gate. Swap [MockPurchaseService] for an
/// `in_app_purchase`-backed implementation to go live — nothing else changes.
abstract interface class PurchaseService {
  bool get isPremium;

  /// Emits the current entitlement and every change.
  Stream<bool> get premiumStream;

  Future<Result<void>> buy(PurchasePlan plan);

  Future<Result<void>> restore();
}
