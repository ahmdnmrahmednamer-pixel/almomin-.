import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/audio/ayah_audio_player.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/surah.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/text/arabic_normalizer.dart';
import '../../core/theme/app_theme.dart';
import '../audio/downloads_manager_screen.dart';
import '../audio/widgets/islamic_audio_player_sheet.dart';
import '../khatma/khatma_screen.dart';
import '../library/screens/quran_sciences_screen.dart';
import '../search/quran_search_screen.dart';
import '../tajweed/tajweed_screen.dart';
import '../topics/quran_topics_screen.dart';
import 'comparative_tafsir_screen.dart';
import 'gharib_quran_screen.dart';
import 'memorization_screen.dart';
import 'page_mode_mushaf_screen.dart';
import 'quran_notes_screen.dart';
import 'surah_reader_screen.dart';
import 'tadabbur_journal_screen.dart';

/// شاشة «رحاب القرآن الكريم» (QuranHubScreen) — منظمة في ٥ أبواب روحانية متناسقة بجميع اللغات الـ ٦
class QuranHubScreen extends StatefulWidget {
  final int initialTabIndex;

  const QuranHubScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<QuranHubScreen> createState() => _QuranHubScreenState();
}

class _QuranHubScreenState extends State<QuranHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  String _surahSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
      vsync: this,
    );
    _loadData();
    IslamicAudioService.instance.init();
    IslamicAudioService.instance.addListener(_onAudioUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    IslamicAudioService.instance.removeListener(_onAudioUpdate);
    super.dispose();
  }

  void _onAudioUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final surahs = await QuranRepository.loadSurahs();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    }
  }

  void _filterSurahs(String q) {
    setState(() {
      _surahSearchQuery = q.trim();
      if (_surahSearchQuery.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        final normQuery =
            ArabicNormalizer.normalize(_surahSearchQuery, loose: true)
                .replaceFirst(RegExp(r'^سوره\s+'), '')
                .trim();
        final lowerQuery = _surahSearchQuery.toLowerCase();
        _filteredSurahs = _surahs.where((s) {
          final idStr = s.id.toString();
          final normAr = ArabicNormalizer.normalize(s.nameAr, loose: true);
          return s.nameAr.contains(_surahSearchQuery) ||
              (normQuery.isNotEmpty && normAr.contains(normQuery)) ||
              s.nameSimple.toLowerCase().contains(lowerQuery) ||
              idStr == _surahSearchQuery;
        }).toList();
      }
    });
  }

  String _toArabicIndic(int num) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num
        .toString()
        .split('')
        .map((d) => arabicDigits[int.tryParse(d) ?? 0])
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final s = SettingsService.instance;
        final lastPage = s.lastReadPageNumber;
        final lastSurah = s.lastReadSurahName;

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
              title: Text(context.tr('holy_quran')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: context.tr('quran_search'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const QuranSearchScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_for_offline_outlined),
                  tooltip: context.tr('download'),
                  onPressed: () => context.push('/downloads'),
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
                        fontWeight: FontWeight.w800, fontSize: 13.5),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        text: context.tr('quran_tab_mushaf'),
                      ),
                      Tab(
                        icon: const Icon(Icons.podcasts_rounded, size: 18),
                        text: context.tr('quran_tab_recitations'),
                      ),
                      Tab(
                        icon: const Icon(Icons.auto_stories_rounded, size: 18),
                        text: context.tr('quran_tab_tafsir'),
                      ),
                      Tab(
                        icon: const Icon(Icons.category_rounded, size: 18),
                        text: context.tr('quran_tab_themes'),
                      ),
                      Tab(
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        text: context.tr('quran_tab_companionship'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))
                : Column(
                    children: [
                      // Quick Resume Hero Banner
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A3D2E), Color(0xFF135A43)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/mushaf-pages?page=$lastPage'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold
                                          .withOpacity(0.22),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.accentGold,
                                          width: 1.5),
                                    ),
                                    child: const Icon(
                                        Icons.auto_stories_rounded,
                                        color: AppColors.softGold,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.tr('last_read'),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'صفحة ${_toArabicIndic(lastPage)} (سورة $lastSurah) • ٦٠٤ صفحات',
                                          style: const TextStyle(
                                              color: AppColors.softGold,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'تلاوة',
                                      style: TextStyle(
                                          color: Color(0xFF07261C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildReadingTab(context, isDark),
                            _buildAudioTab(context, isDark),
                            _buildSearchAndTafsirTab(context, isDark),
                            _buildTopicsTab(context, isDark),
                            _buildToolsTab(context, isDark),
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

  // --- TAB 1: المصحف المرتل ---
  Widget _buildReadingTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: TextField(
            onChanged: _filterSurahs,
            decoration: InputDecoration(
              hintText: 'ابحث باسم السورة الكريمة أو رقمها...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _surahSearchQuery.isNotEmpty
                  ? IconButton(
                    tooltip: 'إغلاق أو مسح',
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _filterSurahs(''),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF13221C)
                  : Colors.grey.withOpacity(0.08),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredSurahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${surah.id}',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                title: Text(
                  'سورة ${surah.nameAr}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15.5),
                ),
                subtitle: Text(
                  '${surah.isMakki ? "مكية" : "مدنية"} • آياتها ${surah.ayahCount} • صفحة ${_toArabicIndic(surah.pageStart)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_stories_outlined,
                          color: AppColors.primaryGreen, size: 20),
                      tooltip: 'صفحات المصحف',
                      onPressed: () => context.push('/mushaf-pages?page=${surah.pageStart}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_align_right_rounded,
                          color: AppColors.accentGold, size: 20),
                      tooltip: 'تلاوة وتفسير وإعراب',
                      onPressed: () => context.push('/surah-reader?surahId=${surah.id}', extra: surah),
                    ),
                  ],
                ),
                onTap: () => context.push('/surah-reader?surahId=${surah.id}', extra: surah),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TAB 2: أصوات الخاشعين ---
  Widget _buildAudioTab(BuildContext context, bool isDark) {
    final availableReciters = SettingsService.availableReciters;
    final currentReciter = SettingsService.instance.currentReciter;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13271F) : const Color(0xFFE9F3ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withOpacity(0.2),
                ),
                child: const Icon(Icons.record_voice_over_rounded,
                    color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('القارئ المفضل للتلاوة:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      currentReciter.nameAr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'الأسلوب: ${currentReciter.style}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.secondaryGreen),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.headphones_rounded,
                    color: AppColors.primaryGreen),
                tooltip: 'المشغل الصوتي',
                onPressed: () => IslamicAudioPlayerSheet.show(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAudioActionCard(
                icon: Icons.download_for_offline_rounded,
                title: 'حفظ السور للاستماع',
                subtitle: 'تلاوة متصلة بدون إنترنت',
                color: const Color(0xFF16A085),
                onTap: () => context.push('/downloads'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAudioActionCard(
                icon: Icons.psychology_rounded,
                title: context.tr('memorization'),
                subtitle: 'تثبيت الحفظ بالتكرار',
                color: const Color(0xFFB8893A),
                onTap: () => context.push('/memorization'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'أصوات القراء الخاشعين (٦١ قارئاً معتمداً):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...availableReciters.map((reciter) {
          final isSelected = reciter.id == currentReciter.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withOpacity(isDark ? 0.25 : 0.12)
                  : (isDark ? const Color(0xFF111D17) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGold
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.person_pin_rounded,
                color:
                    isSelected ? AppColors.accentGold : AppColors.primaryGreen,
              ),
              title: Text(
                reciter.nameAr,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
              subtitle: Text(reciter.style,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              onTap: () async {
                await SettingsService.instance.setSelectedReciter(reciter.id);
                if (!mounted) return;
                setState(() {});
                await AyahAudioPlayer.instance.playReciterPreview(reciter);
              },
              trailing: IconButton(
                tooltip: 'استماع لصوت القارئ',
                icon: const Icon(Icons.volume_up_rounded,
                    color: AppColors.primaryGreen),
                onPressed: () async {
                  await SettingsService.instance.setSelectedReciter(reciter.id);
                  if (!mounted) return;
                  setState(() {});
                  await AyahAudioPlayer.instance.playReciterPreview(reciter);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- TAB 3: بصائر التفسير والبيان ---
  Widget _buildSearchAndTafsirTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolBanner(
          icon: Icons.compare_arrows_rounded,
          title: context.tr('comparative_tafsir'),
          subtitle:
              'مقارنة معاني الآيات في ٩ تفاسير معتمدة مع الإعراب وأسباب النزول',
          color: const Color(0xFF0F5B45),
          isDark: isDark,
          onTap: () => context.push('/comparative-tafsir'),
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.translate_rounded,
          title: context.tr('gharib_quran_dict'),
          subtitle:
              'بيان الكلمات القرآنية وجذورها اللغوية ولطائفها البلاغية واختبار الفهم',
          color: const Color(0xFF1565C0),
          isDark: isDark,
          onTap: () => context.push('/gharib-quran'),
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.menu_book_rounded,
          title: 'علوم القرآن وأسباب النزول ومقاصد السور',
          subtitle: 'أسباب النزول المحققة وفضائل السور والمكي والمدني',
          color: const Color(0xFF8E6C18),
          isDark: isDark,
          onTap: () => context.push('/quran-sciences'),
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.manage_search_rounded,
          title: context.tr('quran_search'),
          subtitle: 'البحث اللحظي بأي كلمة أو جزء من آية في المصحف الشريف',
          color: AppColors.primaryGreen,
          isDark: isDark,
          onTap: () => context.push('/search'),
        ),
      ],
    );
  }

  // --- TAB 4: هدايات الآيات ---
  Widget _buildTopicsTab(BuildContext context, bool isDark) {
    return const QuranTopicsScreen();
  }

  // --- TAB 5: صحبة القرآن والختمات ---
  Widget _buildToolsTab(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToolBanner(
          icon: Icons.event_available_rounded,
          title: context.tr('khatma'),
          subtitle: 'تنظيم الورد اليومي ومتابعة ختمات القرآن الكريم',
          color: AppColors.primaryGreen,
          onTap: () => context.push('/khatma'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.psychology_alt_rounded,
          title: context.tr('tadabbur_journal'),
          subtitle: 'تدوين الرسالة الإيمانية والعمل التطبيقي والدعاء من الآيات',
          color: const Color(0xFF1565C0),
          onTap: () => context.push('/tadabbur-journal'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.palette_rounded,
          title: context.tr('tajweed_rules'),
          subtitle: 'مخارج الحروف وأحكام النون والميم والمدود بالأمثلة',
          color: const Color(0xFF16A085),
          onTap: () => context.push('/tajweed'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.psychology_rounded,
          title: context.tr('memorization'),
          subtitle: 'تكرار الآيات الكريمة وتثبيت المحفوظ ومراجعته',
          color: const Color(0xFF2E7D32),
          onTap: () => context.push('/memorization'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildToolBanner(
          icon: Icons.edit_note_rounded,
          title: context.tr('quran_notes'),
          subtitle: 'حفظ الخواطر والفوائد الإيمانية حول آيات الكتاب العزيز',
          color: const Color(0xFFB8860B),
          onTap: () => context.push('/notes'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAudioActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101F18) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
