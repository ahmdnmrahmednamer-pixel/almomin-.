import 'package:flutter/material.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/daily_wird_service.dart';
import '../../core/services/fiqh_library_service.dart';
import '../../core/services/hadith_service.dart';
import '../../core/services/khatma_service.dart';
import '../../core/services/memorization_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/prayer_tracker_service.dart';
import '../../core/services/quran_topic_service.dart';
import '../../core/services/ramadan_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/stories_service.dart';
import '../../core/services/tajweed_service.dart';
import '../../core/services/zakat_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/adaptive_screen_layouts.dart';
import '../onboarding/onboarding_screen.dart';
import '../search/quran_search_screen.dart';
import '../settings/widgets/settings_language_modal.dart';
import 'widgets/home_adhkar_tasbih_row.dart';
import 'widgets/home_adhkar_time_banner.dart';
import 'widgets/home_date_header_card.dart';
import 'widgets/home_khatma_card.dart';
import 'widgets/home_momen_memorial_banner.dart';
import 'widgets/home_next_prayer_card.dart';
import 'widgets/home_prayer_tracker_card.dart';
import 'widgets/home_quran_continue_card.dart';
import 'widgets/home_shortcuts_list.dart';

/// شاشة «إشراقة اليوم» (HomeScreen) — منظمة في ٤ محطات إيمانية هادئة ومتسلسلة
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    PrayerService.instance.init();
    SettingsService.instance.init();
    KhatmaService.instance.init();
    MemorizationService.instance.init();
    ZakatService.instance.init();
    HadithService.instance.init();
    QuranTopicService.instance.init();
    StoriesService.instance.init();
    RamadanService.instance.init();
    TajweedService.instance.init();
    PrayerTrackerService.instance.init();
    DailyWirdService.instance.init();
    FiqhLibraryService.instance.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SettingsService.instance.hasCompletedOnboarding &&
          SettingsService.instance.showTutorialScreens &&
          mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        PrayerService.instance,
        SettingsService.instance,
        KhatmaService.instance,
      ]),
      builder: (context, _) {
        final s = SettingsService.instance;
        final prayerData = PrayerService.instance.currentData;
        final dayName = HijriDateHelper.getDayOfWeek();
        final hijriStr = HijriDateHelper.getHijriDateString();
        final gregStr = HijriDateHelper.getGregorianDateString();

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
              title: Text(context.tr('app_name')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language_rounded),
                  tooltip: context.tr('app_language'),
                  onPressed: () => showSettingsLanguageModal(context),
                ),
                ScreenLayoutPopupButton(
                  currentMode:
                      ScreenStructureMode.fromId(s.screenLayoutMode),
                  onChanged: (_) => setState(() {}),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: context.tr('quran_search'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuranSearchScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. الإشراقة الزمنية الهجرية والميلادية + صفحة الوفاء والدعاء
                HomeDateHeaderCard(
                  dayName: dayName,
                  hijriStr: hijriStr,
                  gregStr: gregStr,
                ),
                const SizedBox(height: 10),
                const HomeMomenMemorialBanner(),
                const SizedBox(height: 20),

                // ================= المحطة الأولى: نداء المحراب ومواقيت النور =================
                _buildSpiritualStationHeader(
                  icon: Icons.mosque_rounded,
                  title: context.tr('home_station_mihrab'),
                  subtitle: context.tr('home_station_mihrab_sub'),
                  iconColor: AppColors.primaryGreen,
                ),
                const SizedBox(height: 10),
                HomeNextPrayerCard(prayerData: prayerData),
                const SizedBox(height: 10),
                const HomePrayerTrackerCard(),
                const SizedBox(height: 22),

                // ================= المحطة الثانية: وردك من كتاب الله =================
                _buildSpiritualStationHeader(
                  icon: Icons.menu_book_rounded,
                  title: context.tr('home_station_quran'),
                  subtitle: context.tr('home_station_quran_sub'),
                  iconColor: AppColors.accentGold,
                ),
                const SizedBox(height: 10),
                const HomeQuranContinueCard(),
                const SizedBox(height: 10),
                const HomeKhatmaCard(),
                const SizedBox(height: 22),

                // ================= المحطة الثالثة: زاد القلب وأذكار الوقت =================
                _buildSpiritualStationHeader(
                  icon: Icons.favorite_rounded,
                  title: context.tr('home_station_adhkar'),
                  subtitle: context.tr('home_station_adhkar_sub'),
                  iconColor: const Color(0xFF1E8260),
                ),
                const SizedBox(height: 10),
                const HomeAdhkarTimeBanner(),
                const SizedBox(height: 10),
                const HomeAdhkarTasbihRow(),
                const SizedBox(height: 22),

                // ================= المحطة الرابعة: مسارات القرب ورياض المعرفة =================
                _buildSpiritualStationHeader(
                  icon: Icons.auto_awesome_rounded,
                  title: context.tr('home_station_pathways'),
                  subtitle: context.tr('home_station_pathways_sub'),
                  iconColor: AppColors.primaryGreen,
                ),
                const SizedBox(height: 10),
                HomeShortcutsList(prayerData: prayerData),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpiritualStationHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
  }) {
    final color = iconColor ?? AppColors.primaryGreen;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
