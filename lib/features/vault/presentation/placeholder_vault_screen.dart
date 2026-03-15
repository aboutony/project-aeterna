import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/dashboard/presentation/widgets/active_pulse_header.dart';

/// Placeholder Sub-Vault — Used for Sentimental Legacy and Discrete Assets.
///
/// This is a temporary screen that preserves the Active Pulse header and
/// displays a "Coming Soon" state for vaults not yet implemented.
class PlaceholderVaultScreen extends StatelessWidget {
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final IconData icon;
  final Color accentColor;
  final Map<String, dynamic>? vaultIdentity;

  const PlaceholderVaultScreen({
    super.key,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.icon,
    required this.accentColor,
    this.vaultIdentity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor = isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: glassFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: glassBorder),
                      ),
                      child: Icon(
                        isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                        color: textTertiary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? titleAr : title,
                          style: SanctumTypography.labelMedium.copyWith(
                            color: accentColor,
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isRtl ? subtitleAr : subtitle,
                          style: SanctumTypography.bodySmall.copyWith(
                            color: textTertiary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(icon, color: accentColor, size: 24),
                ],
              ),
            ),

            // ─── Active Pulse (persistent) ──────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ActivePulseHeader(vaultIdentity: vaultIdentity),
            ),

            // ─── Coming Soon ────────────────────────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(icon, color: accentColor, size: 36),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isRtl ? 'قريباً' : 'COMING SOON',
                      style: SanctumTypography.labelMedium.copyWith(
                        letterSpacing: 3.0,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRtl
                          ? 'سيتم تفعيل هذه الخزنة في الأوامر القادمة'
                          : 'This vault will be activated in upcoming commands',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Footer ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                isRtl
                    ? 'مشفر بالكامل • خزنة محلية أولاً'
                    : 'Fully Encrypted • Local-First Vault',
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary, letterSpacing: 1.5, fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
