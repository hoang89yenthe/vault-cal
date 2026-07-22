import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../vault/presentation/theme/vault_colors.dart';
import '../cubit/pin_cubit.dart';

class PinPage extends StatelessWidget {
  const PinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PinCubit>(),
      child: const _PinView(),
    );
  }
}

class _PinView extends StatefulWidget {
  const _PinView();

  @override
  State<_PinView> createState() => _PinViewState();
}

class _PinViewState extends State<_PinView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<PinCubit, PinState>(
      listener: (context, state) {
        if (state.error) {
          _shake.forward(from: 0);
        } else if (state.result == PinResult.real ||
            state.result == PinResult.decoy) {
          // Decoy vs real is carried by VaultSession, not the URL.
          context.go(AppRoutes.vault);
        }
      },
      child: Scaffold(
        backgroundColor: VaultColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: VaultColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 28,
                  color: VaultColors.accentLight,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.pinTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: VaultColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.pinSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: VaultColors.textSub,
                ),
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  final t = _shake.value;
                  final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: const _PinDots(),
              ),
              const Spacer(),
              const _PinKeypad(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinCubit, PinState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final filled = i < state.input.length;
            final color = state.error
                ? VaultColors.red
                : filled
                ? VaultColors.accentLight
                : Colors.transparent;
            return Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: state.error
                      ? VaultColors.red
                      : filled
                      ? VaultColors.accentLight
                      : VaultColors.textFaint,
                  width: 1.5,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PinCubit>();

    Widget key({String? digit, IconData? icon, VoidCallback? onTap}) {
      if (digit == null && icon == null) return const SizedBox(width: 64);
      return _PinKey(digit: digit, icon: icon, onTap: onTap!);
    }

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ]) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final d in row)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: key(digit: d, onTap: () => cubit.addDigit(d)),
                ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: key(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: key(digit: '0', onTap: () => cubit.addDigit('0')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: key(
                icon: Icons.backspace_outlined,
                onTap: cubit.backspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({required this.onTap, this.digit, this.icon});

  final String? digit;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VaultColors.card,
      shape: const CircleBorder(
        side: BorderSide(color: VaultColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 22, color: VaultColors.textSub)
                : Text(
                    digit!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: VaultColors.text,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
