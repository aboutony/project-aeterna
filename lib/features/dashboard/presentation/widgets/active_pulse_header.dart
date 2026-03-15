import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Active Pulse Header — The vitality indicator of the Digital Sanctum.
///
/// Displays the vault's heartbeat status with a subtle pulsing animation.
/// The pulse is designed to feel like a "resting heart rate" — calm,
/// rhythmic, and alive — not a panic indicator.
///
/// CTO Directive: "The animation should be subtle. It's a 'Vitality'
/// indicator, not a 'Panic' light. Think 'resting heart rate.'"
///
/// Reads:
///   - vault_identity.status → color of the pulse ring
///   - vault_identity.last_heartbeat → "Last pulse: Xs ago"
///   - vault_identity.threshold_days → Ghost Protocol countdown
class ActivePulseHeader extends StatefulWidget {
  final Map<String, dynamic>? vaultIdentity;
  final VoidCallback? onPulseTap;

  const ActivePulseHeader({
    super.key,
    this.vaultIdentity,
    this.onPulseTap,
  });

  @override
  State<ActivePulseHeader> createState() => _ActivePulseHeaderState();
}

class _ActivePulseHeaderState extends State<ActivePulseHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Resting heart rate: ~3.5 second cycle (subtle, calm breathing)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = widget.vaultIdentity;
    final status = identity?['status'] as String? ?? 'ACTIVE';
    final lastHeartbeat = identity?['last_heartbeat'] as String?;
    final thresholdDays = identity?['threshold_days'] as int? ?? 30;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final statusColor = _statusColor(status);
    final timeSinceHeartbeat = _timeSince(lastHeartbeat);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final textSec = isDark ? SanctumColors.textSecondary : SanctumColors.lightTextSecondary;
    final textTer = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // ─── Pulse Ring ──────────────────────────────────────
              GestureDetector(
                onTap: widget.onPulseTap,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(56, 56),
                      painter: _PulseRingPainter(
                        phase: _pulseAnimation.value,
                        statusColor: statusColor,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // ─── Vitality Info ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isRtl ? 'النبض النشط' : 'ACTIVE PULSE',
                          style: SanctumTypography.labelMedium.copyWith(
                            letterSpacing: 2.0,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: SanctumTypography.bodySmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isRtl
                          ? 'آخر نبضة: $timeSinceHeartbeat'
                          : 'Last pulse: $timeSinceHeartbeat',
                      style: SanctumTypography.monoMedium.copyWith(
                        fontSize: 12,
                        color: textSec,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRtl
                          ? 'بروتوكول الشبح: $thresholdDays يوم'
                          : 'Ghost Protocol: ${thresholdDays}d threshold',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: textTer,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Status Shield Icon ─────────────────────────────
              Icon(
                _statusIcon(status),
                color: statusColor.withValues(alpha: 0.6),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return SanctumColors.pulseResting;
      case 'WARNING':
        return SanctumColors.statusWarning;
      case 'CRITICAL':
        return SanctumColors.statusCritical;
      case 'TRIGGERED':
        return SanctumColors.statusTriggered;
      default:
        return SanctumColors.pulseResting;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.shield_outlined;
      case 'WARNING':
        return Icons.warning_amber_outlined;
      case 'CRITICAL':
        return Icons.error_outline;
      case 'TRIGGERED':
        return Icons.notifications_active_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  String _timeSince(String? isoTimestamp) {
    if (isoTimestamp == null) return 'Never';
    try {
      final dt = DateTime.parse(isoTimestamp);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 10) return 'Just now';
      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Unknown';
    }
  }
}

/// Custom painter for the subtle pulse ring.
///
/// Draws a calm, breathing ring with a soft glow that expands
/// and contracts rhythmically — "resting heart rate" feel.
class _PulseRingPainter extends CustomPainter {
  final double phase;
  final Color statusColor;

  _PulseRingPainter({required this.phase, required this.statusColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.35;

    // Subtle pulse — 3% expansion (resting, calm)
    final breathFactor = 1.0 + 0.03 * math.sin(phase * 2 * math.pi);
    final radius = baseRadius * breathFactor;

    // Outer glow — very subtle
    final glowOpacity = 0.08 + 0.06 * math.sin(phase * 2 * math.pi);
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(center, radius * 1.8, [
        statusColor.withValues(alpha: glowOpacity),
        statusColor.withValues(alpha: 0.0),
      ])
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius * 1.8, glowPaint);

    // Ring
    final ringOpacity = 0.4 + 0.2 * math.sin(phase * 2 * math.pi);
    final ringPaint = Paint()
      ..color = statusColor.withValues(alpha: ringOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner core dot
    final coreOpacity = 0.6 + 0.3 * math.sin(phase * 2 * math.pi);
    final corePaint = Paint()
      ..shader = ui.Gradient.radial(center, radius * 0.35, [
        statusColor.withValues(alpha: coreOpacity),
        statusColor.withValues(alpha: coreOpacity * 0.3),
      ]);
    canvas.drawCircle(center, radius * 0.25, corePaint);

    // Tiny highlight — life sparkle
    final sparkleAngle = phase * 2 * math.pi;
    final sparkleX = center.dx + radius * 0.7 * math.cos(sparkleAngle);
    final sparkleY = center.dy + radius * 0.7 * math.sin(sparkleAngle);
    final sparkleOpacity = 0.3 + 0.4 * math.sin(phase * 4 * math.pi);
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: sparkleOpacity.clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(sparkleX, sparkleY), 1.5, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant _PulseRingPainter old) =>
      old.phase != phase || old.statusColor != statusColor;
}
