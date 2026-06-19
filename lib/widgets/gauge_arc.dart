import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bezel_palette.dart';

class GaugeArc extends StatelessWidget {
  final double size;
  final double value;
  final Color color;
  final Color track;
  final double stroke;
  final Widget? child;

  const GaugeArc({
    super.key,
    required this.size,
    required this.value,
    this.color = BezelPalette.amber,
    this.track = BezelPalette.hairline,
    this.stroke = 10,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
          value: value.clamp(0, 1).toDouble(),
          color: color,
          track: track,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  _ArcPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.stroke,
  });

  static const double _start = math.pi * 0.75;
  static const double _sweepMax = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, _start, _sweepMax, false, trackPaint);

    if (value <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, _start, _sweepMax * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
