import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/models/hadith.dart';
import '../../core/services/hadith_service.dart';
import '../../core/services/riyad_alsalihin_service.dart';
import '../../core/services/quran_accessibility_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';
import '../library/screens/riyad_alsalihin_screen.dart';
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
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCollectionId = 'nawawi40';
  int _selectedRiyadBookNumber = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    HadithService.instance.init();
    RiyadAlSalihinService.instance.init();
    if (widget.initialBookId == 'nawawi40') {
      _selectedCollectionId = 'nawawi40';
      _tabController.index = 0;
    } else if (widget.initialBookId == 'riyadh') {
      _selectedCollectionId = 'riyad_full';
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

    return Semantics(
      container: true,
      label: QuranAccessibilityService.buildHadithSemanticLabel(
        title: hadith.title,
        matn: hadith.matn,
        narrator: hadith.narrator,
        source: hadith.source,
      ),
      child: Card(
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
                Text(
                  hadith.matn,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _buildRiyadEntryCard(RiyadEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      container: true,
      label: QuranAccessibilityService.buildHadithSemanticLabel(
        title: entry.chapterTitle,
        matn: entry.arabicMatn,
        narrator: entry.narrator,
        source: entry.sourceAndGrade,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.accentGold.withOpacity(0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.bookTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.chapterTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              if (entry.quranicIntro != null && entry.quranicIntro!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entry.quranicIntro!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.softGold : const Color(0xFF5D4037),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                entry.arabicMatn,
                style: const TextStyle(fontSize: 15, height: 1.8, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'الراوي: ${entry.narrator} — ${entry.sourceAndGrade}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '💡 الشرح والفوائد: ${entry.sharhAndBenefits}',
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([HadithService.instance, RiyadAlSalihinService.instance]),
      builder: (context, _) {
        final nawawiHadiths = HadithService.instance.searchHadiths(_searchQuery, bookId: 'nawawi40');
        final riyadhSelected = HadithService.instance.searchHadiths(_searchQuery, bookId: 'riyadh');
        final favHadiths = HadithService.instance.getFavorites();

        final bool isEncyclopediaMode = _selectedCollectionId == 'riyad_full' ||
            _selectedCollectionId == 'hisn' ||
            _selectedCollectionId == 'adab_mufrad' ||
            _selectedCollectionId == 'jawami_dua';

        final String encId = _selectedCollectionId == 'riyad_full' ? 'riyad' : _selectedCollectionId;
        final riyadBooks = isEncyclopediaMode
            ? RiyadAlSalihinService.instance.getBooksForEncyclopedia(encId)
            : <MapEntry<int, String>>[];
        final riyadEntries = isEncyclopediaMode
            ? RiyadAlSalihinService.instance.getEntriesForEncyclopedia(
                encId,
                bookNumber: _selectedRiyadBookNumber == 0 ? null : _selectedRiyadBookNumber,
                query: _searchQuery,
              )
            : <RiyadEntry>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text('مكتبة الأحاديث النبوية الشريفة'),
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new_rounded),
                tooltip: 'فتح واجهة رياض الصالحين والموسوعات الكاملة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiyadAlSalihinScreen()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accentGold,
              tabs: const [
                Tab(text: 'الأربعون النووية'),
                Tab(text: 'رياض الصالحين'),
                Tab(text: 'المفضلة'),
              ],
              onTap: (index) {
                setState(() {
                  if (index == 0) _selectedCollectionId = 'nawawi40';
                  if (index == 1) {
                    _selectedCollectionId = 'riyad_full';
                    _selectedRiyadBookNumber = 0;
                  }
                  if (index == 2) _selectedCollectionId = 'favorites';
                });
              },
            ),
          ),
          body: Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: Column(
              children: [
                // 1. Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث في نصوص الأحاديث، الشرح، الرواة، أو الأبواب...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                            tooltip: 'إغلاق أو مسح',
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1B231D)
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),

                // 2. Secondary Dropdown for Book / Kitab when in Riyad As-Salihin mode
                if (isEncyclopediaMode && riyadBooks.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                    child: AppDropdownField<int>(
                      label: 'اختر الكتاب الفرعي أو الباب',
                      value: _selectedRiyadBookNumber,
                      dense: true,
                      prefixIcon: Icons.bookmark_border_rounded,
                      options: [
                        const AppDropdownOption<int>(
                          value: 0,
                          label: 'جميع الكتب والأبواب الكاملة',
                        ),
                        ...riyadBooks.map(
                          (b) => AppDropdownOption<int>(
                            value: b.key,
                            label: b.value,
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedRiyadBookNumber = val);
                      },
                    ),
                  ),

                // 3. Content Body
                Expanded(
                  child: isEncyclopediaMode
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 6, bottom: 20),
                          itemCount: riyadEntries.length + riyadhSelected.length,
                          itemBuilder: (context, index) {
                            if (index < riyadEntries.length) {
                              return _buildRiyadEntryCard(riyadEntries[index]);
                            }
                            if (_selectedCollectionId == 'riyad_full' && _selectedRiyadBookNumber == 0) {
                              return _buildHadithCard(riyadhSelected[index - riyadEntries.length]);
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 6, bottom: 20),
                          itemCount: _selectedCollectionId == 'nawawi40'
                              ? nawawiHadiths.length
                              : (_selectedCollectionId == 'riyadh_selected'
                                  ? riyadhSelected.length
                                  : favHadiths.length),
                          itemBuilder: (context, index) {
                            final list = _selectedCollectionId == 'nawawi40'
                                ? nawawiHadiths
                                : (_selectedCollectionId == 'riyadh_selected'
                                    ? riyadhSelected
                                    : favHadiths);
                            return _buildHadithCard(list[index]);
                          },
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
