import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Glassmorphic Asset Card — the visual chapter of the Digital Sanctum.
///
/// Three variants exist:
///   1. **Financial** — Emerald Teal, shield icon, wealth data
///   2. **Sentimental** — Rose Quartz/Warm Amber, heart icon, legacy media
///   3. **Discrete** — Royal Violet, lock icon, confidential credentials
///
/// CTO Directive: "The 'Sentimental Legacy' card must feel distinctively
/// warmer than the 'Financial' card."
///
/// Implements true Glassmorphism via `BackdropFilter` with 20px blur,
/// semi-transparent fill, and golden border glow.
enum AssetCategory {
  financial,
  sentimental,
  discrete,
}

class AssetCard extends StatefulWidget {
  final AssetCategory category;
  final int assetCount;
  final String? subtitle;
  final Map<String, dynamic>? extraData;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.category,
    required this.assetCount,
    this.subtitle,
    this.extraData,
    this.onTap,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final config = _categoryConfig(isRtl);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final accent = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, _) {
        final fadeIn = _shimmerAnimation.value;

        return Opacity(
          opacity: fadeIn,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - fadeIn)),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: config.accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            config.accentColor.withValues(alpha: 0.08),
                            glassFill,
                            config.secondaryColor.withValues(alpha: 0.04),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Header row ─────────────────────────
                            Row(
                              children: [
                                // Category icon with glow
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: config.accentColor.withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: config.accentColor.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    config.icon,
                                    color: config.accentColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        config.title,
                                        style: SanctumTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        config.subtitle,
                                        style: SanctumTypography.bodySmall.copyWith(
                                          color: config.accentColor.withValues(alpha: 0.7),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Asset count badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: config.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: config.accentColor.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${widget.assetCount}',
                                    style: SanctumTypography.monoLarge.copyWith(
                                      fontSize: 18,
                                      color: config.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ─── Detail row (category-specific) ─────
                            _buildDetailRow(config, isRtl, textTertiary, accent),

                            const SizedBox(height: 12),

                            // ─── Accent bar ─────────────────────────
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    config.accentColor.withValues(alpha: 0.6),
                                    config.secondaryColor.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(_AssetCardConfig config, bool isRtl, Color textTertiary, Color accent) {
    switch (widget.category) {
      case AssetCategory.financial:
        final haswallet = widget.extraData?['hasWallets'] == true;
        return Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 14,
              color: textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              isRtl ? 'مشفر بالكامل' : 'Fully Encrypted',
              style: SanctumTypography.bodySmall,
            ),
            const Spacer(),
            if (haswallet) ...[
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 14,
                color: accent.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                isRtl ? 'محافظ وريث' : 'Heir Wallets',
                style: SanctumTypography.bodySmall.copyWith(
                  color: accent.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        );

      case AssetCategory.sentimental:
        final totalSize = widget.extraData?['totalSizeBytes'] as int? ?? 0;
        final sizeStr = _formatBytes(totalSize);
        final types = (widget.extraData?['types'] as List?)?.cast<String>() ?? [];
        return Row(
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 14,
              color: textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              isRtl ? 'مستودع R2: $sizeStr' : 'R2 Vault: $sizeStr',
              style: SanctumTypography.bodySmall,
            ),
            const Spacer(),
            ...types.take(2).map((t) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: _mediaTypeBadge(t),
            )),
          ],
        );

      case AssetCategory.discrete:
        return Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              isRtl ? 'الوصول: المستوى ٥' : 'Access: Tier 5',
              style: SanctumTypography.bodySmall,
            ),
            const Spacer(),
            Icon(
              Icons.visibility_off_outlined,
              size: 14,
              color: config.accentColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              isRtl ? 'سري' : 'Classified',
              style: SanctumTypography.bodySmall.copyWith(
                color: config.accentColor.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        );
    }
  }

  Widget _mediaTypeBadge(String type) {
    final label = type.replaceAll('_', ' ').split(' ').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SanctumColors.assetSentimentalWarm.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: SanctumTypography.bodySmall.copyWith(
          fontSize: 9,
          color: SanctumColors.assetSentimentalWarm,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _AssetCardConfig _categoryConfig(bool isRtl) {
    switch (widget.category) {
      case AssetCategory.financial:
        return _AssetCardConfig(
          title: isRtl ? 'الأصول المالية' : 'Financial Assets',
          subtitle: isRtl ? 'الثروة السيادية' : 'Sovereign Wealth',
          icon: Icons.shield_outlined,
          accentColor: SanctumColors.assetFinancial,
          secondaryColor: SanctumColors.irisCore,
        );
      case AssetCategory.sentimental:
        return _AssetCardConfig(
          title: isRtl ? 'الإرث العاطفي' : 'Sentimental Legacy',
          subtitle: isRtl ? 'ذكريات خالدة' : 'Eternal Memories',
          icon: Icons.favorite_outline,
          accentColor: SanctumColors.assetSentimental,
          secondaryColor: SanctumColors.assetSentimentalWarm,
        );
      case AssetCategory.discrete:
        return _AssetCardConfig(
          title: isRtl ? 'الأصول السرية' : 'Discrete Assets',
          subtitle: isRtl ? 'بيانات سرية' : 'Classified Credentials',
          icon: Icons.lock_outline,
          accentColor: SanctumColors.assetDiscrete,
          secondaryColor: SanctumColors.statusTriggered,
        );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    final value = bytes / math.pow(1024, i);
    return '${value.toStringAsFixed(1)} ${suffixes[i.clamp(0, 4)]}';
  }
}

class _AssetCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color secondaryColor;

  _AssetCardConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.secondaryColor,
  });
}

