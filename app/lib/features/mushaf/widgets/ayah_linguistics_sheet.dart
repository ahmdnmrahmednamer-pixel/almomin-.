import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/quran_linguistics_service.dart';
import '../../../core/ui/app_dropdown_field.dart';
import 'ayah_card_share_sheet.dart';
import 'tafsir_viewer_sheet.dart';

class AyahLinguisticsSheet extends StatefulWidget {
  final Surah surah;
  final Ayah ayah;
  final int initialTabIndex;

  const AyahLinguisticsSheet({
    super.key,
    required this.surah,
    required this.ayah,
    this.initialTabIndex = 0,
  });

  static void show(
    BuildContext context, {
    required Surah surah,
    required Ayah ayah,
    int initialTabIndex = 0,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahLinguisticsSheet(
        surah: surah,
        ayah: ayah,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  State<AyahLinguisticsSheet> createState() => _AyahLinguisticsSheetState();
}

class _AyahLinguisticsSheetState extends State<AyahLinguisticsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<QuranLinguisticsResult> _detailsFuture;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedSectionIndex = widget.initialTabIndex.clamp(0, 3);
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _selectedSectionIndex,
    );
    _tabController.addListener(_onTabChanged);
    _detailsFuture = QuranLinguisticsService.getDetails(
      surahId: widget.surah.id,
      ayahNumber: widget.ayah.ayahNumber,
    );
  }

  void _onTabChanged() {
    if (_tabController.index != _selectedSectionIndex && mounted) {
      setState(() => _selectedSectionIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2824) : Colors.white;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${widget.surah.nameAr} — آية ${_toArabicIndic(widget.ayah.ayahNumber)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                        Text(
                          'إعراب القرآن · أسباب النزول · الغريب · البلاغة',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'فتح التفاسير الثمانية المعتمدة',
                    icon: const Icon(Icons.auto_stories_rounded, color: AppColors.primaryGreen),
                    onPressed: () {
                      Navigator.pop(context);
                      TafsirViewerSheet.show(context, surah: widget.surah, ayah: widget.ayah);
                    },
                  ),
                  IconButton(
                    tooltip: 'تصميم بطاقة دعوية',
                    icon: const Icon(Icons.brush_rounded, color: AppColors.accentGold),
                    onPressed: () {
                      Navigator.pop(context);
                      AyahCardShareSheet.show(context, surah: widget.surah, ayah: widget.ayah);
                    },
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Ayah Text Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Text(
                widget.ayah.textUthmani,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.8,
                  fontWeight: FontWeight.bold,
                  fontFamilyFallback: ['Traditional Arabic', 'Amiri', 'serif'],
                ),
              ),
            ),

            // Dropdown Selector for Linguistic Section (Phase 4 Dropdown Requirement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: AppDropdownField<int>(
                label: 'اختر العلم القرآني للآية الكريمة',
                value: _selectedSectionIndex,
                dense: true,
                prefixIcon: Icons.school_rounded,
                options: const [
                  AppDropdownOption(
                    value: 0,
                    label: 'معاني الكلمات وغريب القرآن',
                    icon: Icons.auto_stories_rounded,
                  ),
                  AppDropdownOption(
                    value: 1,
                    label: 'أسباب النزول المحققة (الواحدي والسيوطي)',
                    icon: Icons.history_edu_rounded,
                  ),
                  AppDropdownOption(
                    value: 2,
                    label: 'إعراب الآية التفصيلي والتحليل النحوي',
                    icon: Icons.spellcheck_rounded,
                  ),
                  AppDropdownOption(
                    value: 3,
                    label: 'البلاغة والبيان واللطائف القرآنية',
                    icon: Icons.auto_awesome_rounded,
                  ),
                ],
                onChanged: (idx) {
                  setState(() => _selectedSectionIndex = idx);
                  if (_tabController.length > 0) _tabController.animateTo(idx.clamp(0, _tabController.length - 1));
                },
              ),
            ),

            // Content Area
            Expanded(
              child: FutureBuilder<QuranLinguisticsResult>(
                future: _detailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text('تعذر تحميل البيانات اللغوية، يرجى المحاولة لاحقاً.'),
                    );
                  }

                  final data = snapshot.data!;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildWordMeaningsTab(data),
                      _buildAsbabTab(data),
                      _buildGrammarTab(data),
                      _buildRhetoricTab(data),
                    ],
                  );
                },
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18221E) : Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('نسخ البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final data = await _detailsFuture;
                        final text = data.formatForShare(widget.surah.nameAr);
                        await Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الإعراب وأسباب النزول ومعاني الكلمات إلى الحافظة'),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('مشاركة الفائدة', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final data = await _detailsFuture;
                        final text = data.formatForShare(widget.surah.nameAr);
                        try {
                          await Share.share(text);
                        } catch (_) {}
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordMeaningsTab(QuranLinguisticsResult data) {
    if (data.wordMeanings.isEmpty) {
      return const Center(
        child: Text('لا توجد كلمات غريبة مسجلة في هذه الآية الكريمة، وألفاظها واضحة المعنى الجلي.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.wordMeanings.length,
      itemBuilder: (context, index) {
        final w = data.wordMeanings[index];
        return Semantics(
          container: true,
          label: 'الكلمة ${w.word}، معناها: ${w.meaning}',
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '﴿${w.word}﴾',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const Text(
                        'غريب القرآن ومفرداته',
                        style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    w.meaning,
                    style: const TextStyle(fontSize: 14.5, height: 1.6, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAsbabTab(QuranLinguisticsResult data) {
    final asbab = data.asbabNuzul;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Semantics(
        container: true,
        label: '${asbab.title}: ${asbab.narration}، المصدر: ${asbab.source}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: asbab.hasSpecificIncident
                    ? AppColors.primaryGreen.withOpacity(0.08)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: asbab.hasSpecificIncident
                      ? AppColors.primaryGreen.withOpacity(0.3)
                      : Colors.amber.shade700.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        asbab.hasSpecificIncident
                            ? Icons.stars_rounded
                            : Icons.info_outline_rounded,
                        color: asbab.hasSpecificIncident
                            ? AppColors.primaryGreen
                            : Colors.amber.shade800,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          asbab.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: asbab.hasSpecificIncident
                                ? AppColors.primaryGreen
                                : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    asbab.narration,
                    style: const TextStyle(fontSize: 14.5, height: 1.8, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'المصدر والتوثيق: ${asbab.source}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrammarTab(QuranLinguisticsResult data) {
    final grammar = data.grammar;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: 'الإعراب الإجمالي للآية: ${grammar.summary}',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.spellcheck_rounded, color: AppColors.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text('الإعراب الإجمالي للآية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    grammar.summary,
                    style: const TextStyle(fontSize: 14.5, height: 1.8, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('التحليل النحوي والصرفي لمفردات الآية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ...grammar.words.map((w) {
            return Semantics(
              container: true,
              label: 'إعراب كلمة ${w.word}: ${w.role}، ${w.caseEnding}',
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  title: Text('﴿${w.word}﴾', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                  subtitle: Text('${w.role} — ${w.caseEnding}', style: const TextStyle(fontSize: 12.5, height: 1.4)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRhetoricTab(QuranLinguisticsResult data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Semantics(
        container: true,
        label: 'البلاغة والبيان القرآني: ${data.grammar.rhetoricSummary}',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'البلاغة والبيان واللطائف القرآنية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.grammar.rhetoricSummary,
                style: const TextStyle(fontSize: 14.5, height: 1.8, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
