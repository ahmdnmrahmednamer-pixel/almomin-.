import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/theme/app_theme.dart';

/// بطاقة تفاعلية مميزة لدعاء ما بعد الصلاة والأذان
/// لفضيلة الشيخ محمد متولي الشعراوي رحمه الله
/// تضم الاستماع المباشر للتسجيل الصوتي المدمج بدون إنترنت،
/// والنص الكامل بالتشكيل الدقيق، مع أزرار المشاركة والنسخ.
class SharawiPostPrayerDuaaCard extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onOpenFullLibrary;

  const SharawiPostPrayerDuaaCard({
    super.key,
    required this.isDark,
    this.onOpenFullLibrary,
  });

  @override
  State<SharawiPostPrayerDuaaCard> createState() => _SharawiPostPrayerDuaaCardState();
}

class _SharawiPostPrayerDuaaCardState extends State<SharawiPostPrayerDuaaCard> {
  int _selectedTab = 0; // 0: دعاء الأذان والصلاة (المسجل), 1: دعاء ختام الصلاة والمناجاة

  static const String duaaAudioText =
      '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ سَيِّدَنَا مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَالدَّرَجَةَ الْعَالِيَةَ الرَّفِيعَةَ، وَابْعَثْهُ اللَّهُمَّ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ، إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ.. وَصَلِّ اللَّهُمَّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ.. رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِسَيِّدَنَا مُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا».';

  static const String duaaKhatmText =
      '«اللَّهُمَّ يَا رَبَّنَا، مَا قَصُرَ عَنْهُ عِلْمِي، وَلَمْ تَبْلُغْهُ مَسْأَلَتِي، وَلَمْ تَنَلْهُ نِيَّتِي، مِنْ خَيْرٍ وَعَدْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوْ خَيْرٍ أَنْتَ مُعْطِيهِ أَحَدًا مِنْ عِبَادِكَ؛ فَإِنِّي أَرْغَبُ إِلَيْكَ فِيهِ، وَأَسْأَلُكَ إِيَّاهُ بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ..\n\nاللَّهُمَّ اجْعَلْ ثَوَابَ مَا صَلَّيْنَا، وَنُورَ مَا تَلَوْنَا، وَبَرَكَةَ مَا ذَكَرْنَا، هَدِيَّةً وَاصِلَةً إِلَى رَوْضَةِ سَيِّدِنَا وَمَوْلَانَا مُحَمَّدٍ ﷺ، ثُمَّ إِلَى أَرْوَاحِ آبَائِنَا وَأُمَّهَاتِنَا وَأَمْوَاتِنَا وَمَوْتَى الْمُسْلِمِينَ أَجْمَعِينَ، يَا رَبَّ الْعَالَمِينَ».';

  @override
  void initState() {
    super.initState();
    IslamicAudioService.instance.addListener(_onAudioChange);
  }

  @override
  void dispose() {
    IslamicAudioService.instance.removeListener(_onAudioChange);
    super.dispose();
  }

  void _onAudioChange() {
    if (mounted) setState(() {});
  }

  IslamicAudioTrack? get _sharawiTrack {
    return IslamicAudioService.allTracks.firstWhere(
      (t) => t.id == 'duaa_sharawi_post_prayer',
      orElse: () => IslamicAudioService.allTracks.first,
    );
  }

  bool get _isThisTrackActive {
    return IslamicAudioService.instance.currentTrack?.id == 'duaa_sharawi_post_prayer';
  }

  bool get _isPlaying {
    return _isThisTrackActive && IslamicAudioService.instance.isPlaying;
  }

  void _togglePlayback() {
    final service = IslamicAudioService.instance;
    final track = _sharawiTrack;
    if (track == null) return;

    if (_isThisTrackActive) {
      if (service.isPlaying) {
        service.pause();
      } else {
        service.resume();
      }
    } else {
      service.playTrack(track);
    }
  }

  void _copyDuaa() {
    final text = _selectedTab == 0 ? duaaAudioText : duaaKhatmText;
    final title = _selectedTab == 0 ? 'دعاء ما بعد الأذان والصلاة' : 'دعاء ختام الصلاة والمناجاة';
    Clipboard.setData(ClipboardData(text: '$title للشيخ الشعراوي رحمه الله:\n\n$text\n\nتطبيق نور المؤمن 🕌')).catchError((_) {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الدعاء المبارك بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareDuaa() {
    final text = _selectedTab == 0 ? duaaAudioText : duaaKhatmText;
    final title = _selectedTab == 0 ? 'دعاء ما بعد الأذان والصلاة' : 'دعاء ختام الصلاة والمناجاة';
    try {
      Share.share(
      '﴿ $title ﴾\nفضيلة الشيخ محمد متولي الشعراوي رحمه الله\n\n$text\n\nتطبيق نور المؤمن 🕌',
    );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final audioService = IslamicAudioService.instance;
    final position = _isThisTrackActive ? audioService.position : Duration.zero;
    final duration = _isThisTrackActive && audioService.duration > Duration.zero
        ? audioService.duration
        : const Duration(seconds: 68);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDark
              ? [const Color(0xFF142B20), const Color(0xFF0F1E17)]
              : [const Color(0xFFF0FDF4), const Color(0xFFE8F5E9)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.35),
          width: _isPlaying ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(_isPlaying ? 0.25 : 0.08),
            blurRadius: _isPlaying ? 14 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                // Avatar with Golden Ring
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentGold, AppColors.softGold],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? const Color(0xFF0D2319) : Colors.white,
                      ),
                      child: const Icon(
                        Icons.record_voice_over_rounded,
                        color: AppColors.primaryGreen,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'دعاء الشيخ الشعراوي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: widget.isDark ? AppColors.accentGold : AppColors.primaryGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                            ),
                            child: const Text(
                              'مدمج 🎧',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'دعاء ما بعد الأذان والصلاة المأثور بصوته العذب المبارك',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white70 : AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Audio Player Ribbon
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1B3D2F).withOpacity(0.7)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentGold.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Play/Pause Button
                    Material(
                      color: AppColors.primaryGreen,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _togglePlayback,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isPlaying ? 'جاري الاستماع الآن 🎙️' : 'استمع لتسجيل الشيخ الشعراوي',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _isPlaying ? AppColors.accentGold : null,
                                ),
                              ),
                              Text(
                                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Slider Bar
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: AppColors.accentGold,
                              inactiveTrackColor: AppColors.primaryGreen.withOpacity(0.2),
                              thumbColor: AppColors.accentGold,
                            ),
                            child: Slider(
                              value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (val) {
                                if (_isThisTrackActive) {
                                  audioService.seek(Duration(milliseconds: val.toInt()));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs Switcher (الأذان والصلاة / ختام الصلاة)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? AppColors.primaryGreen
                            : (widget.isDark ? Colors.white10 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'دعاء الأذان والصلاة 🎧',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _selectedTab == 0
                                ? Colors.white
                                : (widget.isDark ? Colors.white70 : AppColors.lightText),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? AppColors.primaryGreen
                            : (widget.isDark ? Colors.white10 : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'دعاء ختام الصلاة والمناجاة 🤲',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _selectedTab == 1
                                ? Colors.white
                                : (widget.isDark ? Colors.white70 : AppColors.lightText),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text Content
          Container(
            margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF0F1E17).withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Text(
              _selectedTab == 0 ? duaaAudioText : duaaKhatmText,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.85,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? const Color(0xFFF1F8F4) : const Color(0xFF1B3D2F),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Actions Footer (نسخ ومشاركة وإهداء)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: AppColors.accentGold.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.accentGold),
                      label: const Text(
                        'نسخ',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                      ),
                      onPressed: _copyDuaa,
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 14, color: AppColors.primaryGreen),
                      label: const Text(
                        'مشاركة',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                      onPressed: _shareDuaa,
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.accentGold),
                    SizedBox(width: 4),
                    Text(
                      'أدعية خاشعة ومأثورة',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// عرض دعاء الشيخ الشعراوي في نافذة سفلية (BottomSheet)
void showSharawiPostPrayerModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1A15) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SharawiPostPrayerDuaaCard(isDark: isDark),
            ],
          ),
        ),
      ),
    ),
  );
}
