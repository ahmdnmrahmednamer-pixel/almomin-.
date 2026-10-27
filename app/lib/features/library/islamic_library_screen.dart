import 'package:flutter/material.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/daily_wird_service.dart';
import '../../core/services/fiqh_library_service.dart';
import '../../core/services/hadith_service.dart';
import '../../core/services/ramadan_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/stories_service.dart';
import '../../core/services/zakat_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/adaptive_screen_layouts.dart';
import '../hadith/hadith_detail_screen.dart';
import '../hadith/hadith_library_screen.dart';
import '../prayer/voluntary_fasting_screen.dart';
import '../ramadan/ramadan_screen.dart';
import '../stories/story_detail_screen.dart';
import '../zakat/kaffarah_fidyah_screen.dart';
import '../zakat/mawarith_calculator_screen.dart';
import '../zakat/zakat_screen.dart';
import 'screens/unified_library_search_screen.dart';
import 'widgets/comprehensive_libraries_portal.dart';

/// شاشة «رياض العلم والهدي النبوي» (IslamicLibraryScreen) — منظمة بصفاء وروحانية بجميع اللغات الـ ٦
class IslamicLibraryScreen extends StatefulWidget {
  final int initialTabIndex;

  const IslamicLibraryScreen({super.key, this.initialTabIndex = 0});

  @override
  State<IslamicLibraryScreen> createState() => _IslamicLibraryScreenState();
}

class _IslamicLibraryScreenState extends State<IslamicLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _hadithSearchController = TextEditingController();
  String _hadithSearchQuery = '';
  ScreenStructureMode _layoutMode = ScreenStructureMode.classic;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
      vsync: this,
    );
    _layoutMode =
        ScreenStructureMode.fromId(SettingsService.instance.screenLayoutMode);
    FiqhLibraryService.instance.init();
    DailyWirdService.instance.init();
    HadithService.instance.init();
    StoriesService.instance.init();
    RamadanService.instance.init();
    ZakatService.instance.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hadithSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final s = SettingsService.instance;

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
              title: Text(
                context.tr('islamic_library'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  tooltip: context.tr('search'),
                  icon: const Icon(Icons.manage_search_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UnifiedLibrarySearchScreen()),
                    );
                  },
                ),
                ScreenLayoutPopupButton(
                  currentMode: _layoutMode,
                  onChanged: (m) => setState(() {
                    _layoutMode = m;
                    if (_tabController.length > 0) _tabController.animateTo(0.clamp(0, _tabController.length - 1));
                  }),
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
                        icon: const Icon(Icons.library_books_rounded, size: 18),
                        text: context.tr('lib_tab_gardens'),
                      ),
                      Tab(
                        icon: const Icon(Icons.auto_stories_rounded, size: 18),
                        text: context.tr('lib_tab_hadith'),
                      ),
                      Tab(
                        icon: const Icon(Icons.record_voice_over_rounded,
                            size: 18),
                        text: context.tr('lib_tab_stories'),
                      ),
                      Tab(
                        icon: const Icon(Icons.nightlight_round, size: 18),
                        text: context.tr('lib_tab_seasons'),
                      ),
                      Tab(
                        icon: const Icon(Icons.calculate_rounded, size: 18),
                        text: context.tr('lib_tab_zakat'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: رياض المعرفة الشاملة (5 Spiritual Gardens)
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ComprehensiveLibrariesPortal(
                      layoutMode: _layoutMode,
                      onModeChanged: (m) {
                        SettingsService.instance.setScreenLayoutMode(m.id);
                        setState(() => _layoutMode = m);
                      },
                    ),
                  ],
                ),

                // TAB 2: مشكاة الحديث النبوي
                _buildHadithTab(context, isDark),

                // TAB 3: قصص الوحي والأنبياء
                _buildStoriesTab(context, isDark),

                // TAB 4: نفحات رمضان والريّان
                _buildRamadanAndFastingTab(context, isDark),

                // TAB 5: طُهرة المال والفرائض
                _buildZakatAndFaraidTab(context, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHadithTab(BuildContext context, bool isDark) {
    final books = HadithService.instance.books;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _hadithSearchController,
          onChanged: (val) => setState(() => _hadithSearchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'ابحث في نصوص الأحاديث النبوية الشريفة...',
            prefixIcon: const Icon(Icons.search_rounded,
                size: 20, color: AppColors.primaryGreen),
            filled: true,
            fillColor: isDark ? const Color(0xFF1B231D) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_hadithSearchQuery.isNotEmpty) ...[
          ...HadithService.instance
              .searchHadiths(_hadithSearchQuery)
              .map((hadith) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                title: Text(hadith.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(hadith.matn,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HadithDetailScreen(hadithId: hadith.id)),
                  );
                },
              ),
            );
          }),
        ],
        ...books.map((book) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.primaryGreen, size: 24),
              ),
              title: Text(
                book.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              subtitle: Text(
                '${book.hadithCount} حديثاً نبوياً مسنداً مع الشرح والتخريج',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HadithLibraryScreen(initialBookId: book.id),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStoriesTab(BuildContext context, bool isDark) {
    final stories = StoriesService.instance.getAllStories();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...stories.map((story) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentGold.withOpacity(0.15),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.accentGold),
              ),
              title: Text(
                story.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              subtitle: Text(
                'المدة: ${story.duration} • ${story.narrator}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(story: story),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRamadanAndFastingTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF0F5B45),
              child: Icon(Icons.nightlight_round, color: AppColors.accentGold),
            ),
            title: Text(
              context.tr('ramadan_hub'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
                'إمساكية الشهر الفضيل وأوراد الأيام الثلاثين وأدعية الصيام'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RamadanScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFB88917),
              child: Icon(Icons.wb_twilight_rounded, color: Colors.white),
            ),
            title: Text(
              context.tr('voluntary_fasting'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
                'صيام الإثنين والخميس، الأيام البيض، الست من شوال، عرفة وعاشوراء'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoluntaryFastingScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZakatAndFaraidTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF27AE60),
              child: Icon(Icons.calculate_rounded, color: Colors.white),
            ),
            title: Text(
              context.tr('zakat_calculator'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle:
                const Text('حساب زكاة المال والذهب والفضة وعروض التجارة'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ZakatScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF0F5B45),
              child:
                  Icon(Icons.volunteer_activism_rounded, color: Colors.white),
            ),
            title: Text(
              context.tr('kaffarah_fidyah_calc'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
                'زكاة الفطر بالصاع والنقد، وفدية الصيام، وكفارة اليمين'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KaffarahFidyahScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF8E6C18),
              child: Icon(Icons.balance_rounded, color: Colors.white),
            ),
            title: Text(
              context.tr('mawarith_calc'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
                'تقسيم الفرائض والتركات بالأدلة القرآنية من سورة النساء'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MawarithCalculatorScreen()),
            ),
          ),
        ),
      ],
    );
  }
}
