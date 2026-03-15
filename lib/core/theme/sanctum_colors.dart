import 'dart:ui';

/// The "Digital Sanctum" Color Palette
/// Derived from the Figma Masterpiece Design: deep blacks, golden radiance,
/// and silvered typography. Every color here is the single source of truth.
class SanctumColors {
  SanctumColors._();

  // ─── Core Backgrounds ───────────────────────────────────────────────
  /// The absolute void — true black canvas
  static const Color abyss = Color(0xFF000000);

  /// Deep obsidian — primary surface
  static const Color obsidian = Color(0xFF0D1117);

  /// Elevated surface — glassmorphism panels
  static const Color obsidianElevated = Color(0xFF161B22);

  /// Card / overlay surfaces
  static const Color obsidianCard = Color(0xFF1C2128);

  // ─── Golden Radiance (Primary Accent) ───────────────────────────────
  /// The Iris Core — brightest gold
  static const Color irisCore = Color(0xFFFFD700);

  /// Golden glow — outer aura
  static const Color irisGlow = Color(0xFFFFC107);

  /// Warm amber — secondary ring
  static const Color irisAmber = Color(0xFFFF8F00);

  /// Deep gold — shadow ring
  static const Color irisShadow = Color(0xFFB8860B);

  /// Subtle gold tint for glassmorphism borders
  static const Color goldenMist = Color(0x33FFD700);

  /// Golden radial gradient start (center)
  static const Color auraCenter = Color(0xCCFFD700);

  /// Golden radial gradient end (edge)
  static const Color auraEdge = Color(0x00FFD700);

  // ─── Typography ─────────────────────────────────────────────────────
  /// Primary text — off-white silver
  static const Color textPrimary = Color(0xFFE6EDF3);

  /// Secondary text — muted silver
  static const Color textSecondary = Color(0xFF8B949E);

  /// Subtle text — ghost silver
  static const Color textTertiary = Color(0xFF484F58);

  /// Accent text — gold highlight
  static const Color textGold = Color(0xFFFFD700);

  // ─── Status Indicators ──────────────────────────────────────────────
  /// Active / healthy — emerald
  static const Color statusActive = Color(0xFF3FB950);

  /// Warning — amber
  static const Color statusWarning = Color(0xFFD29922);

  /// Critical — crimson
  static const Color statusCritical = Color(0xFFF85149);

  /// Triggered — deep violet
  static const Color statusTriggered = Color(0xFFA371F7);

  // ─── Glassmorphism ──────────────────────────────────────────────────
  /// Glass panel fill
  static const Color glassFill = Color(0x0DFFFFFF);

  /// Glass border
  static const Color glassBorder = Color(0x1AFFFFFF);

  /// Glass elevated border
  static const Color glassBorderElevated = Color(0x33FFFFFF);

  // ─── Dashboard — Asset Category Colors ──────────────────────────────
  /// Financial assets — Emerald Teal (wealth, stability)
  static const Color assetFinancial = Color(0xFF00D4AA);

  /// Sentimental Legacy — Rose Quartz (warm, intimate, nostalgic)
  static const Color assetSentimental = Color(0xFFFF6B9D);

  /// Sentimental secondary — warm amber glow
  static const Color assetSentimentalWarm = Color(0xFFFFAB76);

  /// Discrete assets — Royal Violet (confidential, exclusive)
  static const Color assetDiscrete = Color(0xFF7C4DFF);

  /// Pulse ring — resting heartbeat green
  static const Color pulseResting = Color(0xFF4ADE80);

  // ─── Light Mode — "Alabaster White" ──────────────────────────────────
  /// Alabaster canvas — warm off-white
  static const Color lightBackground = Color(0xFFF8F6F2);

  /// Pure surface — cards and elevated glass
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Cream elevated surface — subtle warmth
  static const Color lightSurfaceElevated = Color(0xFFFAF8F5);

  /// Primary text — rich charcoal
  static const Color lightTextPrimary = Color(0xFF1A1A2E);

  /// Secondary text — warm slate
  static const Color lightTextSecondary = Color(0xFF5A5A72);

  /// Tertiary text — muted lavender
  static const Color lightTextTertiary = Color(0xFF9A9AB0);

  /// Glassmorphism fill on light — subtle frost
  static const Color lightGlassFill = Color(0x0D000000);

  /// Glass border on light
  static const Color lightGlassBorder = Color(0x14000000);

  /// Glass elevated border on light
  static const Color lightGlassBorderElevated = Color(0x1F000000);

  /// Light accent — warm gold (not as bright as dark mode)
  static const Color lightAccent = Color(0xFFD4A017);

  /// Light status active — deeper emerald for contrast
  static const Color lightStatusActive = Color(0xFF2E9B4F);
}
