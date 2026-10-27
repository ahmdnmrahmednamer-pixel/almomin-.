import 'package:flutter/material.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom bar for Quran memorization audio loop controls.
class MemorizationPlaybackBar extends StatelessWidget {
  final bool isDark;
  final bool isPlaying;
  final int currentAyahNumber;
  final int fromAyah;
  final int toAyah;
  final int currentRangeRepeat;
  final int rangeRepeatTarget;
  final VoidCallback onPlayPause;
  final VoidCallback? onStop;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSelectReciter;

  const MemorizationPlaybackBar({
    super.key,
    required this.isDark,
    required this.isPlaying,
    required this.currentAyahNumber,
    required this.fromAyah,
    required this.toAyah,
    required this.currentRangeRepeat,
    required this.rangeRepeatTarget,
    required this.onPlayPause,
    required this.onStop,
    required this.onPrev,
    required this.onNext,
    required this.onSelectReciter,
  });

  @override
  Widget build(BuildContext context) {
    final reciter = SettingsService.instance.currentReciter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status and Reciter Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.record_voice_over, size: 14, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Text(
                      'القارئ: ${reciter.nameAr}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                    ),
                  ],
                ),
                Text(
                  isPlaying
                      ? 'الآية: $currentAyahNumber · مقطع $currentRangeRepeat/${rangeRepeatTarget >= 999 ? "∞" : rangeRepeatTarget}'
                      : 'المقطع: $fromAyah إلى $toAyah',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Playback Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stop Button
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, size: 28),
                  tooltip: 'إيقاف كامل',
                  onPressed: onStop,
                ),
                const SizedBox(width: 12),

                // Previous Ayah
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 30),
                  tooltip: 'الآية السابقة',
                  onPressed: onPrev,
                ),
                const SizedBox(width: 12),

                // Main Play / Pause Button
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 34,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    tooltip: isPlaying ? 'إيقاف مؤقت' : 'بدء التكرار والتحفيظ',
                    onPressed: onPlayPause,
                  ),
                ),
                const SizedBox(width: 12),

                // Next Ayah
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 30),
                  tooltip: 'الآية التالية',
                  onPressed: onNext,
                ),
                const SizedBox(width: 12),

                // Quick Reciter change
                IconButton(
                  icon: const Icon(Icons.tune, size: 24),
                  tooltip: 'اختيار قارئ آخر',
                  onPressed: onSelectReciter,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
