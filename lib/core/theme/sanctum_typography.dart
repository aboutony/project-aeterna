import 'package:flutter/material.dart';
import 'sanctum_colors.dart';

/// Typography scale for the "Digital Sanctum" design system.
/// Uses Playfair Display (elegant serif) for display text and
/// Inter (clean geometric) for body/UI text.
class SanctumTypography {
  SanctumTypography._();

  // ─── Font Families ──────────────────────────────────────────────────
  static const String displayFont = 'PlayfairDisplay';
  static const String bodyFont = 'Inter';
  static const String monoFont = 'JetBrainsMono';

  // ─── Display Styles (Serif — luxury, elegant) ──────────────────────
  /// Splash / hero titles
  static TextStyle displayLarge = const TextStyle(
    fontFamily: displayFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 8.0,
    height: 1.2,
    color: SanctumColors.textPrimary,
  );

  /// Section hero text
  static TextStyle displayMedium = const TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 4.0,
    height: 1.3,
    color: SanctumColors.textPrimary,
  );

  /// Sub-section display
  static TextStyle displaySmall = const TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    height: 1.4,
    color: SanctumColors.textPrimary,
  );

  // ─── Body Styles (Sans-Serif — clean, functional) ──────────────────
  /// "Align your eyes with the Sanctum" — ethereal instruction text
  static TextStyle sanctumInstruction = const TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 3.0,
    height: 1.6,
    color: SanctumColors.textSecondary,
  );

  /// Primary body text
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: SanctumColors.textPrimary,
  );

  /// Secondary body text
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: SanctumColors.textSecondary,
  );

  /// Caption / metadata
  static TextStyle bodySmall = const TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.4,
    color: SanctumColors.textTertiary,
  );

  // ─── UI Styles ─────────────────────────────────────────────────────
  /// Button text
  static TextStyle buttonText = const TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: SanctumColors.abyss,
  );

  /// Label text
  static TextStyle labelMedium = const TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: SanctumColors.textSecondary,
  );

  // ─── Monospaced (Financial figures, hashes) ─────────────────────────
  /// High-value financial figures (20% larger than body)
  static TextStyle monoLarge = const TextStyle(
    fontFamily: monoFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: SanctumColors.textGold,
  );

  /// Standard monospaced
  static TextStyle monoMedium = const TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: SanctumColors.textPrimary,
  );
}
