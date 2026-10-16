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

  @override
  void initState() {
    super.initState();
    _fontSize = SettingsService.instance.mushafFontSize;
    _ayahsFuture = QuranRepository.getAyahsForSurah(widget.surah.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${widget.surah.nameAr}'),
        actions: [
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
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'سورة ${widget.surah.nameAr}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.surah.isMakki ? "مكية" : "مدنية"} — آياتها ${widget.surah.ayahCount} — ترتيبها ${widget.surah.revelationOrder}',
                            style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '💡 اضغط على الآية للاستماع · اضغط ضغطة مطولة للخيارات والتفسير',
                            style: TextStyle(fontSize: 12, color: AppColors.secondaryGreen),
                          ),
                        ],
                      ),
                    ),

                    // Separate Decorative Basmala (not in Surah 9 At-Tawbah, not separate in Fatihah)
                    if (widget.surah.hasBasmala && widget.surah.id != 1)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
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
                                  color: isPlaying ? AppColors.accentGold : AppColors.lightText,
                                  backgroundColor: isPlaying ? AppColors.accentGold.withOpacity(0.12) : Colors.transparent,
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
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
                                      color: isPlaying ? AppColors.accentGold.withOpacity(0.3) : AppColors.accentGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isPlaying ? AppColors.primaryGreen : AppColors.accentGold,
                                        width: isPlaying ? 1.5 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '﴿${_toArabicIndic(ayah.ayahNumber)}﴾',
                                      style: TextStyle(
                                        fontSize: _fontSize * 0.72,
                                        fontWeight: FontWeight.bold,
                                        color: isPlaying ? AppColors.primaryGreen : AppColors.secondaryGreen,
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
