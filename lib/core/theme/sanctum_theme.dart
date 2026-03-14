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

  // ─── Light Theme (Secondary — "The Surface") ───────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: SanctumTypography.bodyFont,
        scaffoldBackgroundColor: SanctumColors.lightBackground,
        colorScheme: const ColorScheme.light(
          surface: SanctumColors.lightSurface,
          primary: SanctumColors.irisShadow,
          secondary: SanctumColors.irisAmber,
          error: SanctumColors.statusCritical,
          onPrimary: SanctumColors.lightSurface,
          onSurface: SanctumColors.lightTextPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: SanctumTypography.displaySmall.copyWith(
            color: SanctumColors.lightTextPrimary,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
