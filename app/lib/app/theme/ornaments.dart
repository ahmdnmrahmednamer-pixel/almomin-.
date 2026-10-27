import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tokens.dart';

/// Helper to convert standard numbers to Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩) per §4.3
abstract final class ArabicIndicDigits {
  static const List<String> _arabicDigits = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
  ];

  static String format(int number) {
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? _arabicDigits[digit] : char;
    }).join();
  }
}

/// Ornamental End-of-Ayah Marker per Design System §9.6 & §2.3.
class AyahEndMarker extends StatelessWidget {
  final int ayahNumber;
  final double size;
  final Color? color;
  final bool isPlaying;

  const AyahEndMarker({
    super.key,
    required this.ayahNumber,
    this.size = 28.0,
    this.color,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlMominTokens>();
    final markerColor = isPlaying
        ? const Color(0xFFD4AF37)
        : (color ?? tokens?.ayahMarker ?? const Color(0xFFB8893A));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AyahMarkerPainter(color: markerColor, isPlaying: isPlaying),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              ArabicIndicDigits.format(ayahNumber),
              style: TextStyle(
                fontSize: size * 0.40,
                fontWeight: FontWeight.w900,
                color: isPlaying ? const Color(0xFF8B6508) : markerColor,
                height: 1.0,
                fontFamilyFallback: const ['Traditional Arabic', 'Amiri', 'serif'],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AyahMarkerPainter extends CustomPainter {
  final Color color;
  final bool isPlaying;

  _AyahMarkerPainter({required this.color, this.isPlaying = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.2;

    if (isPlaying) {
      // Glow background for currently playing ayah
      final glowPaint = Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + 2, glowPaint);
    }

    // Outer subtle circle
    final outerRingPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, outerRingPaint);

    // Decorative 8-pointed star rosette
    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path();
    const int numPoints = 8;
    final double innerRadius = radius * 0.76;
    final double outerRadius = radius - 1.0;

    for (int i = 0; i < numPoints * 2; i++) {
      final double r = i.isEven ? outerRadius : innerRadius;
      final double angle = (i * math.pi) / numPoints - (math.pi / 2);
      final double x = center.dx + r * math.cos(angle);
      final double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);

    // Inner background disk
    final innerBgPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius - 0.5, innerBgPaint);

    // Inner circle border
    final innerCirclePaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius - 0.5, innerCirclePaint);

    // 4 cardinal accent dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final dotOffset = Offset(
        center.dx + (outerRadius + 0.6) * math.cos(angle),
        center.dy + (outerRadius + 0.6) * math.sin(angle),
      );
      canvas.drawCircle(dotOffset, 0.9, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AyahMarkerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isPlaying != isPlaying;
}

/// 8-Point Islamic Star (Rub el Hizb) Surah Badge per Design System §9.5
class SurahStarBadge extends StatelessWidget {
  final int surahNumber;
  final double size;
  final Color? color;

  const SurahStarBadge({
    super.key,
    required this.surahNumber,
    this.size = 40.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlMominTokens>();
    final badgeColor = color ?? tokens?.gold ?? const Color(0xFFB8893A);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Star8Painter(color: badgeColor),
        child: Center(
          child: Text(
            ArabicIndicDigits.format(surahNumber),
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              color: badgeColor,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _Star8Painter extends CustomPainter {
  final Color color;
  _Star8Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfSide = size.width / 2 - 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Draw first square
    final rect1 = Rect.fromCenter(center: center, width: halfSide * 2, height: halfSide * 2);
    canvas.drawRect(rect1, paint);

    // Draw second square rotated 45 degrees
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4);
    final rect2 = Rect.fromCenter(center: Offset.zero, width: halfSide * 2, height: halfSide * 2);
    canvas.drawRect(rect2, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Star8Painter oldDelegate) => oldDelegate.color != color;
}

/// Ornamental divider with centered gold diamond per Design System §5
class IslamicSectionDivider extends StatelessWidget {
  final Color? color;
  final double height;

  const IslamicSectionDivider({
    super.key,
    this.color,
    this.height = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AlMominTokens>();
    final ornamentColor = color ?? tokens?.gold ?? const Color(0xFFB8893A);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ornamentColor.withOpacity(0.0),
                    ornamentColor.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: ornamentColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ornamentColor.withOpacity(0.6),
                    ornamentColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
