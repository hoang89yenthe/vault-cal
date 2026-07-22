import 'package:flutter/material.dart';

/// Rounded calculator key with the 150ms press-pop from the handoff.
class CalcButton extends StatefulWidget {
  const CalcButton({
    required this.background,
    required this.foreground,
    required this.onTap,
    this.label,
    this.icon,
    this.width,
    this.height,
    super.key,
  }) : assert(label != null || icon != null, 'Provide a label or an icon');

  final String? label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.ease,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: widget.icon != null
              ? Icon(widget.icon, size: 26, color: widget.foreground)
              : Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                    color: widget.foreground,
                  ),
                ),
        ),
      ),
    );
  }
}
