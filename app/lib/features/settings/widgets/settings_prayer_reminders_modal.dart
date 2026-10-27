import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/notifications/prayer_notification_service.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../adhkar/widgets/sharawi_post_prayer_card.dart';

void showSettingsPreReminderModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'وقت التنبيه المسبق قبل الأذان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...[5, 10, 15, 20, 30].map((mins) {
                final isSelected = PrayerNotificationService.instance.preReminderMinutes == mins;
                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.timer_outlined,
                        color: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                      ),
                      title: Text(
                        '$mins دقائق قبل الأذان',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      onTap: () async {
                        await PrayerNotificationService.instance.setPreReminder(mins);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.record_voice_over_rounded, color: AppColors.accentGold, size: 20),
                label: const Text(
                  'تخصيص التنبيهات الصوتية (اقتربت صلاة...) 🎧',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  showSettingsApproachingPrayerVoiceModal(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void showSettingsApproachingPrayerVoiceModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ApproachingPrayerVoiceModalContent(),
  );
}

class _ApproachingPrayerVoiceModalContent extends StatefulWidget {
  const _ApproachingPrayerVoiceModalContent();

  @override
  State<_ApproachingPrayerVoiceModalContent> createState() => _ApproachingPrayerVoiceModalContentState();
}

class _ApproachingPrayerVoiceModalContentState extends State<_ApproachingPrayerVoiceModalContent> {
  String? _currentlyPlayingPrayer;

  final List<Map<String, dynamic>> _prayers = [
    {
      'name': 'الفجر',
      'icon': Icons.nights_stay_rounded,
      'spokenText': 'اقتربت صلاة الفجر، يرجى الاستعداد والتطهر',
      'color': Color(0xFF1E293B),
    },
    {
      'name': 'الظهر',
      'icon': Icons.wb_sunny_rounded,
      'spokenText': 'اقتربت صلاة الظهر، يرجى الاستعداد والتطهر',
      'color': Color(0xFFEAB308),
    },
    {
      'name': 'العصر',
      'icon': Icons.wb_twilight_rounded,
      'spokenText': 'اقتربت صلاة العصر، يرجى الاستعداد والتطهر',
      'color': Color(0xFFF97316),
    },
    {
      'name': 'المغرب',
      'icon': Icons.mode_night_rounded,
      'spokenText': 'اقتربت صلاة المغرب، يرجى الاستعداد والتطهر',
      'color': Color(0xFFDC2626),
    },
    {
      'name': 'العشاء',
      'icon': Icons.dark_mode_rounded,
      'spokenText': 'اقتربت صلاة العشاء، يرجى الاستعداد والتطهر',
      'color': Color(0xFF312E81),
    },
  ];

  @override
  void dispose() {
    IslamicAudioService.instance.stopSfx();
    super.dispose();
  }

  Future<void> _playPreview(String prayerName) async {
    if (_currentlyPlayingPrayer == prayerName) {
      await IslamicAudioService.instance.stopSfx();
      if (mounted) setState(() => _currentlyPlayingPrayer = null);
    } else {
      if (mounted) setState(() => _currentlyPlayingPrayer = prayerName);
      await IslamicAudioService.instance.playApproachingPrayerAudio(prayerName);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _currentlyPlayingPrayer == prayerName) {
          setState(() => _currentlyPlayingPrayer = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifService = PrayerNotificationService.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D18) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle & Title
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
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
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التنبيه الصوتي المسبق قبل الصلاة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'نداء صوتي باقتراب الصلاة للتطهر والتهيؤ في الوقت المناسب',
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Master Switch
                  Container(
                    decoration: BoxDecoration(
                      color: notifService.preReminderVoiceEnabled
                          ? AppColors.primaryGreen.withOpacity(0.08)
                          : (isDark ? const Color(0xFF1C2720) : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notifService.preReminderVoiceEnabled
                            ? AppColors.primaryGreen.withOpacity(0.3)
                            : Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: SwitchListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: notifService.preReminderVoiceEnabled
                              ? AppColors.primaryGreen
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                      ),
                      title: const Text(
                        'تشغيل الصوتيات المسبقة (اقتربت صلاة...)',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                      ),
                      subtitle: const Text(
                        'إطلاق نداء صوتي ينطق باسم الصلاة المقتربة للاستعداد',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                      activeColor: AppColors.accentGold,
                      activeTrackColor: AppColors.primaryGreen,
                      value: notifService.preReminderVoiceEnabled,
                      onChanged: (val) async {
                        await notifService.togglePreReminderVoice(val);
                        if (mounted) setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lead Time Selector (سماع التنبيه قبل الصلاة بـ كم دقيقة)
                  const Text(
                    'توقيت سماع التنبيه قبل موعد الأذان:',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 20, 30].map((mins) {
                      final isSelected = notifService.preReminderMinutes == mins;
                      return InkWell(
                        onTap: () async {
                          await notifService.setPreReminder(mins);
                          if (mounted) setState(() {});
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : (isDark ? const Color(0xFF1E2922) : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.accentGold : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.timer_outlined,
                                size: 16,
                                color: isSelected ? AppColors.accentGold : AppColors.mutedText,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$mins دقائق مسبقاً',
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                  fontSize: 12.5,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Prayers Individual List
                  const Text(
                    'الصلوات الخمس والتنبيهات المخصصة:',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 8),

                  ..._prayers.map((prayer) {
                    final name = prayer['name'] as String;
                    final isPrayerActive = notifService.isPreReminderPrayerEnabled(name);
                    final isPlaying = _currentlyPlayingPrayer == name;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2620) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPrayerActive
                              ? AppColors.primaryGreen.withOpacity(0.25)
                              : Colors.grey.shade200,
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
                                  color: (prayer['color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  prayer['icon'] as IconData,
                                  color: prayer['color'] as Color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'صلاة $name',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '«${prayer['spokenText']}»',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white60 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                activeColor: AppColors.accentGold,
                                activeTrackColor: AppColors.primaryGreen,
                                value: isPrayerActive,
                                onChanged: (val) async {
                                  await notifService.togglePreReminderPrayer(name, val);
                                  if (mounted) setState(() {});
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Action Buttons: Preview Sound & Test Notification
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isPlaying ? Colors.white : AppColors.primaryGreen,
                                    backgroundColor: isPlaying ? AppColors.primaryGreen : Colors.transparent,
                                    side: BorderSide(
                                      color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _playPreview(name),
                                  icon: Icon(
                                    isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                    size: 18,
                                    color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                                  ),
                                  label: Text(
                                    isPlaying ? 'إيقاف الاستماع' : 'استماع للمقطع 🎧',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accentGold,
                                    side: BorderSide(color: AppColors.accentGold.withOpacity(0.4)),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    await notifService.sendTestPreReminderNotification(name);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: AppColors.primaryGreen,
                                          duration: const Duration(seconds: 2),
                                          content: Text('تم إرسال إشعار تجربة اقتراب صلاة $name مع الصوت النقي 🔔'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.accentGold),
                                  label: const Text(
                                    'تجربة الإشعار 🔔',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSettingsQiyamOffsetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'وقت تنبيه قيام الليل والتهجد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...[
                {'mins': 45, 'title': 'قبل أذان الفجر بـ ٤٥ دقيقة'},
                {'mins': 60, 'title': 'قبل أذان الفجر بساعة (٦٠ دقيقة)'},
                {'mins': 90, 'title': 'قبل أذان الفجر بساعة ونصف (٩٠ دقيقة)'},
                {'mins': 120, 'title': 'قبل أذان الفجر بساعتين (١٢٠ دقيقة)'},
              ].map((item) {
                final isSelected = PrayerNotificationService.instance.qiyamOffsetMinutes == item['mins'];
                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.bedtime_rounded,
                        color: isSelected ? AppColors.accentGold : AppColors.secondaryGreen,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      onTap: () async {
                        await PrayerNotificationService.instance.setQiyamOffset(item['mins'] as int);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void showSettingsDuhaOffsetModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'وقت تنبيه صلاة الضحى (صلاة الأوابين)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...[
                {'mins': 15, 'title': 'بعد الشروق بـ ١٥ دقيقة (بداية وقت الجواز)'},
                {'mins': 25, 'title': 'بعد الشروق بـ ٢٥ دقيقة (المستحب الشائع)'},
                {'mins': 40, 'title': 'بعد الشروق بـ ٤٠ دقيقة'},
                {'mins': 60, 'title': 'بعد الشروق بساعة (ارتفاع الضحى)'},
              ].map((item) {
                final isSelected = PrayerNotificationService.instance.duhaReminderMinutesAfterSunrise == item['mins'];
                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.wb_sunny_rounded,
                        color: isSelected ? AppColors.accentGold : AppColors.accentGold,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      onTap: () async {
                        await PrayerNotificationService.instance.setDuhaOffset(item['mins'] as int);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void showSettingsPostAdhkarModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'وقت تنبيه أذكار ما بعد الصلاة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...[
                {'mins': 5, 'title': 'بعد انقضاء الصلاة بـ ٥ دقائق'},
                {'mins': 10, 'title': 'بعد انقضاء الصلاة بـ ١٠ دقائق'},
                {'mins': 15, 'title': 'بعد انقضاء الصلاة بـ ١٥ دقيقة'},
              ].map((item) {
                final isSelected = PrayerNotificationService.instance.postPrayerAdhkarMinutes == item['mins'];
                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.auto_awesome_rounded,
                        color: isSelected ? AppColors.accentGold : AppColors.secondaryGreen,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      onTap: () async {
                        await PrayerNotificationService.instance.setPostPrayerAdhkarOffset(item['mins'] as int);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.record_voice_over_rounded, color: AppColors.accentGold, size: 20),
                label: const Text(
                  'استمع لدعاء الشيخ الشعراوي بعد الصلاة 🎧',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  showSharawiPostPrayerModal(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void showSettingsSoundModeModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final currentMode = PrayerNotificationService.instance.soundMode;

      final modes = [
        {
          'mode': AdhanSoundMode.fullAdhan,
          'title': 'أذان كامل (صوت نداء الحق كاملاً)',
          'desc': 'ينطلق صوت المؤذن كاملاً عند دخول وقت كل صلاة',
          'icon': Icons.volume_up_rounded,
        },
        {
          'mode': AdhanSoundMode.takbeerat,
          'title': 'تكبيرات فقط (الله أكبر الله أكبر)',
          'desc': 'نغمة تكبيرات مختصرة وسريعة بدلاً من الأذان المطول',
          'icon': Icons.campaign_rounded,
        },
        {
          'mode': AdhanSoundMode.softBeep,
          'title': 'نغمة إشعار هادئة (إشعار النظام)',
          'desc': 'تنبيه بصوت إشعار الهاتف القياسي دون تشغيل الأذان',
          'icon': Icons.notifications_active_outlined,
        },
        {
          'mode': AdhanSoundMode.vibrateOnly,
          'title': 'اهتزاز قوي فقط (بدون رنين)',
          'desc': 'اهتزاز الهاتف عند دخول الوقت دون إطلاق صوت الأذان',
          'icon': Icons.vibration_rounded,
        },
        {
          'mode': AdhanSoundMode.silent,
          'title': 'تنبيه صامت (بدون صوت)',
          'desc': 'إشعار بصري فقط على الشاشة وقفل الهاتف دون أي رنين',
          'icon': Icons.notifications_off_outlined,
        },
      ];

      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Text(
                'نمط صوت تنبيه الأذان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...modes.map((item) {
                final isSelected = currentMode == item['mode'];
                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle_rounded : item['icon'] as IconData,
                        color: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      subtitle: Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      onTap: () async {
                        await PrayerNotificationService.instance.setSoundMode(item['mode'] as AdhanSoundMode);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}
