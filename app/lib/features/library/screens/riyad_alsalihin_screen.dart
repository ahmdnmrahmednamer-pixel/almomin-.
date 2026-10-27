import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/riyad_alsalihin_service.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/services/quran_accessibility_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_dropdown_field.dart';

class RiyadAlSalihinScreen extends StatefulWidget {
  final String initialEncyclopediaId;

  const RiyadAlSalihinScreen({
    super.key,
    this.initialEncyclopediaId = 'riyad',
  });

  @override
  State<RiyadAlSalihinScreen> createState() => _RiyadAlSalihinScreenState();
}

class _RiyadAlSalihinScreenState extends State<RiyadAlSalihinScreen> {
  late String _selectedEncyclopediaId;
  int _selectedBookNumber = 0; // 0 = جميع الكتب والأبواب
  String _searchQuery = '';
  bool _onlyBookmarked = false;
  double _fontSize = 18.0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedEncyclopediaId = widget.initialEncyclopediaId;
    RiyadAlSalihinService.instance.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentEncyclopedia = RiyadAlSalihinService.encyclopedias.firstWhere(
      (e) => e.id == _selectedEncyclopediaId,
      orElse: () => RiyadAlSalihinService.encyclopedias.first,
    );
    final books = RiyadAlSalihinService.instance.getBooksForEncyclopedia(_selectedEncyclopediaId);

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('رياض الصالحين والموسوعات الجامعة'),
          actions: [
            IconButton(
              icon: Icon(
                _onlyBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _onlyBookmarked ? AppColors.accentGold : null,
              ),
              tooltip: _onlyBookmarked ? 'عرض جميع الأبواب' : 'عرض المحفوظات فقط',
              onPressed: () {
                setState(() => _onlyBookmarked = !_onlyBookmarked);
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_size_rounded),
              tooltip: 'تكبير وتصغير حجم الخط',
              onPressed: () {
                setState(() {
                  _fontSize = _fontSize >= 26.0 ? 16.0 : _fontSize + 2.0;
                });
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([RiyadAlSalihinService.instance, IslamicAudioService.instance]),
          builder: (context, _) {
            var entries = RiyadAlSalihinService.instance.getEntriesForEncyclopedia(
              _selectedEncyclopediaId,
              bookNumber: _selectedBookNumber == 0 ? null : _selectedBookNumber,
              query: _searchQuery,
            );
            if (_onlyBookmarked) {
              entries = entries.where((e) => RiyadAlSalihinService.instance.isBookmarked(e.id)).toList();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2E22), Color(0xFF1B4332), Color(0xFF2D6A4F)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentEncyclopedia.titleAr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentEncyclopedia.authorAr,
                                  style: const TextStyle(color: AppColors.softGold, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentEncyclopedia.descriptionAr,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Dropdown Selector for Encyclopedia (رياض الصالحين / حصن المسلم / الأدب المفرد / جوامع الدعاء)
                AppDropdownField<String>(
                  label: 'اختر السفر والموسوعة الإسلامية',
                  value: _selectedEncyclopediaId,
                  prefixIcon: Icons.library_books_rounded,
                  options: RiyadAlSalihinService.encyclopedias
                      .map((enc) => AppDropdownOption<String>(
                            value: enc.id,
                            label: enc.titleAr,
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedEncyclopediaId = val;
                      _selectedBookNumber = 0;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // 3. Dropdown Selector for Book / Kitab inside the selected Encyclopedia
                AppDropdownField<int>(
                  label: 'اختر الكتاب أو الباب الموضوعي',
                  value: _selectedBookNumber,
                  prefixIcon: Icons.bookmark_added_rounded,
                  options: [
                    const AppDropdownOption<int>(
                      value: 0,
                      label: 'جميع الكتب والأبواب الكاملة',
                    ),
                    ...books.map(
                      (b) => AppDropdownOption<int>(
                        value: b.key,
                        label: b.value,
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedBookNumber = val);
                  },
                ),
                const SizedBox(height: 12),

                // 4. Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في متن الحديث أو الباب أو الشرح أو اسم الصحابي...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            tooltip: 'مسح البحث',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF16201C) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.25)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),

                // 5. Entries List
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('لا توجد أحاديث مطابقة للبحث الحالي.'),
                    ),
                  )
                else
                  ...entries.map((entry) => _buildEntryCard(entry, isDark)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntryCard(RiyadEntry entry, bool isDark) {
    final isSaved = RiyadAlSalihinService.instance.isBookmarked(entry.id);
    final isAudioPlaying = entry.audioTrackId != null &&
        IslamicAudioService.instance.currentTrack?.id == entry.audioTrackId &&
        IslamicAudioService.instance.isPlaying;

    return Semantics(
      container: true,
      label: QuranAccessibilityService.buildHadithSemanticLabel(
        title: '${entry.bookTitle}، ${entry.chapterTitle}',
        matn: entry.arabicMatn,
        narrator: entry.narrator,
        source: entry.sourceAndGrade,
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppColors.accentGold.withOpacity(0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book & Chapter Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'حديث ${entry.hadithNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.bookTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.accentGold : Colors.grey,
                    ),
                    tooltip: isSaved ? 'إزالة من المحفوظات' : 'حفظ الحديث',
                    onPressed: () {
                      RiyadAlSalihinService.instance.toggleBookmark(entry.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.chapterTitle,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),

              if (entry.quranicIntro != null && entry.quranicIntro!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.quranicIntro!,
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.softGold : const Color(0xFF5D4037),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Matn Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151E1A) : const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.18)),
                ),
                child: Text(
                  entry.arabicMatn,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Narrator & Source Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'الراوي: ${entry.narrator}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.sourceAndGrade,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sharh & Benefits
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.amber.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 17, color: AppColors.accentGold),
                        SizedBox(width: 6),
                        Text(
                          'الشرح والفوائد التربوية والعملية:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.sharhAndBenefits,
                      style: TextStyle(
                        fontSize: (_fontSize - 3).clamp(13.5, 20.0),
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Action Buttons (Audio + Copy + Share)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (entry.audioTrackId != null)
                    TextButton.icon(
                      icon: Icon(
                        isAudioPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                      label: Text(
                        isAudioPlaying ? 'إيقاف الصوت' : 'استماع صوتي HD',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      onPressed: () {
                        if (isAudioPlaying) {
                          IslamicAudioService.instance.stop();
                        } else {
                          IslamicAudioService.instance.playTrackById(entry.audioTrackId!);
                        }
                      },
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text('نسخ', style: TextStyle(fontSize: 12.5)),
                    onPressed: () {
                      final shareText = '${entry.chapterTitle}\n\n${entry.arabicMatn}\n[${entry.sourceAndGrade}]\n\n💡 الفوائد: ${entry.sharhAndBenefits}\n— تطبيق نور المؤمن';
                      Clipboard.setData(ClipboardData(text: shareText)).catchError((_) {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الحديث والفوائد إلى الحافظة')),
                      );
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share_rounded, size: 17),
                    label: const Text('مشاركة', style: TextStyle(fontSize: 12.5)),
                    onPressed: () {
                      final shareText = '${entry.chapterTitle}\n\n${entry.arabicMatn}\n[${entry.sourceAndGrade}]\n\n💡 الفوائد: ${entry.sharhAndBenefits}\n— تطبيق نور المؤمن';
                      try {
                        Share.share(shareText);
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
  }
}
