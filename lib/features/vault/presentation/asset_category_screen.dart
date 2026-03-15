import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Asset Category Detail Screen — "No Assets Found" empty state.
///
/// Navigated to when tapping a financial sub-category (Real Estate, etc.).
/// Shows a branded empty state with an "Add New" CTA placeholder.
class AssetCategoryScreen extends StatelessWidget {
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final IconData icon;
  final Color accentColor;

  const AssetCategoryScreen({
    super.key,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor = isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
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
                            letterSpacing: 2.0,
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

            // ─── Empty State ─────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.08),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: accentColor.withValues(alpha: 0.6),
                          size: 36,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        isRtl ? 'لا توجد أصول' : 'No Assets Found',
                        style: SanctumTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        isRtl
                            ? 'لم يتم تسجيل أي ${titleAr} في خزنتك بعد.'
                            : 'No $title have been registered\nin your vault yet.',
                        style: SanctumTypography.bodySmall.copyWith(
                          color: textTertiary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Add New button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isRtl
                                      ? 'نموذج الإضافة — قريباً في السبرنت التالي'
                                      : 'Add Asset form — coming in the next Sprint',
                                ),
                                backgroundColor: accentColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: isDark
                                ? SanctumColors.abyss
                                : SanctumColors.lightSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isRtl ? 'إضافة أصل جديد' : 'ADD NEW ASSET',
                                style: SanctumTypography.buttonText.copyWith(
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Encryption notice
                      Text(
                        isRtl
                            ? 'مشفر بالكامل • خزنة محلية أولاً'
                            : 'Fully Encrypted • Local-First Vault',
                        style: SanctumTypography.bodySmall.copyWith(
                          color: textTertiary,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
