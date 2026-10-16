import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/mushaf/mushaf_screen.dart';
import '../features/mushaf/page_mode_mushaf_screen.dart';
import '../features/audio/audio_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/adhkar/adhkar_screen.dart';
import '../features/adhkar/tasbih_screen.dart';
import '../features/prayer/qibla_compass_screen.dart';
import '../features/prayer/hijri_calendar_screen.dart';
import '../features/prayer/battery_reliability_screen.dart';
import '../features/khatma/khatma_screen.dart';
import '../features/search/quran_search_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/backup/backup_restore_screen.dart';
import '../features/prayer/prayer_tracker_screen.dart';
import '../features/audio/downloads_manager_screen.dart';
import '../features/mushaf/quran_notes_screen.dart';
import '../features/mushaf/memorization_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/mushaf');
        break;
      case 2:
        context.go('/audio');
        break;
      case 3:
        context.go('/prayer');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'المصحف'),
            BottomNavigationBarItem(icon: Icon(Icons.headphones_outlined), activeIcon: Icon(Icons.headphones), label: 'الاستماع'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time_outlined), activeIcon: Icon(Icons.access_time_filled), label: 'العبادات'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/mushaf', builder: (context, state) => const MushafScreen()),
        GoRoute(path: '/audio', builder: (context, state) => const AudioScreen()),
        GoRoute(path: '/prayer', builder: (context, state) => const PrayerScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(
          path: '/adhkar',
          builder: (context, state) {
            final categoryIndex = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
            return AdhkarScreen(initialCategoryIndex: categoryIndex);
          },
        ),
        GoRoute(path: '/tasbih', builder: (context, state) => const TasbihScreen()),
        GoRoute(path: '/qibla', builder: (context, state) => const QiblaCompassScreen()),
        GoRoute(path: '/calendar', builder: (context, state) => const HijriCalendarScreen()),
        GoRoute(path: '/khatma', builder: (context, state) => const KhatmaScreen()),
        GoRoute(path: '/battery-guide', builder: (context, state) => const BatteryReliabilityScreen()),
        GoRoute(path: '/backup', builder: (context, state) => const BackupRestoreScreen()),
        GoRoute(path: '/prayer-tracker', builder: (context, state) => const PrayerTrackerScreen()),
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
      ],
    ),
  ],
);
