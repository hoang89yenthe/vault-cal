import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../purchases/domain/purchase_service.dart';
import '../../../vault/presentation/theme/vault_colors.dart';

/// IAP paywall bottom sheet. Backed by [PurchaseService]; swap the mock for an
/// `in_app_purchase` implementation to go live.
Future<void> showPaywall(BuildContext context) {
  final l10n = context.l10n;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VaultColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (sheetContext) {
      return _PaywallBody(l10n: l10n);
    },
  );
}

class _PaywallBody extends StatefulWidget {
  const _PaywallBody({required this.l10n});

  final dynamic l10n;

  @override
  State<_PaywallBody> createState() => _PaywallBodyState();
}

class _PaywallBodyState extends State<_PaywallBody> {
  bool _busy = false;
  PurchasePlan _selected = PurchasePlan.yearly;

  Future<void> _buy() async {
    setState(() => _busy = true);
    await getIt<PurchaseService>().buy(_selected);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã kích hoạt Premium 🎉')));
    Navigator.of(context).pop();
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await getIt<PurchaseService>().restore();
    if (mounted) setState(() => _busy = false);
  }

  /// Store price for [plan] when the real IAP has loaded it, else the built-in
  /// fallback string.
  String _priceFor(PurchasePlan plan, String fallback) {
    for (final p in getIt<PurchaseService>().prices) {
      if (p.plan == plan) return p.price;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: VaultColors.gold,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 32,
                color: Color(0xFF1B1810),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.premiumTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: VaultColors.text,
              ),
            ),
            const SizedBox(height: 18),
            for (final feature in [
              l10n.paywallFeature1,
              l10n.paywallFeature2,
              l10n.paywallFeature3,
              l10n.paywallFeature4,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: VaultColors.gold,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: VaultColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PlanCard(
                    title: l10n.planYearTitle,
                    price: _priceFor(PurchasePlan.yearly, l10n.planYearPrice),
                    badge: l10n.saveBadge,
                    highlighted: _selected == PurchasePlan.yearly,
                    onTap: () =>
                        setState(() => _selected = PurchasePlan.yearly),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PlanCard(
                    title: l10n.planLifetimeTitle,
                    price: _priceFor(
                      PurchasePlan.lifetime,
                      l10n.planLifetimePrice,
                    ),
                    highlighted: _selected == PurchasePlan.lifetime,
                    onTap: () =>
                        setState(() => _selected = PurchasePlan.lifetime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _busy ? null : _buy,
                style: FilledButton.styleFrom(
                  backgroundColor: VaultColors.gold,
                  foregroundColor: const Color(0xFF1B1810),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1B1810),
                        ),
                      )
                    : Text(
                        l10n.startTrial,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy ? null : _restore,
              child: Text(
                l10n.restorePurchase,
                style: const TextStyle(
                  fontSize: 13,
                  color: VaultColors.textSub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.onTap,
    this.badge,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final VoidCallback onTap;
  final String? badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: VaultColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? VaultColors.gold : VaultColors.cardBorder,
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed-height badge row so both cards stay the same height and
            // align, whether or not they carry a "SAVE" badge.
            SizedBox(
              height: 20,
              child: badge == null
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: VaultColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B1810),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: VaultColors.textSub),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: VaultColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
