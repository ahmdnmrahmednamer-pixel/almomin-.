import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

enum AyahCardThemeId {
  emerald, // الفجر الزمردي
  midnight, // الليل الساجي
  sepia, // المصحف العتيق
  royal, // الأزرق الملكي
}

class AyahCardTheme {
  final AyahCardThemeId id;
  final String nameAr;
  final LinearGradient gradient;
  final Color borderColor;
  final Color headerBorderColor;
  final Color headerBg;
  final Color headerTextColor;
  final Color ayahTextColor;
  final Color tafsirTextColor;
  final Color tafsirTitleColor;
  final Color accentColor;
  final Color dividerColor;
  final Color dedicationBg;
  final Color dedicationTextColor;
  final Color dedicationNameColor;

  const AyahCardTheme({
    required this.id,
    required this.nameAr,
    required this.gradient,
    required this.borderColor,
    required this.headerBorderColor,
    required this.headerBg,
    required this.headerTextColor,
    required this.ayahTextColor,
    required this.tafsirTextColor,
    required this.tafsirTitleColor,
    required this.accentColor,
    required this.dividerColor,
    required this.dedicationBg,
    required this.dedicationTextColor,
    required this.dedicationNameColor,
  });

  static const List<AyahCardTheme> availableThemes = [
    // 1. الفجر الزمردي
    AyahCardTheme(
      id: AyahCardThemeId.emerald,
      nameAr: 'الفجر الزمردي',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F3022),
          Color(0xFF1B4332),
          Color(0xFF081C15),
        ],
      ),
      borderColor: Color(0xFFD4AF37),
      headerBorderColor: Color(0x66D4AF37),
      headerBg: Color(0x2AD4AF37),
      headerTextColor: Color(0xFFFFE8A3),
      ayahTextColor: Colors.white,
      tafsirTextColor: Color(0xFFE2E8F0),
      tafsirTitleColor: Color(0xFFFFD700),
      accentColor: Color(0xFFD4AF37),
      dividerColor: Color(0x44D4AF37),
      dedicationBg: Color(0x33000000),
      dedicationTextColor: Color(0xFFCBD5E1),
      dedicationNameColor: Colors.white,
    ),

    // 2. الليل الساجي
    AyahCardTheme(
      id: AyahCardThemeId.midnight,
      nameAr: 'الليل الساجي',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF111827),
          Color(0xFF0F172A),
          Color(0xFF030712),
        ],
      ),
      borderColor: Color(0xFF38BDF8),
      headerBorderColor: Color(0x5538BDF8),
      headerBg: Color(0x2238BDF8),
      headerTextColor: Color(0xFFBAE6FD),
      ayahTextColor: Colors.white,
      tafsirTextColor: Color(0xFFCBD5E1),
      tafsirTitleColor: Color(0xFF7DD3FC),
      accentColor: Color(0xFF38BDF8),
      dividerColor: Color(0x4438BDF8),
      dedicationBg: Color(0x33000000),
      dedicationTextColor: Color(0xFF94A3B8),
      dedicationNameColor: Colors.white,
    ),

    // 3. المصحف العتيق
    AyahCardTheme(
      id: AyahCardThemeId.sepia,
      nameAr: 'المصحف العتيق',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFDF5),
          Color(0xFFF7F0DD),
          Color(0xFFEDE0C4),
        ],
      ),
      borderColor: Color(0xFF8C6D37),
      headerBorderColor: Color(0x668C6D37),
      headerBg: Color(0x228C6D37),
      headerTextColor: Color(0xFF4A3510),
      ayahTextColor: Color(0xFF1E170C),
      tafsirTextColor: Color(0xFF3B2F1B),
      tafsirTitleColor: Color(0xFF7A4E08),
      accentColor: Color(0xFF8C6D37),
      dividerColor: Color(0x448C6D37),
      dedicationBg: Color(0x1A8C6D37),
      dedicationTextColor: Color(0xFF5A4626),
      dedicationNameColor: Color(0xFF1E170C),
    ),

    // 4. الأزرق الملكي
    AyahCardTheme(
      id: AyahCardThemeId.royal,
      nameAr: 'الأزرق الملكي',
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E2958),
          Color(0xFF161F44),
          Color(0xFF0B1028),
        ],
      ),
      borderColor: Color(0xFFE5C07B),
      headerBorderColor: Color(0x55E5C07B),
      headerBg: Color(0x22E5C07B),
      headerTextColor: Color(0xFFFDE68A),
      ayahTextColor: Colors.white,
      tafsirTextColor: Color(0xFFE2E8F0),
      tafsirTitleColor: Color(0xFFFCD34D),
      accentColor: Color(0xFFE5C07B),
      dividerColor: Color(0x44E5C07B),
      dedicationBg: Color(0x33000000),
      dedicationTextColor: Color(0xFFCBD5E1),
      dedicationNameColor: Colors.white,
    ),
  ];

  static AyahCardTheme getTheme(AyahCardThemeId id) {
    return availableThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => availableThemes.first,
    );
  }
}

class AyahCardService {
  /// Captures a RenderRepaintBoundary to high-resolution PNG bytes (pixelRatio 3.0).
  static Future<Uint8List?> captureWidgetToBytes(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('AyahCardService.captureWidgetToBytes error: $e');
      return null;
    }
  }

  /// Saves the card PNG bytes to a temporary file.
  static Future<File> saveCardImageFile(
    Uint8List bytes, {
    required int surahId,
    required int ayahNumber,
  }) async {
    Directory dir;
    try {
      dir = await getTemporaryDirectory();
    } catch (_) {
      dir = Directory.systemTemp;
    }
    
    final filename = 'ayah_card_${surahId}_$ayahNumber\_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Formats the accompanying share caption text.
  static String formatShareCaption({
    required Surah surah,
    required Ayah ayah,
    String? tafsirText,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('﴿${ayah.textUthmani}﴾');
    buffer.writeln('[سورة ${surah.nameAr} — الآية ${ayah.ayahNumber}]');
    
    if (tafsirText != null && tafsirText.trim().isNotEmpty) {
      buffer.writeln('\n📖 التفسير الميسر:');
      buffer.writeln(tafsirText.trim());
    }

    buffer.writeln('');
    buffer.write('— تطبيق نور المؤمن (بدون إعلانات وبدون إنترنت)');
    return buffer.toString();
  }

  /// Shares the card image and caption via system share dialog.
  static Future<void> shareCard({
    required BuildContext context,
    required GlobalKey boundaryKey,
    required Surah surah,
    required Ayah ayah,
    String? tafsirText,
  }) async {
    final bytes = await captureWidgetToBytes(boundaryKey);
    final caption = formatShareCaption(surah: surah, ayah: ayah, tafsirText: tafsirText);

    if (bytes != null && bytes.isNotEmpty) {
      try {
        final file = await saveCardImageFile(bytes, surahId: surah.id, ayahNumber: ayah.ayahNumber);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: caption,
          subject: 'آية كريمة من سورة ${surah.nameAr}',
        );
        return;
      } catch (e) {
        debugPrint('Share file failed, falling back to text: $e');
      }
    }

    // Fallback if image capture fails
    try {
        await Share.share(caption, subject: 'آية كريمة من سورة ${surah.nameAr}');
      } catch (_) {}
  }
}
