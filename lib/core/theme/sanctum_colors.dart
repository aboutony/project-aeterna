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

  // ─── Light Mode Overrides ───────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);
}
