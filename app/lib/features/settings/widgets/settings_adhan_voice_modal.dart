import '../../../core/text/arabic_normalizer.dart';
import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/notifications/prayer_notification_service.dart';
import '../../../core/services/islamic_audio_service.dart';

String getAdhanVoiceName(String key) {
  switch (key) {
    case 'adhan_makkah':
      return 'أذان المسجد الحرام (مكة المكرمة) — الشيخ علي ملا';
    case 'adhan_madinah':
      return 'أذان المسجد النبوي الشريف (المدينة المنورة)';
    case 'adhan_aqsa':
      return 'أذان المسجد الأقصى المبارك (القدس الشريف)';
    case 'adhan_cairo':
    case 'adhan_cairo_refaat':
      return 'أذان القاهرة ومصر — الشيخ محمد رفعت';
    case 'adhan_hussary':
      return 'أذان الشيخ محمود خليل الحصري (مقام البيات)';
    case 'adhan_abdulbasit':
      return 'أذان الشيخ عبد الباسط عبد الصمد';
    case 'adhan_afasy':
      return 'أذان الشيخ مشاري بن راشد العفاسي (الكويت والخليج)';
    case 'adhan_fajr':
      return 'أذان الفجر (الصلاة خير من النوم - الحرم المكي)';
    case 'adhan_fajr_afasy':
      return 'أذان الفجر — الشيخ مشاري العفاسي';
    case 'adhan_fajr_madinah':
      return 'أذان الفجر من المسجد النبوي الشريف';
    case 'adhan_fajr_aqsa':
      return 'أذان الفجر من المسجد الأقصى المبارك';
    case 'adhan_shoaisha':
      return 'أذان الشيخ أبو العينين شعيشع';
    case 'adhan_banna':
      return 'أذان الشيخ محمود علي البنا';
    case 'adhan_naina':
      return 'أذان الدكتور أحمد نعينع';
    case 'adhan_turkey':
      return 'أذان مساجد إسطنبول وتركيا (النمط العثماني)';
    case 'adhan_dubai':
      return 'أذان دبي والإمارات العربية المتحدة';
    case 'adhan_sham':
      return 'أذان الجامع الأموي الكبير (دمشق الشام)';
    case 'adhan_algeria':
      return 'أذان الجزائر والمغرب العربي';
    case 'adhan_alqatami':
      return 'أذان الشيخ ناصر القطامي (الرياض)';
    case 'adhan_alzamil':
      return 'أذان الشيخ ماجد الزامل (صوت شجي)';
    case 'adhan_mansoor_alsalimi':
      return 'أذان الشيخ منصور السالمي (خاشع ومؤثر)';
    case 'adhan_essam_bukhari':
      return 'أذان الشيخ عصام بخاري (المسجد النبوي)';
    case 'adhan_farooq_hadrawi':
      return 'أذان الشيخ فاروق حضراوي (المسجد الحرام)';
    case 'adhan_naif_feeda':
      return 'أذان الشيخ نايف فيده (المسجد الحرام)';
    case 'adhan_mustafa_ismail':
      return 'أذان الشيخ مصطفى إسماعيل (مقام الصبا)';
    case 'adhan_omran':
      return 'أذان الشيخ محمد عمران (سلطان المبتهلين)';
    case 'adhan_islam_sobhi':
      return 'أذان القارئ إسلام صبحي (هادئ وناعم)';
    case 'adhan_wadih_alyamani':
      return 'أذان الشيخ وديع اليمني (صنعاء واليمن)';
    case 'adhan_idrees_abkar':
      return 'أذان الشيخ إدريس أبكر (خاشع ومهيب)';
    case 'adhan_tunisia':
      return 'أذان جامع الزيتونة المعمور (تونس الخضراء)';
    case 'adhan_bosnia':
      return 'أذان سراييفو والبوسنة (جامع الغازي خسرو بك)';
    case 'adhan_fajr_abdulbasit':
      return 'أذان الفجر — الشيخ عبد الباسط عبد الصمد';
    case 'adhan_fajr_alqatami':
      return 'أذان الفجر — الشيخ ناصر القطامي';
    case 'adhan_haza_albalushi':
      return 'أذان القارئ هزاع البلوشي (سلطنة عمان)';
    case 'adhan_aldosari':
      return 'أذان الشيخ ياسر الدوسري (الحرم المكي)';
    case 'adhan_albani':
      return 'أذان الشيخ العلامة محمد ناصر الدين الألباني';
    case 'adhan_trabelsi':
      return 'أذان القارئ أحمد الطرابلسي';
    case 'adhan_fajr_trabelsi':
      return 'أذان الفجر — القارئ أحمد الطرابلسي';
    case 'adhan_kabara_rast':
      return 'أذان الشيخ محمد صلاح الدين كبارة (مقام رست 1957)';
    case 'adhan_doukali':
      return 'أذان الشيخ الدوكالي العالم (ليبيا)';
    case 'adhan_tokhi':
      return 'أذان الجمعة من جامع الرفاعي — الشيخ محمود الطوخي';
    case 'adhan_walid_mehsas':
      return 'أذان الشيخ وليد مهساس (الجزائر)';
    case 'adhan_fakhro':
      return 'أذان أحمد فخرو (جامع قطر الكبير)';
    case 'adhan_emadi':
      return 'أذان أحمد العمادي (قطر)';
    case 'adhan_marroush':
      return 'أذان القارئ كمال محمد المروش (المغرب)';
    case 'adhan_palestine_sohaib':
      return 'أذان من فلسطين — بصوت صهيب هاني';
    case 'adhan_iraq_assaf':
      return 'أذان العشاء من بغداد — القارئ ياسين العساف';
    case 'adhan_fajr_iraq_assaf':
      return 'أذان الفجر من العراق — القارئ ياسين العساف';
    case 'adhan_kuwait':
      return 'أذان دولة الكويت الرسمي';
    case 'adhan_fajr_kuwait':
      return 'أذان الفجر من دولة الكويت';
    case 'adhan_oman':
      return 'أذان مسقط وسلطنة عمان';
    case 'takbeerat':
      return 'تكبيرات الأذان والعيدين (نغمة سريعة)';
    default:
      return 'أذان المسجد الحرام (مكة المكرمة)';
  }
}

String getIqamahVoiceName(String key) {
  switch (key) {
    case 'iqamah_madinah':
      return 'إقامة المسجد النبوي الشريف (المدينة المنورة)';
    case 'iqamah_afasy':
      return 'إقامة الشيخ مشاري بن راشد العفاسي';
    case 'iqamah_abdulbasit':
      return 'إقامة الشيخ عبد الباسط عبد الصمد';
    case 'iqamah_cairo':
      return 'إقامة مساجد القاهرة والأزهر الشريف';
    case 'iqamah_short':
      return 'إقامة سريعة وخفيفة للتنبيه';
    case 'iqamah_makkah':
    case 'iqamah_full':
    default:
      return 'إقامة المسجد الحرام (مكة المكرمة)';
  }
}

void showSettingsAdhanVoiceModal(BuildContext context, {int initialTab = 0, String? initialPrayer}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PrayerMuezzinManagerSheet(
      initialTab: initialTab,
      initialPrayer: initialPrayer,
    ),
  );
}

/// Sheet showing the 5 daily prayers, each with its dedicated Muezzin dropdown and audio preview
class _PrayerMuezzinManagerSheet extends StatefulWidget {
  final int initialTab;
  final String? initialPrayer;

  const _PrayerMuezzinManagerSheet({this.initialTab = 0, this.initialPrayer});

  @override
  State<_PrayerMuezzinManagerSheet> createState() => _PrayerMuezzinManagerSheetState();
}

class _PrayerMuezzinManagerSheetState extends State<_PrayerMuezzinManagerSheet> {
  String? _currentlyPlayingTrackId;

  final List<Map<String, dynamic>> _prayers = [
    {
      'name': 'الفجر',
      'icon': Icons.nights_stay_rounded,
      'color': Color(0xFF1E293B),
      'desc': 'أذان الفجر المبارك (نداء الصلاة خير من النوم)',
    },
    {
      'name': 'الظهر',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFEAB308),
      'desc': 'أذان صلاة الظهر ودخول وقت الفريضة',
    },
    {
      'name': 'العصر',
      'icon': Icons.wb_twilight_rounded,
      'color': Color(0xFFF97316),
      'desc': 'أذان صلاة العصر والصلاة الوسطى',
    },
    {
      'name': 'المغرب',
      'icon': Icons.mode_night_rounded,
      'color': Color(0xFFDC2626),
      'desc': 'أذان صلاة المغرب وحلول المساء والإفطار',
    },
    {
      'name': 'العشاء',
      'icon': Icons.dark_mode_rounded,
      'color': Color(0xFF312E81),
      'desc': 'أذان صلاة العشاء والختام المبارك لليوم',
    },
  ];

  @override
  void initState() {
    super.initState();
    IslamicAudioService.instance.init();
    if (widget.initialPrayer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showPrayerMuezzinDropdownPicker(context, widget.initialPrayer!);
      });
    }
  }

  @override
  void dispose() {
    IslamicAudioService.instance.stop();
    super.dispose();
  }

  Future<void> _playPreview(String voiceKey) async {
    final audio = IslamicAudioService.instance;
    final track = IslamicAudioService.allTracks.firstWhere(
      (t) => t.id == voiceKey || t.rawNotificationSound == voiceKey,
      orElse: () => IslamicAudioService.allTracks.first,
    );

    if (_currentlyPlayingTrackId == track.id && audio.isPlaying) {
      await audio.stop();
      if (mounted) setState(() => _currentlyPlayingTrackId = null);
    } else {
      if (mounted) setState(() => _currentlyPlayingTrackId = track.id);
      await audio.playTrack(track);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifService = PrayerNotificationService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: notifService,
      builder: (context, _) {
        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D18) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مؤذنو الصلوات الخمس 🕌',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تخصيص مؤذن مستقل لكل صلاة مع الاستماع المسبق قبل الاختيار',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'إغلاق أو مسح',
                        icon: const Icon(Icons.close_rounded, color: AppColors.mutedText),
                        onPressed: () {
                          IslamicAudioService.instance.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Scrollable List of the 5 Prayers
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Quick Banner: Unified Muezzin option
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'يمكنك تخصيص شيخ مختلف لكل صلاة، أو تعيين مؤذن موحد للكل',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              onPressed: () {
                                showPrayerMuezzinDropdownPicker(context, 'الكل');
                              },
                              icon: const Icon(Icons.tune_rounded, size: 16),
                              label: const Text(
                                'مؤذن موحد',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 5 Prayers Cards
                      ..._prayers.map((prayer) {
                        final name = prayer['name'] as String;
                        final currentVoiceKey = notifService.getPrayerVoice(name);
                        final currentVoiceName = getAdhanVoiceName(currentVoiceKey);
                        final isPlaying = _currentlyPlayingTrackId == currentVoiceKey &&
                            IslamicAudioService.instance.isPlaying;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A2620) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (prayer['color'] as Color).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      prayer['icon'] as IconData,
                                      color: prayer['color'] as Color,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'صلاة $name',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          currentVoiceName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondaryGreen,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Actions: Preview audio + Dropdown / Pick Sheikh
                              Row(
                                children: [
                                  // Preview Sound Button
                                  Expanded(
                                    flex: 4,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isPlaying ? Colors.white : AppColors.primaryGreen,
                                        backgroundColor: isPlaying ? AppColors.primaryGreen : Colors.transparent,
                                        side: BorderSide(
                                          color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.3),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _playPreview(currentVoiceKey),
                                      icon: Icon(
                                        isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                        size: 18,
                                        color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                                      ),
                                      label: Text(
                                        isPlaying ? 'إيقاف الأذان' : 'استماع للمؤذن 🎧',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Dropdown / Change Sheikh Button
                                  Expanded(
                                    flex: 5,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        showPrayerMuezzinDropdownPicker(context, name);
                                      },
                                      icon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 16),
                                      label: const Text(
                                        'تغيير المؤذن ▾',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Iqamah Voice Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2822) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hourglass_bottom_rounded, color: AppColors.accentGold, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'صوت إقامة الصلاة المعتمد',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    getIqamahVoiceName(notifService.selectedIqamahVoice),
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(foregroundColor: AppColors.accentGold),
                              onPressed: () {
                                showPrayerMuezzinDropdownPicker(context, 'إقامة الصلاة', isIqamah: true);
                              },
                              icon: const Icon(Icons.arrow_drop_down_rounded),
                              label: const Text('تغيير ▾', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Test Notification Button
                      Center(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accentGold,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            await notifService.sendTestNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إرسال إشعار تجربة الأذان الحي للشريط العلوي 🔔'),
                                  backgroundColor: AppColors.primaryGreen,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_active_rounded, size: 18),
                          label: const Text(
                            'تجربة إشعار الأذان على الهاتف 🔔',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Interactive Dropdown/Picker Sheet for choosing a Sheikh for a specific prayer
/// Allows listening to any Sheikh's voice before selecting him
void showPrayerMuezzinDropdownPicker(BuildContext context, String prayerName, {bool isIqamah = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PrayerMuezzinPickerSheet(
      prayerName: prayerName,
      isIqamah: isIqamah,
    ),
  );
}

class _PrayerMuezzinPickerSheet extends StatefulWidget {
  final String prayerName;
  final bool isIqamah;

  const _PrayerMuezzinPickerSheet({
    required this.prayerName,
    this.isIqamah = false,
  });

  @override
  State<_PrayerMuezzinPickerSheet> createState() => _PrayerMuezzinPickerSheetState();
}

class _PrayerMuezzinPickerSheetState extends State<_PrayerMuezzinPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentlyPlayingTrackId;

  @override
  void initState() {
    super.initState();
    IslamicAudioService.instance.init();
  }

  @override
  void dispose() {
    IslamicAudioService.instance.stop();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playPreview(IslamicAudioTrack track) async {
    final audio = IslamicAudioService.instance;
    if (_currentlyPlayingTrackId == track.id && audio.isPlaying) {
      await audio.stop();
      if (mounted) setState(() => _currentlyPlayingTrackId = null);
    } else {
      if (mounted) setState(() => _currentlyPlayingTrackId = track.id);
      await audio.playTrack(track);
    }
  }

  List<IslamicAudioTrack> _getFilteredTracks() {
    final all = IslamicAudioService.allTracks.where((t) {
      if (widget.isIqamah) {
        return t.type == IslamicAudioType.iqamah;
      } else {
        return t.type == IslamicAudioType.adhan;
      }
    }).toList();

    if (_searchQuery.trim().isEmpty) return all;

    final q = _searchQuery.trim().toLowerCase();
    final normQ = ArabicNormalizer.normalize(_searchQuery, loose: true);
    return all.where((t) {
      final matchTitle = t.title.toLowerCase().contains(q) ||
          ArabicNormalizer.normalize(t.title, loose: true).contains(normQ);
      final matchSub = t.subtitle.toLowerCase().contains(q) ||
          ArabicNormalizer.normalize(t.subtitle, loose: true).contains(normQ);
      final matchMuezzin = (t.muezzinName?.toLowerCase().contains(q) ?? false) ||
          (t.muezzinName != null && ArabicNormalizer.normalize(t.muezzinName!, loose: true).contains(normQ));
      final matchCat = (t.categoryAr?.toLowerCase().contains(q) ?? false) ||
          (t.categoryAr != null && ArabicNormalizer.normalize(t.categoryAr!, loose: true).contains(normQ));
      return matchTitle || matchSub || matchMuezzin || matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifService = PrayerNotificationService.instance;
    final tracks = _getFilteredTracks();

    final currentSelectedVoice = widget.isIqamah
        ? notifService.selectedIqamahVoice
        : (widget.prayerName == 'الكل'
            ? notifService.selectedAdhanVoice
            : notifService.getPrayerVoice(widget.prayerName));

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D18) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Drag Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentGold, AppColors.softGold.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isIqamah
                              ? 'اختيار صوت إقامة الصلاة'
                              : (widget.prayerName == 'الكل'
                                  ? 'اختيار مؤذن لجميع الصلوات'
                                  : 'اختيار مؤذن صلاة ${widget.prayerName} 🕌'),
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'استمع لصوت الشيخ أولاً عبر زر الاستماع، ثم اضغط اختيار',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق أو مسح',
                    icon: const Icon(Icons.close_rounded, color: AppColors.mutedText),
                    onPressed: () {
                      IslamicAudioService.instance.stop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الشيخ أو المسجد (مكة، المدينة، مصر، العفاسي، القطامي...)...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryGreen),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                        tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1B231D) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Sheikhs List
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد أصوات مطابقة للبحث',
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final isSelected = currentSelectedVoice == track.id ||
                            currentSelectedVoice == track.rawNotificationSound;
                        final isPlaying = _currentlyPlayingTrackId == track.id &&
                            IslamicAudioService.instance.isPlaying;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen.withOpacity(0.08)
                                : (isDark ? const Color(0xFF19251E) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  // Leading Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : (isDark ? const Color(0xFF24342A) : Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      widget.isIqamah ? Icons.hourglass_bottom_rounded : Icons.mosque_rounded,
                                      color: isSelected ? Colors.white : AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Track Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          track.title,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                            fontSize: 14,
                                            color: isSelected ? AppColors.primaryGreen : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          track.subtitle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accentGold),
                                          SizedBox(width: 4),
                                          Text(
                                            'معتمد',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Listen First (استمع أولاً) & Choose (اختيار) buttons
                              Row(
                                children: [
                                  // 1. Preview button (استمع أولاً قبل الاختيار)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isPlaying ? Colors.white : AppColors.primaryGreen,
                                        backgroundColor: isPlaying ? AppColors.primaryGreen : Colors.transparent,
                                        side: BorderSide(
                                          color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.3),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _playPreview(track),
                                      icon: Icon(
                                        isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                        size: 18,
                                        color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                                      ),
                                      label: Text(
                                        isPlaying ? 'إيقاف الاستماع' : 'استماع للصوت 🎧',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 2. Select button (اختيار المؤذن لهذه الصلاة)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        await IslamicAudioService.instance.stop();

                                        if (widget.isIqamah) {
                                          await notifService.setSelectedIqamahVoice(track.id);
                                        } else if (widget.prayerName == 'الكل') {
                                          await notifService.setAllPrayersVoice(track.id);
                                        } else {
                                          await notifService.setPrayerVoice(widget.prayerName, track.id);
                                        }

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                widget.isIqamah
                                                    ? 'تم اعتماد صوت الإقامة: ${track.title} ✨'
                                                    : (widget.prayerName == 'الكل'
                                                        ? 'تم اعتماد ${track.title} لجميع الصلوات 🕌'
                                                        : 'تم اعتماد مؤذن صلاة ${widget.prayerName}: ${track.title} ✨'),
                                              ),
                                              backgroundColor: AppColors.primaryGreen,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(isSelected ? Icons.check_rounded : Icons.add_task_rounded, size: 16),
                                      label: Text(
                                        isSelected ? 'المعتمد حالياً' : 'اختيار لهذه الصلاة ✓',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
