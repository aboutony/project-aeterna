// Project Aeterna — Widget & Smoke Tests
//
// Validates:
//   1. WelcomeScreen renders correctly (Auth Gate entry point)
//   2. SanctumTheme provides valid dark/light themes
//   3. SanctumColors palette constants are defined

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_aeterna/core/theme/sanctum_theme.dart';
import 'package:project_aeterna/core/theme/sanctum_colors.dart';
import 'package:project_aeterna/features/onboarding/presentation/welcome_screen.dart';

void main() {
  group('Aeterna — Auth Gate Tests', () {
    testWidgets('WelcomeScreen displays AETERNA logo and Enter the Sanctum CTA',
        (WidgetTester tester) async {
      // Pump the WelcomeScreen in isolation — avoids platform channel
      // dependencies (sqflite, AuthService) that AeternaApp triggers.
      await tester.pumpWidget(
        MaterialApp(
          theme: SanctumTheme.dark,
          home: const WelcomeScreen(),
        ),
      );

      // Allow entrance animations to begin
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the AETERNA logo/title is rendered
      expect(find.text('AETERNA'), findsOneWidget);

      // Verify the "ENTER THE SANCTUM" call-to-action is present
      expect(find.text('ENTER THE SANCTUM'), findsOneWidget);
    });
  });

  group('Aeterna — Theme & Color Smoke Tests', () {
    test('SanctumTheme provides valid dark and light themes', () {
      final dark = SanctumTheme.dark;
      final light = SanctumTheme.light;

      expect(dark, isA<ThemeData>());
      expect(light, isA<ThemeData>());
      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);
    });

    test('SanctumColors palette constants are defined', () {
      expect(SanctumColors.abyss, isA<Color>());
      expect(SanctumColors.irisCore, isA<Color>());
      expect(SanctumColors.glassFill, isA<Color>());
      expect(SanctumColors.glassBorder, isA<Color>());
    });
  });
}
