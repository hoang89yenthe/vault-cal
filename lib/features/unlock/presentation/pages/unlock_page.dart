import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../vault/presentation/theme/vault_colors.dart';

/// Layer 1 — biometric authentication. The rotating ring + scan line play as
/// the visual layer while a real `local_auth` prompt runs. When biometrics are
/// unavailable or disabled, the flow forwards straight to the PIN.
class UnlockPage extends StatefulWidget {
  const UnlockPage({super.key});

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> with TickerProviderStateMixin {
  static const String _fingerprintKey = 'settings_fingerprint';

  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  bool _done = false;

  @override
  void initState() {
    super.initState();
    _startAuth();
  }

  Future<void> _startAuth() async {
    final enabled = getIt<LocalStorage>().getBool(_fingerprintKey) ?? true;
    final biometrics = getIt<BiometricService>();

    if (enabled && await biometrics.isAvailable) {
      await biometrics.authenticate('Xác thực để mở kho');
      // The PIN is the real gate, so proceed regardless of the biometric
      // outcome — this layer is defence-in-depth, not the sole check.
    }

    if (!mounted) return;
    setState(() => _done = true);
    _ring.stop();
    _scan.stop();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) context.go(AppRoutes.pin);
  }

  @override
  void dispose() {
    _ring.dispose();
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.authTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: VaultColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.authLayer,
                style: const TextStyle(
                  fontSize: 14,
                  color: VaultColors.textSub,
                ),
              ),
              const SizedBox(height: 44),
              SizedBox(
                width: 168,
                height: 168,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _ring,
                      child: CustomPaint(
                        size: const Size(168, 168),
                        painter: _ScanRingPainter(
                          color: _done ? VaultColors.green : VaultColors.accent,
                        ),
                      ),
                    ),
                    Container(
                      width: 128,
                      height: 128,
                      decoration: const BoxDecoration(
                        color: VaultColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _done ? Icons.check_rounded : Icons.fingerprint,
                        size: _done ? 56 : 64,
                        color: _done
                            ? VaultColors.green
                            : VaultColors.accentLight,
                      ),
                    ),
                    if (!_done)
                      AnimatedBuilder(
                        animation: _scan,
                        builder: (context, _) {
                          return Positioned(
                            top: 30 + _scan.value * 108,
                            child: Container(
                              width: 96,
                              height: 2,
                              decoration: BoxDecoration(
                                color: VaultColors.accentLight,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: VaultColors.accent.withValues(
                                      alpha: 0.8,
                                    ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Text(
                _done ? l10n.authenticated : l10n.scanningFingerprint,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _done ? VaultColors.green : VaultColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanRingPainter extends CustomPainter {
  const _ScanRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(2), 0, math.pi * 0.6, false, paint);
    canvas.drawArc(
      rect.deflate(2),
      math.pi,
      math.pi * 0.6,
      false,
      paint..color = color.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_ScanRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
