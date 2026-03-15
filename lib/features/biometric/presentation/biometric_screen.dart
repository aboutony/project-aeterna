import 'package:flutter/material.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/biometric/presentation/painters/face_scan_painter.dart';
import 'package:project_aeterna/features/biometric/presentation/painters/fingerprint_painter.dart';
import 'package:project_aeterna/features/biometric/presentation/widgets/pin_pad_overlay.dart';
import 'package:project_aeterna/features/splash/presentation/widgets/iris_portal.dart';
import 'package:project_aeterna/security/key_derivation.dart';

/// Biometric Authentication Screen — The Cascade.
///
/// Presents three biometric authentication modes with unique 60fps
/// animations, plus a PIN fallback, all within the 450px mobile constraint.
///
/// Modes:
///   1. Iris   — Existing IrisPortalPainter (concentric golden rings)
///   2. Face   — FaceScanPainter (orbiting light-ring)
///   3. Touch  — FingerprintPainter (sonar ripple waves)
///   4. PIN    — Scrambled glassmorphic keypad overlay
///
/// All successful authentication paths trigger KeyDerivation.deriveAndStore()
/// then fire [onComplete] → dissolve to Dashboard.
///
/// CTO Directive: Mode switching must use 300ms cross-fade.
enum BiometricMode { iris, face, touch }

class BiometricScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const BiometricScreen({super.key, this.onComplete});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with TickerProviderStateMixin {
  BiometricMode _currentMode = BiometricMode.iris;
  bool _isScanning = false;
  bool _isUnlocking = false;
  bool _showPinPad = false;
  double _scanProgress = 0.0;

  // ─── Animation Controllers ──────────────────────────────────────────
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _particleController;
  late final AnimationController _scanController;

  // ─── Animations ─────────────────────────────────────────────────────
  late final Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();

    // Entry reveal — 1.2s
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    // Continuous pulse — 4s breathing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Continuous rotation (for Iris ring + Face orbit) — 6s cycle
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Particle orbit (Iris) — 20s
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Scan progress — 2s
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanController.addListener(() {
      setState(() => _scanProgress = _scanController.value);
    });
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onScanComplete();
      }
    });

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  // ─── Scan Actions ──────────────────────────────────────────────────

  void _startScan() {
    if (_isScanning || _isUnlocking) return;
    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
    });
    _scanController.forward(from: 0.0);
  }

  Future<void> _onScanComplete() async {
    setState(() {
      _isScanning = false;
      _isUnlocking = true;
    });
    
    // Derive the master key
    try {
      await KeyDerivation.deriveAndStore();
      debugPrint('[BiometricScreen] ✓ Key derived via ${_currentMode.name}');
    } catch (e) {
      debugPrint('[BiometricScreen] Key derivation error: $e');
    }

    // Brief hold for visual feedback
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      widget.onComplete?.call();
    }
  }

  void _onPinSuccess() async {
    setState(() {
      _showPinPad = false;
      _isUnlocking = true;
    });

    try {
      await KeyDerivation.deriveAndStore();
      debugPrint('[BiometricScreen] ✓ Key derived via PIN');
    } catch (e) {
      debugPrint('[BiometricScreen] Key derivation error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      widget.onComplete?.call();
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor = isDark ? SanctumColors.abyss : SanctumColors.lightBackground;
    final textTertiary = isDark ? SanctumColors.textTertiary : SanctumColors.lightTextTertiary;
    final accentColor = isDark ? SanctumColors.irisCore : SanctumColors.lightAccent;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Main Content ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ─── Title ──────────────────────────────────────
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _entryAnimation,
                  child: Text(
                    'AETERNA',
                    style: SanctumTypography.displayMedium.copyWith(
                      letterSpacing: 12,
                      fontSize: 20,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: _entryAnimation,
                  child: Text(
                    isRtl ? 'المصادقة البيومترية' : 'BIOMETRIC AUTHENTICATION',
                    style: SanctumTypography.labelMedium.copyWith(
                      letterSpacing: 2.5,
                      color: textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ),

                // ─── Biometric Canvas ───────────────────────────
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _startScan,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _buildBiometricCanvas(),
                      ),
                    ),
                  ),
                ),

                // ─── Mode Label ─────────────────────────────────
                _buildModeLabel(isRtl, accentColor, textTertiary),

                const SizedBox(height: 16),

                // ─── Mode Toggles ───────────────────────────────
                _buildModeToggles(accentColor, textTertiary, isDark),

                const SizedBox(height: 16),

                // ─── PIN Fallback Link ──────────────────────────
                GestureDetector(
                  onTap: () => setState(() => _showPinPad = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      isRtl ? 'استخدام رمز الوصول' : 'Use PIN instead',
                      style: SanctumTypography.bodySmall.copyWith(
                        color: accentColor.withValues(alpha: 0.5),
                        decoration: TextDecoration.underline,
                        decorationColor: accentColor.withValues(alpha: 0.3),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // ─── PIN Pad Overlay ───────────────────────────────────
          if (_showPinPad)
            PinPadOverlay(
              onSuccess: _onPinSuccess,
              onCancel: () => setState(() => _showPinPad = false),
            ),

          // ─── Unlocking Overlay ────────────────────────────────
          if (_isUnlocking)
            Container(
              color: bgColor.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isRtl ? 'جارٍ فتح الخزنة...' : 'Unlocking Vault...',
                      style: SanctumTypography.bodyMedium.copyWith(
                        color: accentColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Biometric Canvas ──────────────────────────────────────────────

  Widget _buildBiometricCanvas() {
    switch (_currentMode) {
      case BiometricMode.iris:
        return _buildIrisCanvas();
      case BiometricMode.face:
        return _buildFaceCanvas();
      case BiometricMode.touch:
        return _buildFingerprintCanvas();
    }
  }

  Widget _buildIrisCanvas() {
    return AnimatedBuilder(
      key: const ValueKey('iris'),
      animation: Listenable.merge([
        _pulseController,
        _rotationController,
        _particleController,
        _entryController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.50,
          ),
          painter: IrisPortalPainter(
            pulsePhase: _pulseController.value,
            rotationAngle: _rotationController.value * 6.283,
            particlePhase: _particleController.value,
            entryProgress: _entryAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildFaceCanvas() {
    return AnimatedBuilder(
      key: const ValueKey('face'),
      animation: Listenable.merge([
        _rotationController,
        _pulseController,
        _entryController,
        _scanController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.50,
          ),
          painter: FaceScanPainter(
            orbitPhase: _rotationController.value,
            pulsePhase: _pulseController.value,
            entryProgress: _entryAnimation.value,
            scanProgress: _isScanning ? _scanProgress : 0.0,
          ),
        );
      },
    );
  }

  Widget _buildFingerprintCanvas() {
    return AnimatedBuilder(
      key: const ValueKey('fingerprint'),
      animation: Listenable.merge([
        _rotationController,
        _pulseController,
        _entryController,
        _scanController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.50,
          ),
          painter: FingerprintPainter(
            ripplePhase: _rotationController.value,
            pulsePhase: _pulseController.value,
            entryProgress: _entryAnimation.value,
            scanProgress: _isScanning ? _scanProgress : 0.0,
            isScanning: _isScanning,
          ),
        );
      },
    );
  }

  // ─── Mode Label ────────────────────────────────────────────────────

  Widget _buildModeLabel(bool isRtl, Color accent, Color tertiary) {
    final labels = {
      BiometricMode.iris: isRtl ? 'اضغط لمسح القزحية' : 'Tap to scan iris',
      BiometricMode.face: isRtl ? 'اضغط لمسح الوجه' : 'Tap to scan face',
      BiometricMode.touch: isRtl ? 'اضغط للمسح بالبصمة' : 'Tap to scan fingerprint',
    };

    final scanLabels = {
      BiometricMode.iris: isRtl ? 'جارٍ المسح...' : 'Scanning iris...',
      BiometricMode.face: isRtl ? 'جارٍ المسح...' : 'Scanning face...',
      BiometricMode.touch: isRtl ? 'جارٍ المسح...' : 'Scanning fingerprint...',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        _isScanning ? scanLabels[_currentMode]! : labels[_currentMode]!,
        key: ValueKey('${_currentMode}_$_isScanning'),
        style: SanctumTypography.bodySmall.copyWith(
          color: _isScanning ? accent : tertiary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ─── Mode Toggles ─────────────────────────────────────────────────

  Widget _buildModeToggles(Color accent, Color tertiary, bool isDark) {
    final glassFill = isDark ? SanctumColors.glassFill : SanctumColors.lightGlassFill;
    final glassBorder = isDark ? SanctumColors.glassBorder : SanctumColors.lightGlassBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder),
      ),
      child: Row(
        children: BiometricMode.values.map((mode) {
          final isActive = _currentMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isScanning || _isUnlocking) return;
                setState(() {
                  _currentMode = mode;
                  _scanProgress = 0.0;
                  _scanController.reset();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _modeIcon(mode),
                      size: 18,
                      color: isActive ? accent : tertiary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _modeLabel(mode),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? accent : tertiary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _modeIcon(BiometricMode mode) {
    switch (mode) {
      case BiometricMode.iris:
        return Icons.remove_red_eye_outlined;
      case BiometricMode.face:
        return Icons.face_outlined;
      case BiometricMode.touch:
        return Icons.fingerprint;
    }
  }

  String _modeLabel(BiometricMode mode) {
    switch (mode) {
      case BiometricMode.iris:
        return 'IRIS';
      case BiometricMode.face:
        return 'FACE';
      case BiometricMode.touch:
        return 'TOUCH';
    }
  }
}
