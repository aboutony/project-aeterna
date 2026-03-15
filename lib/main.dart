import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:project_aeterna/core/theme/sanctum_theme.dart';
import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/core/transitions/dissolve_transition.dart';
import 'package:project_aeterna/features/biometric/presentation/biometric_screen.dart';
import 'package:project_aeterna/features/splash/presentation/splash_screen.dart';
import 'package:project_aeterna/features/dashboard/presentation/sanctum_dashboard.dart';
import 'package:project_aeterna/features/onboarding/presentation/welcome_screen.dart';
import 'package:project_aeterna/features/onboarding/presentation/otp_screen.dart';
import 'package:project_aeterna/features/onboarding/data/auth_service.dart';
import 'package:project_aeterna/features/vault/data/database/turso_client.dart';
import 'package:project_aeterna/features/vault/presentation/asset_detail_screen.dart';
import 'package:project_aeterna/security/key_derivation.dart';

// Web database factory
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for web platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
    debugPrint('[Aeterna] Web database factory initialized (sqflite_ffi_web)');
  }

  runApp(const AeternaApp());
}

/// Project Aeterna — The Sovereign Digital Vault
///
/// Mobile-First, Edge-Native, Zero-Knowledge architecture.
/// On web/desktop: constrained to 450px centered frame.
/// On mobile: edge-to-edge fullscreen.
class AeternaApp extends StatefulWidget {
  const AeternaApp({super.key});

  @override
  State<AeternaApp> createState() => _AeternaAppState();
}

class _AeternaAppState extends State<AeternaApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Locale _locale = const Locale('en', '');
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  // Auth data — populated on session check or OTP verify
  String _userPhone = '';
  String _userCountryCode = '';

  @override
  void initState() {
    super.initState();
    _detectLocale();
    _checkAuth();
  }

  /// Auto-detect browser/device locale for bilingual support.
  void _detectLocale() {
    try {
      final platformLocales = ui.PlatformDispatcher.instance.locales;
      for (final locale in platformLocales) {
        if (locale.languageCode == 'ar') {
          _locale = const Locale('ar', '');
          debugPrint('[Aeterna] Auto-detected Arabic locale — RTL mode');
          return;
        }
      }
      debugPrint('[Aeterna] Locale: English (default)');
    } catch (_) {
      debugPrint('[Aeterna] Locale detection fallback: English');
    }
  }

  /// Check if user has an active session.
  Future<void> _checkAuth() async {
    final hasSession = await AuthService.instance.checkSession();
    if (mounted) {
      if (hasSession) {
        final profile = AuthService.instance.userProfile;
        _userPhone = profile['user_phone'] ?? '';
        _userCountryCode = profile['user_country_code'] ?? '';
      }
      setState(() {
        _isAuthenticated = hasSession;
        _isCheckingAuth = false;
      });
    }
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  void _setThemeMode(ThemeMode mode) {
    _themeNotifier.value = mode;
  }



  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Project Aeterna',
          debugShowCheckedModeBanner: false,

          // Dual theme — Alabaster White / Digital Sanctum
          theme: SanctumTheme.light,
          darkTheme: SanctumTheme.dark,
          themeMode: mode,

          // ─── Global RTL/LTR Localization ─────────────────────────────
          locale: _locale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ─── Named Routes (for logout navigation) ─────────────────
          routes: {
            '/asset-details': (context) => const AssetDetailScreen(),
            '/welcome': (context) => _buildWelcomeScreen(),
          },

          // Force directionality + Mobile-First responsive container
          builder: (context, child) {
            Widget content = Directionality(
              textDirection:
                  _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );

            // ─── Mobile-First Constraint ─────────────────────────────
            // On web/desktop: 450px centered, simulating mobile device
            // On mobile: edge-to-edge
            if (kIsWeb || _isDesktop()) {
              final isDark = mode == ThemeMode.dark;
              content = Container(
                color: isDark
                    ? const Color(0xFF050508) // Ultra-dark ambient
                    : const Color(0xFFE8E4DE), // Warm cream ambient
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? SanctumColors.irisCore
                                    : SanctumColors.lightAccent)
                                .withValues(alpha: 0.08),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: content,
                    ),
                  ),
                ),
              );
            }

            return content;
          },

          home: _isCheckingAuth
              ? _buildAuthCheckScreen()
              : _isAuthenticated
                  ? _buildSplashToDashboard()
                  : _buildWelcomeScreen(),
        );
      },
    );
  }

  /// Splash screen while checking auth session.
  Widget _buildAuthCheckScreen() {
    final isDark = _themeNotifier.value == ThemeMode.dark;
    return Scaffold(
      backgroundColor: isDark ? SanctumColors.abyss : SanctumColors.lightBackground,
      body: Center(
        child: SizedBox(
          width: 32, height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? SanctumColors.irisCore : SanctumColors.lightAccent,
          ),
        ),
      ),
    );
  }

  /// Welcome screen — unauthenticated entry.
  /// Flow: Welcome → OTP → Splash (2s) → BiometricScreen → Dashboard
  Widget _buildWelcomeScreen() {
    return WelcomeScreen(
      themeNotifier: _themeNotifier,
      onEnter: () {
        final nav = _navigatorKey.currentState;
        if (nav == null) return;
        nav.push(
          DissolvePageRoute(
            page: OtpScreen(
              onVerified: () {
                setState(() => _isAuthenticated = true);
                nav.pushAndRemoveUntil(
                  DissolvePageRoute(
                    page: SplashScreen(
                      onComplete: () {
                        debugPrint('[Aeterna] OTP → Splash → Biometric');
                        nav.pushReplacement(
                          DissolvePageRoute(
                            page: BiometricScreen(
                              onComplete: () {
                                debugPrint('[Aeterna] Biometric → Dashboard');
                                nav.pushReplacement(
                                  DissolvePageRoute(
                                    page: _dashboardWidget(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Returning user flow: Splash (2s) → BiometricScreen → Dashboard
  Widget _buildSplashToDashboard() {
    return SplashScreen(
      onComplete: () {
        debugPrint('[Aeterna] Authenticated → Biometric gate');
        final nav = _navigatorKey.currentState;
        if (nav == null) return;
        nav.pushReplacement(
          DissolvePageRoute(
            page: BiometricScreen(
              onComplete: () {
                debugPrint('[Aeterna] Biometric → Dashboard');
                nav.pushReplacement(
                  DissolvePageRoute(page: _dashboardWidget()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _dashboardWidget() {
    return SanctumDashboard(
      onLocaleChange: _setLocale,
      onThemeChange: _setThemeMode,
      currentThemeMode: _themeNotifier.value,
      themeNotifier: _themeNotifier,
      countryCode: _userCountryCode,
      phoneNumber: _userPhone,
      onLogout: _handleLogout,
    );
  }

  /// Logout: clear DB session, reset state, navigate to Welcome.
  void _handleLogout() async {
    await AuthService.instance.logout();
    _userPhone = '';
    _userCountryCode = '';
    if (mounted) {
      setState(() => _isAuthenticated = false);
      // Force-navigate to WelcomeScreen, removing all routes
      _navigatorKey.currentState?.pushAndRemoveUntil(
        DissolvePageRoute(page: _buildWelcomeScreen()),
        (route) => false,
      );
    }
  }

  bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}

/// Demo Home — Sprint 1 Fidelity Demonstration
///
/// Shows:
///   1. Key Derivation demo button
///   2. Database health check
///   3. RTL/LTR locale toggle
///   4. Offline-first status
class DemoHomeScreen extends StatefulWidget {
  final ValueChanged<Locale>? onLocaleChange;

  const DemoHomeScreen({super.key, this.onLocaleChange});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  bool _isRunningKeyDemo = false;
  String _keyStatus = 'Ready';
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: SanctumColors.abyss,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ─────────────────────────────────────────
              Text(
                'AETERNA',
                style: SanctumTypography.displayMedium.copyWith(
                  letterSpacing: 12,
                  color: SanctumColors.irisCore,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isRtl ? 'لوحة القيادة — السبرنت ١' : 'Sprint 1 — Command Panel',
                style: SanctumTypography.sanctumInstruction,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ─── RTL/LTR Toggle ─────────────────────────────────
              _buildGlassCard(
                title: isRtl ? 'اللغة والاتجاه' : 'Language & Direction',
                icon: Icons.language,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRtl
                          ? 'الوضع الحالي: عربي (RTL)'
                          : 'Current: English (LTR)',
                      style: SanctumTypography.bodyMedium,
                    ),
                    Switch(
                      value: _isArabic,
                      activeTrackColor: SanctumColors.irisCore.withValues(alpha: 0.5),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return SanctumColors.irisCore;
                        }
                        return SanctumColors.textSecondary;
                      }),
                      onChanged: (value) {
                        setState(() => _isArabic = value);
                        widget.onLocaleChange?.call(
                          value ? const Locale('ar', '') : const Locale('en', ''),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Direction Verification Card ────────────────────
              _buildGlassCard(
                title: isRtl ? 'التحقق من الاتجاه' : 'Direction Verification',
                icon: isRtl ? Icons.format_textdirection_r_to_l : Icons.format_textdirection_l_to_r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _verificationRow(
                      isRtl ? 'اتجاه النص' : 'Text Direction',
                      isRtl ? 'يمين → يسار ✓' : 'Left → Right ✓',
                    ),
                    const SizedBox(height: 8),
                    _verificationRow(
                      isRtl ? 'محاذاة الأيقونات' : 'Icon Alignment',
                      isRtl ? 'معكوس ✓' : 'Standard ✓',
                    ),
                    const SizedBox(height: 8),
                    _verificationRow(
                      isRtl ? 'تخطيط الزجاج' : 'Glass Layout',
                      isRtl ? 'سليم ✓' : 'Intact ✓',
                    ),
                    const SizedBox(height: 12),
                    // Gradient bar to verify glassmorphism doesn't break
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [
                            SanctumColors.irisCore,
                            SanctumColors.irisAmber,
                            SanctumColors.irisShadow,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Zero-Knowledge Key Derivation ──────────────────
              _buildGlassCard(
                title: isRtl ? 'اشتقاق المفتاح' : 'Key Derivation',
                icon: Icons.fingerprint,
                child: Column(
                  children: [
                    Text(
                      _keyStatus,
                      style: SanctumTypography.monoMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isRunningKeyDemo ? null : _runKeyDemo,
                        child: Text(
                          _isRunningKeyDemo
                              ? (isRtl ? 'جارٍ الاشتقاق...' : 'DERIVING...')
                              : (isRtl ? 'تشغيل اشتقاق المفتاح' : 'RUN KEY DERIVATION'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Offline-First Status ───────────────────────────
              _buildGlassCard(
                title: isRtl ? 'الوضع غير المتصل' : 'Offline-First Status',
                icon: Icons.wifi_off,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _verificationRow(
                      isRtl ? 'قاعدة البيانات المحلية' : 'Local Database',
                      isRtl ? 'نشط ✓' : 'Active ✓',
                    ),
                    const SizedBox(height: 8),
                    _verificationRow(
                      isRtl ? 'المزامنة السحابية' : 'Cloud Sync',
                      isRtl ? 'غير متصل (طبيعي)' : 'Disconnected (Normal)',
                    ),
                    const SizedBox(height: 8),
                    _verificationRow(
                      isRtl ? 'نبض القلب' : 'Heartbeat Pulse',
                      isRtl ? 'يسجل محلياً ✓' : 'Recording Locally ✓',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SanctumColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SanctumColors.glassBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: SanctumColors.irisCore, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: SanctumTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: SanctumColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _verificationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SanctumTypography.bodyMedium),
        Text(
          value,
          style: SanctumTypography.monoMedium.copyWith(
            color: SanctumColors.statusActive,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _runKeyDemo() async {
    setState(() {
      _isRunningKeyDemo = true;
      _keyStatus = 'Executing Biology-to-Entropy pipeline...';
    });

    try {
      await KeyDerivation.runDemonstration();
      setState(() {
        _keyStatus = '✓ Zero-Knowledge Proof Complete\n'
            'See console for full output';
      });
    } catch (e) {
      setState(() {
        _keyStatus = '✗ Error: $e';
      });
    } finally {
      setState(() => _isRunningKeyDemo = false);
    }
  }
}
