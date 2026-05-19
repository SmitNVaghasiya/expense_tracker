import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:spendwise/core/design_system.dart';

/// 4px linear progress bar — accent fill, surface track.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,   // 0.0 – 1.0
    this.color,
    this.height = 4,
    this.radius,
  });

  final double value;
  final Color? color;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height / 2;
    final fill = color ?? context.cAccent;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Container(
        height: height,
        color: context.cSurface,
        child: FractionallySizedBox(
          widthFactor: clamped,
          alignment: Alignment.centerLeft,
          child: Container(color: fill),
        ),
      ),
    );
  }
}

/// Circular progress ring — stroke 4px, accent arc on surface track.
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    super.key,
    required this.value,   // 0.0 – 1.0
    this.size = 48,
    this.strokeWidth = 4,
    this.color,
    this.child,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? context.cAccent;
    final clamped = value.clamp(0.0, 1.0);

    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: clamped,
          fillColor: fill,
          trackColor: context.cSurface,
          strokeWidth: strokeWidth,
        ),
        child: child != null
            ? Center(child: child)
            : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.fillColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color fillColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - strokeWidth) / 2;
    const start = -math.pi / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = fillColor;

    canvas.drawCircle(Offset(cx, cy), r, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      start, 2 * math.pi * value, false, fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.fillColor != fillColor;
}
