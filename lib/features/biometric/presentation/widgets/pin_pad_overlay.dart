import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Glassmorphic PIN Pad — Secure fallback authentication.
///
/// Features:
///   - 6-digit PIN with circular dot indicators
///   - Scrambled keypad (randomized number positions each time)
///   - Golden accent on dark glass buttons
///   - Frosted background blur overlay
///   - Mock verify: any 6-digit PIN succeeds
///
/// CTO Directive: "Include a 'Physical Fallback' link that opens
/// a secure, high-end PIN pad."
class PinPadOverlay extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PinPadOverlay({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PinPadOverlay> createState() => _PinPadOverlayState();
}

class _PinPadOverlayState extends State<PinPadOverlay>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late List<int> _keyOrder;
  bool _isVerifying = false;
  late final AnimationController _entryController;
  late final Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _scrambleKeys();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
  }

  void _scrambleKeys() {
    _keyOrder = List.generate(10, (i) => i)..shuffle(math.Random());
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _onDigitTap(int digit) {
    if (_isVerifying || _pin.length >= 6) return;
    setState(() => _pin += digit.toString());

    if (_pin.length == 6) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_isVerifying || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    // Mock verification — any 6-digit PIN succeeds
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
    final textPrimary = isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final glassFill = isDark
        ? SanctumColors.obsidian.withValues(alpha: 0.95)
        : SanctumColors.lightSurface.withValues(alpha: 0.95);

    return FadeTransition(
      opacity: _entryAnimation,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Icon(Icons.close, color: textTertiary, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      isRtl ? 'رمز الوصول' : 'ACCESS PIN',
                      style: SanctumTypography.labelMedium.copyWith(
                        letterSpacing: 3.0,
                        color: accentColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24), // Balance
                  ],
                ),
              ),

              const Spacer(),

              // ─── Lock Icon ──────────────────────────────────────
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  _isVerifying ? Icons.lock_open_outlined : Icons.lock_outline,
                  color: accentColor,
                  size: 28,
                ),
              ),

              const SizedBox(height: 24),

              // ─── PIN Dots ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: filled ? 14 : 12,
                    height: filled ? 14 : 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? accentColor
                          : Colors.transparent,
                      border: Border.all(
                        color: filled
                            ? accentColor
                            : accentColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: filled
                          ? [BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            )]
                          : null,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // ─── Status text ────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isVerifying
                      ? (isRtl ? 'جارٍ التحقق...' : 'Verifying...')
                      : (isRtl ? 'أدخل رمز الوصول' : 'Enter your access PIN'),
                  key: ValueKey(_isVerifying),
                  style: SanctumTypography.bodySmall.copyWith(
                    color: _isVerifying ? accentColor : textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ─── Scrambled Keypad ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _buildKeypad(
                  accentColor: accentColor,
                  textPrimary: textPrimary,
                  glassFill: glassFill,
                ),
              ),

              const Spacer(),

              // ─── Footer ─────────────────────────────────────────
              Text(
                isRtl ? 'لوحة مفاتيح مشفرة' : 'Scrambled Keypad • Anti-Shoulder',
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

  Widget _buildKeypad({
    required Color accentColor,
    required Color textPrimary,
    required Color glassFill,
  }) {
    // Layout: 3 rows of 3 digits + bottom row (empty, 0, delete)
    final rows = <List<Widget>>[];

    for (int row = 0; row < 3; row++) {
      final rowWidgets = <Widget>[];
      for (int col = 0; col < 3; col++) {
        final idx = row * 3 + col;
        final digit = _keyOrder[idx + 1]; // 1-9 scrambled
        rowWidgets.add(_buildKey(
          digit.toString(), () => _onDigitTap(digit),
          accentColor: accentColor,
          textPrimary: textPrimary,
          glassFill: glassFill,
        ));
      }
      rows.add(rowWidgets);
    }

    // Bottom row: empty | 0 | delete
    rows.add([
      const SizedBox(width: 70, height: 60),
      _buildKey(
        _keyOrder[0].toString(), () => _onDigitTap(_keyOrder[0]),
        accentColor: accentColor,
        textPrimary: textPrimary,
        glassFill: glassFill,
      ),
      _buildKey(
        '⌫', _onDelete,
        accentColor: accentColor,
        textPrimary: textPrimary,
        glassFill: glassFill,
        isAction: true,
      ),
    ]);

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(
    String label,
    VoidCallback onTap, {
    required Color accentColor,
    required Color textPrimary,
    required Color glassFill,
    bool isAction = false,
  }) {
    return GestureDetector(
      onTap: _isVerifying ? null : onTap,
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          color: glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: isAction
                ? TextStyle(
                    fontSize: 22,
                    color: accentColor.withValues(alpha: 0.6),
                  )
                : SanctumTypography.monoLarge.copyWith(
                    fontSize: 22,
                    color: accentColor,
                  ),
          ),
        ),
      ),
    );
  }
}
