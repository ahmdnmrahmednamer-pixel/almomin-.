import '../../../core/services/settings_service.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/islamic_mutoon_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_dropdown_field.dart';

class IslamicMutoonScreen extends StatefulWidget {
  const IslamicMutoonScreen({super.key});

  @override
  State<IslamicMutoonScreen> createState() => _IslamicMutoonScreenState();
}

class _IslamicMutoonScreenState extends State<IslamicMutoonScreen> {
  String _selectedBookId = 'tuhfat_atfal';
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    IslamicMutoonService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('islamic_mutoon')),
          actions: [
            IconButton(
              icon: const Icon(Icons.format_size_rounded),
              tooltip: 'تكبير وتصغير الخط',
              onPressed: () {
                setState(() {
                  _fontSize = _fontSize >= 26.0 ? 16.0 : _fontSize + 2.0;
                });
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: IslamicMutoonService.instance,
          builder: (context, _) {
            final sections = IslamicMutoonService.instance.getSectionsForBook(_selectedBookId);
            final memorizedCount = sections.where((s) => IslamicMutoonService.instance.isMemorized(s.id)).length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2E22), Color(0xFF1B4332)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '«من حفظ المتون حاز الفنون»',
                        style: TextStyle(color: AppColors.accentGold, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'متون التجويد والقواعد الفقهية والعقيدة الإسلامية مشكولة مع الشرح الميسر وتتبع الحفظ',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المحفوظ في هذا المتن: $memorizedCount من ${sections.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'إجمالي المحفوظات: ${IslamicMutoonService.instance.memorizedIds.length}',
                            style: const TextStyle(color: AppColors.softGold, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Dropdown Selector for Matn Book
                AppDropdownField<String>(
                  label: 'اختر المتن العلمي من القائمة المنسدلة',
                  value: _selectedBookId,
                  prefixIcon: Icons.school_rounded,
                  options: [
                    ...IslamicMutoonService.matnBooks.entries.map(
                      (e) => AppDropdownOption<String>(
                        value: e.key,
                        label: e.value,
                      ),
                    ),
                    const AppDropdownOption<String>(
                      value: 'all',
                      label: 'عرض جميع المتون العلمية معاً',
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedBookId = val),
                ),
                const SizedBox(height: 14),

                // 3. Sections List
                ...sections.map((sec) {
                  final isMem = IslamicMutoonService.instance.isMemorized(sec.id);
                  return Semantics(
                    container: true,
                    label: '${sec.chapterTitle} من ${sec.matnBookTitle}: ${sec.vocalizedText}، الشرح: ${sec.sharhAndExplanation}',
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isMem ? AppColors.accentGold : Colors.grey.withOpacity(0.25),
                          width: isMem ? 1.6 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sec.chapterTitle,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                FilterChip(
                                  label: Text(isMem ? 'تم الحفظ ✓' : 'تحديد كمحفوظ'),
                                  selected: isMem,
                                  selectedColor: AppColors.accentGold.withOpacity(0.35),
                                  onSelected: (_) => IslamicMutoonService.instance.toggleMemorized(sec.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF16211C) : const Color(0xFFFBF9F2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.accentGold.withOpacity(0.45)),
                              ),
                              child: Text(
                                sec.vocalizedText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: 1.9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '📖 الشرح والبيان:\n${sec.sharhAndExplanation}',
                              style: const TextStyle(fontSize: 14, height: 1.65),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '💡 خلاصة الضابط العلمي: ${sec.keyTakeaway}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('نسخ'),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                      text: '${sec.chapterTitle}\n\n${sec.vocalizedText}\n\nالشرح: ${sec.sharhAndExplanation}',
                                    )).catchError((_) {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم نسخ المتن والشرح إلى الحافظة')),
                                    );
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.share_rounded, size: 16),
                                  label: const Text('مشاركة'),
                                  onPressed: () {
                                    try {
                                      Share.share('${sec.chapterTitle}\n\n${sec.vocalizedText}\n\nالشرح: ${sec.sharhAndExplanation}\n— تطبيق نور المؤمن');
                                    } catch (_) {}
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
