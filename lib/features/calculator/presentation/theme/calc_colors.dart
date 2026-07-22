import 'package:flutter/material.dart';

/// Calculator screen palette from the design handoff (2 themes).
class CalcColors {
  const CalcColors({
    required this.background,
    required this.keyBg,
    required this.keyFg,
    required this.fnBg,
    required this.fnFg,
    required this.opBg,
    required this.opFg,
    required this.eqBg,
    required this.eqFg,
    required this.display,
    required this.displaySub,
  });

  final Color background;
  final Color keyBg;
  final Color keyFg;
  final Color fnBg;
  final Color fnFg;
  final Color opBg;
  final Color opFg;
  final Color eqBg;
  final Color eqFg;
  final Color display;
  final Color displaySub;

  static const light = CalcColors(
    background: Color(0xFFF4F4F6),
    keyBg: Color(0xFFFFFFFF),
    keyFg: Color(0xFF1C1C1E),
    fnBg: Color(0xFFE5E5EA),
    fnFg: Color(0xFF1C1C1E),
    opBg: Color(0xFFEEF1FB),
    opFg: Color(0xFF3B6BFF),
    eqBg: Color(0xFF3B6BFF),
    eqFg: Color(0xFFFFFFFF),
    display: Color(0xFF1C1C1E),
    displaySub: Color(0xFF8A8A92),
  );

  static const dark = CalcColors(
    background: Color(0xFF0D0D10),
    keyBg: Color(0xFF26262B),
    keyFg: Color(0xFFF5F5F7),
    fnBg: Color(0xFF3A3A40),
    fnFg: Color(0xFFF5F5F7),
    opBg: Color(0xFF26262B),
    opFg: Color(0xFF8AB0FF),
    eqBg: Color(0xFF4F7DFF),
    eqFg: Color(0xFFFFFFFF),
    display: Color(0xFFFFFFFF),
    displaySub: Color(0xFF8A8A92),
  );
}
