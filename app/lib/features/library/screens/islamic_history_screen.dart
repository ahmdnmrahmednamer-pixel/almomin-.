import 'package:flutter/material.dart';
import '../../../core/models/islamic_libraries_models.dart';
import '../../../core/services/islamic_history_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';

/// شاشة مكتبة التاريخ الإسلامي والسيرة والصحابة وأعلام الأمة مع تخطيطات متعددة
class IslamicHistoryScreen extends StatefulWidget {
  const IslamicHistoryScreen({super.key});

  @override
  State<IslamicHistoryScreen> createState() => _IslamicHistoryScreenState();
}

class _IslamicHistoryScreenState extends State<IslamicHistoryScreen> {
  final IslamicHistoryService _service = IslamicHistoryService.instance;
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

  void _showHistoryDetail(BuildContext context, IslamicHistoryEntry entry, bool isDark) {
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
                Text(
                  '${entry.eraOrCategory} • ${entry.yearHijri}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(entry.summary, style: const TextStyle(fontSize: 14, height: 1.6)),
                const SizedBox(height: 12),
                const Text(
                  'أبرز المحطات والمواقف الخالدة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 6),
                ...entry.keyHighlights.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        Expanded(child: Text(h, style: const TextStyle(fontSize: 13.5))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💡 العبرة المستفادة: ${entry.lessonLearned}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
    final entries = _service.searchEntries(_searchQuery, category: _selectedCategory);

    final structured = entries
        .map(
          (e) => StructuredScreenItem(
            id: e.id,
            title: e.title,
            subtitle: e.summary,
            badgeText: e.yearHijri,
            category: e.eraOrCategory,
            icon: Icons.history_edu_rounded,
            accentColor: const Color(0xFF6B4C35),
            onTap: () => _showHistoryDetail(context, e, isDark),
          ),
        )
        .toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مكتبة التاريخ الإسلامي والسيرة والأعلام'),
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
                hintText: 'ابحث في الغزوات، الخلفاء الراشدين، أمهات المؤمنين، الأئمة...',
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _service.categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
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
