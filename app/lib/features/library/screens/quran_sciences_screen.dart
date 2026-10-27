import 'package:flutter/material.dart';
import '../../../core/models/islamic_libraries_models.dart';
import '../../../core/services/quran_sciences_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';
import '../../../core/ui/app_dropdown_field.dart';

/// شاشة مكتبة علوم القرآن وأسباب النزول والمكي والمدني مع تخطيطات عرض متعددة
class QuranSciencesScreen extends StatefulWidget {
  const QuranSciencesScreen({super.key});

  @override
  State<QuranSciencesScreen> createState() => _QuranSciencesScreenState();
}

class _QuranSciencesScreenState extends State<QuranSciencesScreen> {
  final QuranSciencesService _service = QuranSciencesService.instance;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  late ScreenStructureMode _layoutMode;

  @override
  void initState() {
    super.initState();
    _layoutMode = ScreenStructureMode.fromId(
      SettingsService.instance.screenLayoutMode,
    );
  }

  void _showEntrySheet(BuildContext context, QuranScienceEntry item, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.category} • ${item.surahName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'إغلاق أو مسح',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الموضع: ${item.ayahReference}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.narrationOrRule,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🌿 الفائدة التدبرية والعملية: ${item.practicalBenefit}',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '📚 التخريج والمصدر العلمي: ${item.scholarlySource}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _service.searchEntries(_searchQuery, category: _selectedCategory);

    final structured = items
        .map(
          (e) => StructuredScreenItem(
            id: e.id,
            title: e.title,
            subtitle: e.narrationOrRule,
            badgeText: e.surahName,
            category: e.category,
            icon: Icons.menu_book_rounded,
            accentColor: const Color(0xFF1F6E58),
            onTap: () => _showEntrySheet(context, e, isDark),
          ),
        )
        .toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مكتبة علوم القرآن وأسباب النزول'),
          actions: [
            ScreenLayoutPopupButton(
              currentMode: _layoutMode,
              onChanged: (m) => setState(() => _layoutMode = m),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdaptiveLayoutSwitcherBar(
              currentMode: _layoutMode,
              onModeChanged: (m) {
                SettingsService.instance.setScreenLayoutMode(m.id);
                setState(() => _layoutMode = m);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ابحث في أسباب النزول، المكي والمدني، فضائل ومقاصد السور...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppTheme.darkCard : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppDropdownField<String>(
              label: 'اختر علم القرآن من القائمة المنسدلة',
              value: _service.categories.contains(_selectedCategory) ? _selectedCategory : (_service.categories.isNotEmpty ? _service.categories.first : 'الكل'),
              dense: true,
              prefixIcon: Icons.menu_book_rounded,
              options: _service.categories
                  .map((cat) => AppDropdownOption<String>(value: cat, label: cat))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 14),
            AdaptiveStructuredCollectionView(
              mode: _layoutMode,
              items: structured,
            ),
          ],
        ),
      ),
    );
  }
}
