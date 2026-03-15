import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Claim Portal — The Heir's view of the inherited legacy.
///
/// Flow: Sentimental Message (video/audio — mock) → Asset Reveal → Claim button.
///
/// CTO Directive: "The UI must match the Sanctum aesthetic but lead
/// with the 'Sentimental Message' before showing the assets."
/// The 0.75% success fee is displayed on the final "CLAIM FUNDS" button.
class ClaimPortalScreen extends StatefulWidget {
  final String heirAlias;
  final double totalValueUsd;

  const ClaimPortalScreen({
    super.key,
    this.heirAlias = 'The Protector',
    this.totalValueUsd = 2450000.00,
  });

  @override
  State<ClaimPortalScreen> createState() => _ClaimPortalScreenState();
}

class _ClaimPortalScreenState extends State<ClaimPortalScreen>
    with TickerProviderStateMixin {
  bool _messageRevealed = false;
  bool _assetsRevealed = false;
  bool _claiming = false;
  bool _claimed = false;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final AnimationController _revealController;
  late final Animation<double> _revealFade;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accentColor => _isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
  Color get _glassFill => _isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
  Color get _glassBorder => _isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
  Color get _textPrimary => _isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
  Color get _textSecondary => _isDark ? SanctumColors.textSecondary : SanctumColors.lightTextSecondary;
  Color get _textTertiary => _isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
  Color get _bgColor => _isDark ? SanctumColors.abyss : SanctumColors.lightBackground;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000),
    )..repeat();
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _revealController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _revealFade = CurvedAnimation(parent: _revealController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  double get _successFee => widget.totalValueUsd * 0.0075;
  double get _netAmount => widget.totalValueUsd - _successFee;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final goldColor = const Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ─── Header ─────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _glassFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _glassBorder),
                      ),
                      child: Icon(
                        isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                        color: _textTertiary, size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isRtl ? 'بوابة الإرث' : 'CLAIM PORTAL',
                    style: SanctumTypography.labelMedium.copyWith(
                      color: goldColor, letterSpacing: 3.0,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Welcome Heir ─────────────────────────────────────
              Text(
                isRtl ? 'مرحباً،' : 'Welcome,',
                style: SanctumTypography.bodySmall.copyWith(
                  color: _textTertiary, letterSpacing: 1.0,
                ),
              ),
              Text(
                widget.heirAlias,
                style: SanctumTypography.displayMedium.copyWith(
                  color: goldColor, fontSize: 24, letterSpacing: 4.0,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Sentimental Message (Phase 1) ────────────────────
              if (!_messageRevealed)
                _buildSentimentalEnvelope(isRtl, goldColor)
              else ...[
                _buildSentimentalMessage(isRtl, goldColor),
                const SizedBox(height: 20),

                // ─── Asset Reveal (Phase 2) ──────────────────────────
                if (!_assetsRevealed)
                  _buildRevealAssetsButton(isRtl, goldColor)
                else
                  FadeTransition(
                    opacity: _revealFade,
                    child: Column(
                      children: [
                        _buildAssetSummary(isRtl, goldColor),
                        const SizedBox(height: 16),
                        _buildFeeBreakdown(isRtl, goldColor),
                        const SizedBox(height: 20),
                        _buildClaimButton(isRtl, goldColor),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sentimental Envelope (Tap to open) ───────────────────────────

  Widget _buildSentimentalEnvelope(bool isRtl, Color gold) {
    return GestureDetector(
      onTap: () => setState(() => _messageRevealed = true),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glow = 0.1 + 0.1 * math.sin(_glowAnimation.value * 2 * math.pi);
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _glassFill,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: glow),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.mail_outlined, color: gold, size: 48),
                const SizedBox(height: 16),
                Text(
                  isRtl ? 'رسالة من المُوَرِّث' : 'A MESSAGE FROM THE VAULT KEEPER',
                  style: SanctumTypography.labelMedium.copyWith(
                    color: gold, letterSpacing: 2.0, fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isRtl ? 'اضغط لفتح الرسالة' : 'Tap to open',
                  style: SanctumTypography.bodySmall.copyWith(
                    color: _textTertiary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Sentimental Message (Revealed) ───────────────────────────────

  Widget _buildSentimentalMessage(bool isRtl, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: gold, size: 32),
          const SizedBox(height: 12),
          Text(
            isRtl ? 'رسالة شخصية' : 'PERSONAL MESSAGE',
            style: SanctumTypography.labelMedium.copyWith(
              color: gold, letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),

          // Mock video/audio placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gold.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_outline, color: gold, size: 40),
                  const SizedBox(height: 4),
                  Text(
                    isRtl ? 'رسالة فيديو مشفرة' : 'Encrypted Video Message',
                    style: SanctumTypography.bodySmall.copyWith(
                      color: _textTertiary, fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Written message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isRtl
                  ? '"إذا كنت تقرأ هذا، فاعلم أن كل ما بنيته كان من أجلك. '
                    'احفظ هذا الإرث كما حفظته أنا."'
                  : '"If you are reading this, know that everything I built was for you. '
                    'Guard this legacy as I once did."',
              style: SanctumTypography.bodyMedium.copyWith(
                color: _textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reveal Assets Button ─────────────────────────────────────────

  Widget _buildRevealAssetsButton(bool isRtl, Color gold) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          setState(() => _assetsRevealed = true);
          _revealController.forward();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: BorderSide(color: gold.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open, size: 18, color: gold),
            const SizedBox(width: 8),
            Text(
              isRtl ? 'كشف الأصول' : 'REVEAL ASSETS',
              style: SanctumTypography.buttonText.copyWith(
                letterSpacing: 2.0, color: gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Asset Summary ────────────────────────────────────────────────

  Widget _buildAssetSummary(bool isRtl, Color gold) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        children: [
          Text(
            isRtl ? 'ملخص الأصول الموروثة' : 'INHERITED ASSET SUMMARY',
            style: SanctumTypography.labelMedium.copyWith(
              color: gold, letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          _assetRow(isRtl ? 'عقارات' : 'Real Estate', '\$1,200,000', Icons.home_outlined, gold),
          _assetRow(isRtl ? 'أسهم' : 'Corporate Shares', '\$450,000', Icons.trending_up, gold),
          _assetRow(isRtl ? 'حسابات بنكية' : 'Bank Accounts', '\$350,000', Icons.account_balance_outlined, gold),
          _assetRow(isRtl ? 'ذهب / فضة' : 'Gold / Silver', '\$250,000', Icons.diamond_outlined, gold),
          _assetRow(isRtl ? 'أصول رقمية' : 'Crypto / Digital', '\$200,000', Icons.currency_bitcoin, gold),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRtl ? 'الإجمالي' : 'TOTAL',
                style: SanctumTypography.labelMedium.copyWith(
                  color: _textPrimary, letterSpacing: 2.0,
                ),
              ),
              Text(
                '\$${_formatNumber(widget.totalValueUsd)}',
                style: SanctumTypography.monoLarge.copyWith(
                  color: gold, fontSize: 22, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetRow(String label, String value, IconData icon, Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: gold.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: SanctumTypography.bodySmall.copyWith(color: _textSecondary)),
          ),
          Text(value,
              style: SanctumTypography.monoMedium.copyWith(color: _textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Fee Breakdown ────────────────────────────────────────────────

  Widget _buildFeeBreakdown(bool isRtl, Color gold) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                isRtl ? 'تفاصيل الرسوم' : 'FEE BREAKDOWN',
                style: SanctumTypography.labelMedium.copyWith(
                  color: Colors.amber, letterSpacing: 2.0, fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _feeRow(
            isRtl ? 'الإجمالي' : 'Gross Value',
            '\$${_formatNumber(widget.totalValueUsd)}',
          ),
          _feeRow(
            isRtl ? 'رسوم النجاح (0.75%)' : 'Success Fee (0.75%)',
            '-\$${_formatNumber(_successFee)}',
            isDeduction: true,
          ),
          const Divider(height: 16),
          _feeRow(
            isRtl ? 'صافي المبلغ' : 'Net to Heir',
            '\$${_formatNumber(_netAmount)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value,
      {bool isDeduction = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: SanctumTypography.bodySmall.copyWith(
                  color: _textSecondary,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: SanctumTypography.monoMedium.copyWith(
                color: isDeduction
                    ? SanctumColors.statusCritical
                    : (isBold ? _accentColor : _textPrimary),
                fontSize: isBold ? 15 : 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              )),
        ],
      ),
    );
  }

  // ─── Claim Button ─────────────────────────────────────────────────

  Widget _buildClaimButton(bool isRtl, Color gold) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _claiming ? null : _claimFunds,
            style: ElevatedButton.styleFrom(
              backgroundColor: _claimed ? SanctumColors.statusActive : gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _claiming
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _claimed ? Icons.check_circle : Icons.account_balance_wallet,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _claimed
                                ? (isRtl ? '✓ تم تحويل الإرث' : '✓ LEGACY TRANSFERRED')
                                : (isRtl ? 'استلام الإرث' : 'CLAIM FUNDS'),
                            style: SanctumTypography.buttonText.copyWith(
                              letterSpacing: 2.0, color: Colors.black,
                            ),
                          ),
                          if (!_claimed)
                            Text(
                              isRtl
                                  ? 'رسوم النجاح: 0.75% (\$${_formatNumber(_successFee)})'
                                  : 'Success Fee: 0.75% (\$${_formatNumber(_successFee)})',
                              style: TextStyle(
                                fontSize: 9, color: Colors.black.withValues(alpha: 0.6),
                                letterSpacing: 0.5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRtl
              ? 'التحويل نهائي ولا يمكن التراجع عنه'
              : 'Transfer is final and irreversible',
          style: SanctumTypography.bodySmall.copyWith(
            color: _textTertiary, fontSize: 9, letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Future<void> _claimFunds() async {
    setState(() => _claiming = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() { _claiming = false; _claimed = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Directionality.of(context) == TextDirection.rtl
                ? '✓ تم تحويل الإرث بنجاح إلى عنوان المستفيد'
                : '✓ Legacy successfully transferred to beneficiary address',
          ),
          backgroundColor: SanctumColors.statusActive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(2);
  }
}
