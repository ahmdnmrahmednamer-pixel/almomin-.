import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'tokens.dart';

/// Noor Al-Momin Theme Builder per Noor Noor Al-Momin Design System §13.4
abstract final class AppTheme {
  static const String uiFont = 'IBMPlexSansArabic';
  static const Color emerald = AppColors.emerald700;
  static const Color gold = AppColors.gold500;
  static const Color darkBg = AppColors.night900;
  static const Color darkCard = Color(0xFF16221D);

  /// Builds ThemeData for any of the 4 canonical theme modes
  static ThemeData of(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _build(AppColors.lightScheme, AppColors.lightTokens, AppColors.lightBackground);
      case AppThemeMode.sepia:
        return _build(AppColors.sepiaScheme, AppColors.sepiaTokens, AppColors.sepiaBackground);
      case AppThemeMode.dark:
        return _build(AppColors.darkScheme, AppColors.darkTokens, AppColors.darkBackground);
      case AppThemeMode.black:
        return _build(AppColors.blackScheme, AppColors.blackTokens, AppColors.blackBackground);
    }
  }

  // ==========================================
  // CONVENIENCE GETTERS & BACKWARD COMPATIBILITY
  // ==========================================
  static ThemeData get lightTheme => of(AppThemeMode.light);
  static ThemeData get sepiaTheme => of(AppThemeMode.sepia);
  static ThemeData get darkTheme => of(AppThemeMode.dark);
  static ThemeData get oledTheme => of(AppThemeMode.black);
  static ThemeData get blackTheme => of(AppThemeMode.black);

  /// Typography scale following Design System §3.2 (with generous line-height for Arabic)
  static TextTheme _textTheme(Color primary, Color secondary) {
    TextStyle s(double size, double lineHeightPx, FontWeight w, Color c) => TextStyle(
          fontFamily: uiFont,
          fontSize: size,
          height: lineHeightPx / size,
          fontWeight: w,
          color: c,
          letterSpacing: 0,
        );

    return TextTheme(
      displayLarge: s(36, 48, FontWeight.w800, primary),
      displayMedium: s(32, 44, FontWeight.w700, primary),
      displaySmall: s(28, 38, FontWeight.w700, primary),
      headlineLarge: s(28, 38, FontWeight.w800, primary),
      headlineMedium: s(24, 34, FontWeight.w700, primary),
      headlineSmall: s(20, 30, FontWeight.w700, primary),
      titleLarge: s(20, 30, FontWeight.w600, primary),
      titleMedium: s(17, 26, FontWeight.w600, primary),
      titleSmall: s(15, 22, FontWeight.w600, primary),
      bodyLarge: s(18, 30, FontWeight.w400, primary),
      bodyMedium: s(16, 26, FontWeight.w400, primary),
      bodySmall: s(14, 22, FontWeight.w400, secondary),
      labelLarge: s(14, 20, FontWeight.w600, primary),
      labelMedium: s(13, 19, FontWeight.w500, secondary),
      labelSmall: s(12, 18, FontWeight.w500, secondary),
    );
  }

  /// Internal theme builder assembling all tokens and component specs
  static ThemeData _build(ColorScheme scheme, AlMominTokens tokens, Color background) {
    final text = _textTheme(scheme.onSurface, scheme.onSurfaceVariant);
    final isOled = background == AppColors.blackBackground;
    final cardColor = isOled ? AppColors.oledCard : scheme.surface;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: uiFont,
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[tokens],
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: isOled ? 0 : 2,
          minimumSize: const Size(64, 52),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: Space.x5, vertical: Space.x3),
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: Space.x4, vertical: Space.x3),
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: isOled ? 0 : 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.lgAll,
          side: BorderSide(
            color: isOled ? AppColors.oledBorder : scheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        side: BorderSide(color: scheme.outline),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: text.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: text.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: Space.x4,
          vertical: Space.x4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.full),
          borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.full),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        thumbColor: scheme.primary,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: Radii.xlAll),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
    );
  }
}
