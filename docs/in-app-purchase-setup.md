# In-App Purchase (Premium) setup

The app has a `PurchaseService` abstraction with two implementations:

- `MockPurchaseService` — default; buying just flips a local flag (dev/demo).
- `InAppPurchaseService` — real StoreKit (iOS) / Play Billing (Android).

## Switching to the real service

The DI binding picks the real service at build time:

```
flutter run     --dart-define=REAL_IAP=true
flutter build … --dart-define=REAL_IAP=true
```

Without the flag it stays on the mock, so a fresh checkout still runs.

## Product IDs (must match the stores)

| Plan | ID | Type |
|---|---|---|
| Yearly | `vault_premium_yearly` | Auto-renewable subscription |
| Lifetime | `vault_premium_lifetime` | Non-consumable |

(Change these in `lib/features/purchases/data/in_app_purchase_service.dart`.)

## Store configuration

**App Store Connect**
1. Agreements, Tax, and Banking must be active.
2. Create the two products with the IDs above; submit for review with the app.
3. The Runner target's App ID must have In-App Purchase enabled (default).
4. Test with a Sandbox tester account.

**Google Play Console**
1. Create a subscription (`vault_premium_yearly`) and an in-app product
   (`vault_premium_lifetime`).
2. Upload a signed release to a testing track (needs the real keystore — see
   `android/README-signing.md`).
3. Add license testers. The `com.android.vending.BILLING` permission is added
   automatically by the plugin.

## Before shipping (important)

`InAppPurchaseService._handlePurchase` currently grants premium as soon as the
store reports `purchased`/`restored`. For production, **verify the receipt
server-side** (`PurchaseDetails.verificationData`) against Apple/Google — or use
a service like RevenueCat — before granting, to stop trivial client-side
entitlement forgery. See the TODO in that method.

The paywall automatically shows the store's localized price
(`ProductDetails.price`) when the real service has loaded products, falling back
to the hard-coded strings otherwise.
