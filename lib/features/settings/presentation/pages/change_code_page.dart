import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../unlock/domain/entities/pin_match.dart';
import '../../../unlock/domain/repositories/credentials_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../vault/presentation/theme/vault_colors.dart';
import '../cubit/change_code_cubit.dart';

class ChangeCodePage extends StatelessWidget {
  const ChangeCodePage({required this.type, super.key});

  final CodeType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangeCodeCubit(getIt<CredentialsRepository>(), type),
      child: _ChangeCodeView(type: type),
    );
  }
}

class _ChangeCodeView extends StatefulWidget {
  const _ChangeCodeView({required this.type});

  final CodeType type;

  @override
  State<_ChangeCodeView> createState() => _ChangeCodeViewState();
}

class _ChangeCodeViewState extends State<_ChangeCodeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  String _title(CodeType type) => switch (type) {
        CodeType.secret => 'Đổi mật mã bí mật',
        CodeType.realPin => 'Đổi PIN thật',
        CodeType.decoyPin => 'Đổi PIN giả',
      };

  String _stepLabel(ChangeCodeStep step) => switch (step) {
        ChangeCodeStep.verifyOld => 'Nhập mã hiện tại',
        ChangeCodeStep.enterNew => 'Nhập mã mới (4 chữ số)',
        ChangeCodeStep.confirmNew => 'Nhập lại mã mới',
      };

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.text,
        title: Text(_title(widget.type)),
      ),
      body: BlocConsumer<ChangeCodeCubit, ChangeCodeState>(
        listener: (context, state) {
          if (state.error != null) _shake.forward(from: 0);
          if (state.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật mã thành công')),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChangeCodeCubit>();
          return SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  _stepLabel(state.step),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: Text(
                    state.error ?? '',
                    style: const TextStyle(color: VaultColors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    final t = _shake.value;
                    final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
                    return Transform.translate(
                        offset: Offset(dx, 0), child: child);
                  },
                  child: _Dots(count: state.input.length, error: state.error != null),
                ),
                const Spacer(),
                _Keypad(
                  onDigit: cubit.addDigit,
                  onBackspace: cubit.backspace,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.error});

  final int count;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < count;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: error
                ? VaultColors.red
                : filled
                    ? VaultColors.accentLight
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: error
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
          padding: const EdgeInsets.symmetric(vertical: 9),
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
        row([for (final d in ['1', '2', '3']) key(digit: d, onTap: () => onDigit(d))]),
        row([for (final d in ['4', '5', '6']) key(digit: d, onTap: () => onDigit(d))]),
        row([for (final d in ['7', '8', '9']) key(digit: d, onTap: () => onDigit(d))]),
        row([
          key(),
          key(digit: '0', onTap: () => onDigit('0')),
          key(icon: Icons.backspace_outlined, onTap: onBackspace),
        ]),
      ],
    );
  }
}
