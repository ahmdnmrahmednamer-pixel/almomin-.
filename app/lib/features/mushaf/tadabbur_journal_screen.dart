import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/surah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/tadabbur_journal_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

class TadabburJournalScreen extends StatefulWidget {
  const TadabburJournalScreen({super.key});

  @override
  State<TadabburJournalScreen> createState() => _TadabburJournalScreenState();
}

class _TadabburJournalScreenState extends State<TadabburJournalScreen> {
  String _selectedViewMode = 'all'; // 'all', 'journal', 'accountability'
  List<Surah> _surahs = [];

  @override
  void initState() {
    super.initState();
    TadabburJournalService.instance.init();
    QuranRepository.loadSurahs().then((list) {
      if (mounted) setState(() => _surahs = list);
    });
  }

  Future<void> _showAddReflectionDialog() async {
    int selectedSurahId = 1;
    int selectedAyahNum = 1;
    final faithCtrl = TextEditingController();
    final actionCtrl = TextEditingController();
    final duaCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final surah = _surahs.isNotEmpty
                ? _surahs.firstWhere((s) => s.id == selectedSurahId, orElse: () => _surahs.first)
                : null;
            final maxAyahs = surah?.ayahCount ?? 7;

            return Directionality(
              textDirection: SettingsService.instance.textDirection,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 20,
                  left: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'إضافة بطاقة تدبُّر وعمل بالآية الكريمة 🌿',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                      const SizedBox(height: 12),
                      if (_surahs.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppDropdownField<int>(
                                label: 'السورة',
                                value: selectedSurahId,
                                dense: true,
                                options: _surahs
                                    .map((s) => AppDropdownOption(value: s.id, label: 'سورة ${s.nameAr}'))
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedSurahId = val;
                                    selectedAyahNum = 1;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: AppDropdownField<int>(
                                label: 'الآية',
                                value: selectedAyahNum.clamp(1, maxAyahs),
                                dense: true,
                                options: List.generate(
                                  maxAyahs,
                                  (i) => AppDropdownOption(value: i + 1, label: 'آية ${i + 1}'),
                                ),
                                onChanged: (val) => setModalState(() => selectedAyahNum = val),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: faithCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '١. الرسالة الإيمانية (ماذا علمتني الآية عن ربي؟)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: actionCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '٢. العمل التطبيقي (كيف أعمل بهذه الآية اليوم؟)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: duaCtrl,
                        decoration: InputDecoration(
                          labelText: '٣. الدعاء المستنبط من الآية الكريمة',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('حفظ بطاقة التدبر والعمل'),
                        onPressed: () async {
                          final ayah = await QuranRepository.getAyah(selectedSurahId, selectedAyahNum);
                          await TadabburJournalService.instance.addReflection(
                            surahId: selectedSurahId,
                            surahName: surah?.nameAr ?? 'الفاتحة',
                            ayahNumber: selectedAyahNum,
                            ayahSnippet: ayah?.textUthmani ?? '',
                            faithMessage: faithCtrl.text.trim().isNotEmpty
                                ? faithCtrl.text.trim()
                                : 'تأمل في عظمة كلام الله وهدايته.',
                            practicalAction: actionCtrl.text.trim().isNotEmpty
                                ? actionCtrl.text.trim()
                                : 'العمل بما دلت عليه الآية الكريمة في يومي.',
                            derivedDua: duaCtrl.text.trim().isNotEmpty
                                ? duaCtrl.text.trim()
                                : 'اللهم اجعل القرآن العظيم ربيع قلبي ونور صدري.',
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), () {
        faithCtrl.dispose();
        actionCtrl.dispose();
        duaCtrl.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('دفتر التدبر والعمل بالقرآن ومحاسبة النفس'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          onPressed: _showAddReflectionDialog,
          icon: const Icon(Icons.add_rounded),
          label: const Text('تدبُّر جديد'),
        ),
        body: AnimatedBuilder(
          animation: TadabburJournalService.instance,
          builder: (context, _) {
            final svc = TadabburJournalService.instance;
            final entries = svc.entries;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // 1. Dropdown Selector for Section
                AppDropdownField<String>(
                  label: 'اختر قسم التدبر والمحاسبة من القائمة المنسدلة',
                  value: _selectedViewMode,
                  dense: true,
                  prefixIcon: Icons.psychology_alt_rounded,
                  options: const [
                    AppDropdownOption(
                      value: 'all',
                      label: 'عرض دفتر التدبر القرآني + ورد محاسبة النفس اليومي',
                    ),
                    AppDropdownOption(
                      value: 'journal',
                      label: 'دفتر تدبر الآيات والعمل بها فقط',
                    ),
                    AppDropdownOption(
                      value: 'accountability',
                      label: 'ورد محاسبة النفس والأخلاق اليومية فقط',
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedViewMode = v),
                ),
                const SizedBox(height: 14),

                // 2. Daily Ethical Self-Accountability Checklist
                if (_selectedViewMode == 'all' || _selectedViewMode == 'accountability') ...[
                  const Text(
                    '📋 ورد محاسبة النفس وتزكية الأخلاق اليومي:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 8),
                  ...TadabburJournalService.dailyEthicalChecklist.map((item) {
                    final id = item['id']!;
                    final done = svc.isEthicalItemDoneToday(id);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: CheckboxListTile(
                        value: done,
                        activeColor: AppColors.primaryGreen,
                        title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(item['verse']!, style: const TextStyle(fontSize: 12, color: AppColors.secondaryGreen)),
                        onChanged: (_) => svc.toggleEthicalItemToday(id),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // 3. Guided Quranic Tadabbur Cards
                if (_selectedViewMode == 'all' || _selectedViewMode == 'journal') ...[
                  const Text(
                    '📖 بطاقات التدبر والعمل بالآيات (أفلا يتدبرون القرآن):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 8),
                  ...entries.map((entry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: AppColors.accentGold.withOpacity(0.45)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'سورة ${entry.surahName} — آية ${entry.ayahNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryGreen),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share_rounded, size: 18),
                                  tooltip: 'مشاركة بطاقة التدبر',
                                  onPressed: () {
                                    try {
                                      Share.share(
                                      '🌿 تدبر وعمل — سورة ${entry.surahName} (${entry.ayahNumber}):\n'
                                      '${entry.ayahSnippet}\n\n'
                                      '💡 الرسالة الإيمانية: ${entry.faithMessage}\n'
                                      '✅ العمل التطبيقي: ${entry.practicalAction}\n'
                                      '🤲 الدعاء: ${entry.derivedDua}',
                                    );
                                    } catch (_) {}
                                  },
                                ),
                              ],
                            ),
                            if (entry.ayahSnippet.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF17221D) : const Color(0xFFFBF9F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entry.ayahSnippet,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text('💡 الرسالة الإيمانية: ${entry.faithMessage}', style: const TextStyle(fontSize: 13.5, height: 1.5)),
                            const SizedBox(height: 6),
                            Text('✅ العمل التطبيقي: ${entry.practicalAction}', style: const TextStyle(fontSize: 13.5, height: 1.5, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('🤲 الدعاء المستنبط: ${entry.derivedDua}', style: const TextStyle(fontSize: 13.5, color: AppColors.secondaryGreen)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
