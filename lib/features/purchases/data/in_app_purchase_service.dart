import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/error/failures.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';
import '../domain/purchase_service.dart';

/// Real StoreKit (iOS) / Play Billing (Android) implementation of
/// [PurchaseService].
///
/// Store setup required before this works end to end:
///   • App Store Connect: create the products with the IDs below (a
///     non-consumable "lifetime" and an auto-renewable "yearly" subscription).
///   • Play Console: create matching in-app products / a subscription.
///   • iOS: add the "In-App Purchase" capability to the Runner target.
///
/// Entitlement is persisted locally after a purchased/restored callback so it
/// survives restarts. For production, verify [PurchaseDetails.verificationData]
/// against Apple/Google server-side (or RevenueCat) before granting — see the
/// TODO in [_handlePurchase].
class InAppPurchaseService implements PurchaseService {
  InAppPurchaseService(this._storage) {
    _premium = _storage.getBool(_entitlementKey) ?? false;
    _controller = StreamController<bool>.broadcast(
      onListen: () => _controller.add(_premium),
    );
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdates, onError: (_) {});
    unawaited(_loadProducts());
  }

  static const String yearlyId = 'vault_premium_yearly';
  static const String lifetimeId = 'vault_premium_lifetime';
  static const Set<String> _productIds = {yearlyId, lifetimeId};
  static const String _entitlementKey = 'premium_active';

  final LocalStorage _storage;
  final InAppPurchase _iap = InAppPurchase.instance;

  late final StreamController<bool> _controller;
  late final StreamSubscription<List<PurchaseDetails>> _sub;

  final Map<String, ProductDetails> _products = {};
  bool _premium = false;

  @override
  bool get isPremium => _premium;

  @override
  Stream<bool> get premiumStream => _controller.stream;

  @override
  List<PlanPrice> get prices => [
    for (final entry in _planToProduct.entries)
      if (_products[entry.value] case final p?)
        PlanPrice(plan: entry.key, price: p.price),
  ];

  static const Map<PurchasePlan, String> _planToProduct = {
    PurchasePlan.yearly: yearlyId,
    PurchasePlan.lifetime: lifetimeId,
  };

  Future<void> _loadProducts() async {
    if (!await _iap.isAvailable()) return;
    final response = await _iap.queryProductDetails(_productIds);
    for (final p in response.productDetails) {
      _products[p.id] = p;
    }
    // Re-sync any prior entitlement (also drives the pending-purchase stream).
    await _iap.restorePurchases();
  }

  @override
  Future<Result<void>> buy(PurchasePlan plan) async {
    final product = _products[_planToProduct[plan]];
    if (product == null) {
      return const Err(ServerFailure('Sản phẩm chưa sẵn sàng, thử lại sau'));
    }
    final param = PurchaseParam(productDetails: product);
    try {
      // Both plans are non-consumable entitlements (subscription / lifetime).
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      // The real outcome arrives asynchronously via [_onPurchaseUpdates].
      return started
          ? const Ok(null)
          : const Err(ServerFailure('Không thể bắt đầu thanh toán'));
    } on Object catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> restore() async {
    try {
      await _iap.restorePurchases();
      return const Ok(null);
    } on Object catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // TODO(store): verify purchase.verificationData server-side before
        // granting entitlement in production.
        await _grantPremium();
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
      case PurchaseStatus.pending:
        break;
    }
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<void> _grantPremium() async {
    if (_premium) return;
    _premium = true;
    await _storage.setBool(_entitlementKey, value: true);
    _controller.add(true);
  }

  void dispose() {
    _sub.cancel();
    _controller.close();
  }
}
