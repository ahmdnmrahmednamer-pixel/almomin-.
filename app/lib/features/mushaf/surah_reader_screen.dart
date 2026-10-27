import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/models/surah.dart';
import '../../core/models/ayah.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/audio/ayah_audio_player.dart';
import 'widgets/ayah_action_sheet.dart';
import 'widgets/ayah_linguistics_sheet.dart';
import 'widgets/ayah_card_share_sheet.dart';
import 'page_mode_mushaf_screen.dart';
import '../settings/widgets/settings_reciter_modal.dart';
import '../../core/services/khatma_service.dart';
import '../../core/services/quran_accessibility_service.dart';
import '../../core/ui/app_dropdown_field.dart';

class SurahReaderScreen extends StatefulWidget {
  final Surah surah;
  final int initialAyah;

  const SurahReaderScreen({
    super.key,
    required this.surah,
    this.initialAyah = 1,
  });

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  late double _fontSize;
  late Future<List<Ayah>> _ayahsFuture;
  final List<TapGestureRecognizer> _recognizers = [];
  int _themeModeIndex = 0; // 0: تلقائي/النظام, 1: مصحفي ورقي, 2: ليلي داكن, 3: نهاري أبيض
  String _readingDisplayMode = 'continuous'; // 'continuous' (المصحف المتصل) أو 'cards' (بطاقات الآيات والتفسير)
  final Set<int> _expandedTafseerAyahs = {};

  @override
  void initState() {
    super.initState();
    _fontSize = SettingsService.instance.mushafFontSize;
    _ayahsFuture = QuranRepository.getAyahsForSurah(widget.surah.id);
    SettingsService.instance.saveLastRead(
      surahId: widget.surah.id,
      ayahNumber: widget.initialAyah,
      pageNumber: widget.surah.pageStart,
      surahName: widget.surah.nameAr,
    );
    KhatmaService.instance.updateProgressFromReading(widget.surah.pageStart);
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  String _toArabicIndic(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }

  void _cycleReadingTheme() {
    setState(() {
      _themeModeIndex = (_themeModeIndex + 1) % 4;
    });
    final names = ['تلقائي حسب نظام الهاتف', 'ورقي مصحفي دافئ', 'ليلي مريح للعين', 'نهاري ناصع'];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('وضع القراءة: ${names[_themeModeIndex]}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSysDark = Theme.of(context).brightness == Brightness.dark;
    final isDark = _themeModeIndex == 2 || (_themeModeIndex == 0 && isSysDark);
    final isSepia = _themeModeIndex == 1;

    final Color pageBg = isSepia
        ? const Color(0xFFF7F1E3)
        : (isDark ? const Color(0xFF141716) : const Color(0xFFFCFCFA));

    final Color textColor = isSepia
        ? const Color(0xFF262019)
        : (isDark ? const Color(0xFFF7F7F7) : const Color(0xFF181C1A));

    final Color basmalaColor = isSepia
        ? const Color(0xFF2D5A27)
        : (isDark ? AppColors.softGold : AppColors.primaryGreen);

    final Color headerBg = isSepia
        ? const Color(0xFFEFE6D2)
        : (isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.08));

    final Color headerBorder = isSepia
        ? const Color(0xFFC9A84D)
        : (isDark ? AppColors.accentGold : AppColors.accentGold);

    final Color headerTitleColor = isSepia
        ? const Color(0xFF2D5A27)
        : (isDark ? AppColors.accentGold : AppColors.primaryGreen);

    final IconData themeIcon = _themeModeIndex == 1
        ? Icons.menu_book
        : (_themeModeIndex == 2 ? Icons.nightlight_round : (_themeModeIndex == 3 ? Icons.wb_sunny : Icons.brightness_auto));

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: Text('سورة ${widget.surah.nameAr}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over_rounded),
            tooltip: 'تغيير القارئ للتلاوة',
            onPressed: () => showSettingsReciterModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_rounded),
            tooltip: 'الانتقال إلى نمط صفحات المصحف (604 صفحات)',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PageModeMushafScreen(initialPage: widget.surah.pageStart),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: AppToolbarDropdown<String>(
              semanticLabel: 'نمط عرض الآيات',
              value: _readingDisplayMode,
              options: const [
                AppDropdownOption(value: 'continuous', label: 'المصحف المتصل', icon: Icons.menu_book_rounded),
                AppDropdownOption(value: 'cards', label: 'بطاقات الآيات والتفسير', icon: Icons.view_agenda_rounded),
              ],
              onChanged: (val) {
                setState(() {
                  _readingDisplayMode = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: AppToolbarDropdown<int>(
              semanticLabel: 'مظهر القراءة',
              value: _themeModeIndex,
              options: const [
                AppDropdownOption(value: 0, label: 'تلقائي', icon: Icons.brightness_auto_rounded),
                AppDropdownOption(value: 1, label: 'ورقي مصحفي', icon: Icons.menu_book_rounded),
                AppDropdownOption(value: 2, label: 'ليلي مريح', icon: Icons.nightlight_round),
                AppDropdownOption(value: 3, label: 'نهاري ناصع', icon: Icons.wb_sunny_rounded),
              ],
              onChanged: (val) {
                setState(() {
                  _themeModeIndex = val;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'تغيير حجم الخط',
            onPressed: () {
              setState(() {
                _fontSize = _fontSize >= 34.0 ? 18.0 : _fontSize + 4.0;
              });
              SettingsService.instance.setMushafFontSize(_fontSize);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حجم الخط: ${_fontSize.toInt()}'),
                  duration: const Duration(milliseconds: 600),
                ),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: FutureBuilder<List<Ayah>>(
          future: _ayahsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGreen),
                    SizedBox(height: 16),
                    Text('جاري تحميل آيات السورة الكريمة...', style: TextStyle(color: AppColors.mutedText)),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text('تعذر تحميل السورة: ${snapshot.error ?? "لا توجد بيانات"}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _ayahsFuture = QuranRepository.getAyahsForSurah(widget.surah.id);
                        });
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final ayahs = snapshot.data!;

            // Clear old recognizers
            for (final r in _recognizers) {
              r.dispose();
            }
            _recognizers.clear();

            return ValueListenableBuilder<String?>(
              valueListenable: AyahAudioPlayer.instance.currentPlayingKey,
              builder: (context, playingKey, _) {
                if (_readingDisplayMode == 'cards' || MediaQuery.accessibleNavigationOf(context)) {
                  return _buildAccessibleAyahList(
                    ayahs: ayahs,
                    playingKey: playingKey,
                    isDark: isDark,
                    isSepia: isSepia,
                    textColor: textColor,
                    pageBg: pageBg,
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    // Decorative Surah Header Frame
                    Semantics(
                      label: QuranAccessibilityService.buildSurahHeaderSemanticLabel(
                        surahName: widget.surah.nameAr,
                        isMakki: widget.surah.isMakki,
                        ayahCount: widget.surah.ayahCount,
                        revelationOrder: widget.surah.revelationOrder,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        decoration: BoxDecoration(
                          color: headerBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: headerBorder, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'سورة ${widget.surah.nameAr}',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: headerTitleColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.surah.isMakki ? "مكية" : "مدنية"} — آياتها ${widget.surah.ayahCount} — ترتيبها ${widget.surah.revelationOrder}',
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.mutedText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '💡 اضغط على الآية للاستماع · اضغط ضغطة مطولة للخيارات والتفسير',
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.softGold : AppColors.secondaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Separate Decorative Basmala (not in Surah 9 At-Tawbah, not separate in Fatihah)
                    if (widget.surah.hasBasmala && widget.surah.id != 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Semantics(
                          label: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                          child: Text(
                            'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: basmalaColor,
                            ),
                          ),
                        ),
                      ),

                    // Text Mode Ayah Flow with Uthmani text & Accessibility Semantics
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: ayahs.map((ayah) {
                          final isPlaying = playingKey == '${widget.surah.id}:${ayah.ayahNumber}';

                          final rec = TapGestureRecognizer()
                            ..onTap = () {
                              AyahAudioPlayer.instance.playAyah(
                                context,
                                widget.surah.id,
                                ayah.ayahNumber,
                                surahName: widget.surah.nameAr,
                              );
                            };
                          _recognizers.add(rec);

                          return TextSpan(
                            children: [
                              TextSpan(
                                text: '${ayah.textUthmani} ',
                                semanticsLabel: QuranAccessibilityService.buildAyahSemanticLabel(
                                  surahName: widget.surah.nameAr,
                                  ayahNumber: ayah.ayahNumber,
                                  uthmaniText: ayah.textUthmani,
                                ),
                                recognizer: rec,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: 2.2,
                                  color: isPlaying ? AppColors.accentGold : textColor,
                                  backgroundColor: isPlaying ? AppColors.accentGold.withOpacity(0.18) : Colors.transparent,
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                                  fontFamilyFallback: const [
                                    'Traditional Arabic',
                                    'Scheherazade New',
                                    'Amiri',
                                    'serif',
                                  ],
                                ),
                              ),
                              // Ayah Number Islamic Medallion Ornament (Exquisite End of Ayah Rosette)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ExcludeSemantics(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      AyahActionSheet.show(
                                        context,
                                        surah: widget.surah,
                                        ayah: ayah,
                                      );
                                    },
                                    onLongPress: () {
                                      AyahLinguisticsSheet.show(
                                        context,
                                        surah: widget.surah,
                                        ayah: ayah,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: AyahEndMarker(
                                        ayahNumber: ayah.ayahNumber,
                                        size: (_fontSize * 1.15).clamp(24.0, 42.0),
                                        color: isPlaying
                                            ? AppColors.accentGold
                                            : (isDark ? AppColors.softGold : AppColors.accentGold),
                                        isPlaying: isPlaying,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' '),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccessibleAyahList({
    required List<Ayah> ayahs,
    required String? playingKey,
    required bool isDark,
    required bool isSepia,
    required Color textColor,
    required Color pageBg,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
      itemCount: ayahs.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2823) : AppColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppColors.primaryGreen, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'عرض بطاقات الآيات المفصلة: اضغط على أي آية للاستماع أو فتح التفسير والإعراب وأسباب النزول.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.secondaryGreen,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final ayah = ayahs[index - 1];
        final isPlaying = playingKey == '${widget.surah.id}:${ayah.ayahNumber}';
        final isTafseerExpanded = _expandedTafseerAyahs.contains(ayah.ayahNumber);
        final isBookmarked = SettingsService.instance.isBookmarked(widget.surah.id, ayah.ayahNumber);
        final spokenText = QuranAccessibilityService.toScreenReaderText(ayah.textUthmani);

        return Semantics(
          container: true,
          label: QuranAccessibilityService.buildAyahSemanticLabel(
            surahName: widget.surah.nameAr,
            ayahNumber: ayah.ayahNumber,
            uthmaniText: ayah.textUthmani,
          ),
          hint: QuranAccessibilityService.ayahSemanticHint,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C221F) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPlaying
                    ? AppColors.accentGold
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                width: isPlaying ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'آية ${_toArabicIndic(ayah.ayahNumber)} / ${_toArabicIndic(widget.surah.ayahCount)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPlaying ? Colors.black : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    if (isPlaying)
                      const Row(
                        children: [
                          Icon(Icons.volume_up_rounded, color: AppColors.accentGold, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'جاري الاستماع',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quranic Text
                Text(
                  ayah.textUthmani,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 2.1,
                    fontWeight: FontWeight.w600,
                    color: isPlaying ? AppColors.accentGold : textColor,
                    fontFamilyFallback: const [
                      'Traditional Arabic',
                      'Scheherazade New',
                      'Amiri',
                      'serif',
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Phonetic Screen Reader Spoken Guide
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over_outlined, size: 16, color: AppColors.secondaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          spokenText,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 18),

                // Accessible Action Buttons Row (WCAG AA Target >= 48px)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      iconSize: 26,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                      ),
                      tooltip: isPlaying ? 'إيقاف التلاوة' : 'استماع للتلاوة',
                      onPressed: () {
                        if (isPlaying) {
                          AyahAudioPlayer.instance.stop();
                        } else {
                          AyahAudioPlayer.instance.playAyah(
                            context,
                            widget.surah.id,
                            ayah.ayahNumber,
                            surahName: widget.surah.nameAr,
                          );
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: Icon(
                        isTafseerExpanded ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                        color: isTafseerExpanded ? AppColors.accentGold : AppColors.secondaryGreen,
                      ),
                      tooltip: isTafseerExpanded ? 'إخفاء التفسير الميسر' : 'عرض التفسير الميسر',
                      onPressed: () {
                        setState(() {
                          if (isTafseerExpanded) {
                            _expandedTafseerAyahs.remove(ayah.ayahNumber);
                          } else {
                            _expandedTafseerAyahs.add(ayah.ayahNumber);
                          }
                        });
                      },
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppColors.accentGold : Colors.grey,
                      ),
                      tooltip: isBookmarked ? 'إزالة من العلامات المرجعية' : 'حفظ في العلامات المرجعية',
                      onPressed: () async {
                        final added = await SettingsService.instance.toggleBookmark(widget.surah.id, ayah.ayahNumber);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(added ? 'تم حفظ الآية في العلامات المرجعية' : 'تمت إزالة الآية من العلامات'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: const Icon(Icons.history_edu_rounded, color: AppColors.secondaryGreen),
                      tooltip: 'معاني الكلمات، غريب القرآن، وأسباب النزول',
                      onPressed: () {
                        AyahLinguisticsSheet.show(
                          context,
                          surah: widget.surah,
                          ayah: ayah,
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: const Icon(Icons.brush_rounded, color: AppColors.accentGold),
                      tooltip: 'تصميم ومشاركة بطاقة دعوية للآية (صورة)',
                      onPressed: () {
                        AyahCardShareSheet.show(
                          context,
                          surah: widget.surah,
                          ayah: ayah,
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 22,
                      icon: const Icon(Icons.more_horiz_rounded, color: AppColors.primaryGreen),
                      tooltip: 'خيارات الآية، التكرار، والنسخ',
                      onPressed: () {
                        AyahActionSheet.show(
                          context,
                          surah: widget.surah,
                          ayah: ayah,
                        );
                      },
                    ),
                  ],
                ),

                // Inline Tafseer Expansion
                if (isTafseerExpanded) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.accentGold),
                            SizedBox(width: 6),
                            Text(
                              'التفسير الميسر:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ayah.tafseer ?? 'التفسير غير متوفر لهذه الآية حالياً.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
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
      },
    );
  }
}
