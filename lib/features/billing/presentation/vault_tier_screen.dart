import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Vault Tier Selection Screen — Sovereign Free vs Masterpiece Pro.
///
/// Presents two subscription tiers with glassmorphic comparison cards.
/// Returns the selected tier string ('free' | 'pro') via Navigator.pop().
///
/// Tier Details:
///   - Sovereign Free: 1GB R2 Storage, Standard Biometrics.
///   - Masterpiece Pro: 10GB R2 Storage, Advanced Sharding, Priority Support.
class VaultTierScreen extends StatelessWidget {
  final String currentTier;

  const VaultTierScreen({
    super.key,
    required this.currentTier,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor = isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // ─── Header ────────────────────────────────────────────
              Row(
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
                  const Spacer(),
                  Text(
                    isRtl ? 'مستويات الخزنة' : 'VAULT TIERS',
                    style: SanctumTypography.labelMedium.copyWith(
                      color: accentColor,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Subtitle ──────────────────────────────────────────
              Text(
                isRtl
                    ? 'اختر مستوى الحماية المناسب لثروتك السيادية'
                    : 'Choose the protection level for your sovereign wealth',
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary, letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // ─── The Keeper Tier ────────────────────────────────────
              _buildTierCard(
                context: context,
                tier: 'keeper',
                isActive: currentTier == 'keeper',
                title: isRtl ? 'الحارس' : 'THE KEEPER',
                price: '\$9.99/mo',
                description: isRtl
                    ? 'حماية رقمية أساسية'
                    : 'Entry-level digital protection.',
                icon: Icons.shield_outlined,
                color: SanctumColors.statusActive,
                features: [
                  _TierFeature(isRtl ? '1GB تخزين R2' : '1GB R2 Storage', true),
                  _TierFeature(isRtl ? 'بيومتري قياسي' : 'Standard Biometrics', true),
                  _TierFeature(isRtl ? 'تشفير من طرف إلى طرف' : 'End-to-End Encryption', true),
                  _TierFeature(isRtl ? 'خزنة محلية أولاً' : 'Local-First Vault', true),
                ],
                accentColor: accentColor,
                textPrimary: textPrimary,
                textTertiary: textTertiary,
                glassFill: glassFill,
                glassBorder: glassBorder,
              ),

              const SizedBox(height: 16),

              // ─── The Patriarch Tier ─────────────────────────────────
              _buildTierCard(
                context: context,
                tier: 'patriarch',
                isActive: currentTier == 'patriarch',
                title: isRtl ? 'البطريرك' : 'THE PATRIARCH',
                price: '\$29.99/mo',
                description: isRtl
                    ? 'أمان جاهز للنقاب وإدارة العائلة'
                    : 'Niqab-Ready security & family mgmt.',
                icon: Icons.security,
                color: const Color(0xFFC0C0C0),
                features: [
                  _TierFeature(isRtl ? '5GB تخزين R2' : '5GB R2 Storage', true),
                  _TierFeature(isRtl ? 'بيومتري متقدم' : 'Advanced Biometrics', true),
                  _TierFeature(isRtl ? 'تشفير من طرف إلى طرف' : 'End-to-End Encryption', true),
                  _TierFeature(isRtl ? 'خزنة محلية أولاً' : 'Local-First Vault', true),
                  _TierFeature(isRtl ? 'إدارة العائلة' : 'Family Management', true),
                ],
                accentColor: accentColor,
                textPrimary: textPrimary,
                textTertiary: textTertiary,
                glassFill: glassFill,
                glassBorder: glassBorder,
                isRecommended: true,
              ),

              const SizedBox(height: 16),

              // ─── The Sovereign Tier ─────────────────────────────────
              _buildTierCard(
                context: context,
                tier: 'sovereign',
                isActive: currentTier == 'sovereign',
                title: isRtl ? 'السيادي' : 'THE SOVEREIGN',
                price: '\$49.99/mo',
                description: isRtl
                    ? 'ضمان USDT كامل وسرية تامة'
                    : 'Full USDT escrow & total discretion.',
                icon: Icons.diamond_outlined,
                color: goldColor,
                features: [
                  _TierFeature(isRtl ? '20GB تخزين R2' : '20GB R2 Storage', true),
                  _TierFeature(isRtl ? 'توقيع بيومتري متعدد' : 'Biometric Multi-Sig', true),
                  _TierFeature(isRtl ? 'بروتوكول المنفذ الإرثي' : 'Legacy Executor Protocol', true),
                ],
                accentColor: accentColor,
                textPrimary: textPrimary,
                textTertiary: textTertiary,
                glassFill: glassFill,
                glassBorder: glassBorder,
              ),

              const SizedBox(height: 24),

              // ─── Footer ────────────────────────────────────────────
              Text(
                isRtl
                    ? 'يمكنك التبديل بين المستويات في أي وقت'
                    : 'You can switch tiers at any time',
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary, fontSize: 10, letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required BuildContext context,
    required String tier,
    required bool isActive,
    required String title,
    required String price,
    required String description,
    required IconData icon,
    required Color color,
    required List<_TierFeature> features,
    required Color accentColor,
    required Color textPrimary,
    required Color textTertiary,
    required Color glassFill,
    required Color glassBorder,
    bool isRecommended = false,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.5) : glassBorder,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Recommended badge
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  isRtl ? '⭐ مُوصى به' : '⭐ RECOMMENDED',
                  style: SanctumTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Icon + Title
                Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.1),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: SanctumTypography.labelMedium.copyWith(
                              color: color,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            price,
                            style: SanctumTypography.monoMedium.copyWith(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: SanctumTypography.bodySmall.copyWith(
                              color: textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isRtl ? 'حالي' : 'CURRENT',
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Feature list
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        f.included ? Icons.check_circle : Icons.remove_circle_outline,
                        size: 16,
                        color: f.included ? color : textTertiary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        f.label,
                        style: SanctumTypography.bodySmall.copyWith(
                          color: f.included ? textPrimary : textTertiary.withValues(alpha: 0.4),
                          decoration: f.included ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 16),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: isActive
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isRtl ? 'خطتك الحالية' : 'Current Plan',
                            style: TextStyle(color: textTertiary, letterSpacing: 1.0),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(tier),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            tier == 'sovereign'
                                ? (isRtl ? 'اختيار السيادي' : 'SELECT SOVEREIGN')
                                : tier == 'patriarch'
                                    ? (isRtl ? 'ترقية إلى البطريرك' : 'UPGRADE TO PATRIARCH')
                                    : (isRtl ? 'اختر الحارس' : 'SELECT KEEPER'),
                            style: SanctumTypography.buttonText.copyWith(
                              letterSpacing: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierFeature {
  final String label;
  final bool included;
  const _TierFeature(this.label, this.included);
}
