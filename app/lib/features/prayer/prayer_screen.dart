import 'package:flutter/material.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/notifications/prayer_notification_service.dart';
import '../../core/services/fajr_qiyam_alarm_service.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/prayer_tracker_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import 'adhan_control_screen.dart';
import 'fajr_qiyam_alarm_screen.dart';
import 'hijri_calendar_screen.dart';
import 'sunan_rawatib_screen.dart';
import 'voluntary_fasting_screen.dart';
import 'widgets/arab_city_picker_modal.dart';
import 'widgets/prayer_audio_quick_card.dart';
import 'widgets/prayer_date_card.dart';
import 'widgets/prayer_location_banner.dart';
import 'widgets/prayer_muezzin_selector_card.dart';
import 'widgets/prayer_nav_cards.dart';
import 'widgets/prayer_times_card.dart';

/// شاشة «محراب الصلاة» (PrayerScreen) — منظمة في ٤ أبواب روحانية بجميع اللغات الـ ٦
class PrayerScreen extends StatefulWidget {
  final int initialTabIndex;

  const PrayerScreen({super.key, this.initialTabIndex = 0});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
      vsync: this,
    );
    PrayerService.instance.init();
    PrayerNotificationService.instance.init();
    PrayerTrackerService.instance.init();
    FajrQiyamAlarmService.instance.init();
    IslamicAudioService.instance.init();
    IslamicAudioService.instance.addListener(_onAudioServiceUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    IslamicAudioService.instance.removeListener(_onAudioServiceUpdate);
    super.dispose();
  }

  void _onAudioServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _showCityPicker(BuildContext context) {
    showArabCityPickerModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        PrayerService.instance,
        SettingsService.instance,
        PrayerNotificationService.instance,
      ]),
      builder: (context, _) {
        final s = SettingsService.instance;
        final data = PrayerService.instance.currentData;

        return Directionality(
          textDirection: s.textDirection,
          child: Scaffold(
            drawer: const AppNavigationDrawer(),
            appBar: AppBar(
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: s.isArabic ? 'القائمة الإيمانية' : 'Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              title: Text(context.tr('nav_prayer'),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.location_city_rounded),
                  tooltip: 'اختيار المدينة',
                  onPressed: () => _showCityPicker(context),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location_rounded),
                  tooltip: 'تحديث الموقع عبر GPS',
                  onPressed: () async {
                    final ok =
                        await PrayerService.instance.requestGpsLocation();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'تم تحديث الموقع ومواقيت الصلاة بنجاح'
                                : (PrayerService.instance.errorMessage ??
                                    'تعذر تحديث الموقع'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          backgroundColor: ok
                              ? AppColors.primaryGreen
                              : Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: isDark ? const Color(0xFF0F1A15) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primaryGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.accentGold,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.access_time_filled_rounded,
                            size: 18),
                        text: context.tr('prayer_tab_times'),
                      ),
                      Tab(
                        icon: const Icon(Icons.record_voice_over_rounded,
                            size: 18),
                        text: context.tr('prayer_tab_muezzins'),
                      ),
                      Tab(
                        icon: const Icon(Icons.explore_rounded, size: 18),
                        text: context.tr('prayer_tab_qibla'),
                      ),
                      Tab(
                        icon: const Icon(Icons.fact_check_rounded, size: 18),
                        text: context.tr('prayer_tab_covenant'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: مواقيت النور
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const PrayerDateCard(),
                    const SizedBox(height: 12),
                    PrayerLocationBanner(data: data),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.alarm_on_rounded,
                              color: AppColors.primaryGreen, size: 26),
                        ),
                        title: Text(
                          context.tr('dawn_awakening'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14.5),
                        ),
                        subtitle: Text(
                          context.tr('dawn_awakening_sub'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 15, color: AppColors.primaryGreen),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FajrQiyamAlarmScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrayerTimesCard(data: data, isDark: isDark),
                    const SizedBox(height: 16),
                  ],
                ),

                // TAB 2: نداء الحق والمؤذنون
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    PrayerMuezzinSelectorCard(isDark: isDark),
                    const SizedBox(height: 16),
                    PrayerAudioQuickCard(isDark: isDark),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F4E38), Color(0xFF1E7051)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  border: Border.all(
                                      color: AppColors.accentGold, width: 1.5),
                                ),
                                child: const Icon(Icons.mosque_rounded,
                                    color: AppColors.softGold, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معاينة شاشة نداء الأذان والخشوع',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'تفاعل هادئ مع نداء الأذان وإيماءات الهاتف الذكية',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGold,
                                foregroundColor: const Color(0xFF0B2E21),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon:
                                  const Icon(Icons.play_circle_filled_rounded),
                              label: const Text('معاينة نداء الأذان الآن',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdhanControlScreen(
                                      prayerName: 'الظهر',
                                      isIqamah: false,
                                      autoPlay: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrayerBatteryOverviewCard(isDark: isDark),
                  ],
                ),

                // TAB 3: القبلة والأيام
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    PrayerQiblaOverviewCard(data: data),
                    const SizedBox(height: 14),
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_month_rounded,
                              color: AppColors.accentGold, size: 26),
                        ),
                        title: Text(
                          context.tr('hijri_calendar'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'الأشهر الحرم، الأيام البيض، والمواسم الإيمانية المباركة',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HijriCalendarScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // TAB 4: عهد الصلاة والرواتب
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    PrayerTrackerOverviewCard(isDark: isDark),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0F5B45),
                          child:
                              Icon(Icons.mosque_rounded, color: Colors.white),
                        ),
                        title: Text(
                          context.tr('sunan_rawatib'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: const Text(
                            'المواظبة على السنن الرواتب الاثنتي عشرة وصلاة الضحى والوتر'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 15),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SunanRawatibScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFB88917),
                          child: Icon(Icons.wb_twilight_rounded,
                              color: Colors.white),
                        ),
                        title: Text(
                          context.tr('voluntary_fasting'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: const Text(
                            'صيام الإثنين والخميس والأيام البيض والست من شوال وعرفة'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 15),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VoluntaryFastingScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
