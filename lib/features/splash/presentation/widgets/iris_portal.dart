import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:project_aeterna/core/theme/sanctum_colors.dart';

/// The Iris Portal — a mesmerizing, multi-layered golden portal
/// that serves as the biometric gateway to the Digital Sanctum.
///
/// Rendered via CustomPainter for maximum 60fps performance.
/// Layers (back to front):
///   1. Atmospheric radial lines (subtle structure rays)
///   2. Outer ambient glow (large, soft golden aura)
///   3. Outermost ring (thin, ghostly)
///   4. Secondary ring (medium opacity)
///   5. Primary ring (bright, thick golden)
///   6. Inner ring (tight, sharp)
///   7. Core sphere (bright radial gradient)
///   8. Floating particles (glowing dots orbiting)
class IrisPortalPainter extends CustomPainter {
  final double pulsePhase;       // 0.0 → 1.0 breathing cycle
  final double rotationAngle;    // continuous rotation in radians
  final double particlePhase;    // particle orbit position
  final double entryProgress;    // 0.0 → 1.0 for initial reveal

  IrisPortalPainter({
    required this.pulsePhase,
    required this.rotationAngle,
    required this.particlePhase,
    required this.entryProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.38;

    // Scale everything by entry progress for the reveal animation
    final scale = Curves.easeOutCubic.transform(entryProgress.clamp(0.0, 1.0));
    if (scale <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // Pulsing factor — subtle breathing between 0.95 and 1.05
    final pulse = 1.0 + 0.05 * math.sin(pulsePhase * 2 * math.pi);

    // 1. Atmospheric radial lines
    _drawRadialLines(canvas, center, maxRadius * 1.8 * pulse);

    // 2. Outer ambient glow
    _drawAmbientGlow(canvas, center, maxRadius * 1.6 * pulse);

    // 3–6. Concentric rings
    _drawRing(canvas, center, maxRadius * 1.4 * pulse, 1.0, 0.15,
        SanctumColors.irisShadow);
    _drawRing(canvas, center, maxRadius * 1.1 * pulse, 1.5, 0.3,
        SanctumColors.irisAmber);
    _drawRing(canvas, center, maxRadius * 0.85 * pulse, 2.5, 0.7,
        SanctumColors.irisCore);
    _drawRing(canvas, center, maxRadius * 0.6 * pulse, 1.5, 0.5,
        SanctumColors.irisGlow);

    // 7. Core sphere
    _drawCore(canvas, center, maxRadius * 0.35 * pulse);

    // 8. Floating particles
    _drawParticles(canvas, center, maxRadius * pulse);

    canvas.restore();
  }

  void _drawRadialLines(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const lineCount = 24;
    for (int i = 0; i < lineCount; i++) {
      final angle = (i / lineCount) * 2 * math.pi + rotationAngle * 0.1;
      final opacity = 0.03 + 0.05 * math.sin(angle * 3 + pulsePhase * math.pi);
      paint.color = SanctumColors.irisCore.withValues(alpha: opacity);

      final innerRadius = radius * 0.4;
      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paint,
      );
    }
  }

  void _drawAmbientGlow(Canvas canvas, Offset center, double radius) {
    final gradient = ui.Gradient.radial(
      center,
      radius,
      [
        SanctumColors.irisCore.withValues(alpha: 0.15),
        SanctumColors.irisGlow.withValues(alpha: 0.08),
        SanctumColors.irisAmber.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      [0.0, 0.3, 0.6, 1.0],
    );

    final paint = Paint()..shader = gradient;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawRing(Canvas canvas, Offset center, double radius,
      double strokeWidth, double opacity, Color color) {
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius, glowPaint);

    // Core ring
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawCore(Canvas canvas, Offset center, double radius) {
    // Soft outer glow
    final outerGlow = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius * 2.5,
        [
          SanctumColors.irisCore.withValues(alpha: 0.4),
          SanctumColors.irisGlow.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 2.5, outerGlow);

    // Core gradient sphere
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
        radius,
        [
          SanctumColors.irisCore,
          SanctumColors.irisGlow,
          SanctumColors.irisAmber.withValues(alpha: 0.6),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius, corePaint);

    // Inner highlight (top-left specular)
    final highlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
        radius * 0.6,
        [
          Colors.white.withValues(alpha: 0.5),
          Colors.transparent,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, radius * 0.6, highlightPaint);
  }

  void _drawParticles(Canvas canvas, Offset center, double maxRadius) {
    final random = math.Random(42); // Deterministic seed for consistent layout
    const particleCount = 16;

    for (int i = 0; i < particleCount; i++) {
      final orbitRadius = maxRadius * (0.5 + random.nextDouble() * 0.9);
      final baseAngle = (i / particleCount) * 2 * math.pi;
      final angle = baseAngle + particlePhase * 2 * math.pi * (0.3 + random.nextDouble() * 0.2);

      final x = center.dx + orbitRadius * math.cos(angle);
      final y = center.dy + orbitRadius * math.sin(angle);

      final particleSize = 1.5 + random.nextDouble() * 2.5;
      final opacity = 0.3 + 0.5 * math.sin(particlePhase * 4 * math.pi + i);

      // Glow
      final glowPaint = Paint()
        ..color = SanctumColors.irisCore.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), particleSize * 2, glowPaint);

      // Core dot
      final dotPaint = Paint()
        ..color = SanctumColors.irisCore.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), particleSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant IrisPortalPainter oldDelegate) {
    return oldDelegate.pulsePhase != pulsePhase ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.particlePhase != particlePhase ||
        oldDelegate.entryProgress != entryProgress;
  }
}
