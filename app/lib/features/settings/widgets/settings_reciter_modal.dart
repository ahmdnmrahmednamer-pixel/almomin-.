import '../../../core/text/arabic_normalizer.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/audio/ayah_audio_player.dart';

void showSettingsReciterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ReciterSelectionSheet(),
  );
}

class _ReciterSelectionSheet extends StatefulWidget {
  const _ReciterSelectionSheet();

  @override
  State<_ReciterSelectionSheet> createState() => _ReciterSelectionSheetState();
}

class _ReciterSelectionSheetState extends State<_ReciterSelectionSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentReciterId = SettingsService.instance.selectedReciterId;

    final allReciters = SettingsService.availableReciters;
    final normRecQ = ArabicNormalizer.normalize(_searchQuery, loose: true);
    final filteredReciters = allReciters.where((r) {
      final matchesQuery = _searchQuery.isEmpty ||
          r.nameAr.contains(_searchQuery) ||
          ArabicNormalizer.normalize(r.nameAr, loose: true).contains(normRecQ) ||
          r.style.contains(_searchQuery) ||
          ArabicNormalizer.normalize(r.style, loose: true).contains(normRecQ) ||
          r.id.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'الكل' || r.style == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'اختر القارئ الافتراضي للتلاوة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          'القارئ الحالي: ${SettingsService.instance.currentReciter.nameAr}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredReciters.length} قارئ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم القارئ (مثل: المنشاوي، الحصري، عبد الباسط)...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                        tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.06),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),

            // Style Categories Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: ['الكل', 'مرتل', 'مجود', 'المعلم', 'تلاوة خاشعة'].map((cat) {
                  final isCatSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilterChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCatSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isCatSelected ? Colors.white : AppColors.primaryGreen,
                        ),
                      ),
                      selected: isCatSelected,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: isDark ? const Color(0xFF242A27) : AppColors.primaryGreen.withOpacity(0.08),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Reciters List
            Expanded(
              child: filteredReciters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          Text(
                            'لم يتم العثور على قارئ يطابق "$_searchQuery"',
                            style: const TextStyle(color: AppColors.mutedText, fontSize: 13.5),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filteredReciters.length,
                      itemBuilder: (ctx, index) {
                        final r = filteredReciters[index];
                        final isSelected = currentReciterId == r.id;
                        final isMinshawi = r.id == 'minshawi_murattal';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryGreen.withOpacity(0.10)
                                : (isDark ? const Color(0xFF1B221E) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGold
                                  : (isDark ? Colors.white12 : Colors.grey.shade200),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentGold.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : (isDark ? const Color(0xFF28342E) : AppColors.primaryGreen.withOpacity(0.08)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? Icons.check_rounded : Icons.person_rounded,
                                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.nameAr,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                        fontSize: 14.5,
                                        color: isSelected ? AppColors.primaryGreen : null,
                                      ),
                                    ),
                                  ),
                                  if (isMinshawi)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'الافتراضي ⭐',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.style,
                                      style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'رواية حفص عن عاصم',
                                    style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'محدد 🎧',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                            onTap: () async {
                              await SettingsService.instance.setSelectedReciter(r.id);
                              await AyahAudioPlayer.instance.playReciterPreview(r);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم اعتماد القارئ: ${r.nameAr} — جاري سماع صوته الآن 🎧',
                                      style: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                    backgroundColor: AppColors.primaryGreen,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
