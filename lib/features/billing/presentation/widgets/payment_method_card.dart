import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Payment Method Type — USDT (Polygon) or Credit/Debit Card.
enum PaymentType { usdt, card }

/// Payment Method Card — Glassmorphic selection tile.
///
/// USDT Mode:
///   - Connect Wallet button (mock)
///   - QR code deposit address display
///   - Copy-to-clipboard on address
///
/// Card Mode:
///   - Mock Visa/Mastercard interface
///   - "Coming Soon" connector
class PaymentMethodCard extends StatelessWidget {
  final PaymentType type;
  final bool isSelected;
  final bool isConnected;
  final VoidCallback onSelect;
  final VoidCallback onConnect;

  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.isConnected,
    required this.onSelect,
    required this.onConnect,
  });

  // Mock USDT deposit address (Polygon network)
  static const _mockDepositAddress =
      '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;

    final cardColor = type == PaymentType.usdt
        ? const Color(0xFF26A17B) // Tether green
        : const Color(0xFF1A1F71); // Visa blue

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cardColor.withValues(alpha: 0.5)
                : glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Row ─────────────────────────────────────────
            Row(
              children: [
                // Payment icon
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColor.withValues(alpha: 0.12),
                    border: Border.all(color: cardColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(
                    type == PaymentType.usdt
                        ? Icons.currency_bitcoin // closest to USDT
                        : Icons.credit_card,
                    color: cardColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == PaymentType.usdt
                            ? 'USDT (Polygon)'
                            : (isRtl ? 'بطاقة ائتمان/خصم' : 'Credit/Debit Card'),
                        style: SanctumTypography.bodyMedium.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        type == PaymentType.usdt
                            ? (isRtl ? 'السكة الأساسية' : 'Primary Rail')
                            : (isRtl ? 'فيزا / ماستركارد' : 'Visa / Mastercard'),
                        style: SanctumTypography.bodySmall.copyWith(
                          color: textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selected indicator
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? cardColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? cardColor : textTertiary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: cardColor, size: 14)
                      : null,
                ),
              ],
            ),

            // ─── USDT Details (when selected) ──────────────────────
            if (type == PaymentType.usdt && isSelected) ...[
              const SizedBox(height: 16),

              // Connect Wallet / Connected Badge
              if (!isConnected)
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onConnect,
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    label: Text(
                      isRtl ? 'توصيل المحفظة' : 'CONNECT WALLET',
                      style: SanctumTypography.buttonText.copyWith(
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: cardColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isRtl ? 'المحفظة متصلة' : 'Wallet Connected',
                        style: SanctumTypography.bodySmall.copyWith(
                          color: cardColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // Deposit Address label
              Text(
                isRtl ? 'عنوان الإيداع (Polygon)' : 'Deposit Address (Polygon)',
                style: SanctumTypography.bodySmall.copyWith(
                  color: textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              // QR Code
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: _mockDepositAddress,
                    version: QrVersions.auto,
                    size: 140,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0A0A0E),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0A0A0E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Address with copy
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    const ClipboardData(text: _mockDepositAddress),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isRtl ? '✓ تم نسخ العنوان' : '✓ Address copied',
                      ),
                      backgroundColor: cardColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_mockDepositAddress.substring(0, 12)}...${_mockDepositAddress.substring(_mockDepositAddress.length - 8)}',
                          style: SanctumTypography.monoMedium.copyWith(
                            color: textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Icon(Icons.copy, size: 16, color: accentColor),
                    ],
                  ),
                ),
              ),
            ],

            // ─── Card Details (when selected) ──────────────────────
            if (type == PaymentType.card && isSelected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.add_card, size: 18),
                  label: Text(
                    isRtl ? 'إضافة بطاقة' : 'ADD CARD',
                    style: SanctumTypography.buttonText.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  isRtl
                      ? 'بوابة الدفع بالبطاقة قيد التطوير'
                      : 'Card payment gateway under development',
                  style: SanctumTypography.bodySmall.copyWith(
                    color: textTertiary, fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
