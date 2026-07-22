import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault_cal/core/storage/local_storage.dart';
import 'package:vault_cal/features/purchases/data/mock_purchase_service.dart';
import 'package:vault_cal/features/purchases/domain/purchase_service.dart';

void main() {
  late LocalStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage(await SharedPreferences.getInstance());
  });

  test('starts non-premium and becomes premium after buy', () async {
    final service = MockPurchaseService(storage);
    expect(service.isPremium, isFalse);

    await service.buy(PurchasePlan.yearly);
    expect(service.isPremium, isTrue);
  });

  test('premiumStream emits the entitlement change', () async {
    final service = MockPurchaseService(storage);
    final future = service.premiumStream.firstWhere((v) => v == true);
    await service.buy(PurchasePlan.lifetime);
    expect(await future, isTrue);
  });

  test('persists premium across instances', () async {
    await MockPurchaseService(storage).buy(PurchasePlan.yearly);
    final reopened = MockPurchaseService(storage);
    expect(reopened.isPremium, isTrue);
  });
}
