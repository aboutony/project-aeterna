import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/core/theme/sanctum_typography.dart';
import 'package:project_aeterna/features/splash/presentation/widgets/iris_portal.dart';

/// The Gateway — Project Aeterna's Splash Screen.
///
/// A full-screen immersive experience that presents the Iris Portal
/// as the ceremonial entry point to the Digital Sanctum.
///
/// Animation timeline:
///   0.0s – 1.5s : Portal fades in and scales up
///   1.0s – 2.5s : Title text reveals with fade + slide
///   2.0s – 3.5s : Instruction text appears
///   3.0s – 4.5s : Scan line pulses once
///   ∞           : Portal breathes, rotates, particles orbit
class SplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ──────────────────────────────────────────
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _particleController;
  late final AnimationController _textController;

  // ─── Animations ─────────────────────────────────────────────────────
  late final Animation<double> _portalEntry;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _instructionFade;
  late final Animation<double> _scanLineFade;

  @override
  void initState() {
    super.initState();

    // Lock to portrait and immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Portal entry — 1.5s ease-out
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _portalEntry = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    // Continuous pulse — 4s breathing cycle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Continuous rotation — slow 30s full revolution
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Particle orbit — 20s full cycle
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Text animations — staggered reveal
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _instructionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _scanLineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Kick off the sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Portal entry
    _entryController.forward();

    // Text stagger — start after portal is partially visible
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Auto-navigate after the full reveal
    await Future.delayed(const Duration(milliseconds: 4000));
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _textController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanctumColors.abyss,
      body: Stack(
        children: [
          // ─── Background atmospheric blur circles ────────────────
          _buildAtmosphericBackground(),

          // ─── The Iris Portal (center) ───────────────────────────
          Center(
            child: AnimatedBuilder(
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
                    MediaQuery.of(context).size.height * 0.55,
                  ),
                  painter: IrisPortalPainter(
                    pulsePhase: _pulseController.value,
                    rotationAngle: _rotationController.value * 6.283,
                    particlePhase: _particleController.value,
                    entryProgress: _portalEntry.value,
                  ),
                );
              },
            ),
          ),

          // ─── Text overlay (bottom section) ──────────────────────
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // "Align your eyes with the Sanctum"
                FadeTransition(
                  opacity: _instructionFade,
                  child: Text(
                    'Align your eyes with the Sanctum',
                    style: SanctumTypography.sanctumInstruction,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Scan line indicator
                FadeTransition(
                  opacity: _scanLineFade,
                  child: Container(
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.transparent,
                          SanctumColors.irisCore,
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── AETERNA title (top area) ───────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleFade,
                child: Text(
                  'AETERNA',
                  style: SanctumTypography.displayLarge.copyWith(
                    letterSpacing: 16,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          SanctumColors.irisCore,
                          SanctumColors.irisGlow,
                          SanctumColors.irisCore,
                        ],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 300, 60),
                      ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Atmospheric background — large, soft blurred golden auras
  /// positioned off-center to add depth (per Figma: top-left and bottom-right)
  Widget _buildAtmosphericBackground() {
    return Stack(
      children: [
        // Top-left aura
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SanctumColors.irisAmber.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-right aura
        Positioned(
          bottom: -150,
          right: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SanctumColors.irisCore.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
