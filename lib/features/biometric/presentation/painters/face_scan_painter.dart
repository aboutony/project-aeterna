import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';

/// Face Scan Painter — Golden orbiting light-ring animation.
///
/// Renders a circular scan frame with:
///   1. Rounded corner brackets (golden alignment guides)
///   2. Orbiting light-arc that sweeps around the frame at 60fps
///   3. Subtle crosshair alignment lines inside the frame
///   4. Breathing ambient glow matching the Sanctum aesthetic
///
/// CTO Directive: "FaceID scanning frame with a golden-glow orbit animation."
class FaceScanPainter extends CustomPainter {
  final double orbitPhase;      // 0.0 → 1.0 light-ring orbit
  final double pulsePhase;      // 0.0 → 1.0 breathing cycle
  final double entryProgress;   // 0.0 → 1.0 reveal animation
  final double scanProgress;    // 0.0 → 1.0 scanning fill (when active)

  FaceScanPainter({
    required this.orbitPhase,
    required this.pulsePhase,
    required this.entryProgress,
    this.scanProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final frameRadius = math.min(size.width, size.height) * 0.34;

    final scale = Curves.easeOutCubic.transform(entryProgress.clamp(0.0, 1.0));
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    final pulse = 1.0 + 0.03 * math.sin(pulsePhase * 2 * math.pi);
    final r = frameRadius * pulse;

    // 1. Ambient glow
    _drawAmbientGlow(canvas, center, r * 1.6);

    // 2. Circular scan frame
    _drawScanFrame(canvas, center, r);

    // 3. Corner brackets
    _drawCornerBrackets(canvas, center, r);

    // 4. Crosshair alignment
    _drawCrosshair(canvas, center, r);

    // 5. Orbiting light-arc
    _drawOrbitingArc(canvas, center, r * 1.05);

    // 6. Scan progress fill (when scanning)
    if (scanProgress > 0) {
      _drawScanFill(canvas, center, r);
    }

    // 7. Face silhouette hint
    _drawFaceSilhouette(canvas, center, r * 0.6);

    canvas.restore();
  }

  void _drawAmbientGlow(Canvas canvas, Offset center, double radius) {
    final gradient = ui.Gradient.radial(
      center, radius,
      [
        SanctumColors.irisCore.withValues(alpha: 0.10),
        SanctumColors.irisGlow.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(center, radius, Paint()..shader = gradient);
  }

  void _drawScanFrame(Canvas canvas, Offset center, double radius) {
    // Outer glow ring
    final glowPaint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);

    // Main frame ring
    final framePaint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, framePaint);
  }

  void _drawCornerBrackets(Canvas canvas, Offset center, double r) {
    final bracketLength = r * 0.35;
    final paint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 4 corners at 45°, 135°, 225°, 315°
    for (int i = 0; i < 4; i++) {
      final baseAngle = (i * 90 + 45) * math.pi / 180;
      final edgePoint = Offset(
        center.dx + r * math.cos(baseAngle),
        center.dy + r * math.sin(baseAngle),
      );

      // Two short arcs from each corner
      for (final offset in [-0.15, 0.15]) {
        final startAngle = baseAngle + offset;
        final endAngle = baseAngle + offset + (offset > 0 ? 0.18 : -0.18);
        final path = Path()
          ..moveTo(
            center.dx + r * math.cos(startAngle),
            center.dy + r * math.sin(startAngle),
          )
          ..lineTo(
            center.dx + (r + bracketLength * 0.1) * math.cos((startAngle + endAngle) / 2),
            center.dy + (r + bracketLength * 0.1) * math.sin((startAngle + endAngle) / 2),
          );
        canvas.drawPath(path, paint);
      }

      // Corner dot
      final dotPaint = Paint()
        ..color = SanctumColors.irisCore.withValues(alpha: 0.9);
      canvas.drawCircle(edgePoint, 2.5, dotPaint);
    }
  }

  void _drawCrosshair(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;

    // Horizontal
    canvas.drawLine(
      Offset(center.dx - r * 0.5, center.dy),
      Offset(center.dx + r * 0.5, center.dy),
      paint,
    );
    // Vertical
    canvas.drawLine(
      Offset(center.dx, center.dy - r * 0.5),
      Offset(center.dx, center.dy + r * 0.5),
      paint,
    );
  }

  void _drawOrbitingArc(Canvas canvas, Offset center, double r) {
    final sweepAngle = math.pi * 0.4; // 72° arc
    final startAngle = orbitPhase * 2 * math.pi;

    // Glow arc
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          SanctumColors.irisCore.withValues(alpha: 0.5),
          SanctumColors.irisGlow.withValues(alpha: 0.7),
          SanctumColors.irisCore.withValues(alpha: 0.5),
          Colors.transparent,
        ],
        [0.0, 0.1, 0.5, 0.9, 1.0],
        TileMode.clamp,
        startAngle,
        startAngle + sweepAngle,
      );

    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    // Core arc (brighter)
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.sweep(
        center,
        [
          Colors.transparent,
          SanctumColors.irisCore.withValues(alpha: 0.8),
          SanctumColors.irisCore,
          SanctumColors.irisCore.withValues(alpha: 0.8),
          Colors.transparent,
        ],
        [0.0, 0.15, 0.5, 0.85, 1.0],
        TileMode.clamp,
        startAngle,
        startAngle + sweepAngle,
      );
    canvas.drawArc(rect, startAngle, sweepAngle, false, corePaint);

    // Leading particle
    final leadAngle = startAngle + sweepAngle;
    final px = center.dx + r * math.cos(leadAngle);
    final py = center.dy + r * math.sin(leadAngle);
    final particlePaint = Paint()
      ..color = SanctumColors.irisCore
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(px, py), 3, particlePaint);
  }

  void _drawScanFill(Canvas canvas, Offset center, double r) {
    final fillPaint = Paint()
      ..shader = ui.Gradient.radial(
        center, r,
        [
          SanctumColors.irisCore.withValues(alpha: 0.15 * scanProgress),
          SanctumColors.irisGlow.withValues(alpha: 0.08 * scanProgress),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(center, r * scanProgress, fillPaint);
  }

  void _drawFaceSilhouette(Canvas canvas, Offset center, double r) {
    // Simple oval head outline
    final paint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final headRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - r * 0.1),
      width: r * 1.0,
      height: r * 1.3,
    );
    canvas.drawOval(headRect, paint);
  }

  @override
  bool shouldRepaint(covariant FaceScanPainter old) =>
      old.orbitPhase != orbitPhase ||
      old.pulsePhase != pulsePhase ||
      old.entryProgress != entryProgress ||
      old.scanProgress != scanProgress;
}
