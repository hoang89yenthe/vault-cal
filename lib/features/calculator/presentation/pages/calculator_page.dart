import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/di/injection.dart';
import '../cubit/calculator_cubit.dart';
import '../theme/calc_colors.dart';
import '../widgets/calc_button.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CalculatorCubit>(),
      child: const _CalculatorView(),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? CalcColors.dark : CalcColors.light;

    return BlocListener<CalculatorCubit, CalculatorState>(
      listenWhen: (prev, next) => !prev.secretTriggered && next.secretTriggered,
      listener: (context, state) {
        context.read<CalculatorCubit>().consumeSecret();
        context.go(AppRoutes.unlock);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: colors.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  _TopBar(colors: colors, isDark: isDark),
                  Expanded(child: _Display(colors: colors)),
                  const SizedBox(height: 18),
                  _Keypad(colors: colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.colors, required this.isDark});

  final CalcColors colors;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '9:41',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.display,
          ),
        ),
        GestureDetector(
          onTap: () => context.read<ThemeCubit>().setMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.fnBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 18,
              color: colors.fnFg,
            ),
          ),
        ),
      ],
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.colors});

  final CalcColors colors;

  double _fontSize(String text) {
    if (text.length <= 7) return 72;
    if (text.length <= 9) return 58;
    if (text.length <= 12) return 44;
    return 34;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final main = state.current.isEmpty ? '0' : state.current;
        return Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                state.subline,
                style: TextStyle(fontSize: 20, color: colors.displaySub),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  main,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _fontSize(main),
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                    color: colors.display,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _KeyKind { fn, digit, op, eq }

class _KeySpec {
  const _KeySpec(this.kind, {this.label, this.icon, required this.onTap});

  final _KeyKind kind;
  final String? label;
  final IconData? icon;
  final void Function(CalculatorCubit cubit) onTap;
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.colors});

  final CalcColors colors;

  static const double _gap = 14;

  List<List<_KeySpec>> get _rows => [
    [
      _KeySpec(_KeyKind.fn, label: 'AC', onTap: (c) => c.clear()),
      _KeySpec(_KeyKind.fn, label: '%', onTap: (c) => c.percent()),
      _KeySpec(
        _KeyKind.fn,
        icon: Icons.backspace_outlined,
        onTap: (c) => c.backspace(),
      ),
      _KeySpec(_KeyKind.op, label: '÷', onTap: (c) => c.setOperator('÷')),
    ],
    [
      for (final d in ['7', '8', '9'])
        _KeySpec(_KeyKind.digit, label: d, onTap: (c) => c.inputDigit(d)),
      _KeySpec(_KeyKind.op, label: '×', onTap: (c) => c.setOperator('×')),
    ],
    [
      for (final d in ['4', '5', '6'])
        _KeySpec(_KeyKind.digit, label: d, onTap: (c) => c.inputDigit(d)),
      _KeySpec(_KeyKind.op, label: '−', onTap: (c) => c.setOperator('−')),
    ],
    [
      for (final d in ['1', '2', '3'])
        _KeySpec(_KeyKind.digit, label: d, onTap: (c) => c.inputDigit(d)),
      _KeySpec(_KeyKind.op, label: '+', onTap: (c) => c.setOperator('+')),
    ],
  ];

  (Color, Color) _colorsFor(_KeyKind kind) => switch (kind) {
    _KeyKind.fn => (colors.fnBg, colors.fnFg),
    _KeyKind.digit => (colors.keyBg, colors.keyFg),
    _KeyKind.op => (colors.opBg, colors.opFg),
    _KeyKind.eq => (colors.eqBg, colors.eqFg),
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalculatorCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // The first Android frame can arrive with zero width.
        if (constraints.maxWidth <= _gap * 3) return const SizedBox.shrink();
        final cell = (constraints.maxWidth - _gap * 3) / 4;

        Widget key(_KeySpec spec, {double? width}) {
          final (bg, fg) = _colorsFor(spec.kind);
          return CalcButton(
            label: spec.label,
            icon: spec.icon,
            background: bg,
            foreground: fg,
            width: width ?? cell,
            height: cell,
            onTap: () => spec.onTap(cubit),
          );
        }

        return Column(
          children: [
            for (final row in _rows) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [for (final spec in row) key(spec)],
              ),
              const SizedBox(height: _gap),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                key(
                  _KeySpec(
                    _KeyKind.digit,
                    label: '0',
                    onTap: (c) => c.inputDigit('0'),
                  ),
                  width: cell * 2 + _gap,
                ),
                key(
                  _KeySpec(
                    _KeyKind.digit,
                    label: '.',
                    onTap: (c) => c.inputDot(),
                  ),
                ),
                key(
                  _KeySpec(_KeyKind.eq, label: '=', onTap: (c) => c.evaluate()),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
