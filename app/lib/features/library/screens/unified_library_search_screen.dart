import 'package:flutter/material.dart';
import '../../../core/services/scholars_lectures_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/unified_library_search_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';
import '../../audio/widgets/global_mini_player_bar.dart';

/// شاشة محرك البحث الموسوعي الشامل عبر جميع المكتبات الإسلامية والعلمية والصوتية في التطبيق
class UnifiedLibrarySearchScreen extends StatefulWidget {
  final String initialQuery;

  const UnifiedLibrarySearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<UnifiedLibrarySearchScreen> createState() =>
      _UnifiedLibrarySearchScreenState();
}

class _UnifiedLibrarySearchScreenState extends State<UnifiedLibrarySearchScreen> {
  late final TextEditingController _controller;
  final UnifiedLibrarySearchService _searchService =
      UnifiedLibrarySearchService.instance;
  String _selectedLibrary = 'الكل';
  String _query = '';
  late ScreenStructureMode _layoutMode;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
    _layoutMode = ScreenStructureMode.fromId(
      SettingsService.instance.screenLayoutMode,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _searchService.searchAllLibraries(
      _query,
      selectedLibrary: _selectedLibrary,
    );

    final structuredResults = results
        .map(
          (r) => StructuredScreenItem(
            id: r.id,
            title: r.title,
            subtitle: '${r.snippet}\n(${r.sourceReference})',
            badgeText: r.libraryName,
            category: r.category,
            icon: r.icon,
            accentColor: r.accentColor,
            onTap: () {
              final isScholarLecture = r.id.startsWith('scholar_lec_');
              final rawLectureId = isScholarLecture
                  ? r.id.replaceFirst('scholar_lec_', '')
                  : null;
              ScholarAudioLecture? matchingLecture;
              if (rawLectureId != null) {
                for (final l in ScholarsLecturesService.instance.allLectures) {
                  if (l.id == rawLectureId) {
                    matchingLecture = l;
                    break;
                  }
                }
              }

              showDialog(
                context: context,
                builder: (ctx) => Directionality(
                  textDirection: SettingsService.instance.textDirection,
                  child: AlertDialog(
                    title: Text(
                      r.title,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${r.libraryName} • ${r.category}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: r.accentColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(r.snippet, style: const TextStyle(height: 1.6)),
                          const SizedBox(height: 10),
                          Text(
                            'المصدر: ${r.sourceReference}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      if (matchingLecture != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.play_circle_fill_rounded,
                            size: 18,
                          ),
                          label: const Text('استماع للدرس الصوتي الآن 🎙️'),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScholarsLecturesService.instance.playLecture(
                              matchingLecture!,
                            );
                          },
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البحث الموسوعي الشامل في جميع المكتبات'),
          actions: [
            ScreenLayoutPopupButton(
              currentMode: _layoutMode,
              onChanged: (m) => setState(() => _layoutMode = m),
            ),
          ],
        ),
        bottomNavigationBar: const GlobalMiniPlayerBar(),
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
              controller: _controller,
              autofocus: widget.initialQuery.isEmpty,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText:
                    'ابحث في مجالس العلماء، رياض الصالحين، الفقه، غريب القرآن، المتون، صيدلية القلوب...',
                prefixIcon: const Icon(Icons.manage_search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                      tooltip: 'إغلاق أو مسح',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
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
                children: _searchService.libraryFilters.map((lib) {
                  final selected = _selectedLibrary == lib;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(lib),
                      selected: selected,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedLibrary = lib),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            if (_query.trim().isEmpty) ...[
              const Text(
                'اقتراحات سريعة للبحث الموسوعي الشامل (١٣ موسوعة):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'سمير مصطفى',
                  'محمود الحسنات',
                  'نبيل العوضي',
                  'الشعراوي',
                  'الوضوء',
                  'الزكاة',
                  'الفاتحة',
                  'الرحمن',
                  'الهجرة',
                  'الإخلاص',
                  'الصلاة',
                  'جبر الخواطر',
                ].map((suggestion) {
                  return ActionChip(
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 15),
                    label: Text(suggestion),
                    onPressed: () {
                      _controller.text = suggestion;
                      setState(() => _query = suggestion);
                    },
                  );
                }).toList(),
              ),
            ] else if (structuredResults.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('لا توجد نتائج مطابقة في المكتبات المختارة'),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'تم العثور على ${structuredResults.length} نتيجة في الموسوعات الإسلامية:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              AdaptiveStructuredCollectionView(
                mode: _layoutMode,
                items: structuredResults,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
