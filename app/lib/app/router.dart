import '../features/library/screens/riyad_alsalihin_screen.dart';
import '../features/prayer/sunan_rawatib_screen.dart';
import '../features/library/screens/islamic_mutoon_screen.dart';
import '../features/zakat/mawarith_calculator_screen.dart';
import '../features/mushaf/tadabbur_journal_screen.dart';
import '../features/audio/scholars_audio_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/localization/app_localizations.dart';
import '../core/models/quran_topic.dart';
import '../core/services/settings_service.dart';
import '../core/theme/app_theme.dart';
import '../features/adhkar/adhkar_hub_screen.dart';
import '../features/adhkar/adhkar_screen.dart';
import '../features/adhkar/spiritual_mood_remedy_screen.dart';
import '../features/adhkar/tasbih_screen.dart';
import '../features/audio/audio_screen.dart';
import '../features/audio/downloads_manager_screen.dart';
import '../features/audio/widgets/global_mini_player_bar.dart';
import '../features/backup/backup_restore_screen.dart';
import '../features/egypt/egyptian_heritage_screen.dart';
import '../features/hadith/hadith_detail_screen.dart';
import '../features/hadith/hadith_library_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/momen_duaa_screen.dart';
import '../features/khatma/khatma_screen.dart';
import '../features/library/islamic_library_screen.dart';
import '../features/library/screens/asma_allah_shamail_screen.dart';
import '../features/library/screens/fiqh_library_screen.dart';
import '../features/library/screens/hajj_umrah_companion_screen.dart';
import '../features/library/screens/islamic_history_screen.dart';
import '../features/library/screens/quran_sciences_screen.dart';
import '../features/library/screens/unified_library_search_screen.dart';
import '../features/mushaf/gharib_quran_screen.dart';
import '../features/mushaf/memorization_screen.dart';
import '../features/mushaf/mushaf_screen.dart';
import '../features/mushaf/page_mode_mushaf_screen.dart';
import '../features/mushaf/quran_hub_screen.dart';
import '../features/mushaf/quran_notes_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/prayer/adhan_control_screen.dart';
import '../features/prayer/battery_reliability_screen.dart';
import '../features/prayer/fajr_qiyam_alarm_screen.dart';
import '../features/prayer/hijri_calendar_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/prayer/prayer_tracker_screen.dart';
import '../features/prayer/qibla_compass_screen.dart';
import '../features/prayer/voluntary_fasting_screen.dart';
import '../features/ramadan/ramadan_screen.dart';
import '../features/search/quran_search_screen.dart';
import '../features/settings/contact_support_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stories/stories_screen.dart';
import '../features/studio/daawah_card_studio_screen.dart';
import '../features/tajweed/tajweed_screen.dart';
import '../features/topics/quran_topics_screen.dart';
import '../features/topics/topic_detail_screen.dart';
import '../features/wird/daily_wird_screen.dart';
import '../features/zakat/kaffarah_fidyah_screen.dart';
import '../features/zakat/zakat_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _rootNavigatorKey = rootNavigatorKey;

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  String _safeLocation(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.path;
    } catch (_) {
      return '/home';
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = _safeLocation(context);
    if (location.startsWith('/mushaf') ||
        location.startsWith('/quran-hub') ||
        location.startsWith('/mushaf-reader') ||
        location.startsWith('/mushaf-pages') ||
        location.startsWith('/audio') ||
        location.startsWith('/scholars-audio') ||
        location.startsWith('/notes') ||
        location.startsWith('/memorization') ||
        location.startsWith('/topics') ||
        location.startsWith('/topic-detail') ||
        location.startsWith('/search') ||
        location.startsWith('/khatma') ||
        location.startsWith('/gharib-quran') ||
        location.startsWith('/tajweed')) {
      return 1;
    }
    if (location.startsWith('/prayer') ||
        location.startsWith('/adhan-control') ||
        location.startsWith('/qibla') ||
        location.startsWith('/calendar') ||
        location.startsWith('/prayer-tracker') ||
        location.startsWith('/fajr-qiyam-alarm') ||
        location.startsWith('/voluntary-fasting') ||
        location.startsWith('/battery-guide')) {
      return 2;
    }
    if (location.startsWith('/adhkar') ||
        location.startsWith('/adhkar-hub') ||
        location.startsWith('/spiritual-mood') ||
        location.startsWith('/tasbih')) {
      return 3;
    }
    if (location.startsWith('/library') ||
        location.startsWith('/hadith') ||
        location.startsWith('/hadith-detail') ||
        location.startsWith('/stories') ||
        location.startsWith('/ramadan') ||
        location.startsWith('/zakat') ||
        location.startsWith('/kaffarah-fidyah') ||
        location.startsWith('/hajj-umrah') ||
        location.startsWith('/downloads') ||
        location.startsWith('/egypt-heritage') ||
        location.startsWith('/fiqh-library') ||
        location.startsWith('/quran-sciences') ||
        location.startsWith('/asma-shamail') ||
        location.startsWith('/islamic-history') ||
        location.startsWith('/library-search') ||
        location.startsWith('/daily-wird') ||
        location.startsWith('/daawah-studio')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/mushaf');
        break;
      case 2:
        context.go('/prayer');
        break;
      case 3:
        context.go('/adhkar-hub');
        break;
      case 4:
        context.go('/library');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = _safeLocation(context);
    final isSettingsOrSub = location.startsWith('/settings') ||
        location.startsWith('/backup') ||
        location.startsWith('/support');

    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: isSettingsOrSub
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlobalMiniPlayerBar(),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GlobalMiniPlayerBar(),
                    Directionality(
                      textDirection: SettingsService.instance.textDirection,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111A14) : Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? const Color(0xFF1E3126)
                                  : const Color(0xFFE2EBE5),
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: NavigationBar(
                          selectedIndex: selectedIndex,
                          onDestinationSelected: (index) =>
                              _onItemTapped(index, context),
                          height: 70,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          indicatorColor: AppColors.primaryGreen
                              .withOpacity(isDark ? 0.28 : 0.15),
                          labelBehavior:
                              NavigationDestinationLabelBehavior.alwaysShow,
                          destinations: [
                            NavigationDestination(
                              icon: const Icon(Icons.home_outlined),
                              selectedIcon: const Icon(Icons.home_rounded,
                                  color: AppColors.primaryGreen),
                              label: context.tr('nav_home'),
                              tooltip: context.tr('tooltip_home'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.menu_book_outlined),
                              selectedIcon: const Icon(Icons.menu_book_rounded,
                                  color: AppColors.primaryGreen),
                              label: context.tr('nav_quran'),
                              tooltip: context.tr('tooltip_quran'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.access_time_outlined),
                              selectedIcon: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: AppColors.primaryGreen),
                              label: context.tr('nav_prayer'),
                              tooltip: context.tr('tooltip_prayer'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.fingerprint_outlined),
                              selectedIcon: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppColors.primaryGreen),
                              label: context.tr('nav_adhkar'),
                              tooltip: context.tr('tooltip_adhkar'),
                            ),
                            NavigationDestination(
                              icon: const Icon(Icons.auto_stories_outlined),
                              selectedIcon: const Icon(
                                  Icons.auto_stories_rounded,
                                  color: AppColors.primaryGreen),
                              label: context.tr('nav_library'),
                              tooltip: context.tr('tooltip_library'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/momen-duaa',
  routes: [
    GoRoute(
      path: '/momen-duaa',
      builder: (context, state) => const MomenDuaaScreen(),
    ),
    GoRoute(
      path: '/duaa',
      builder: (context, state) => const MomenDuaaScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/adhan-control',
      builder: (context, state) {
        final prayer = state.uri.queryParameters['prayer'] ?? 'الظهر';
        final isIqamah = state.uri.queryParameters['isIqamah'] == 'true';
        final autoPlay = state.uri.queryParameters['autoPlay'] != 'false';
        return AdhanControlScreen(
          prayerName: prayer,
          isIqamah: isIqamah,
          autoPlay: autoPlay,
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/mushaf', builder: (context, state) => const QuranHubScreen()),
        GoRoute(path: '/quran-hub', builder: (context, state) => const QuranHubScreen()),
        GoRoute(path: '/adhkar-hub', builder: (context, state) => const AdhkarHubScreen()),
        GoRoute(path: '/mushaf-reader', builder: (context, state) => const MushafScreen()),
        GoRoute(path: '/audio', builder: (context, state) => const AudioScreen()),
        GoRoute(path: '/scholars-audio', builder: (context, state) => const ScholarsAudioLibraryScreen()),
        GoRoute(path: '/prayer', builder: (context, state) => const PrayerScreen()),
        GoRoute(path: '/library', builder: (context, state) => const IslamicLibraryScreen()),
        GoRoute(path: '/egypt-heritage', builder: (context, state) => const EgyptianHeritageScreen()),
        GoRoute(path: '/fiqh-library', builder: (context, state) => const FiqhLibraryScreen()),
        GoRoute(path: '/quran-sciences', builder: (context, state) => const QuranSciencesScreen()),
        GoRoute(path: '/asma-shamail', builder: (context, state) => const AsmaAllahShamailScreen()),
        GoRoute(path: '/islamic-history', builder: (context, state) => const IslamicHistoryScreen()),
        GoRoute(path: '/library-search', builder: (context, state) => const UnifiedLibrarySearchScreen()),
        GoRoute(path: '/daily-wird', builder: (context, state) => const DailyWirdScreen()),
        GoRoute(path: '/daawah-studio', builder: (context, state) => const DaawahCardStudioScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/ramadan', builder: (context, state) => const RamadanScreen()),
        GoRoute(path: '/stories', builder: (context, state) => const StoriesScreen()),
        GoRoute(path: '/tajweed', builder: (context, state) => const TajweedScreen()),
        GoRoute(path: '/hajj-umrah', builder: (context, state) => const HajjUmrahCompanionScreen()),
        GoRoute(path: '/voluntary-fasting', builder: (context, state) => const VoluntaryFastingScreen()),
        GoRoute(path: '/spiritual-mood', builder: (context, state) => const SpiritualMoodRemedyScreen()),
        GoRoute(path: '/gharib-quran', builder: (context, state) => const GharibQuranScreen()),
        GoRoute(path: '/kaffarah-fidyah', builder: (context, state) => const KaffarahFidyahScreen()),
        GoRoute(
          path: '/adhkar',
          builder: (context, state) {
            final indexParam = state.uri.queryParameters['index'];
            if (indexParam != null) {
              final categoryIndex = int.tryParse(indexParam) ?? 0;
              return AdhkarScreen(initialCategoryIndex: categoryIndex);
            }
            return const AdhkarHubScreen();
          },
        ),
        GoRoute(path: '/tasbih', builder: (context, state) => const TasbihScreen()),
        GoRoute(path: '/qibla', builder: (context, state) => const QiblaCompassScreen()),
        GoRoute(path: '/calendar', builder: (context, state) => const HijriCalendarScreen()),
        GoRoute(path: '/khatma', builder: (context, state) => const KhatmaScreen()),
        GoRoute(path: '/battery-guide', builder: (context, state) => const BatteryReliabilityScreen()),
        GoRoute(path: '/backup', builder: (context, state) => const BackupRestoreScreen()),
        GoRoute(path: '/prayer-tracker', builder: (context, state) => const PrayerTrackerScreen()),
        GoRoute(path: '/fajr-qiyam-alarm', builder: (context, state) => const FajrQiyamAlarmScreen()),
        GoRoute(path: '/downloads', builder: (context, state) => const DownloadsManagerScreen()),
        GoRoute(path: '/notes', builder: (context, state) => const QuranNotesScreen()),
        GoRoute(
          path: '/memorization',
          builder: (context, state) {
            final surahId = int.tryParse(state.uri.queryParameters['surahId'] ?? '1') ?? 1;
            final fromAyah = int.tryParse(state.uri.queryParameters['fromAyah'] ?? '1') ?? 1;
            final toAyah = int.tryParse(state.uri.queryParameters['toAyah'] ?? '7') ?? 7;
            return MemorizationScreen(
              initialSurahId: surahId,
              initialFromAyah: fromAyah,
              initialToAyah: toAyah,
            );
          },
        ),
        GoRoute(path: '/zakat', builder: (context, state) => const ZakatScreen()),
        GoRoute(
          path: '/hadith',
          builder: (context, state) {
            final bookId = state.uri.queryParameters['bookId'];
            return HadithLibraryScreen(initialBookId: bookId);
          },
        ),
        GoRoute(
          path: '/hadith-detail',
          builder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '1') ?? 1;
            return HadithDetailScreen(hadithId: id);
          },
        ),
        GoRoute(
          path: '/topics',
          builder: (context, state) {
            final catStr = state.uri.queryParameters['category'];
            TopicCategory? cat;
            if (catStr != null) {
              try {
                cat = TopicCategory.values.firstWhere((c) => c.name == catStr, orElse: () => TopicCategory.values.first);
              } catch (_) {}
            }
            return QuranTopicsScreen(initialCategory: cat);
          },
        ),
        GoRoute(
          path: '/topic-detail',
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'patience';
            return TopicDetailScreen(topicId: id);
          },
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final q = state.uri.queryParameters['q'];
            return QuranSearchScreen(initialQuery: q);
          },
        ),
        GoRoute(
          path: '/mushaf-pages',
          builder: (context, state) {
            final page = int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
            return PageModeMushafScreen(initialPage: page);
          },
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const ContactSupportScreen(),
        ),
      ],
    ),
  ],
);
