import 'package:flutter/material.dart';

/// Spacing scale (4 dp base) per Noor Noor Al-Momin Design System §4.1
abstract final class Space {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
}

/// Corner radii tokens per Noor Noor Al-Momin Design System §5
abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

/// Motion and duration tokens per Noor Noor Al-Momin Design System §8
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Curve easeBase = Curves.easeOutCubic;
}

/// Extra tokens that do not exist in Material 3 ColorScheme per Noor Noor Al-Momin Design System §2.2 & §2.3.
@immutable
class AlMominTokens extends ThemeExtension<AlMominTokens> {
  const AlMominTokens({
    required this.gold,
    required this.goldText,
    required this.mushafPaper,
    required this.quranText,
    required this.ayahPlaying,
    required this.ayahSelected,
    required this.ayahMarker,
    required this.pageFrame,
    required this.success,
    required this.warning,
    required this.scrim,
    required this.textTertiary,
  });

  final Color gold;
  final Color goldText;
  final Color mushafPaper;
  final Color quranText;
  final Color ayahPlaying;
  final Color ayahSelected;
  final Color ayahMarker;
  final Color pageFrame;
  final Color success;
  final Color warning;
  final Color scrim;
  final Color textTertiary;

  @override
  AlMominTokens copyWith({
    Color? gold,
    Color? goldText,
    Color? mushafPaper,
    Color? quranText,
    Color? ayahPlaying,
    Color? ayahSelected,
    Color? ayahMarker,
    Color? pageFrame,
    Color? success,
    Color? warning,
    Color? scrim,
    Color? textTertiary,
  }) {
    return AlMominTokens(
      gold: gold ?? this.gold,
      goldText: goldText ?? this.goldText,
      mushafPaper: mushafPaper ?? this.mushafPaper,
      quranText: quranText ?? this.quranText,
      ayahPlaying: ayahPlaying ?? this.ayahPlaying,
      ayahSelected: ayahSelected ?? this.ayahSelected,
      ayahMarker: ayahMarker ?? this.ayahMarker,
      pageFrame: pageFrame ?? this.pageFrame,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      scrim: scrim ?? this.scrim,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AlMominTokens lerp(ThemeExtension<AlMominTokens>? other, double t) {
    if (other is! AlMominTokens) return this;
    return AlMominTokens(
      gold: Color.lerp(gold, other.gold, t)!,
      goldText: Color.lerp(goldText, other.goldText, t)!,
      mushafPaper: Color.lerp(mushafPaper, other.mushafPaper, t)!,
      quranText: Color.lerp(quranText, other.quranText, t)!,
      ayahPlaying: Color.lerp(ayahPlaying, other.ayahPlaying, t)!,
      ayahSelected: Color.lerp(ayahSelected, other.ayahSelected, t)!,
      ayahMarker: Color.lerp(ayahMarker, other.ayahMarker, t)!,
      pageFrame: Color.lerp(pageFrame, other.pageFrame, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

/// Convenience extension for reading tokens via context.tokens
extension AlMominThemeX on BuildContext {
  AlMominTokens get tokens => Theme.of(this).extension<AlMominTokens>()!;
}
