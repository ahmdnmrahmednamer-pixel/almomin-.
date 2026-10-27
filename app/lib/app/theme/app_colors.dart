import 'package:flutter/material.dart';
import 'tokens.dart';

/// Available canonical themes per Noor Noor Al-Momin Design System §2.2
enum AppThemeMode { light, sepia, dark, black }

abstract final class AppColors {
  // ==========================================
  // BRAND PALETTE REFERENCE SWATCHES (§2.1)
  // ==========================================
  static const Color emerald900 = Color(0xFF0A3D2E); // Deepest brand green
  static const Color emerald700 = Color(0xFF0F5B45); // Primary brand color
  static const Color emerald300 = Color(0xFF5FC29A); // Primary on dark themes
  static const Color mint100 = Color(0xFFD7EBE2);    // Primary container (light)
  static const Color gold500 = Color(0xFFB8893A);    // Accent ornament
  static const Color gold700 = Color(0xFF7A5818);    // Gold for text (WCAG AA)
  static const Color gold300 = Color(0xFFD9B25F);    // Gold on dark themes
  static const Color paper50 = Color(0xFFFBF8F1);    // Light background
  static const Color night900 = Color(0xFF0F1714);   // Dark background

  // ==========================================
  // 1. LIGHT THEME TOKENS (§2.2 & §2.3)
  // ==========================================
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F5B45),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD7EBE2),
    onPrimaryContainer: Color(0xFF062E22),
    secondary: Color(0xFFB8893A),
    onSecondary: Color(0xFF1B1405),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B2420),
    surfaceContainerHighest: Color(0xFFF1EBDD),
    onSurfaceVariant: Color(0xFF4A5750),
    outline: Color(0xFFC9C2AD),
    outlineVariant: Color(0xFFE2DCCB),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );

  static const AlMominTokens lightTokens = AlMominTokens(
    gold: Color(0xFFB8893A),
    goldText: Color(0xFF7A5818),
    mushafPaper: Color(0xFFFFFDF7),
    quranText: Color(0xFF1B1B18),
    ayahPlaying: Color(0xFFCFE8DC),
    ayahSelected: Color(0xFFF3E3B8),
    ayahMarker: Color(0xFFB8893A),
    pageFrame: Color(0xFFC9B47A),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    scrim: Color(0x66000000), // 40%
    textTertiary: Color(0xFF5F6A64),
  );

  static const Color lightBackground = Color(0xFFFBF8F1);

  // ==========================================
  // 2. SEPIA THEME TOKENS (§2.2 & §2.3)
  // ==========================================
  static const ColorScheme sepiaScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2F5A3F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5E2C6),
    onPrimaryContainer: Color(0xFF1E3A28),
    secondary: Color(0xFF8F6A22),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFF8EFD9),
    onSurface: Color(0xFF3A2D17),
    surfaceContainerHighest: Color(0xFFEADBB6),
    onSurfaceVariant: Color(0xFF5A4A2D),
    outline: Color(0xFFBFAE82),
    outlineVariant: Color(0xFFD9C9A0),
    error: Color(0xFFA32B22),
    onError: Color(0xFFFFFFFF),
  );

  static const AlMominTokens sepiaTokens = AlMominTokens(
    gold: Color(0xFF8F6A22),
    goldText: Color(0xFF6B4E14),
    mushafPaper: Color(0xFFF6EACB),
    quranText: Color(0xFF2E2312),
    ayahPlaying: Color(0xFFD3E0BE),
    ayahSelected: Color(0xFFE8D49A),
    ayahMarker: Color(0xFF8F6A22),
    pageFrame: Color(0xFFB39B5E),
    success: Color(0xFF3B6B2E),
    warning: Color(0xFF9A5B00),
    scrim: Color(0x66000000), // 40%
    textTertiary: Color(0xFF6E5C3A),
  );

  static const Color sepiaBackground = Color(0xFFF3E7CB);

  // ==========================================
  // 3. DARK THEME TOKENS (§2.2 & §2.3)
  // ==========================================
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5FC29A),
    onPrimary: Color(0xFF06281C),
    primaryContainer: Color(0xFF1D4A3A),
    onPrimaryContainer: Color(0xFFCFEFE2),
    secondary: Color(0xFFD9B25F),
    onSecondary: Color(0xFF2A1F05),
    surface: Color(0xFF16211D),
    onSurface: Color(0xFFE8EEE9),
    surfaceContainerHighest: Color(0xFF1F2D27),
    onSurfaceVariant: Color(0xFFA9B7AF),
    outline: Color(0xFF3A4F46),
    outlineVariant: Color(0xFF2A3B34),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF3B0A07),
  );

  static const AlMominTokens darkTokens = AlMominTokens(
    gold: Color(0xFFD9B25F),
    goldText: Color(0xFFE6C57A),
    mushafPaper: Color(0xFF121A17),
    quranText: Color(0xFFF2EFE6),
    ayahPlaying: Color(0xFF1F3A30),
    ayahSelected: Color(0xFF3A3019),
    ayahMarker: Color(0xFFD9B25F),
    pageFrame: Color(0xFF3A4F46),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    scrim: Color(0x99000000), // 60%
    textTertiary: Color(0xFF8A9A91),
  );

  static const Color darkBackground = Color(0xFF0F1714);

  // ==========================================
  // 4. TRUE BLACK (OLED) THEME TOKENS (§2.2 & §2.3)
  // ==========================================
  static final ColorScheme blackScheme = darkScheme.copyWith(
    surface: const Color(0xFF0B0F0D),
    primaryContainer: const Color(0xFF14372B),
    surfaceContainerHighest: const Color(0xFF141A17),
    outline: const Color(0xFF2C3A34),
    outlineVariant: const Color(0xFF1E2824),
  );

  static final AlMominTokens blackTokens = darkTokens.copyWith(
    mushafPaper: const Color(0xFF000000),
    pageFrame: const Color(0xFF2C3A34),
    ayahPlaying: const Color(0xFF17302A),
    ayahSelected: const Color(0xFF2E2713),
    scrim: const Color(0xB3000000), // 70%
  );

  static const Color blackBackground = Color(0xFF000000);

  // ==========================================
  // TAJWEED PALETTE (§2.4)
  // ==========================================
  static const Color tajweedGhunnah = Color(0xFF2E9E6B);
  static const Color tajweedIkhfa = Color(0xFFC2410C);
  static const Color tajweedIdgham = Color(0xFF0E7490);
  static const Color tajweedIqlab = Color(0xFF7C3AED);
  static const Color tajweedQalqalah = Color(0xFF2563EB);
  static const Color tajweedMadd = Color(0xFFB45309);
  static const Color tajweedMaddAlt = Color(0xFFD97706);
  static const Color tajweedSilent = Color(0xFF8B8B85);

  // ==========================================
  // BOOKMARK PALETTE (§2.3)
  // ==========================================
  static const Color bookmarkGreen = Color(0xFF2E9E6B);
  static const Color bookmarkGold = Color(0xFFB8893A);
  static const Color bookmarkBlue = Color(0xFF2F6FB5);
  static const Color bookmarkRose = Color(0xFFB5476B);
  static const Color bookmarkViolet = Color(0xFF6B4FB5);

  // ==========================================
  // BACKWARD COMPATIBILITY ALIASES
  // Keeps existing codebase 100% functional
  // ==========================================
  static const Color primaryGreen = Color(0xFF0F5B45);
  static const Color secondaryGreen = Color(0xFF2F5A3F);
  static const Color emeraldLight = Color(0xFF40916C);
  static const Color accentGold = Color(0xFFB8893A);
  static const Color brightGold = Color(0xFFFFD700);
  static const Color softGold = Color(0xFFE9D8A6);

  static const Color lightBg = Color(0xFFFBF8F1);
  static const Color sepiaBg = Color(0xFFF3E7CB);
  static const Color darkBg = Color(0xFF0F1714);
  static const Color darkSurface = Color(0xFF16211D);
  static const Color darkCard = Color(0xFF1F2D27);
  static const Color oledBg = Color(0xFF000000);
  static const Color oledSurface = Color(0xFF0B0F0D);
  static const Color oledCard = Color(0xFF101010);
  static const Color oledBorder = Color(0xFF2C3A34);

  static const Color lightText = Color(0xFF1B2420);
  static const Color darkText = Color(0xFFE8EEE9);
  static const Color mutedText = Color(0xFF4A5750);
  static const Color mutedTextDark = Color(0xFFA9B7AF);
}
