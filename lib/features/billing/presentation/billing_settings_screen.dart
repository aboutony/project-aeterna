import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/core/transitions/dissolve_transition.dart';
import 'package:project_aeterna/features/billing/presentation/vault_tier_screen.dart';
import 'package:project_aeterna/features/billing/presentation/widgets/payment_method_card.dart';
import 'package:project_aeterna/features/billing/presentation/widgets/success_fee_card.dart';

/// Billing & Payments Settings — Sovereign Subscription Hub.
///
/// Accessible from the Profile screen. Contains:
///   1. Current Vault Tier (with upgrade button)
///   2. Payment Methods (USDT + Card)
///   3. Inheritance Success Fee transparency card
///
/// CTO Directive: "Create a dedicated Billing & Payments section."
class BillingSettingsScreen extends StatefulWidget {
  const BillingSettingsScreen({super.key});

  @override
  State<BillingSettingsScreen> createState() => _BillingSettingsScreenState();
}

class _BillingSettingsScreenState extends State<BillingSettingsScreen> {
  String _currentTier = 'free';        // 'free' | 'pro'
  String _paymentMethod = 'none';      // 'none' | 'usdt' | 'card'
  bool _walletConnected = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accentColor => _isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
  Color get _glassFill => _isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
  Color get _glassBorder => _isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
  Color get _textTertiary => _isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
  Color get _bgColor => _isDark ? SanctumColors.abyss : SanctumColors.lightBackground;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 8),
                child: Row(
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
                          color: _textTertiary,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isRtl ? 'الفوترة والمدفوعات' : 'BILLING & PAYMENTS',
                      style: SanctumTypography.labelMedium.copyWith(
                        color: _accentColor,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // ─── Current Tier Banner ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildCurrentTierBanner(isRtl),
              ),
            ),

            // ─── Section: Payment Methods ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
                child: Text(
                  isRtl ? 'طرق الدفع' : 'PAYMENT METHODS',
                  style: SanctumTypography.labelMedium.copyWith(
                    letterSpacing: 3.0, color: _textTertiary,
                  ),
                ),
              ),
            ),

            // ─── USDT (Polygon) ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: PaymentMethodCard(
                  type: PaymentType.usdt,
                  isSelected: _paymentMethod == 'usdt',
                  isConnected: _walletConnected,
                  onSelect: () => setState(() => _paymentMethod = 'usdt'),
                  onConnect: _mockConnectWallet,
                ),
              ),
            ),

            // ─── Credit/Debit ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: PaymentMethodCard(
                  type: PaymentType.card,
                  isSelected: _paymentMethod == 'card',
                  isConnected: false,
                  onSelect: () => setState(() => _paymentMethod = 'card'),
                  onConnect: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isRtl
                            ? 'سيتم تفعيل بوابة البطاقة قريباً'
                            : 'Card gateway coming soon'),
                        backgroundColor: _accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ─── Section: Transparency ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
                child: Text(
                  isRtl ? 'الشفافية' : 'TRANSPARENCY',
                  style: SanctumTypography.labelMedium.copyWith(
                    letterSpacing: 3.0, color: _textTertiary,
                  ),
                ),
              ),
            ),

            // ─── Success Fee Card ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: const SuccessFeeCard(),
              ),
            ),

            // ─── Footer ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 40),
                child: Center(
                  child: Text(
                    isRtl
                        ? 'جميع المعاملات مشفرة من طرف إلى طرف'
                        : 'All transactions are end-to-end encrypted',
                    style: SanctumTypography.bodySmall.copyWith(
                      color: _textTertiary, fontSize: 10, letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Current Tier Banner ──────────────────────────────────────────

  Widget _buildCurrentTierBanner(bool isRtl) {
    final isPro = _currentTier == 'pro';
    final tierColor = isPro ? const Color(0xFFD4AF37) : SanctumColors.statusActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tierColor.withValues(alpha: 0.12),
              border: Border.all(color: tierColor.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isPro ? Icons.diamond_outlined : Icons.shield_outlined,
              color: tierColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro
                      ? (isRtl ? 'تحفة برو' : 'MASTERPIECE PRO')
                      : (isRtl ? 'سيادة مجاني' : 'SOVEREIGN FREE'),
                  style: SanctumTypography.labelMedium.copyWith(
                    color: tierColor,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPro
                      ? (isRtl ? '10GB تخزين • تجزئة متقدمة' : '10GB Storage • Advanced Sharding')
                      : (isRtl ? '1GB تخزين • بيومتري قياسي' : '1GB Storage • Standard Biometrics'),
                  style: SanctumTypography.bodySmall.copyWith(
                    color: _textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.of(context).push<String>(
                DissolvePageRoute(
                  page: VaultTierScreen(currentTier: _currentTier),
                ),
              );
              if (result != null && mounted) {
                setState(() => _currentTier = result);
                _persistTier(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                isPro
                    ? (isRtl ? 'إدارة' : 'Manage')
                    : (isRtl ? 'ترقية' : 'Upgrade'),
                style: SanctumTypography.bodySmall.copyWith(
                  color: _accentColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────

  void _mockConnectWallet() {
    setState(() => _walletConnected = true);
    _persistPaymentState('usdt', 'connected');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Directionality.of(context) == TextDirection.rtl
              ? '✓ تم توصيل المحفظة (محاكاة)'
              : '✓ Wallet connected (mock)',
        ),
        backgroundColor: SanctumColors.statusActive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _persistTier(String tier) async {
    debugPrint('[BillingSettings] Tier saved: $tier');
    // In production: write to app_settings table via TursoClient.
  }

  Future<void> _persistPaymentState(String method, String state) async {
    debugPrint('[BillingSettings] Payment state: $method = $state');
    // In production: write to app_settings table via TursoClient.
  }
}
