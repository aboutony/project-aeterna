import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/dashboard/presentation/widgets/active_pulse_header.dart';

/// Financial Sub-Vault — The Sovereign Wealth Gateway.
///
/// Presents a SliverGrid of asset categories within the 450px
/// Mobile-First constraint. Each category is a glassmorphic tile
/// with a unique icon, ready for Command 6 (Add Asset forms).
///
/// Categories: Real Estate, Corporate Shares, Bank Accounts,
/// Precious Metals, Crypto/Digital Assets.
class FinancialVaultScreen extends StatelessWidget {
  final Map<String, dynamic>? vaultIdentity;
  final VoidCallback? onPulseTap;

  const FinancialVaultScreen({
    super.key,
    this.vaultIdentity,
    this.onPulseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor = isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;

    final categories = _getCategories(isRtl);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
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
                            isRtl ? 'الأصول المالية' : 'FINANCIAL ASSETS',
                            style: SanctumTypography.labelMedium.copyWith(
                              color: SanctumColors.assetFinancial,
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRtl ? 'الثروة السيادية' : 'Sovereign Wealth',
                            style: SanctumTypography.bodySmall.copyWith(
                              color: textTertiary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.shield_outlined,
                      color: SanctumColors.assetFinancial,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            // ─── Active Pulse (persistent) ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ActivePulseHeader(
                  vaultIdentity: vaultIdentity,
                  onPulseTap: onPulseTap,
                ),
              ),
            ),

            // ─── Section Title ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
                child: Text(
                  isRtl ? 'اختر فئة الأصل' : 'SELECT ASSET CATEGORY',
                  style: SanctumTypography.labelMedium.copyWith(
                    letterSpacing: 2.0,
                    color: textTertiary,
                  ),
                ),
              ),
            ),

            // ─── Asset Category Grid ────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    return _AssetCategoryTile(
                      icon: cat.icon,
                      title: cat.title,
                      subtitle: cat.subtitle,
                      accentColor: cat.color,
                      glassFill: glassFill,
                      glassBorder: glassBorder,
                      textPrimary: textPrimary,
                      textTertiary: textTertiary,
                      onTap: () {
                        debugPrint('[FinancialVault] Tapped: ${cat.title}');
                        // Command 6 will implement the Add Asset forms
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isRtl
                                  ? '${cat.title} — قريباً في الأمر ٦'
                                  : '${cat.title} — Coming in Command 6',
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
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),

            // ─── Footer ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 40),
                child: Column(
                  children: [
                    Container(
                      width: 40, height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            SanctumColors.assetFinancial.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRtl
                          ? 'مشفر بالكامل • خزنة محلية أولاً'
                          : 'Fully Encrypted • Local-First Vault',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: textTertiary, letterSpacing: 1.5, fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_AssetCategoryData> _getCategories(bool isRtl) {
    return [
      _AssetCategoryData(
        icon: Icons.apartment_outlined,
        title: isRtl ? 'العقارات' : 'Real Estate',
        subtitle: isRtl ? 'أراضٍ • مباني • حصص' : 'Land • Buildings • Shares',
        color: const Color(0xFF2ECC71),
      ),
      _AssetCategoryData(
        icon: Icons.business_outlined,
        title: isRtl ? 'الأسهم والحصص' : 'Corporate Shares',
        subtitle: isRtl ? 'شركات • صناديق • حقوق' : 'Equity • Funds • Rights',
        color: const Color(0xFF3498DB),
      ),
      _AssetCategoryData(
        icon: Icons.account_balance_outlined,
        title: isRtl ? 'الحسابات البنكية' : 'Bank Accounts',
        subtitle: isRtl ? 'جارية • ادخار • وديعة' : 'Current • Savings • FD',
        color: const Color(0xFF9B59B6),
      ),
      _AssetCategoryData(
        icon: Icons.diamond_outlined,
        title: isRtl ? 'المعادن الثمينة' : 'Precious Metals',
        subtitle: isRtl ? 'ذهب • فضة • بلاتين' : 'Gold • Silver • Platinum',
        color: const Color(0xFFD4AF37),
      ),
      _AssetCategoryData(
        icon: Icons.currency_bitcoin_outlined,
        title: isRtl ? 'الأصول الرقمية' : 'Crypto & Digital',
        subtitle: isRtl ? 'محافظ • رموز • NFT' : 'Wallets • Tokens • NFTs',
        color: const Color(0xFFE67E22),
      ),
    ];
  }
}

class _AssetCategoryData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AssetCategoryData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// Individual asset category tile — glassmorphic design.
class _AssetCategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color glassFill;
  final Color glassBorder;
  final Color textPrimary;
  final Color textTertiary;
  final VoidCallback? onTap;

  const _AssetCategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textTertiary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Spacer(),
              // Title
              Text(
                title,
                style: SanctumTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              // Subtitle
              Text(
                subtitle,
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Accent bar
              Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.6),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
