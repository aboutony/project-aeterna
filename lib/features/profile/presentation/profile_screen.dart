import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/core/transitions/dissolve_transition.dart';
import 'package:project_aeterna/features/billing/presentation/billing_settings_screen.dart';
import 'package:project_aeterna/features/onboarding/data/auth_service.dart';

/// Profile Screen — Sovereign Identity Management.
///
/// ISOLATION NOTE: This is a standalone widget with ZERO external dependencies.
/// It does NOT import AuthService or TursoClient.
/// "Mock Save" uses local setState + in-memory map — no DB writes.
/// Communicates outward ONLY via the [onLogout] callback.
///
/// Fields:
///   - Legal Name (editable)
///   - Verified Mobile (read-only, passed via constructor)
///   - Country Code (read-only, passed via constructor)
///   - Legal ID Metadata (type selector + number input)
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final String countryCode;
  final String phoneNumber;
  final String? initialName;

  const ProfileScreen({
    super.key,
    this.onLogout,
    this.countryCode = '',
    this.phoneNumber = '',
    this.initialName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService.instance;
  final _nameController = TextEditingController();
  final _legalIdController = TextEditingController();
  String _legalIdType = 'passport'; // passport | national_id
  bool _isSaving = false;
  bool _saved = false;

  /// In-memory profile store — local "app_settings" mock.
  /// This is the "Identity Island" — no DB, no AuthService.
  final Map<String, String> _localProfile = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate from constructor params
    _localProfile['user_phone'] = widget.phoneNumber;
    _localProfile['user_country_code'] = widget.countryCode;
    // Pre-populate name if provided by AuthService
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
      _localProfile['user_full_name'] = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legalIdController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accentColor => _isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;
  Color get _glassFill => _isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
  Color get _glassBorder => _isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;
  Color get _textPrimary => _isDark ? SanctumColors.textPrimary : SanctumColors.lightTextPrimary;
  Color get _textSecondary => _isDark ? SanctumColors.textSecondary : SanctumColors.lightTextSecondary;
  Color get _textTertiary => _isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
  Color get _bgColor => _isDark ? SanctumColors.abyss : SanctumColors.lightBackground;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final phone = widget.phoneNumber.isNotEmpty
        ? '${widget.countryCode} ${widget.phoneNumber}'
        : '';

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ─── Header ───────────────────────────────────────────
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
                        color: _textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isRtl ? 'الملف الشخصي' : 'PROFILE',
                    style: SanctumTypography.labelMedium.copyWith(
                      color: _accentColor,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance for back button
                ],
              ),

              const SizedBox(height: 32),

              // ─── Avatar ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: _accentColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : (isRtl ? 'مالك الخزنة' : 'Vault Owner'),
                  style: SanctumTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              if (phone.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      phone,
                      style: SanctumTypography.monoMedium.copyWith(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // ─── Full Name (Legal) ────────────────────────────────
              _buildSectionHeader(
                isRtl ? 'الاسم الكامل (قانوني)' : 'Full Name (Legal)',
                Icons.badge_outlined,
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: isRtl ? 'كما هو في جواز السفر' : 'As appears on passport',
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),

              const SizedBox(height: 24),

              // ─── Verified Mobile ──────────────────────────────────
              _buildSectionHeader(
                isRtl ? 'الهاتف الموثق' : 'Verified Mobile',
                Icons.verified_outlined,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _glassFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: _accentColor, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      phone.isNotEmpty ? phone : (isRtl ? 'لم يُضف بعد' : 'Not set'),
                      style: SanctumTypography.monoMedium.copyWith(
                        color: phone.isNotEmpty ? _textPrimary : _textTertiary,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: SanctumColors.statusActive.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isRtl ? 'موثق' : 'Verified',
                        style: SanctumTypography.bodySmall.copyWith(
                          color: SanctumColors.statusActive,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Country Code (Read-Only) ─────────────────────────
              _buildSectionHeader(
                isRtl ? 'رمز الدولة' : 'Country Code',
                Icons.flag_outlined,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _glassFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.public, color: _accentColor, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      widget.countryCode.isNotEmpty
                          ? widget.countryCode
                          : (isRtl ? 'لم يُحدد' : 'Not set'),
                      style: SanctumTypography.monoMedium.copyWith(
                        color: widget.countryCode.isNotEmpty
                            ? _textPrimary
                            : _textTertiary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Legal ID Metadata ────────────────────────────────
              _buildSectionHeader(
                isRtl ? 'بيانات الهوية القانونية' : 'Legal ID Metadata',
                Icons.security_outlined,
              ),
              const SizedBox(height: 8),

              // ID Type selector
              Container(
                decoration: BoxDecoration(
                  color: _glassFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _glassBorder),
                ),
                child: Row(
                  children: [
                    _idTypeButton(
                      'passport',
                      isRtl ? 'جواز سفر' : 'Passport',
                      Icons.menu_book_outlined,
                    ),
                    _idTypeButton(
                      'national_id',
                      isRtl ? 'هوية وطنية' : 'National ID',
                      Icons.credit_card_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _legalIdController,
                hint: _legalIdType == 'passport'
                    ? (isRtl ? 'رقم جواز السفر' : 'Passport Number')
                    : (isRtl ? 'رقم الهوية الوطنية' : 'National ID Number'),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),

              const SizedBox(height: 32),

              // ─── Mock Save Button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _mockSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _isDark
                        ? SanctumColors.abyss
                        : SanctumColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _saved ? Icons.check : Icons.save_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _saved
                                  ? (isRtl ? 'تم الحفظ' : 'SAVED')
                                  : (isRtl ? 'حفظ الملف' : 'MOCK SAVE'),
                              style: SanctumTypography.buttonText.copyWith(
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Billing & Payments ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      DissolvePageRoute(
                        page: const BillingSettingsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accentColor,
                    side: BorderSide(
                      color: _accentColor.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 18, color: _accentColor),
                      const SizedBox(width: 8),
                      Text(
                        Directionality.of(context) == TextDirection.rtl
                            ? 'الفوترة والمدفوعات'
                            : 'BILLING & PAYMENTS',
                        style: SanctumTypography.buttonText.copyWith(
                          letterSpacing: 2.0,
                          color: _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Logout Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SanctumColors.statusCritical,
                    side: BorderSide(
                      color: SanctumColors.statusCritical.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isRtl ? 'تسجيل الخروج' : 'LOGOUT',
                        style: SanctumTypography.buttonText.copyWith(
                          letterSpacing: 2.0,
                          color: SanctumColors.statusCritical,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accentColor, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: SanctumTypography.labelMedium.copyWith(
            color: _textTertiary,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _glassBorder),
      ),
      child: TextField(
        controller: controller,
        style: SanctumTypography.bodyMedium.copyWith(
          color: _textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: SanctumTypography.bodyMedium.copyWith(
            color: _textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _idTypeButton(String type, String label, IconData icon) {
    final isActive = _legalIdType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _legalIdType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? _accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? _accentColor : _textTertiary, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: SanctumTypography.bodySmall.copyWith(
                  color: isActive ? _accentColor : _textTertiary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mock Save — writes to local in-memory map + shows SnackBar.
  /// Updates the local `_localProfile` (simulating `app_settings` table).
  /// No AuthService. No TursoClient. Pure setState.
  Future<void> _mockSaveProfile() async {
    setState(() => _isSaving = true);

    // Simulate a brief save delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Write to local in-memory profile store
    _localProfile['user_full_name'] = _nameController.text;
    _localProfile['user_legal_id'] = _legalIdController.text;
    _localProfile['user_legal_id_type'] = _legalIdType;

    debugPrint('[ProfileScreen] ✓ Mock Save to local app_settings:');
    _localProfile.forEach((key, value) {
      debugPrint('  $key: $value');
    });

    if (mounted) {
      setState(() {
        _isSaving = false;
        _saved = true;
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Directionality.of(context) == TextDirection.rtl
                ? '✓ تم حفظ الملف الشخصي محلياً'
                : '✓ Profile saved to local app_settings',
          ),
          backgroundColor: SanctumColors.statusActive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Reset saved indicator after 2s
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
    }
  }

  /// Logout confirmation — fires [onLogout] callback. No AuthService dependency.
  void _confirmLogout() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDark ? SanctumColors.obsidian : SanctumColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isRtl ? 'تسجيل الخروج' : 'Logout',
          style: SanctumTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        content: Text(
          isRtl
              ? 'سيتم مسح جلستك بالكامل. هل أنت متأكد؟'
              : 'Your session will be completely cleared. Are you sure?',
          style: SanctumTypography.bodyMedium.copyWith(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isRtl ? 'إلغاء' : 'Cancel',
              style: TextStyle(color: _textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _authService.logout(); // Clear the local DB session
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
            child: Text(
              isRtl ? 'تسجيل الخروج' : 'Logout',
              style: const TextStyle(color: SanctumColors.statusCritical),
            ),
          ),
        ],
      ),
    );
  }
}
