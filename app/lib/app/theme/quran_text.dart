import 'package:flutter/material.dart';

/// Quran typography scale and text styling per Noor Noor Al-Momin Design System §3.3 & §13.3.
abstract final class QuranText {
  static const String fontFamily = 'KFGQPCHafs';
  static const String uiFontFamily = 'IBMPlexSansArabic';

  /// Standard font scale steps: XS, S, M (default), L, XL, XXL
  static const List<double> sizes = [22, 26, 30, 36, 44, 54];
  static const List<double> heights = [2.0, 2.0, 2.05, 2.1, 2.15, 2.2];

  /// Standard step indices
  static const int stepXS = 0;
  static const int stepS = 1;
  static const int stepM = 2; // Default
  static const int stepL = 3;
  static const int stepXL = 4;
  static const int stepXXL = 5;

  /// Returns TextStyle for Quran text ensuring zero letter spacing and correct line-height
  static TextStyle style({required int sizeStep, required Color color, String? customFontFamily}) {
    final i = sizeStep.clamp(0, sizes.length - 1);
    return TextStyle(
      fontFamily: customFontFamily ?? fontFamily,
      fontSize: sizes[i],
      height: heights[i],
      color: color,
      fontWeight: FontWeight.w400,
      letterSpacing: 0, // Never add spacing to Arabic
    );
  }
}
