import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/dashboard/data/dashboard_data_service.dart';

/// Asset Category Detail Screen — lists real vault assets via FutureBuilder.
///
/// Navigated to when tapping a vault chapter (Financial, Sentimental, Discrete).
/// Fetches data from the local DB and renders results; shows branded empty state
/// if none exist.
class AssetCategoryScreen extends StatefulWidget {
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final IconData icon;
  final Color accentColor;
  final String categoryId;

  const AssetCategoryScreen({
    super.key,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.icon,
    required this.accentColor,
    required this.categoryId,
  });

  @override
  State<AssetCategoryScreen> createState() => _AssetCategoryScreenState();
}

class _AssetCategoryScreenState extends State<AssetCategoryScreen> {
  final DashboardDataService _dataService = DashboardDataService.instance;
  late Future<List<Map<String, dynamic>>> _assetsFuture;

  @override
  void initState() {
    super.initState();
    _assetsFuture = _dataService.getAssetsByCategory(widget.categoryId);
  }

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
                          isRtl ? widget.titleAr : widget.title,
                          style: SanctumTypography.labelMedium.copyWith(
                            color: widget.accentColor,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isRtl ? widget.subtitleAr : widget.subtitle,
                          style: SanctumTypography.bodySmall.copyWith(
                            color: textTertiary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(widget.icon, color: widget.accentColor, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Asset List via FutureBuilder ─────────────────────────
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _assetsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.accentColor,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(
                      isDark: isDark,
                      isRtl: isRtl,
                      textPrimary: textPrimary,
                      textTertiary: textTertiary,
                    );
                  }

                  final assets = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: assets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            debugPrint("Asset Clicked: ${asset['id']}");
                            Navigator.pushNamed(context, '/asset-details', arguments: asset);
                          },
                          child: _buildAssetTile(
                            asset: asset,
                            isDark: isDark,
                            isRtl: isRtl,
                            glassFill: glassFill,
                            glassBorder: glassBorder,
                            textPrimary: textPrimary,
                            textTertiary: textTertiary,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a single asset row card.
  Widget _buildAssetTile({
    required Map<String, dynamic> asset,
    required bool isDark,
    required bool isRtl,
    required Color glassFill,
    required Color glassBorder,
    required Color textPrimary,
    required Color textTertiary,
  }) {
    // Determine display name + subtitle based on category
    String displayName;
    String displaySubtitle;
    IconData tileIcon;

    if (widget.categoryId == 'SENTIMENTAL') {
      final mediaType = asset['media_type'] as String? ?? 'MEDIA';
      final sizeBytes = asset['file_size_bytes'] as int? ?? 0;
      final sizeMB = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
      displayName = _mediaTypeLabel(mediaType, isRtl);
      displaySubtitle = '$sizeMB MB';
      tileIcon = _mediaTypeIcon(mediaType);
    } else {
      final category = asset['category'] as String? ?? '';
      final tier = asset['access_tier'] as int? ?? 0;
      final hasWallet = asset['heir_wallet_address'] != null;
      displayName = isRtl
          ? (category == 'FINANCIAL' ? 'أصل مالي' : 'أصل سري')
          : (category == 'FINANCIAL' ? 'Financial Asset' : 'Discrete Asset');
      displaySubtitle = isRtl
          ? 'المستوى $tier${hasWallet ? ' • محفظة مرتبطة' : ''}'
          : 'Tier $tier${hasWallet ? ' • Wallet linked' : ''}';
      tileIcon = category == 'FINANCIAL'
          ? Icons.account_balance_outlined
          : Icons.lock_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.accentColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              tileIcon,
              color: widget.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: SanctumTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displaySubtitle,
                  style: SanctumTypography.bodySmall.copyWith(
                    color: textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: widget.accentColor.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  String _mediaTypeLabel(String type, bool isRtl) {
    switch (type) {
      case 'VIDEO_LEGACY':
        return isRtl ? 'فيديو إرثي' : 'Legacy Video';
      case 'PHOTO_ARCHIVE':
        return isRtl ? 'أرشيف صور' : 'Photo Archive';
      case 'VOICE_VAULT':
        return isRtl ? 'خزنة صوتية' : 'Voice Vault';
      default:
        return isRtl ? 'وسائط' : 'Media';
    }
  }

  IconData _mediaTypeIcon(String type) {
    switch (type) {
      case 'VIDEO_LEGACY':
        return Icons.videocam_outlined;
      case 'PHOTO_ARCHIVE':
        return Icons.photo_library_outlined;
      case 'VOICE_VAULT':
        return Icons.mic_outlined;
      default:
        return Icons.perm_media_outlined;
    }
  }

  /// Branded empty state — shown when the category has no assets.
  Widget _buildEmptyState({
    required bool isDark,
    required bool isRtl,
    required Color textPrimary,
    required Color textTertiary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.accentColor.withValues(alpha: 0.6),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isRtl ? 'لا توجد أصول' : 'No Assets Found',
              style: SanctumTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl
                  ? 'لم يتم تسجيل أي ${widget.titleAr} في خزنتك بعد.'
                  : 'No ${widget.title} have been registered\nin your vault yet.',
              style: SanctumTypography.bodySmall.copyWith(
                color: textTertiary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
                      backgroundColor: widget.accentColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
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
    );
  }
}
