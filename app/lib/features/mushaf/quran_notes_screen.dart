import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/ayah_note.dart';
import '../../core/models/surah.dart';
import '../../core/models/ayah.dart';
import '../../core/services/ayah_notes_service.dart';
import '../../core/services/quran_repository.dart';
import 'page_mode_mushaf_screen.dart';
import 'widgets/ayah_note_edit_dialog.dart';

/// Screen displaying and searching all personal Quranic reflections and notes (FR-BKM-004 / T-110)
class QuranNotesScreen extends StatefulWidget {
  const QuranNotesScreen({super.key});

  @override
  State<QuranNotesScreen> createState() => _QuranNotesScreenState();
}

class _QuranNotesScreenState extends State<QuranNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedSurahId;

  @override
  void initState() {
    super.initState();
    AyahNotesService.instance.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _shareNote(AyahNote note) {
    final text = '﴿${note.ayahText}﴾\n[سورة ${note.surahName} - آية ${note.ayahNumber}]\n\n'
        'خاطرة وتدبر:\n${note.noteText}\n\n'
        '— تطبيق نور المؤمن للقرآن الكريم والعبادات';
    try {
      Share.share(text);
    } catch (_) {}
  }

  Future<void> _confirmDelete(AyahNote note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
          title: const Text('حذف الخاطرة'),
          content: Text('هل ترغب في حذف خاطرتك على سورة ${note.surahName} آية ${note.ayahNumber}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await AyahNotesService.instance.deleteNote(note.surahId, note.ayahNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الخاطرة بنجاح', textAlign: TextAlign.right),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تدبراتي وخواطري القرآنية'),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: AyahNotesService.instance,
          builder: (context, _) {
            final allNotes = AyahNotesService.instance.getAllNotes();
            final filteredNotes = AyahNotesService.instance.getAllNotes(
              searchQuery: _searchQuery,
              filterSurahId: _selectedSurahId,
            );

            // Extract unique surahs that have reflections
            final surahMap = <int, String>{};
            for (final n in allNotes) {
              surahMap[n.surahId] = n.surahName;
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Noble Dedication Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: Color(0xFFD4AF37), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'سجل خواطرك وتدبراتك القرآنية واحفظها بأمان',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Statistics & Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.rate_review_rounded, color: AppColors.primaryGreen, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الخواطر والتدبرات المسجلة',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  allNotes.isEmpty
                                      ? 'ابدأ بتدوين تدبراتك على الآيات'
                                      : '${allNotes.length} خاطرة عبر ${surahMap.length} سورة كريمة',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${allNotes.length}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (allNotes.isNotEmpty) ...[
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث في كلمات الخواطر أو الآيات أو السور...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
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
                      fillColor: isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                  const SizedBox(height: 12),

                  // Surahs Filter Chips
                  if (surahMap.length > 1) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('جميع السور'),
                            selected: _selectedSurahId == null,
                            onSelected: (_) => setState(() => _selectedSurahId = null),
                          ),
                          const SizedBox(width: 8),
                          ...surahMap.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text('سورة ${entry.value}'),
                                selected: _selectedSurahId == entry.key,
                                onSelected: (_) => setState(() => _selectedSurahId = entry.key),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],

                // Content or Empty State
                if (allNotes.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_outlined, size: 68, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد خواطر أو تدبرات مدونة بعد',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '«أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ أَمْ عَلَىٰ قُلُوبٍ أَقْفَالُهَا»\n\n'
                          'اضغط مطولاً على أي آية في المصحف أو شاشة القراءة، ثم اختر «تدبر وخاطرة» لتدوين ما فتح الله به عليك وحفظه هنا للرجوع إليه دائماً 🌿',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ] else if (filteredNotes.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Text(
                      'لا توجد خواطر مطابقة للبحث',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),
                  ),
                ] else ...[
                  ...filteredNotes.map((note) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'سورة ${note.surahName} : آية ${note.ayahNumber}',
                                        style: const TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ص ${note.pageNumber}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                Text(
                                  _formatDate(note.updatedAt),
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Ayah Box
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.accentGold.withOpacity(0.25)),
                              ),
                              child: Text(
                                '﴿${note.ayahText}﴾',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14.5, height: 1.7, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Reflection Text
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF222825) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                note.noteText,
                                style: const TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.normal),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Action Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.menu_book, size: 16),
                                  label: const Text('في المصحف', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PageModeMushafScreen(initialPage: note.pageNumber),
                                      ),
                                    );
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.share, size: 16),
                                  label: const Text('مشاركة', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _shareNote(note),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('تعديل', style: TextStyle(fontSize: 12)),
                                  onPressed: () async {
                                    final surahs = await QuranRepository.loadSurahs();
                                    final surah = surahs.firstWhere(
                                      (s) => s.id == note.surahId,
                                      orElse: () => Surah(
                                        id: note.surahId,
                                        nameAr: note.surahName,
                                        nameSimple: note.surahName,
                                        revelationPlace: 'makkah',
                                        revelationOrder: 1,
                                        ayahCount: 1,
                                        hasBasmala: true,
                                        pageStart: note.pageNumber,
                                        pageEnd: note.pageNumber,
                                      ),
                                    );
                                    final ayah = Ayah(
                                      id: note.ayahNumber,
                                      surahId: note.surahId,
                                      ayahNumber: note.ayahNumber,
                                      page: note.pageNumber,
                                      juz: 1,
                                      hizb: 1,
                                      rub: 1,
                                      sajdah: 0,
                                      textUthmani: note.ayahText,
                                      textImlaei: note.ayahText,
                                      textSearch: note.ayahText,
                                    );
                                    if (mounted) {
                                      AyahNoteEditDialog.show(context, surah: surah, ayah: ayah);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                  tooltip: 'حذف',
                                  onPressed: () => _confirmDelete(note),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
