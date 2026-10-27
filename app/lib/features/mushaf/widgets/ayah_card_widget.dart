import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/ayah_card_service.dart';
import '../../../core/theme/app_theme.dart';

class AyahIslamicCardWidget extends StatelessWidget {
  final Surah surah;
  final Ayah ayah;
  final AyahCardTheme theme;
  final double fontSize;
  final bool includeTafsir;
  final bool includeSurahHeader;
  final bool includeDedication;
  final String? tafsirText;

  const AyahIslamicCardWidget({
    super.key,
    required this.surah,
    required this.ayah,
    required this.theme,
    this.fontSize = 22.0,
    this.includeTafsir = true,
    this.includeSurahHeader = true,
    this.includeDedication = true,
    this.tafsirText,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          gradient: theme.gradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.borderColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: theme.borderColor.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header (Surah & Ayah metadata)
            if (includeSurahHeader) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.headerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.headerBorderColor, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '۞',
                            style: TextStyle(color: theme.accentColor, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'سورة ${surah.nameAr}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: theme.headerTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'آية ${ayah.ayahNumber} · جزء ${ayah.juz}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.headerTextColor.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // 2. Decorative Top Motif
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, theme.accentColor],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '﷽',
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accentColor, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Ayah Uthmani Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '﴿${ayah.textUthmani}﴾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 2.1,
                  fontWeight: FontWeight.w600,
                  color: theme.ayahTextColor,
                  fontFamily: 'Amiri',
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Tafsir Section (Optional)
            if (includeTafsir && tafsirText != null && tafsirText!.trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories, size: 14, color: theme.tafsirTitleColor),
                          const SizedBox(width: 4),
                          Text(
                            'التفسير الميسر',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: theme.tafsirTitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                ),
                child: Text(
                  tafsirText!.trim(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.7,
                    color: theme.tafsirTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 5. Dedication Footer (إهداء الأجر ودعاء للمرحوم مؤمن إبراهيم)
            if (includeDedication) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.dedicationBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.accentColor.withOpacity(0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'إهداء ودعاء بالرحمة والمغفرة للمرحوم',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.dedicationTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'مؤمن إبراهيم (رحمهُ الله)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: theme.dedicationNameColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تطبيق نور المؤمن · بدون إعلانات وبدون إنترنت',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.dedicationTextColor.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
