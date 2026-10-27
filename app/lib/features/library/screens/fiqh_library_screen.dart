import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/islamic_libraries_models.dart';
import '../../../core/services/fiqh_library_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';
import '../../../core/ui/app_dropdown_field.dart';

/// شاشة موسوعة الفقه الميسر على المذاهب الأربعة مع دعم أنماط العرض المتعددة
class FiqhLibraryScreen extends StatefulWidget {
  const FiqhLibraryScreen({super.key});

  @override
  State<FiqhLibraryScreen> createState() => _FiqhLibraryScreenState();
}

class _FiqhLibraryScreenState extends State<FiqhLibraryScreen> {
  final FiqhLibraryService _service = FiqhLibraryService.instance;
  String _selectedChapter = 'الكل';
  String _searchQuery = '';
  bool _favoritesOnly = false;
  late ScreenStructureMode _layoutMode;

  @override
  void initState() {
    super.initState();
    _service.init();
    _layoutMode = ScreenStructureMode.fromId(
      SettingsService.instance.screenLayoutMode,
    );
  }

  void _showTopicDetailSheet(BuildContext context, FiqhTopicItem topic, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          expand: false,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
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
                      topic.chapter,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'نسخ المسألة الفقهية',
                    onPressed: () {
                      final madhahibStr = topic.madhahibComparison.entries
                          .map((e) => '• ${e.key}: ${e.value}')
                          .join('\n');
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${topic.title}\n\nالحكم الميسر: ${topic.summaryRuling}\n\nالدليل: ${topic.evidenceText}\n\nأقوال المذاهب الأربعة:\n$madhahibStr\n\nتطبيق معاصر: ${topic.contemporaryNote}',
                        ),
                      ).catchError((_) {});
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ المسألة الفقهية إلى الحافظة')),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'إغلاق أو مسح',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.title,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الحكم الشرعي الميسر:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(topic.summaryRuling, style: const TextStyle(height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '📖 الدليل من الكتاب والسنة:\n${topic.evidenceText}',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '⚖️ مقارنة أقوال المذاهب الفقهية الأربعة:',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 8),
              ...topic.madhahibComparison.entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: '${entry.key}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        TextSpan(text: entry.value),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💡 تطبيقات وفتاوى معاصرة: ${topic.contemporaryNote}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = _service.searchTopics(
      _searchQuery,
      category: _selectedChapter,
      favoritesOnly: _favoritesOnly,
    );

    final structuredItems = topics
        .map(
          (t) => StructuredScreenItem(
            id: t.id,
            title: t.title,
            subtitle: t.summaryRuling,
            badgeText: t.chapter.replaceFirst('فقه ', ''),
            category: t.chapter,
            icon: Icons.balance_rounded,
            accentColor: AppColors.primaryGreen,
            onTap: () => _showTopicDetailSheet(context, t, isDark),
            trailing: IconButton(
              tooltip: 'حفظ في المفضلة',
              icon: Icon(
                _service.isFavorite(t.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _service.isFavorite(t.id) ? Colors.redAccent : Colors.grey,
              ),
              onPressed: () => setState(() {
                _service.toggleFavorite(t.id);
              }),
            ),
          ),
        )
        .toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موسوعة الفقه الميسر والمذاهب الأربعة'),
          actions: [
            IconButton(
              tooltip: _favoritesOnly ? 'عرض الكل' : 'المفضلة فقط',
              icon: Icon(
                _favoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _favoritesOnly ? AppColors.accentGold : null,
              ),
              onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
            ),
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
                hintText: 'ابحث في أبواب الفقه والمذاهب الأربعة (وضوء، صلاة، صيام، زكاة، تقسيط)...',
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
              label: 'اختر الباب الفقهي من القائمة المنسدلة',
              value: _service.chapters.contains(_selectedChapter) ? _selectedChapter : (_service.chapters.isNotEmpty ? _service.chapters.first : 'الكل'),
              dense: true,
              prefixIcon: Icons.balance_rounded,
              options: _service.chapters
                  .map((ch) => AppDropdownOption<String>(value: ch, label: ch))
                  .toList(),
              onChanged: (val) => setState(() => _selectedChapter = val),
            ),
            const SizedBox(height: 14),
            if (structuredItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('لا توجد مسائل فقهية مطابقة للبحث الحالي')),
              )
            else
              AdaptiveStructuredCollectionView(
                mode: _layoutMode,
                items: structuredItems,
              ),
          ],
        ),
      ),
    );
  }
}
