import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/app/theme/tokens.dart';
import 'package:almomin/app/theme/app_colors.dart';
import 'package:almomin/app/theme/quran_text.dart';
import 'package:almomin/app/theme/app_theme.dart';
import 'package:almomin/app/theme/ornaments.dart';

double _mathPow(double base, double exp) {
  return double.parse((math.pow(base, exp)).toStringAsFixed(8));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Al-Momin Design System: Spacing & Radii & Motion Tokens (§4 & §5 & §8)', () {
    test('Space tokens follow 4 dp base grid', () {
      expect(Space.x1, 4.0);
      expect(Space.x2, 8.0);
      expect(Space.x3, 12.0);
      expect(Space.x4, 16.0);
      expect(Space.x5, 20.0);
      expect(Space.x6, 24.0);
      expect(Space.x8, 32.0);
      expect(Space.x10, 40.0);
      expect(Space.x12, 48.0);
      expect(Space.x16, 64.0);
    });

    test('Radii tokens define correct corner curves', () {
      expect(Radii.sm, 8.0);
      expect(Radii.md, 12.0);
      expect(Radii.lg, 16.0);
      expect(Radii.xl, 24.0);
      expect(Radii.full, 999.0);

      expect(Radii.smAll, BorderRadius.circular(8.0));
      expect(Radii.mdAll, BorderRadius.circular(12.0));
      expect(Radii.lgAll, BorderRadius.circular(16.0));
      expect(Radii.xlAll, BorderRadius.circular(24.0));
    });

    test('Motion tokens specify calibrated durations and easing', () {
      expect(Motion.fast, const Duration(milliseconds: 120));
      expect(Motion.base, const Duration(milliseconds: 200));
      expect(Motion.slow, const Duration(milliseconds: 320));
      expect(Motion.easeBase, Curves.easeOutCubic);
    });
  });

  group('Al-Momin Design System: 4 Canonical Color Palettes & Tokens (§2)', () {
    test('Light theme tokens match design system spec', () {
      expect(AppColors.lightScheme.primary, const Color(0xFF0F5B45));
      expect(AppColors.lightBackground, const Color(0xFFFBF8F1));
      expect(AppColors.lightTokens.gold, const Color(0xFFB8893A));
      expect(AppColors.lightTokens.goldText, const Color(0xFF7A5818));
      expect(AppColors.lightTokens.mushafPaper, const Color(0xFFFFFDF7));
      expect(AppColors.lightTokens.ayahPlaying, const Color(0xFFCFE8DC));
      expect(AppColors.lightTokens.ayahSelected, const Color(0xFFF3E3B8));
    });

    test('Sepia theme tokens match design system spec', () {
      expect(AppColors.sepiaScheme.primary, const Color(0xFF2F5A3F));
      expect(AppColors.sepiaBackground, const Color(0xFFF3E7CB));
      expect(AppColors.sepiaTokens.gold, const Color(0xFF8F6A22));
      expect(AppColors.sepiaTokens.mushafPaper, const Color(0xFFF6EACB));
      expect(AppColors.sepiaTokens.quranText, const Color(0xFF2E2312));
    });

    test('Dark theme tokens match design system spec', () {
      expect(AppColors.darkScheme.primary, const Color(0xFF5FC29A));
      expect(AppColors.darkBackground, const Color(0xFF0F1714));
      expect(AppColors.darkTokens.gold, const Color(0xFFD9B25F));
      expect(AppColors.darkTokens.goldText, const Color(0xFFE6C57A));
      expect(AppColors.darkTokens.mushafPaper, const Color(0xFF121A17));
    });

    test('True Black (OLED) theme tokens match design system spec', () {
      expect(AppColors.blackBackground, const Color(0xFF000000));
      expect(AppColors.blackTokens.mushafPaper, const Color(0xFF000000));
      expect(AppColors.blackScheme.surface, const Color(0xFF0B0F0D));
      expect(AppColors.blackTokens.pageFrame, const Color(0xFF2C3A34));
    });

    test('Tajweed palette tokens are defined correctly', () {
      expect(AppColors.tajweedGhunnah, const Color(0xFF2E9E6B));
      expect(AppColors.tajweedIkhfa, const Color(0xFFC2410C));
      expect(AppColors.tajweedIdgham, const Color(0xFF0E7490));
      expect(AppColors.tajweedIqlab, const Color(0xFF7C3AED));
      expect(AppColors.tajweedQalqalah, const Color(0xFF2563EB));
      expect(AppColors.tajweedMadd, const Color(0xFFB45309));
    });
  });

  group('Al-Momin Design System: ThemeExtension Lerp & CopyWith', () {
    test('AlMominTokens copyWith updates targeted fields', () {
      const original = AppColors.lightTokens;
      final modified = original.copyWith(gold: const Color(0xFF123456));

      expect(modified.gold, const Color(0xFF123456));
      expect(modified.goldText, original.goldText);
      expect(modified.mushafPaper, original.mushafPaper);
    });

    test('AlMominTokens lerp interpolates smoothly between light and dark', () {
      final lerped = AppColors.lightTokens.lerp(AppColors.darkTokens, 0.5);

      expect(lerped, isNotNull);
      expect(lerped.gold, isNot(AppColors.lightTokens.gold));
      expect(lerped.gold, isNot(AppColors.darkTokens.gold));
    });
  });

  group('Al-Momin Design System: Quran Typography (§3.3 & §13.3)', () {
    test('QuranText sizes and line heights adhere to strict scale', () {
      expect(QuranText.sizes.length, 6);
      expect(QuranText.heights.length, 6);

      expect(QuranText.sizes[QuranText.stepXS], 22.0);
      expect(QuranText.sizes[QuranText.stepM], 30.0);
      expect(QuranText.sizes[QuranText.stepXXL], 54.0);

      expect(QuranText.heights[QuranText.stepXS], 2.0);
      expect(QuranText.heights[QuranText.stepM], 2.05);
      expect(QuranText.heights[QuranText.stepXXL], 2.2);
    });

    test('QuranText style generates style with zero letter spacing and correct font', () {
      final style = QuranText.style(sizeStep: QuranText.stepM, color: Colors.black);

      expect(style.fontSize, 30.0);
      expect(style.height, 2.05);
      expect(style.letterSpacing, 0.0); // Never add letter spacing to Arabic
      expect(style.fontFamily, QuranText.fontFamily);
    });
  });

  group('Al-Momin Design System: AppTheme Builder & Material 3 Specs (§13.4)', () {
    test('AppTheme.of creates valid ThemeData for all 4 modes', () {
      for (final mode in AppThemeMode.values) {
        final theme = AppTheme.of(mode);
        expect(theme.useMaterial3, isTrue);
        expect(theme.extension<AlMominTokens>(), isNotNull);
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(theme.filledButtonTheme.style, isNotNull);
        expect(theme.appBarTheme.centerTitle, isTrue);
      }
    });

    test('AppTheme convenience getters match their corresponding modes', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(AppTheme.sepiaTheme.scaffoldBackgroundColor, AppColors.sepiaBackground);
      expect(AppTheme.darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(AppTheme.oledTheme.scaffoldBackgroundColor, AppColors.blackBackground);
    });
  });

  group('Al-Momin Design System: Ornaments & Arabic-Indic Digits (§4.3 & §9)', () {
    test('ArabicIndicDigits converts western numerals accurately', () {
      expect(ArabicIndicDigits.format(1), '١');
      expect(ArabicIndicDigits.format(7), '٧');
      expect(ArabicIndicDigits.format(114), '١١٤');
      expect(ArabicIndicDigits.format(286), '٢٨٦');
      expect(ArabicIndicDigits.format(6236), '٦٢٣٦');
    });

    testWidgets('AyahEndMarker, SurahStarBadge, and IslamicSectionDivider render without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                AyahEndMarker(ayahNumber: 7),
                SurahStarBadge(surahNumber: 1),
                IslamicSectionDivider(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AyahEndMarker), findsOneWidget);
      expect(find.text('٧'), findsOneWidget);
      expect(find.byType(SurahStarBadge), findsOneWidget);
      expect(find.text('١'), findsOneWidget);
      expect(find.byType(IslamicSectionDivider), findsOneWidget);
    });

    testWidgets('AlMominThemeX extension allows context.tokens access in widgets', (tester) async {
      Color? readGold;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              readGold = context.tokens.gold;
              return Container();
            },
          ),
        ),
      );

      expect(readGold, AppColors.lightTokens.gold);
    });
  });

  group('Al-Momin Design System: WCAG AA Contrast Compliance (§2.1)', () {
    double relativeLuminance(Color c) {
      double f(double v) {
        return v <= 0.03928 ? v / 12.92 : _mathPow((v + 0.055) / 1.055, 2.4);
      }
      return 0.2126 * f(c.red / 255.0) + 0.7152 * f(c.green / 255.0) + 0.0722 * f(c.blue / 255.0);
    }

    double contrastRatio(Color fg, Color bg) {
      final l1 = relativeLuminance(fg);
      final l2 = relativeLuminance(bg);
      final lighter = l1 > l2 ? l1 : l2;
      final darker = l1 > l2 ? l2 : l1;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('Body text on background satisfies WCAG AA (>= 4.5:1) in all themes', () {
      // Light
      final lightContrast = contrastRatio(AppColors.lightScheme.onSurface, AppColors.lightBackground);
      expect(lightContrast, greaterThanOrEqualTo(4.5), reason: 'Light theme contrast $lightContrast must be >= 4.5');

      // Sepia
      final sepiaContrast = contrastRatio(AppColors.sepiaScheme.onSurface, AppColors.sepiaBackground);
      expect(sepiaContrast, greaterThanOrEqualTo(4.5), reason: 'Sepia theme contrast $sepiaContrast must be >= 4.5');

      // Dark
      final darkContrast = contrastRatio(AppColors.darkScheme.onSurface, AppColors.darkBackground);
      expect(darkContrast, greaterThanOrEqualTo(4.5), reason: 'Dark theme contrast $darkContrast must be >= 4.5');

      // True Black OLED
      final blackContrast = contrastRatio(AppColors.blackScheme.onSurface, AppColors.blackBackground);
      expect(blackContrast, greaterThanOrEqualTo(4.5), reason: 'Black theme contrast $blackContrast must be >= 4.5');
    });

    test('Gold text (goldText) on Light background satisfies WCAG AA (>= 4.5:1)', () {
      final goldContrast = contrastRatio(AppColors.lightTokens.goldText, AppColors.lightBackground);
      expect(goldContrast, greaterThanOrEqualTo(4.5), reason: 'Gold text contrast $goldContrast must be >= 4.5');
    });
  });
}
