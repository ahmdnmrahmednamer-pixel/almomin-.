import '../../core/text/arabic_normalizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import 'adhkar_screen.dart';
import 'spiritual_mood_remedy_screen.dart';
import 'tasbih_screen.dart';
import 'widgets/sharawi_post_prayer_card.dart';

/// شاشة «أُنس الذاكرين وسكينة القلوب» (AdhkarHubScreen) — منظمة في ٤ أبواب روحانية بجميع اللغات الـ ٦
class AdhkarHubScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdhkarHubScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdhkarHubScreen> createState() => _AdhkarHubScreenState();
}

class _AdhkarHubScreenState extends State<AdhkarHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
      vsync: this,
    );
    AdhkarService.instance.init();
    AdhkarService.instance.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    AdhkarService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = AdhkarService.instance.categories;

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
                context.tr('adhkar_hub'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_rounded),
                  tooltip: context.tr('spiritual_mood_remedy'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SpiritualMoodRemedyScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fingerprint_rounded),
                  tooltip: context.tr('electronic_tasbih'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TasbihScreen()),
                    );
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
                        icon: const Icon(Icons.wb_sunny_rounded, size: 18),
                        text: context.tr('adhkar_tab_daily'),
                      ),
                      Tab(
                        icon: const Icon(Icons.fingerprint_rounded, size: 18),
                        text: context.tr('adhkar_tab_tasbih'),
                      ),
                      Tab(
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        text: context.tr('adhkar_tab_healing'),
                      ),
                      Tab(
                        icon: const Icon(Icons.auto_stories_rounded, size: 18),
                        text: context.tr('adhkar_tab_fortress'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: أوراد طرفي النهار
                _buildDailyAdhkarTab(context, isDark, categories),

                // TAB 2: مسبحة الأُنس
                _buildIntegratedTasbihTab(context, isDark),

                // TAB 3: طِبّ القلوب والرقية
                _buildRuqyahAndHealingTab(context, isDark),

                // TAB 4: حصن المؤمن الجامع
                _buildHisnMuslimTab(context, isDark, categories),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyAdhkarTab(
      BuildContext context, bool isDark, List<dynamic> categories) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withOpacity(0.22),
                  border: Border.all(color: AppColors.accentGold, width: 2),
                ),
                child: const Icon(Icons.fingerprint_rounded,
                    color: AppColors.softGold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('electronic_tasbih'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'سليدر الحبات التفاعلي والتسبيح بزر رفع الصوت (+١)',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: const Color(0xFF07261C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TasbihScreen()),
                  );
                },
                child: const Text('فتح المسبحة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SharawiPostPrayerDuaaCard(isDark: isDark),
        const SizedBox(height: 14),
        ...categories.asMap().entries.where((entry) {
          final t = entry.value.title;
          return t.contains('الصباح') ||
              t.contains('المساء') ||
              t.contains('الصلاة') ||
              t.contains('النوم') ||
              t.contains('الاستيقاظ');
        }).map((entry) =>
            _buildCategoryTile(context, entry.key, entry.value, isDark)),
      ],
    );
  }

  Widget _buildHisnMuslimTab(
      BuildContext context, bool isDark, List<dynamic> categories) {
    final normQ = ArabicNormalizer.normalize(_searchQuery, loose: true);
    final filtered = categories.asMap().entries.where((e) {
      if (_searchQuery.isEmpty) return true;
      final title = e.value.title.toString();
      return title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ArabicNormalizer.normalize(title, loose: true).contains(normQ);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            hintText: 'ابحث في أبواب حصن المؤمن والأدعية النبوية...',
            prefixIcon: const Icon(Icons.search_rounded,
                size: 20, color: AppColors.primaryGreen),
            filled: true,
            fillColor: isDark ? const Color(0xFF1B231D) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...filtered.map((entry) =>
            _buildCategoryTile(context, entry.key, entry.value, isDark)),
      ],
    );
  }

  Widget _buildIntegratedTasbihTab(BuildContext context, bool isDark) {
    final s = AdhkarService.instance;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132019) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                s.selectedTasbihPhrase,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Amiri',
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: AdhkarService.famousTasbihPhrases.take(4).map((p) {
                  final isSelected = p == s.selectedTasbihPhrase;
                  return ChoiceChip(
                    label: Text(p, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87)),
                    onSelected: (selected) {
                      if (selected) s.setSelectedTasbihPhrase(p);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () {
              s.incrementTasbih();
              if (s.hapticEnabled) HapticFeedback.selectionClick();
            },
            child: Container(
              width: 195,
              height: 195,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F5B45), const Color(0xFF072B20)]
                      : [AppColors.primaryGreen, const Color(0xFF0B4633)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${s.tasbihCount}',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'الورد: ${s.tasbihTarget}',
                      style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('reset')),
              onPressed: () => s.resetTasbih(),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.open_in_full_rounded),
              label: Text(context.tr('electronic_tasbih')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasbihScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuqyahAndHealingTab(BuildContext context, bool isDark) {
    final categories = AdhkarService.instance.categories;
    final ruqyahIndex = categories.indexWhere((c) => c.id == 'ruqyah');
    final targetIndex = ruqyahIndex >= 0 ? ruqyahIndex : 0;
    final ruqyahAndDuaEntries = categories
        .asMap()
        .entries
        .where((e) => const [
              'ruqyah',
              'distress_relief',
              'duas',
              'quran_duas'
            ].contains(e.value.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Spiritual Mood & Heart Remedy Featured Card
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF0F5B45),
              child: Icon(Icons.favorite_rounded, color: AppColors.accentGold),
            ),
            title: Text(
              context.tr('spiritual_mood_remedy'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
              'اختر ما يشعر به قلبك الآن (القلق، الحزن، ضيق الرزق، التوبة) لتقرأ الآية الشافية والدعاء النبوي',
              style: TextStyle(fontSize: 12.5),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SpiritualMoodRemedyScreen()),
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
              child: Icon(Icons.shield_moon_rounded, color: Colors.white),
            ),
            title: Text(
              context.tr('ruqyah'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
            ),
            subtitle: const Text(
              'آيات السكينة والشفاء والحفظ من القرآن الكريم والسنة المطهرة',
              style: TextStyle(fontSize: 12.5),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AdhkarScreen(initialCategoryIndex: targetIndex)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...ruqyahAndDuaEntries.map((entry) =>
            _buildCategoryTile(context, entry.key, entry.value, isDark)),
      ],
    );
  }

  Widget _buildCategoryTile(
      BuildContext context, int idx, dynamic cat, bool isDark) {
    IconData iconData = Icons.auto_awesome_rounded;
    Color catColor = AppColors.primaryGreen;

    if (cat.title.contains('الصباح')) {
      iconData = Icons.wb_sunny_rounded;
      catColor = const Color(0xFFD97706);
    } else if (cat.title.contains('المساء')) {
      iconData = Icons.nights_stay_rounded;
      catColor = const Color(0xFF4F46E5);
    } else if (cat.title.contains('النوم')) {
      iconData = Icons.bedtime_rounded;
      catColor = const Color(0xFF6366F1);
    } else if (cat.title.contains('الصلاة')) {
      iconData = Icons.mosque_rounded;
      catColor = const Color(0xFF059669);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112019) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catColor.withOpacity(0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: catColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(iconData, color: catColor, size: 22),
        ),
        title: Text(
          cat.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${cat.items.length} ذكراً مأثوراً بالفضل والعدد',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdhkarScreen(initialCategoryIndex: idx),
            ),
          );
        },
      ),
    );
  }
}
