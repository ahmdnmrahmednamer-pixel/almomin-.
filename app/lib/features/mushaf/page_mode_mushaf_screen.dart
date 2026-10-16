import 'package:flutter/material.dart';
import '../../core/models/ayah.dart';
import '../../core/models/surah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/khatma_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/audio/ayah_audio_player.dart';
import 'widgets/ayah_action_sheet.dart';
import 'surah_reader_screen.dart';

class PageModeMushafScreen extends StatefulWidget {
  final int initialPage;

  const PageModeMushafScreen({
    super.key,
    this.initialPage = 1,
  });

  @override
  State<PageModeMushafScreen> createState() => _PageModeMushafScreenState();
}

class _PageModeMushafScreenState extends State<PageModeMushafScreen> {
  late int _currentPage;
  late PageController _pageController;
  bool _showControls = true;
  int _themeModeIndex = 0; // 0: تلقائي/نظام, 1: ورقي مصحفي, 2: ليلي داكن, 3: نهاري ناصع
  double _fontSize = 22.0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPage - 1);
    _fontSize = SettingsService.instance.mushafFontSize;
    _recordCurrentPageRead();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _recordCurrentPageRead() async {
    final meta = await QuranRepository.getPageMetadata(_currentPage);
    if (meta != null && mounted) {
      SettingsService.instance.saveLastRead(
        surahId: meta.surahId,
        ayahNumber: meta.startAyah,
        pageNumber: _currentPage,
        surahName: meta.surahName,
      );
      KhatmaService.instance.updateProgress(_currentPage);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
    });
    _recordCurrentPageRead();
  }

  void _jumpToPage(int page) {
    final p = page.clamp(1, 604);
    _pageController.jumpToPage(p - 1);
  }

  void _cycleTheme() {
    setState(() {
      _themeModeIndex = (_themeModeIndex + 1) % 4;
    });
    final names = ['تلقائي', 'ورقي مصحفي', 'ليلي داكن', 'نهاري ناصع'];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('وضع القراءة: ${names[_themeModeIndex]}'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _showJumpDialog() {
    final controller = TextEditingController(text: _currentPage.toString());
    double sliderVal = _currentPage.toDouble();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('الانتقال إلى صفحة'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('صفحة: ${sliderVal.toInt()} من 604', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Slider(
                      value: sliderVal,
                      min: 1,
                      max: 604,
                      divisions: 603,
                      activeColor: AppColors.accentGold,
                      onChanged: (val) {
                        setDialogState(() {
                          sliderVal = val;
                          controller.text = val.toInt().toString();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'رقم الصفحة (1 - 604)',
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 1 && parsed <= 604) {
                          setDialogState(() {
                            sliderVal = parsed.toDouble();
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                    onPressed: () {
                      final p = int.tryParse(controller.text);
                      if (p != null) {
                        _jumpToPage(p);
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('انتقال'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final isSysDark = Theme.of(context).brightness == Brightness.dark;
    final isDark = _themeModeIndex == 2 || (_themeModeIndex == 0 && isSysDark);
    final isSepia = _themeModeIndex == 1;

    final Color pageBg = isSepia
        ? const Color(0xFFF7F1E3)
        : (isDark ? const Color(0xFF141716) : const Color(0xFFFCFCFA));

    final Color frameColor = isSepia
        ? const Color(0xFFC9A84D)
        : (isDark ? AppColors.accentGold.withOpacity(0.4) : AppColors.accentGold);

    final Color textColor = isSepia
        ? const Color(0xFF262019)
        : (isDark ? const Color(0xFFF7F7F7) : const Color(0xFF181C1A));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: _showControls
            ? AppBar(
                title: Text('صفحة ${_toArabicIndic(_currentPage)} / ٦٠٤'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'الانتقال إلى نمط السور النصي',
                    onPressed: () async {
                      final meta = await QuranRepository.getPageMetadata(_currentPage);
                      if (meta != null && mounted) {
                        final surah = await QuranRepository.getSurahById(meta.surahId);
                        if (surah != null && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahReaderScreen(surah: surah, initialAyah: meta.startAyah),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    tooltip: 'حفظ موضع القراءة الحالي',
                    onPressed: () async {
                      final meta = await QuranRepository.getPageMetadata(_currentPage);
                      if (meta != null && mounted) {
                        final added = await SettingsService.instance.toggleBookmark(meta.surahId, meta.startAyah);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(added
                                  ? 'تمت إضافة سورة ${meta.surahName} (صفحة $_currentPage) إلى العلامات المرجعية'
                                  : 'تمت إزالة العلامة المرجعية'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.find_in_page_outlined),
                    tooltip: 'الانتقال إلى صفحة...',
                    onPressed: _showJumpDialog,
                  ),
                  IconButton(
                    icon: Icon(_themeModeIndex == 1
                        ? Icons.menu_book
                        : (_themeModeIndex == 2 ? Icons.nightlight_round : Icons.wb_sunny_outlined)),
                    tooltip: 'تغيير وضع القراءة',
                    onPressed: _cycleTheme,
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: 604,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final pageNum = index + 1;
                  return _buildMushafPage(pageNum, pageBg, frameColor, textColor, isDark, isSepia);
                },
              ),

              // Bottom Overlay Navigation Bar
              if (_showControls)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2522).withOpacity(0.95) : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                          tooltip: 'الصفحة السابقة',
                          onPressed: _currentPage > 1 ? () => _jumpToPage(_currentPage - 1) : null,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _showJumpDialog,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'صفحة ${_toArabicIndic(_currentPage)} من ٦٠٤',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'اضغط للقفز المباشر أو التمرير',
                                  style: TextStyle(fontSize: 10, color: AppColors.mutedText),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          tooltip: 'الصفحة التالية',
                          onPressed: _currentPage < 604 ? () => _jumpToPage(_currentPage + 1) : null,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMushafPage(
    int pageNum,
    Color pageBg,
    Color frameColor,
    Color textColor,
    bool isDark,
    bool isSepia,
  ) {
    return FutureBuilder<List<Ayah>>(
      future: QuranRepository.getAyahsForPage(pageNum),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final ayahs = snapshot.data ?? [];
        if (ayahs.isEmpty) {
          return const Center(child: Text('لا توجد آيات في هذه الصفحة'));
        }

        final firstAyah = ayahs.first;

        return ValueListenableBuilder<String?>(
          valueListenable: AyahAudioPlayer.instance.currentPlayingKey,
          builder: (context, playingKey, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: pageBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: frameColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Page Header: Surah name & Juz
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الجزء ${_toArabicIndic(firstAyah.juz)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.softGold : AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          'الحزب ${_toArabicIndic(firstAyah.hizb)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.softGold : AppColors.secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: frameColor.withOpacity(0.4), height: 1, thickness: 1),
                  const SizedBox(height: 8),

                  // Page Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _renderPageContent(ayahs, playingKey, textColor, isDark, isSepia),
                      ),
                    ),
                  ),

                  // Page Footer: Page Number in Arabic Ornament
                  const SizedBox(height: 6),
                  Divider(color: frameColor.withOpacity(0.4), height: 1, thickness: 1),
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: frameColor, width: 1.2),
                        borderRadius: BorderRadius.circular(12),
                        color: frameColor.withOpacity(0.12),
                      ),
                      child: Text(
                        '﴿ ${_toArabicIndic(pageNum)} ﴾',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.softGold : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _renderPageContent(
    List<Ayah> ayahs,
    String? playingKey,
    Color textColor,
    bool isDark,
    bool isSepia,
  ) {
    final List<Widget> widgets = [];
    final Map<int, List<Ayah>> groupedBySurah = {};

    for (final a in ayahs) {
      groupedBySurah.putIfAbsent(a.surahId, () => []).add(a);
    }

    groupedBySurah.forEach((surahId, surahAyahs) {
      final firstInSurah = surahAyahs.first;
      // If surah begins on this page
      if (firstInSurah.ayahNumber == 1) {
        widgets.add(
          FutureBuilder<Surah?>(
            future: QuranRepository.getSurahById(surahId),
            builder: (context, snap) {
              final sName = snap.data?.nameAr ?? 'السورة';
              final isMakki = snap.data?.isMakki ?? true;
              final aCount = snap.data?.ayahCount ?? 0;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF222C27) : const Color(0xFFF0E8D0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentGold, width: 1.2),
                ),
                child: Column(
                  children: [
                    Text(
                      'سورة $sName',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isMakki ? "مكية" : "مدنية"} — آياتها ${_toArabicIndic(aCount)}',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.mutedText),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        // Basmala (not in Surah 9 At-Tawbah, not separate in Surah 1 Al-Fatiha)
        if (surahId != 9 && surahId != 1) {
          widgets.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
            ),
          );
        }
      }

      // Continuous Ayah RichText
      widgets.add(
        RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            children: surahAyahs.map((ayah) {
              final isPlaying = playingKey == '$surahId:${ayah.ayahNumber}';

              return TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () {
                        AyahAudioPlayer.instance.playAyah(
                          context,
                          ayah.surahId,
                          ayah.ayahNumber,
                        );
                      },
                      onLongPress: () async {
                        final surah = await QuranRepository.getSurahById(ayah.surahId);
                        if (surah != null && context.mounted) {
                          AyahActionSheet.show(
                            context,
                            surah: surah,
                            ayah: ayah,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isPlaying ? AppColors.accentGold.withOpacity(0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${ayah.textUthmani} ',
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 2.1,
                            color: isPlaying ? AppColors.accentGold : textColor,
                            fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Ayah Number Bracket ﴿١﴾
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: InkWell(
                      onTap: () {
                        AyahAudioPlayer.instance.playAyah(
                          context,
                          ayah.surahId,
                          ayah.ayahNumber,
                        );
                      },
                      onLongPress: () async {
                        final surah = await QuranRepository.getSurahById(ayah.surahId);
                        if (surah != null && context.mounted) {
                          AyahActionSheet.show(
                            context,
                            surah: surah,
                            ayah: ayah,
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isPlaying ? AppColors.accentGold : AppColors.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentGold, width: 0.8),
                        ),
                        child: Text(
                          '﴿${_toArabicIndic(ayah.ayahNumber)}﴾',
                          style: TextStyle(
                            fontSize: _fontSize * 0.68,
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
      );
    });

    return widgets;
  }
}
