import 'package:flutter/material.dart';
import '../../core/models/surah.dart';
import '../../core/models/juz.dart';
import '../../core/services/quran_repository.dart';
import '../../core/theme/app_theme.dart';
import '../search/quran_search_screen.dart';
import 'surah_reader_screen.dart';

class MushafScreen extends StatefulWidget {
  const MushafScreen({super.key});

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Surah> _surahs = [];
  List<Juz> _juzList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final surahs = await QuranRepository.loadSurahs();
    final juz = await QuranRepository.loadJuz();
    if (mounted) {
      setState(() {
        _surahs = surahs;
        _juzList = juz;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف الشريف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
          indicatorColor: AppColors.accentGold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'السور (114)'),
            Tab(text: 'الأجزاء (30)'),
            Tab(text: 'العلامات المرجعية'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Surahs list (114)
                  ListView.separated(
                    itemCount: _surahs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final surah = _surahs[index];
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
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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

                  // Tab 3: Bookmarks list
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: const Icon(Icons.bookmark, color: AppColors.accentGold, size: 32),
                          title: const Text('آخر موضع قراءة (صفحة 2)', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('سورة البقرة — آية 1'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () async {
                            final surah = await QuranRepository.getSurahById(2);
                            if (mounted && surah != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SurahReaderScreen(surah: surah)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
