import 'package:flutter/material.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/memorization_item.dart';
import '../../../core/services/memorization_service.dart';
import '../../../core/theme/app_theme.dart';

/// Ayah card with interactive word-level masking and spaced-repetition Leitner rating buttons.
class MemorizationAyahCard extends StatelessWidget {
  final Ayah ayah;
  final int surahId;
  final bool isCurrentPlaying;
  final bool isDelaying;
  final int remainingDelaySeconds;
  final int currentAyahRepeat;
  final int ayahRepeatTarget;
  final MemorizationHideMode hideMode;
  final Set<String> revealedWords;
  final bool isDark;
  final void Function(int ayahNumber, int wordIndex) onToggleWordReveal;
  final void Function(Ayah ayah, MemorizationRating rating) onRateAyah;

  const MemorizationAyahCard({
    super.key,
    required this.ayah,
    required this.surahId,
    required this.isCurrentPlaying,
    required this.isDelaying,
    required this.remainingDelaySeconds,
    required this.currentAyahRepeat,
    required this.ayahRepeatTarget,
    required this.hideMode,
    required this.revealedWords,
    required this.isDark,
    required this.onToggleWordReveal,
    required this.onRateAyah,
  });

  @override
  Widget build(BuildContext context) {
    final memItem = MemorizationService.instance.getItem(surahId, ayah.ayahNumber);
    final words = MemorizationMaskHelper.splitAyahWords(ayah.textUthmani);

    return Card(
      elevation: isCurrentPlaying ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCurrentPlaying ? AppColors.accentGold : Colors.transparent,
          width: isCurrentPlaying ? 2 : 0,
        ),
      ),
      color: isCurrentPlaying
          ? (isDark ? const Color(0xFF233020) : const Color(0xFFF0F7F2))
          : (isDark ? AppColors.darkSurface : Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Ayah Number + Spaced-Repetition Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrentPlaying ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الآية ${ayah.ayahNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrentPlaying ? Colors.black : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    if (isCurrentPlaying) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDelaying
                              ? 'وقفة للترديد ($remainingDelaySeconds ث)'
                              : 'تكرار $currentAyahRepeat من ${ayahRepeatTarget >= 999 ? "∞" : ayahRepeatTarget}',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                // Leitner Status Badge
                if (memItem != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: memItem.leitnerBox >= 3 ? Colors.green.withOpacity(0.15) : Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'الصندوق ${memItem.leitnerBox}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: memItem.leitnerBox >= 3 ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Ayah Text with Interactive Masking
            Wrap(
              spacing: 6,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(words.length, (wordIdx) {
                final isRevealed = revealedWords.contains('${ayah.ayahNumber}:$wordIdx');
                final isMasked = MemorizationMaskHelper.isWordMasked(
                  wordIndex: wordIdx,
                  totalWords: words.length,
                  mode: hideMode,
                  isRevealed: isRevealed,
                );

                if (isMasked) {
                  // Interactive blurred / hidden pill
                  return InkWell(
                    onTap: () => onToggleWordReveal(ayah.ayahNumber, wordIdx),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.withOpacity(0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, size: 12, color: AppColors.mutedText),
                          SizedBox(width: 4),
                          Text(
                            '••••••',
                            style: TextStyle(
                              letterSpacing: 2,
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Visible word (or user-revealed word)
                return InkWell(
                  onTap: () {
                    if (hideMode != MemorizationHideMode.none) {
                      onToggleWordReveal(ayah.ayahNumber, wordIdx);
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: isRevealed ? AppColors.accentGold.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      words[wordIdx],
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.8,
                        fontWeight: isCurrentPlaying ? FontWeight.bold : FontWeight.w500,
                        color: isRevealed ? AppColors.accentGold : null,
                        fontFamilyFallback: const ['Traditional Arabic', 'Amiri', 'serif'],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Rating / Leitner Evaluation Buttons (FR-MEM-003)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatingButton(
                    label: 'متقن',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onTap: () => onRateAyah(ayah, MemorizationRating.easy),
                  ),
                  _buildRatingButton(
                    label: 'تثبيت',
                    icon: Icons.timelapse,
                    color: Colors.amber.shade800,
                    onTap: () => onRateAyah(ayah, MemorizationRating.hard),
                  ),
                  _buildRatingButton(
                    label: 'نسيت',
                    icon: Icons.replay,
                    color: Colors.redAccent,
                    onTap: () => onRateAyah(ayah, MemorizationRating.forgot),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
