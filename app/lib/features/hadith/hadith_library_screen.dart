import 'package:flutter/material.dart';
import '../../core/models/hadith.dart';
import '../../core/services/hadith_service.dart';
import '../../core/theme/app_theme.dart';
import 'hadith_detail_screen.dart';

class HadithLibraryScreen extends StatefulWidget {
  final String? initialBookId;

  const HadithLibraryScreen({
    super.key,
    this.initialBookId,
  });

  @override
  State<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends State<HadithLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    HadithService.instance.init();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialBookId == 'riyadh') {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getGradingColor(String grading) {
    if (grading.contains('متفق عليه') || grading.contains('صحيح')) {
      return AppColors.primaryGreen;
    } else if (grading.contains('حسن')) {
      return Colors.amber.shade800;
    }
    return AppColors.accentGold;
  }

  Widget _buildHadithCard(HadithItem hadith) {
    final isFav = HadithService.instance.isFavorite(hadith.id);
    final gradingColor = _getGradingColor(hadith.grading);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithDetailScreen(hadithId: hadith.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Number, Chapter, and Favorite Button
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${hadith.number}',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hadith.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          hadith.chapter,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? AppColors.accentGold : Colors.grey.shade400,
                      size: 22,
                    ),
                    tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                    onPressed: () {
                      HadithService.instance.toggleFavorite(hadith.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Matn Snippet
              Text(
                hadith.matn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Row: Source & Grading Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hadith.source,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gradingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: gradingColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      hadith.grading,
                      style: TextStyle(
                        color: gradingColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHadithList(List<HadithItem> hadiths, {String emptyMessage = 'لا توجد أحاديث مطابقة'}) {
    if (hadiths.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: hadiths.length,
      itemBuilder: (context, index) => _buildHadithCard(hadiths[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: HadithService.instance,
      builder: (context, _) {
        final hadithOfTheDay = HadithService.instance.getHadithOfTheDay();
        final nawawiHadiths = HadithService.instance.searchHadiths(
          _searchQuery,
          bookId: 'nawawi40',
        );
        final riyadhHadiths = HadithService.instance.searchHadiths(
          _searchQuery,
          bookId: 'riyadh',
        );
        final favHadiths = HadithService.instance.getFavorites().where((h) {
          if (_searchQuery.isEmpty) return true;
          return HadithService.instance
              .searchHadiths(_searchQuery)
              .any((searched) => searched.id == h.id);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('مكتبة الأحاديث النبوية الشريفة'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: false,
              tabs: [
                Tab(text: 'الأربعون النووية (${nawawiHadiths.length})'),
                Tab(text: 'رياض الصالحين (${riyadhHadiths.length})'),
                Tab(
                  icon: const Icon(Icons.star, size: 16),
                  text: 'المفضلة (${favHadiths.length})',
                ),
              ],
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث في نصوص الأحاديث، الرواة، أو الأبواب...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                  ),
                ),

                // Hadith of the Day Banner (shown only when not searching)
                if (_searchQuery.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'حديث اليوم المختارة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  hadithOfTheDay.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentGold,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('قراءة'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HadithDetailScreen(
                                    hadithId: hadithOfTheDay.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tabs Body
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHadithList(nawawiHadiths),
                      _buildHadithList(riyadhHadiths),
                      _buildHadithList(
                        favHadiths,
                        emptyMessage: 'لم تقم بإضافة أي حديث إلى المفضلة بعد.\nانقر على علامة النجمة ⭐ بجانب أي حديث لحفظه هنا.',
                      ),
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
}
