import '../../../core/utils/result.dart';

enum PurchasePlan { yearly, lifetime }

/// Localized store price for a plan (from the store when available).
class PlanPrice {
  const PlanPrice({required this.plan, required this.price});

  final PurchasePlan plan;

  /// Store-formatted price string (e.g. "99.000₫"), or null if unavailable.
  final String price;
}

/// Premium entitlement gate. [MockPurchaseService] is used for development;
/// [InAppPurchaseService] is the real StoreKit / Play Billing implementation —
/// swap the DI binding to go live.
abstract interface class PurchaseService {
  bool get isPremium;

  /// Emits the current entitlement and every change.
  Stream<bool> get premiumStream;

  /// Store prices when available (empty for the mock / before products load).
  List<PlanPrice> get prices;

  Future<Result<void>> buy(PurchasePlan plan);

  Future<Result<void>> restore();
}
