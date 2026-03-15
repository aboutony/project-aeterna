import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';

/// Fingerprint Painter — Rippling sonar-wave from touch point.
///
/// Renders a stylized fingerprint glyph with:
///   1. Concentric golden arcs (fingerprint ridges)
///   2. Expanding sonar-wave rings on touch simulation
///   3. Central contact glow that brightens during scan
///   4. Bottom-positioned for natural thumb reach
///
/// CTO Directive: "Rippling light-wave from the contact point."
class FingerprintPainter extends CustomPainter {
  final double ripplePhase;     // 0.0 → 1.0 sonar wave expansion
  final double pulsePhase;      // 0.0 → 1.0 breathing cycle
  final double entryProgress;   // 0.0 → 1.0 reveal animation
  final double scanProgress;    // 0.0 → 1.0 scanning state
  final bool isScanning;        // Whether actively scanning

  FingerprintPainter({
    required this.ripplePhase,
    required this.pulsePhase,
    required this.entryProgress,
    this.scanProgress = 0.0,
    this.isScanning = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final maxRadius = math.min(size.width, size.height) * 0.30;

    final scale = Curves.easeOutCubic.transform(entryProgress.clamp(0.0, 1.0));
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    final pulse = 1.0 + 0.025 * math.sin(pulsePhase * 2 * math.pi);
    final r = maxRadius * pulse;

    // 1. Background glow
    _drawBackgroundGlow(canvas, center, r * 1.8);

    // 2. Fingerprint ridges (concentric arcs)
    _drawFingerprintRidges(canvas, center, r);

    // 3. Contact glow (central)
    _drawContactGlow(canvas, center, r * 0.2);

    // 4. Sonar ripple waves (when scanning)
    if (isScanning || scanProgress > 0) {
      _drawRippleWaves(canvas, center, r * 1.4);
    }

    // 5. Touch point indicator
    _drawTouchPoint(canvas, center);

    canvas.restore();
  }

  void _drawBackgroundGlow(Canvas canvas, Offset center, double radius) {
    final gradient = ui.Gradient.radial(
      center, radius,
      [
        SanctumColors.irisCore.withValues(alpha: 0.06),
        SanctumColors.irisGlow.withValues(alpha: 0.02),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(center, radius, Paint()..shader = gradient);
  }

  void _drawFingerprintRidges(Canvas canvas, Offset center, double r) {
    const ridgeCount = 8;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < ridgeCount; i++) {
      final fraction = (i + 1) / ridgeCount;
      final ridgeR = r * fraction;
      final opacity = 0.12 + 0.18 * (1.0 - fraction);

      // Each ridge is an arc (not full circle) — fingerprint feel
      final startAngle = -math.pi * 0.7 + (i * 0.05);
      final sweepAngle = math.pi * 1.4 - (i * 0.1);

      basePaint.color = SanctumColors.irisCore.withValues(alpha: opacity);

      final rect = Rect.fromCircle(center: center, radius: ridgeR);
      canvas.drawArc(rect, startAngle, sweepAngle, false, basePaint);

      // Alternate offset arcs for realism
      if (i % 2 == 0 && i < ridgeCount - 1) {
        final altR = ridgeR + r * 0.04;
        basePaint.color = SanctumColors.irisGlow.withValues(alpha: opacity * 0.5);
        final altRect = Rect.fromCircle(center: center, radius: altR);
        canvas.drawArc(altRect, startAngle + 0.3, sweepAngle * 0.5, false, basePaint);
      }
    }
  }

  void _drawContactGlow(Canvas canvas, Offset center, double radius) {
    final intensity = isScanning ? 0.6 + 0.3 * scanProgress : 0.3;
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center, radius * 2,
        [
          SanctumColors.irisCore.withValues(alpha: intensity),
          SanctumColors.irisGlow.withValues(alpha: intensity * 0.3),
          Colors.transparent,
        ],
        [0.0, 0.4, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 2, glowPaint);

    // Core dot
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        center, radius,
        [
          SanctumColors.irisCore.withValues(alpha: intensity + 0.2),
          SanctumColors.irisGlow.withValues(alpha: intensity * 0.5),
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, radius, corePaint);
  }

  void _drawRippleWaves(Canvas canvas, Offset center, double maxR) {
    const waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      // Stagger waves
      final wavePhase = (ripplePhase + i * 0.33) % 1.0;
      final waveR = maxR * wavePhase;
      final opacity = (1.0 - wavePhase) * 0.4;

      if (opacity <= 0) continue;

      // Glow ring
      final glowPaint = Paint()
        ..color = SanctumColors.irisCore.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, waveR, glowPaint);

      // Core ring
      final ringPaint = Paint()
        ..color = SanctumColors.irisCore.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, waveR, ringPaint);
    }
  }

  void _drawTouchPoint(Canvas canvas, Offset center) {
    final opacity = isScanning
        ? 0.8 + 0.2 * math.sin(pulsePhase * 4 * math.pi)
        : 0.4 + 0.2 * math.sin(pulsePhase * 2 * math.pi);

    // Outer ring
    final ringPaint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 8, ringPaint);

    // Inner dot
    final dotPaint = Paint()
      ..color = SanctumColors.irisCore.withValues(alpha: opacity);
    canvas.drawCircle(center, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant FingerprintPainter old) =>
      old.ripplePhase != ripplePhase ||
      old.pulsePhase != pulsePhase ||
      old.entryProgress != entryProgress ||
      old.scanProgress != scanProgress ||
      old.isScanning != isScanning;
}
