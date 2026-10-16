import 'package:flutter/material.dart';
import '../../core/models/surah.dart';
import '../../core/models/juz.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../search/quran_search_screen.dart';
import 'surah_reader_screen.dart';
import 'page_mode_mushaf_screen.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  List<Juz> _juzList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final surahs = await QuranRepository.loadSurahs();
    final juz = await QuranRepository.loadJuz();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _juzList = juz;
        _isLoading = false;
      });
    }
  }

  void _filterSurahs(String q) {
    setState(() {
      _searchQuery = q.trim();
      if (_searchQuery.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((s) {
          return s.nameAr.contains(_searchQuery) ||
                 s.nameSimple.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 s.id.toString() == _searchQuery;
        }).toList();
      }
    });
  }

  String _toArabicIndic(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصحف الشريف'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_stories_rounded),
              tooltip: 'فتح المصحف بالصفحات الكاملة (604)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageModeMushafScreen(
                      initialPage: SettingsService.instance.lastReadPageNumber,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'البحث القرآني السريع',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuranSearchScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.accentGold,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'السور (١١٤)'),
              Tab(text: 'الأجزاء (٣٠)'),
              Tab(text: 'صفحات المصحف (٦٠٤)'),
              Tab(text: 'العلامات المرجعية'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : Column(
                children: [
                  // Prominent Banner to Open 604 Pages Reader Mode
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PageModeMushafScreen(
                              initialPage: SettingsService.instance.lastReadPageNumber,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: AppColors.softGold, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'عرض صفحات المصحف الشريف (٦٠٤ صفحات)',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'متابعة من صفحة ${SettingsService.instance.lastReadPageNumber} (سورة ${SettingsService.instance.lastReadSurahName})',
                                    style: const TextStyle(color: AppColors.softGold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.softGold, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Surahs list (114)
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              child: TextField(
                                onChanged: _filterSurahs,
                                decoration: InputDecoration(
                                  hintText: 'ابحث باسم السورة أو رقمها...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.06),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _filteredSurahs.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final surah = _filteredSurahs[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primaryGreen.withOpacity(0.08),
                                      child: Text(
                                        '${surah.id}',
                                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text('سورة ${surah.nameAr}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Text(
                                      '${surah.isMakki ? "مكية" : "مدنية"} — آياتها ${surah.ayahCount} — صفحة ${surah.pageStart}',
                                      style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.auto_stories, color: AppColors.primaryGreen, size: 20),
                                          tooltip: 'فتح بالصفحات المصحفية',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PageModeMushafScreen(initialPage: surah.pageStart),
                                              ),
                                            );
                                          },
                                        ),
                                        const Icon(Icons.arrow_forward_ios, size: 14),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SurahReaderScreen(surah: surah),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        // Tab 2: Juz list (30)
                        ListView.separated(
                          itemCount: _juzList.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final juz = _juzList[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondaryGreen.withOpacity(0.1),
                                child: Text(
                                  '${juz.id}',
                                  style: const TextStyle(color: AppColors.secondaryGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text('الجزء ${juz.id} (${juz.nameAr})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('صفحة ${juz.pageStart} — بداية السورة رقم ${juz.startSurah}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.auto_stories, color: AppColors.secondaryGreen, size: 20),
                                    tooltip: 'فتح بالصفحات',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PageModeMushafScreen(initialPage: juz.pageStart),
                                        ),
                                      );
                                    },
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14),
                                ],
                              ),
                              onTap: () async {
                                final surah = await QuranRepository.getSurahById(juz.startSurah);
                                if (mounted && surah != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurahReaderScreen(surah: surah, initialAyah: juz.startAyah),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),

                        // Tab 3: Pages (1 to 604)
                        ListView.builder(
                          itemCount: 604,
                          itemBuilder: (context, index) {
                            final pageNum = index + 1;
                            return FutureBuilder<PageMetadata?>(
                              future: QuranRepository.getPageMetadata(pageNum),
                              builder: (context, snap) {
                                final meta = snap.data;
                                final surahName = meta?.surahName ?? '...';
                                final juz = meta?.juzNumber ?? 1;

                                return ListTile(
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.accentGold),
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.accentGold.withOpacity(0.08),
                                    ),
                                    child: Text(
                                      _toArabicIndic(pageNum),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                    ),
                                  ),
                                  title: Text('صفحة ${_toArabicIndic(pageNum)} — سورة $surahName', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('الجزء ${_toArabicIndic(juz)}'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PageModeMushafScreen(initialPage: pageNum),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),

                        // Tab 4: Real Saved Bookmarks
                        AnimatedBuilder(
                          animation: SettingsService.instance,
                          builder: (context, _) {
                            final bookmarks = SettingsService.instance.bookmarks;
                            if (bookmarks.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey.withOpacity(0.4)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'لا توجد علامات مرجعية محفوظة بعد',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'اضغط على أيقونة الإشارة المرجعية أثناء القراءة لحفظ الآية هنا',
                                      style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return FutureBuilder<List<BookmarkDetail>>(
                              future: QuranRepository.getBookmarksDetails(bookmarks),
                              builder: (context, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final details = snap.data ?? [];
                                if (details.isEmpty) {
                                  return const Center(child: Text('جاري تحميل العلامات...'));
                                }

                                return ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: details.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final b = details[index];
                                    return Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      child: ListTile(
                                        leading: const Icon(Icons.bookmark, color: AppColors.accentGold, size: 30),
                                        title: Text('سورة ${b.surahName} — الآية ${_toArabicIndic(b.ayahNumber)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                          '${b.textSnippet}\nصفحة ${_toArabicIndic(b.pageNumber)}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () async {
                                            await SettingsService.instance.toggleBookmark(b.surahId, b.ayahNumber);
                                          },
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PageModeMushafScreen(initialPage: b.pageNumber),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
