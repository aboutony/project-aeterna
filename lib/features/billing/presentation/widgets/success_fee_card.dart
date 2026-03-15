import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Success Fee Transparency Card — 0.75% Inheritance Transfer Fee.
///
/// A glassmorphic informational card that explains the fee structure
/// as mandated by Doc 6. Hard-coded 0.75% — non-negotiable.
///
/// CTO Directive: "Add a 'Transparency Card' explaining the 0.75%
/// Inheritance Success Fee that is hard-coded into the final asset transfer."
class SuccessFeeCard extends StatelessWidget {
  const SuccessFeeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ─────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? 'رسوم نجاح التوريث' : 'INHERITANCE SUCCESS FEE',
                      style: SanctumTypography.labelMedium.copyWith(
                        color: accentColor,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      isRtl ? 'بطاقة الشفافية' : 'Transparency Card',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── Fee Display ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '0.75%',
                  style: SanctumTypography.monoLarge.copyWith(
                    color: accentColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isRtl
                      ? 'من القيمة الإجمالية المحولة'
                      : 'of total transferred value',
                  style: SanctumTypography.bodySmall.copyWith(
                    color: textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ─── Explanation Items ───────────────────────────────────
          _buildExplainerRow(
            isRtl ? 'يُطبق فقط عند التحويل الناجح للأصول' : 'Only applied upon successful asset transfer',
            Icons.check_circle_outline,
            textPrimary,
            accentColor,
          ),
          const SizedBox(height: 8),
          _buildExplainerRow(
            isRtl ? 'لا رسوم على التخزين أو البيومتري' : 'No fees on storage or biometric access',
            Icons.check_circle_outline,
            textPrimary,
            accentColor,
          ),
          const SizedBox(height: 8),
          _buildExplainerRow(
            isRtl ? 'محدد في العقد الذكي — لا يمكن تعديله' : 'Hard-coded in smart contract — immutable',
            Icons.lock_outline,
            textPrimary,
            accentColor,
          ),
          const SizedBox(height: 8),
          _buildExplainerRow(
            isRtl
                ? 'يغطي: إدارة الخزنة، بروتوكول النقل، والتحقق'
                : 'Covers: Vault custody, transfer protocol & verification',
            Icons.info_outline,
            textPrimary,
            accentColor,
          ),

          const SizedBox(height: 14),

          // ─── Disclaimer ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isRtl
                        ? 'هذه الرسوم ثابتة ولا يمكن التفاوض عليها. '
                          'هي جزء لا يتجزأ من عقد النقل الذكي.'
                        : 'This fee is fixed and non-negotiable. '
                          'It is an integral part of the transfer smart contract.',
                    style: SanctumTypography.bodySmall.copyWith(
                      color: Colors.amber.withValues(alpha: 0.8),
                      fontSize: 10,
                      height: 1.4,
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

  Widget _buildExplainerRow(
    String text, IconData icon, Color textColor, Color accentColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: accentColor.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: SanctumTypography.bodySmall.copyWith(
              color: textColor,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
