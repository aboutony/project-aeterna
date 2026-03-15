import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';

/// Country data model for the GCC + International picker.
class _CountryCode {
  final String flag;
  final String name;
  final String nameAr;
  final String code;

  const _CountryCode(this.flag, this.name, this.nameAr, this.code);
}

/// The OTP Screen — sovereign identity verification.
///
/// ISOLATION NOTE: This is a standalone widget with ZERO external dependencies.
/// It does NOT import AuthService or TursoClient.
/// Mock OTP verification is handled inline — any 6-digit code succeeds.
/// Communicates outward ONLY via the [onVerified] callback.
///
/// Flow: Country Code Selection → Phone Input → Mock OTP → Verify
/// Supports GCC-first country list with international options.
class OtpScreen extends StatefulWidget {
  final VoidCallback? onVerified;

  const OtpScreen({super.key, this.onVerified});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // ─── Country Codes (GCC-first + International) ─────────────────────
  static const _countries = <_CountryCode>[
    // GCC
    _CountryCode('🇸🇦', 'Saudi Arabia', 'السعودية', '+966'),
    _CountryCode('🇦🇪', 'UAE', 'الإمارات', '+971'),
    _CountryCode('🇶🇦', 'Qatar', 'قطر', '+974'),
    _CountryCode('🇰🇼', 'Kuwait', 'الكويت', '+965'),
    _CountryCode('🇧🇭', 'Bahrain', 'البحرين', '+973'),
    _CountryCode('🇴🇲', 'Oman', 'عُمان', '+968'),
    // International
    _CountryCode('🇺🇸', 'United States', 'أمريكا', '+1'),
    _CountryCode('🇬🇧', 'United Kingdom', 'بريطانيا', '+44'),
    _CountryCode('🇩🇪', 'Germany', 'ألمانيا', '+49'),
    _CountryCode('🇫🇷', 'France', 'فرنسا', '+33'),
    _CountryCode('🇮🇳', 'India', 'الهند', '+91'),
    _CountryCode('🇵🇰', 'Pakistan', 'باكستان', '+92'),
    _CountryCode('🇪🇬', 'Egypt', 'مصر', '+20'),
    _CountryCode('🇯🇴', 'Jordan', 'الأردن', '+962'),
    _CountryCode('🇱🇧', 'Lebanon', 'لبنان', '+961'),
    _CountryCode('🇹🇷', 'Turkey', 'تركيا', '+90'),
  ];

  _CountryCode _selectedCountry = _countries[0]; // Default: Saudi Arabia
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isPhoneStage = true; // true = phone input, false = OTP input
  bool _isVerifying = false;
  String? _errorText;

  late final AnimationController _fadeController;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _fadeController.dispose();
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

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _contentFade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ─── Back button ────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    if (!_isPhoneStage) {
                      setState(() {
                        _isPhoneStage = true;
                        _errorText = null;
                        for (final c in _otpControllers) {
                          c.clear();
                        }
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
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

                const SizedBox(height: 32),

                // ─── Header ─────────────────────────────────────────
                Text(
                  _isPhoneStage
                      ? (isRtl ? 'هوية سيادية' : 'Sovereign Identity')
                      : (isRtl ? 'رمز التحقق' : 'Verification Code'),
                  style: SanctumTypography.displayMedium.copyWith(
                    fontSize: 24,
                    letterSpacing: 2.0,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isPhoneStage
                      ? (isRtl
                          ? 'أدخل رقم هاتفك للتحقق من الهوية'
                          : 'Enter your mobile number to verify identity')
                      : (isRtl
                          ? 'أدخل الرمز المكون من ٦ أرقام'
                          : 'Enter the 6-digit code sent to your device'),
                  style: SanctumTypography.bodyMedium.copyWith(
                    color: _textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // ─── Content ────────────────────────────────────────
                _isPhoneStage
                    ? _buildPhoneInput(isRtl)
                    : _buildOtpInput(isRtl),

                // ─── Error ──────────────────────────────────────────
                if (_errorText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorText!,
                    style: SanctumTypography.bodySmall.copyWith(
                      color: SanctumColors.statusCritical,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // ─── Action Button ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: _isDark
                          ? SanctumColors.abyss
                          : SanctumColors.lightSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: _accentColor.withValues(alpha: 0.3),
                    ),
                    child: _isVerifying
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _isDark
                                  ? SanctumColors.abyss
                                  : SanctumColors.lightSurface,
                            ),
                          )
                        : Text(
                            _isPhoneStage
                                ? (isRtl ? 'إرسال الرمز' : 'SEND CODE')
                                : (isRtl ? 'تحقق' : 'VERIFY'),
                            style: SanctumTypography.buttonText.copyWith(
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Mock hint ──────────────────────────────────────
                if (!_isPhoneStage)
                  Center(
                    child: Text(
                      isRtl
                          ? 'تلميح العرض: أي رمز من ٦ أرقام يعمل'
                          : 'Demo hint: any 6-digit code works',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: _textTertiary,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Phone Input Section ──────────────────────────────────────────────
  Widget _buildPhoneInput(bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Picker
        Text(
          isRtl ? 'رمز الدولة' : 'Country Code',
          style: SanctumTypography.labelMedium.copyWith(
            color: _textTertiary,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCountryPicker(isRtl),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _glassFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _glassBorder),
            ),
            child: Row(
              children: [
                Text(
                  _selectedCountry.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedCountry.code,
                  style: SanctumTypography.monoLarge.copyWith(
                    color: _accentColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isRtl ? _selectedCountry.nameAr : _selectedCountry.name,
                    style: SanctumTypography.bodyMedium.copyWith(
                      color: _textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: _textTertiary, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Phone Number Input
        Text(
          isRtl ? 'رقم الهاتف' : 'Phone Number',
          style: SanctumTypography.labelMedium.copyWith(
            color: _textTertiary,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _glassFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _glassBorder),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: SanctumTypography.monoLarge.copyWith(
              color: _textPrimary,
              fontSize: 18,
              letterSpacing: 2.0,
            ),
            decoration: InputDecoration(
              hintText: isRtl ? '٥٥ ١٢٣ ٤٥٦٧' : '55 123 4567',
              hintStyle: SanctumTypography.monoLarge.copyWith(
                color: _textTertiary,
                fontSize: 18,
                letterSpacing: 2.0,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  _selectedCountry.code,
                  style: SanctumTypography.monoLarge.copyWith(
                    color: _accentColor,
                    fontSize: 18,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
          ),
        ),
      ],
    );
  }

  // ─── OTP Input Section ────────────────────────────────────────────────
  Widget _buildOtpInput(bool isRtl) {
    return Column(
      children: [
        // Phone display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android, color: _accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_selectedCountry.code} ${_phoneController.text}',
                style: SanctumTypography.monoMedium.copyWith(
                  color: _accentColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // OTP fields
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 44,
              height: 56,
              margin: EdgeInsets.only(
                left: i > 0 ? 8 : 0,
                right: i == 2 ? 8 : 0, // Extra spacing after 3rd digit
              ),
              decoration: BoxDecoration(
                color: _glassFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpControllers[i].text.isNotEmpty
                      ? _accentColor.withValues(alpha: 0.5)
                      : _glassBorder,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: SanctumTypography.monoLarge.copyWith(
                  color: _accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {}); // Refresh border color
                  if (value.isNotEmpty && i < 5) {
                    _otpFocusNodes[i + 1].requestFocus();
                  }
                  if (value.isEmpty && i > 0) {
                    _otpFocusNodes[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── Country Picker Bottom Sheet ──────────────────────────────────────
  void _showCountryPicker(bool isRtl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDark ? SanctumColors.obsidian : SanctumColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isRtl ? 'اختر الدولة' : 'Select Country',
                style: SanctumTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
            // GCC header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  isRtl ? 'دول الخليج' : 'GCC',
                  style: SanctumTypography.labelMedium.copyWith(
                    color: _accentColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _countries.length,
                itemBuilder: (context, i) {
                  final c = _countries[i];
                  final isGccEnd = i == 5;
                  return Column(
                    children: [
                      ListTile(
                        leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
                        title: Text(
                          isRtl ? c.nameAr : c.name,
                          style: SanctumTypography.bodyMedium.copyWith(
                            color: _textPrimary,
                          ),
                        ),
                        trailing: Text(
                          c.code,
                          style: SanctumTypography.monoMedium.copyWith(
                            color: _textSecondary,
                          ),
                        ),
                        onTap: () {
                          setState(() => _selectedCountry = c);
                          Navigator.pop(context);
                        },
                      ),
                      if (isGccEnd) ...[
                        Divider(color: _glassBorder, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              isRtl ? 'دولي' : 'INTERNATIONAL',
                              style: SanctumTypography.labelMedium.copyWith(
                                color: _accentColor,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────
  void _onAction() {
    if (_isPhoneStage) {
      // Validate phone
      if (_phoneController.text.length < 7) {
        setState(() => _errorText = 'Please enter a valid phone number');
        return;
      }
      setState(() {
        _isPhoneStage = false;
        _errorText = null;
      });
      // Auto-focus first OTP field
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _otpFocusNodes[0].requestFocus();
      });
    } else {
      // Verify OTP
      final otp = _otpControllers.map((c) => c.text).join();
      if (otp.length != 6) {
        setState(() => _errorText = 'Please enter all 6 digits');
        return;
      }
      _verifyOtp(otp);
    }
  }

  /// Mock OTP verification — inline, no external service dependency.
  /// Any 6-digit code succeeds. Fires [onVerified] callback on success.
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Mock verification: any 6-digit OTP is valid
    if (otp.length == 6) {
      debugPrint('[OtpScreen] ✓ Mock OTP verified: ${_selectedCountry.code} ${_phoneController.text}');
      widget.onVerified?.call();
    } else {
      setState(() {
        _isVerifying = false;
        _errorText = 'Verification failed. Please try again.';
      });
    }
  }
}
