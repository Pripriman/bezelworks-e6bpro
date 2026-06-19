import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bezel_palette.dart';

class BezelDial extends StatefulWidget {
  final double size;
  final int ticks;
  final bool interactive;
  final bool spin;
  final ValueChanged<int>? onDetent;
  final Widget? child;

  const BezelDial({
    super.key,
    this.size = 200,
    this.ticks = 36,
    this.interactive = false,
    this.spin = false,
    this.onDetent,
    this.child,
  });

  @override
  State<BezelDial> createState() => _BezelDialState();
}

class _BezelDialState extends State<BezelDial>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _dragStart = 0;
  double _angleStart = 0;
  int _lastDetent = 0;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    if (widget.spin) _idle.repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  double _pointerAngle(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    return math.atan2(local.dy - center.dy, local.dx - center.dx);
  }

  void _onPanStart(DragStartDetails d) {
    _dragStart = _pointerAngle(d.localPosition);
    _angleStart = _angle;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final now = _pointerAngle(d.localPosition);
    setState(() => _angle = _angleStart + (now - _dragStart));
    final step = (2 * math.pi) / widget.ticks;
    final detent = (_angle / step).round();
    if (detent != _lastDetent) {
      _lastDetent = detent;
      HapticFeedback.selectionClick();
      widget.onDetent?.call(detent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dial = AnimatedBuilder(
      animation: _idle,
      builder: (context, child) {
        final base = widget.spin ? _idle.value * 2 * math.pi : 0.0;
        return CustomPaint(
          painter: _BezelPainter(_angle + base, widget.ticks),
          child: child,
        );
      },
      child: Center(child: widget.child),
    );

    final framed = SizedBox(
      width: widget.size,
      height: widget.size,
      child: dial,
    );

    if (!widget.interactive) return framed;
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      child: framed,
    );
  }
}

class _BezelPainter extends CustomPainter {
  final double angle;
  final int ticks;
  _BezelPainter(this.angle, this.ticks);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;

    final ring = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF8B9199),
          Color(0xFFCBD1D8),
          Color(0xFF6E747C),
          Color(0xFFB4BAC2),
          Color(0xFF8B9199),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outer));
    canvas.drawCircle(center, outer, ring);

    final inner = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF2A2E34), Color(0xFF15181C)],
      ).createShader(Rect.fromCircle(center: center, radius: outer * 0.78));
    canvas.drawCircle(center, outer * 0.78, inner);

    final tickPaint = Paint()
      ..color = BezelPalette.baseDeep
      ..strokeWidth = 2;
    final majorPaint = Paint()
      ..color = BezelPalette.engrave
      ..strokeWidth = 2.4;

    for (var i = 0; i < ticks; i++) {
      final a = angle + (i / ticks) * 2 * math.pi;
      final major = i % 3 == 0;
      final rOuter = outer * 0.96;
      final rInner = outer * (major ? 0.84 : 0.88);
      final p1 = center + Offset(math.cos(a) * rInner, math.sin(a) * rInner);
      final p2 = center + Offset(math.cos(a) * rOuter, math.sin(a) * rOuter);
      canvas.drawLine(p1, p2, major ? majorPaint : tickPaint);
    }

    final marker = Paint()..color = BezelPalette.amber;
    final mTop = center + Offset(0, -outer * 0.99);
    final path = Path()
      ..moveTo(mTop.dx - 6, mTop.dy)
      ..lineTo(mTop.dx + 6, mTop.dy)
      ..lineTo(mTop.dx, mTop.dy + 12)
      ..close();
    canvas.drawPath(path, marker);
  }

  @override
  bool shouldRepaint(covariant _BezelPainter old) =>
      old.angle != angle || old.ticks != ticks;
}
