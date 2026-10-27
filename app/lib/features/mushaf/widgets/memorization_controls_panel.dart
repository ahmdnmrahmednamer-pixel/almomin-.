import 'package:flutter/material.dart';
import '../../../core/models/memorization_item.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_theme.dart';

/// Configuration panel for surah range, audio loop repeats, delay, and hide-to-test modes.
class MemorizationControlsPanel extends StatelessWidget {
  final bool isDark;
  final List<Surah> surahs;
  final int selectedSurahId;
  final Surah? currentSurah;
  final int fromAyah;
  final int toAyah;
  final int ayahRepeatTarget;
  final int rangeRepeatTarget;
  final int delaySeconds;
  final MemorizationHideMode hideMode;
  final ValueChanged<int> onSurahChanged;
  final ValueChanged<int> onFromAyahChanged;
  final ValueChanged<int> onToAyahChanged;
  final ValueChanged<int> onAyahRepeatChanged;
  final ValueChanged<int> onRangeRepeatChanged;
  final ValueChanged<int> onDelayChanged;
  final ValueChanged<MemorizationHideMode> onHideModeChanged;
  final VoidCallback onRevealAllWords;
  final VoidCallback onHideAllWords;

  const MemorizationControlsPanel({
    super.key,
    required this.isDark,
    required this.surahs,
    required this.selectedSurahId,
    required this.currentSurah,
    required this.fromAyah,
    required this.toAyah,
    required this.ayahRepeatTarget,
    required this.rangeRepeatTarget,
    required this.delaySeconds,
    required this.hideMode,
    required this.onSurahChanged,
    required this.onFromAyahChanged,
    required this.onToAyahChanged,
    required this.onAyahRepeatChanged,
    required this.onRangeRepeatChanged,
    required this.onDelayChanged,
    required this.onHideModeChanged,
    required this.onRevealAllWords,
    required this.onHideAllWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Surah Selection & Ayah Bounds Pickers
          Row(
            children: [
              // Surah Dropdown
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: surahs.any((s) => s.id == selectedSurahId)
                          ? selectedSurahId
                          : (surahs.isNotEmpty ? surahs.first.id : null),
                      items: surahs.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            '${s.id}. ${s.nameAr}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && val != selectedSurahId) {
                          onSurahChanged(val);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // From Ayah Picker
              Expanded(
                flex: 2,
                child: _buildNumberSelector(
                  label: 'من آية',
                  value: fromAyah,
                  max: currentSurah?.ayahCount ?? 7,
                  onChanged: onFromAyahChanged,
                ),
              ),
              const SizedBox(width: 6),

              // To Ayah Picker
              Expanded(
                flex: 2,
                child: _buildNumberSelector(
                  label: 'إلى آية',
                  value: toAyah,
                  max: currentSurah?.ayahCount ?? 7,
                  onChanged: onToAyahChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Loop Target Controls (Ayah Repeats, Range Repeats, Delay)
          Row(
            children: [
              _buildCompactBadge(
                title: 'تكرار الآية',
                value: ayahRepeatTarget >= 999 ? 'مستمر' : '${ayahRepeatTarget}x',
                options: [1, 3, 5, 7, 10, 999],
                onSelected: onAyahRepeatChanged,
              ),
              const SizedBox(width: 8),
              _buildCompactBadge(
                title: 'تكرار المقطع',
                value: rangeRepeatTarget >= 999 ? 'مستمر' : '${rangeRepeatTarget}x',
                options: [1, 2, 3, 5, 999],
                onSelected: onRangeRepeatChanged,
              ),
              const SizedBox(width: 8),
              _buildCompactBadge(
                title: 'وقفة الترديد',
                value: delaySeconds == 0 ? 'بدون' : '$delaySeconds ث',
                options: [0, 1, 2, 3, 5],
                onSelected: onDelayChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Hide-To-Test Modes (FR-MEM-002)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHideModeChip('كامل الآية ظاهر', MemorizationHideMode.none, Icons.visibility),
                const SizedBox(width: 6),
                _buildHideModeChip('إخفاء النصف الثاني', MemorizationHideMode.secondHalf, Icons.hourglass_bottom),
                const SizedBox(width: 6),
                _buildHideModeChip('إخفاء كلمات متناوبة', MemorizationHideMode.everyNthWord, Icons.shuffle),
                const SizedBox(width: 6),
                _buildHideModeChip('إخفاء كامل (غيباً)', MemorizationHideMode.allWords, Icons.visibility_off),
                if (hideMode != MemorizationHideMode.none) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('كشف الكل', style: TextStyle(fontSize: 11)),
                    onPressed: onRevealAllWords,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('إخفاء الكل', style: TextStyle(fontSize: 11)),
                    onPressed: onHideAllWords,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector({
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedText)),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              isDense: true,
              value: value.clamp(1, max < 1 ? 1 : max),
              items: List.generate(max < 1 ? 1 : max, (i) => i + 1).map((num) {
                return DropdownMenuItem<int>(
                  value: num,
                  child: Text('$num', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge({
    required String title,
    required String value,
    required List<int> options,
    required ValueChanged<int> onSelected,
  }) {
    return Expanded(
      child: PopupMenuButton<int>(
        tooltip: title,
        onSelected: onSelected,
        itemBuilder: (context) {
          return options.map((opt) {
            final text = opt >= 999 ? 'مستمر (∞)' : (title.contains('وقفة') ? '$opt ثوانٍ' : '$opt مرات');
            return PopupMenuItem<int>(
              value: opt,
              child: Text(text),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: AppColors.mutedText)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHideModeChip(String title, MemorizationHideMode mode, IconData icon) {
    final isSelected = hideMode == mode;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onHideModeChanged(mode);
        }
      },
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.primaryGreen),
      label: Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      visualDensity: VisualDensity.compact,
    );
  }
}
