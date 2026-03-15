import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// The Welcome Screen — the sovereign entrance to Project Aeterna.
///
/// ISOLATION NOTE: This is a standalone widget with ZERO external dependencies.
/// It communicates outward ONLY via the [onEnter] callback.
/// It does NOT import AuthService, TursoClient, or any routing logic.
///
/// Precedes the OTP screen. Presents a premium "Enter the Sanctum"
/// call-to-action with the golden iris motif and breathing animation.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback? onEnter;
  final ValueNotifier<ThemeMode>? themeNotifier;

  const WelcomeScreen({super.key, this.onEnter, this.themeNotifier});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _breatheController;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _buttonFade;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _titleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _subtitleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _breathe = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: _isDark ? SanctumColors.abyss : SanctumColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─── Theme Toggle ─────────────────────────────────
                if (widget.themeNotifier != null)
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ValueListenableBuilder<ThemeMode>(
                        valueListenable: widget.themeNotifier!,
                        builder: (context, mode, _) {
                          return IconButton(
                            icon: Icon(
                              mode == ThemeMode.dark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              color: mode == ThemeMode.dark
                                  ? SanctumColors.irisCore
                                  : SanctumColors.lightAccent,
                              size: 24,
                            ),
                            onPressed: () {
                              widget.themeNotifier!.value =
                                  widget.themeNotifier!.value == ThemeMode.dark
                                      ? ThemeMode.light
                                      : ThemeMode.dark;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                const Spacer(flex: 2),

                // ─── Iris Emblem ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _breathe,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(120, 120),
                      painter: _IrisEmblemPainter(
                        breathe: _breathe.value,
                        isDark: _isDark,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // ─── Title ──────────────────────────────────────────
                FadeTransition(
                  opacity: _titleFade,
                  child: Text(
                    'AETERNA',
                    style: SanctumTypography.displayMedium.copyWith(
                      letterSpacing: 14,
                      fontSize: 32,
                      color: _isDark
                          ? SanctumColors.irisCore
                          : SanctumColors.lightAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Subtitle ───────────────────────────────────────
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text(
                    isRtl
                        ? 'الخزنة الرقمية السيادية'
                        : 'The Sovereign Digital Vault',
                    style: SanctumTypography.bodyMedium.copyWith(
                      letterSpacing: 2.0,
                      color: _isDark
                          ? SanctumColors.textSecondary
                          : SanctumColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // ─── Enter Button ───────────────────────────────────
                FadeTransition(
                  opacity: _buttonFade,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDark
                            ? SanctumColors.irisCore
                            : SanctumColors.lightAccent,
                        foregroundColor: _isDark
                            ? SanctumColors.abyss
                            : SanctumColors.lightSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isRtl ? 'ادخل العرين' : 'ENTER THE SANCTUM',
                        style: SanctumTypography.buttonText.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Footer ─────────────────────────────────────────
                FadeTransition(
                  opacity: _buttonFade,
                  child: Text(
                    isRtl
                        ? 'تشفير من الدرجة العسكرية • محلي أولاً'
                        : 'Military-Grade Encryption • Local-First',
                    style: SanctumTypography.bodySmall.copyWith(
                      color: _isDark
                          ? SanctumColors.textTertiary
                          : SanctumColors.lightTextTertiary,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Iris emblem painter — golden concentric rings with breathing glow.
class _IrisEmblemPainter extends CustomPainter {
  final double breathe;
  final bool isDark;

  _IrisEmblemPainter({required this.breathe, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    final accent = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;

    // Outer glow
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(center, maxRadius * 1.5, [
        accent.withValues(alpha: 0.12 * breathe),
        accent.withValues(alpha: 0.0),
      ])
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, maxRadius * 1.5, glowPaint);

    // Rings
    for (int i = 3; i >= 1; i--) {
      final ratio = i / 3.0;
      final radius = maxRadius * ratio * (0.95 + 0.05 * breathe);
      final opacity = (0.15 + 0.1 * ratio) * breathe;
      final paint = Paint()
        ..color = accent.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }

    // Core
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(center, maxRadius * 0.2, [
        accent.withValues(alpha: 0.8 * breathe),
        accent.withValues(alpha: 0.2 * breathe),
      ]);
    canvas.drawCircle(center, maxRadius * 0.15, corePaint);
  }

  @override
  bool shouldRepaint(covariant _IrisEmblemPainter old) =>
      old.breathe != breathe || old.isDark != isDark;
}
