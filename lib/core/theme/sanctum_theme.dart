import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sanctum_colors.dart';
import 'sanctum_typography.dart';

/// The "Digital Sanctum" Theme — the visual DNA of Project Aeterna.
/// Glassmorphism, deep blacks, golden radiance, and 60fps elegance.
class SanctumTheme {
  SanctumTheme._();

  // ─── Dark Theme (Primary — "The Vault") ────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: SanctumTypography.bodyFont,

        // Core colors
        scaffoldBackgroundColor: SanctumColors.abyss,
        colorScheme: const ColorScheme.dark(
          surface: SanctumColors.obsidian,
          primary: SanctumColors.irisCore,
          secondary: SanctumColors.irisGlow,
          tertiary: SanctumColors.irisAmber,
          error: SanctumColors.statusCritical,
          onPrimary: SanctumColors.abyss,
          onSurface: SanctumColors.textPrimary,
          onSecondary: SanctumColors.abyss,
        ),

        // App bar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: SanctumTypography.displaySmall,
          iconTheme: const IconThemeData(
            color: SanctumColors.textPrimary,
          ),
        ),

        // Cards — Glassmorphism base
        cardTheme: CardThemeData(
          color: SanctumColors.glassFill,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: SanctumColors.glassBorder,
              width: 1,
            ),
          ),
        ),

        // Elevated buttons — Gold accent
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SanctumColors.irisCore,
            foregroundColor: SanctumColors.abyss,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: SanctumTypography.buttonText,
          ),
        ),

        // Text button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: SanctumColors.irisCore,
            textStyle: SanctumTypography.buttonText.copyWith(
              color: SanctumColors.irisCore,
            ),
          ),
        ),

        // Input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SanctumColors.glassFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SanctumColors.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SanctumColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: SanctumColors.irisCore,
              width: 1.5,
            ),
          ),
          labelStyle: SanctumTypography.bodyMedium,
          hintStyle: SanctumTypography.bodyMedium.copyWith(
            color: SanctumColors.textTertiary,
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: SanctumColors.glassBorder,
          thickness: 1,
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: SanctumColors.textSecondary,
          size: 24,
        ),

        // Page transitions — smooth and premium
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // ─── Light Theme (Secondary — "Alabaster White") ─────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: SanctumTypography.bodyFont,

        // Core colors — Alabaster White
        scaffoldBackgroundColor: SanctumColors.lightBackground,
        colorScheme: const ColorScheme.light(
          surface: SanctumColors.lightSurface,
          primary: SanctumColors.lightAccent,
          secondary: SanctumColors.irisAmber,
          tertiary: SanctumColors.irisShadow,
          error: SanctumColors.statusCritical,
          onPrimary: SanctumColors.lightSurface,
          onSurface: SanctumColors.lightTextPrimary,
          onSecondary: SanctumColors.lightSurface,
        ),

        // App bar — transparent with dark overlay
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: SanctumTypography.displaySmall.copyWith(
            color: SanctumColors.lightTextPrimary,
          ),
          iconTheme: const IconThemeData(
            color: SanctumColors.lightTextPrimary,
          ),
        ),

        // Cards — Light Glassmorphism
        cardTheme: CardThemeData(
          color: SanctumColors.lightGlassFill,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: SanctumColors.lightGlassBorder,
              width: 1,
            ),
          ),
        ),

        // Elevated buttons — Warm Gold
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SanctumColors.lightAccent,
            foregroundColor: SanctumColors.lightSurface,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: SanctumTypography.buttonText,
          ),
        ),

        // Text button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: SanctumColors.lightAccent,
            textStyle: SanctumTypography.buttonText.copyWith(
              color: SanctumColors.lightAccent,
            ),
          ),
        ),

        // Input decoration — Frost glass
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SanctumColors.lightGlassFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SanctumColors.lightGlassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SanctumColors.lightGlassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: SanctumColors.lightAccent,
              width: 1.5,
            ),
          ),
          labelStyle: SanctumTypography.bodyMedium.copyWith(
            color: SanctumColors.lightTextSecondary,
          ),
          hintStyle: SanctumTypography.bodyMedium.copyWith(
            color: SanctumColors.lightTextTertiary,
          ),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: SanctumColors.lightGlassBorder,
          thickness: 1,
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: SanctumColors.lightTextSecondary,
          size: 24,
        ),

        // Page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
