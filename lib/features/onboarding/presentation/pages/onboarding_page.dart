import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../unlock/domain/repositories/credentials_repository.dart';
import '../../../vault/presentation/theme/vault_colors.dart';
import '../cubit/onboarding_cubit.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(getIt<CredentialsRepository>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
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

  (String, String) _labels(OnboardingStep step) => switch (step) {
    OnboardingStep.intro => ('', ''),
    OnboardingStep.secret => (
      'Đặt mã bí mật',
      'Dãy số bạn gõ trên máy tính rồi bấm = để mở kho (4–10 số)',
    ),
    OnboardingStep.secretConfirm => (
      'Xác nhận mã bí mật',
      'Nhập lại mã bí mật',
    ),
    OnboardingStep.realPin => ('Đặt PIN', 'Nhập 4 chữ số để vào kho'),
    OnboardingStep.realPinConfirm => ('Xác nhận PIN', 'Nhập lại PIN'),
  };

  int _stepNumber(OnboardingStep step) => switch (step) {
    OnboardingStep.intro => 0,
    OnboardingStep.secret || OnboardingStep.secretConfirm => 1,
    OnboardingStep.realPin || OnboardingStep.realPinConfirm => 2,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.error != null) _shake.forward(from: 0);
          if (state.done) context.go(AppRoutes.calculator);
        },
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          if (state.step == OnboardingStep.intro) {
            return _Intro(onStart: cubit.start);
          }
          final (title, subtitle) = _labels(state.step);

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Bước ${_stepNumber(state.step)}/2',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.accentLight,
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(
                  Icons.shield_outlined,
                  size: 44,
                  color: VaultColors.accentLight,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: VaultColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: VaultColors.textSub,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 20,
                  child: Text(
                    state.error ?? '',
                    style: const TextStyle(
                      color: VaultColors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                  child: _Display(state: state),
                ),
                const Spacer(),
                _Keypad(onDigit: cubit.addDigit, onBackspace: cubit.backspace),
                const SizedBox(height: 16),
                if (!state.isPinStep)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: state.input.length >= 4
                            ? cubit.submitSecret
                            : null,
                        child: const Text('Tiếp tục'),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
        child: Column(
          children: [
            const Spacer(),
            const Icon(
              Icons.lock_outline,
              size: 56,
              color: VaultColors.accentLight,
            ),
            const SizedBox(height: 20),
            const Text(
              'Kho riêng tư',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: VaultColors.text,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ứng dụng trông như một máy tính bình thường. '
              'Gõ mã bí mật của bạn rồi bấm “=” để mở kho ảnh, video và ghi chú '
              'được mã hoá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: VaultColors.textSub,
              ),
            ),
            const SizedBox(height: 20),
            const _IntroPoint(
              icon: Icons.calculate_outlined,
              text: 'Đặt mã bí mật để mở kho',
            ),
            const _IntroPoint(
              icon: Icons.pin_outlined,
              text: 'Đặt mã PIN bảo vệ lớp hai',
            ),
            const _IntroPoint(
              icon: Icons.lock_clock_outlined,
              text: 'Chỉ 2 bước, làm chưa tới một phút',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onStart,
                child: const Text('Bắt đầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPoint extends StatelessWidget {
  const _IntroPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VaultColors.accentLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: VaultColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final error = state.error != null;
    if (state.isPinStep) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final filled = i < state.input.length;
          final color = error
              ? VaultColors.red
              : filled
              ? VaultColors.accentLight
              : VaultColors.textFaint;
          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: filled ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
          );
        }),
      );
    }
    // Secret code: show a filled dot per digit (variable length).
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: List.generate(
        state.input.isEmpty ? 1 : state.input.length,
        (i) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: state.input.isEmpty
                ? Colors.transparent
                : (error ? VaultColors.red : VaultColors.accentLight),
            shape: BoxShape.circle,
            border: Border.all(
              color: error ? VaultColors.red : VaultColors.textFaint,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key({String? digit, IconData? icon, VoidCallback? onTap}) {
      if (digit == null && icon == null) return const SizedBox(width: 64);
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

    Widget row(List<Widget> children) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in children)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: c,
            ),
        ],
      ),
    );

    return Column(
      children: [
        row([
          for (final d in ['1', '2', '3'])
            key(digit: d, onTap: () => onDigit(d)),
        ]),
        row([
          for (final d in ['4', '5', '6'])
            key(digit: d, onTap: () => onDigit(d)),
        ]),
        row([
          for (final d in ['7', '8', '9'])
            key(digit: d, onTap: () => onDigit(d)),
        ]),
        row([
          key(),
          key(digit: '0', onTap: () => onDigit('0')),
          key(icon: Icons.backspace_outlined, onTap: onBackspace),
        ]),
      ],
    );
  }
}
