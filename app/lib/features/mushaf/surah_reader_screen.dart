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
import 'page_mode_mushaf_screen.dart';

class AyahGestureRecognizer extends PrimaryPointerGestureRecognizer {
  VoidCallback? onTap;
  VoidCallback? onLongPress;
  Timer? _timer;

  AyahGestureRecognizer({super.debugOwner});

  @override
  void handlePrimaryPointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 450), () {
        resolve(GestureDisposition.accepted);
        onLongPress?.call();
        _timer = null;
      });
    } else if (event is PointerUpEvent) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
        _timer = null;
        resolve(GestureDisposition.accepted);
        onTap?.call();
      }
    } else if (event is PointerCancelEvent) {
      _timer?.cancel();
      _timer = null;
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  String get debugDescription => 'AyahGestureRecognizer';
}

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
  final List<AyahGestureRecognizer> _recognizers = [];
  int _themeModeIndex = 0; // 0: تلقائي/النظام, 1: مصحفي ورقي, 2: ليلي داكن, 3: نهاري أبيض

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
          IconButton(
            icon: Icon(themeIcon),
            tooltip: 'تغيير وضع القراءة (مصحفي / ليلي / نهاري)',
            onPressed: _cycleReadingTheme,
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
        textDirection: TextDirection.rtl,
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
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    // Decorative Surah Header Frame
                    Container(
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

                    // Separate Decorative Basmala (not in Surah 9 At-Tawbah, not separate in Fatihah)
                    if (widget.surah.hasBasmala && widget.surah.id != 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
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

                    // Text Mode Ayah Flow with Uthmani text
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: ayahs.map((ayah) {
                          final isPlaying = playingKey == '${widget.surah.id}:${ayah.ayahNumber}';

                          final rec = AyahGestureRecognizer()
                            ..onTap = () {
                              AyahAudioPlayer.instance.playAyah(
                                context,
                                widget.surah.id,
                                ayah.ayahNumber,
                                surahName: widget.surah.nameAr,
                              );
                            }
                            ..onLongPress = () {
                              AyahActionSheet.show(
                                context,
                                surah: widget.surah,
                                ayah: ayah,
                              );
                            };
                          _recognizers.add(rec);

                          return TextSpan(
                            children: [
                              TextSpan(
                                text: '${ayah.textUthmani} ',
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
                              // Ayah Number Bracket Ornament ﴿١﴾
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    AyahAudioPlayer.instance.playAyah(
                                      context,
                                      widget.surah.id,
                                      ayah.ayahNumber,
                                      surahName: widget.surah.nameAr,
                                    );
                                  },
                                  onLongPress: () {
                                    AyahActionSheet.show(
                                      context,
                                      surah: widget.surah,
                                      ayah: ayah,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPlaying ? AppColors.accentGold : (isDark ? AppColors.accentGold.withOpacity(0.25) : AppColors.accentGold.withOpacity(0.15)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPlaying ? AppColors.accentGold : (isDark ? AppColors.softGold : AppColors.accentGold),
                                        width: isPlaying ? 1.5 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '﴿${_toArabicIndic(ayah.ayahNumber)}﴾',
                                      style: TextStyle(
                                        fontSize: _fontSize * 0.72,
                                        fontWeight: FontWeight.bold,
                                        color: isPlaying ? Colors.black : (isDark ? AppColors.softGold : AppColors.secondaryGreen),
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
}
