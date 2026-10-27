import 'package:flutter/material.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/widgets/settings_adhan_voice_modal.dart';
import '../adhan_control_screen.dart';

/// Quick listening card for Adhan and Iqamah audio tracks (FR-AUD-005).
class PrayerAudioQuickCard extends StatelessWidget {
  final bool isDark;

  const PrayerAudioQuickCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final audioService = IslamicAudioService.instance;
    final currentTrack = audioService.currentTrack;
    final isPlaying = audioService.isPlaying;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.headphones_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'سماع الأذان والإقامة 🎧',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'أصوات الحرمين ومصر والقدس والإقامة المدمجة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdhanControlScreen(prayerName: 'الظهر', autoPlay: false),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app_rounded, size: 12, color: AppColors.accentGold),
                            SizedBox(width: 4),
                            Text(
                              'شاشة التحكم 🎛️',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => showSettingsAdhanVoiceModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اختيار الشيوخ 🕌',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Active Track Banner if playing
            if (currentTrack != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3D2F) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'تشغيل أو إيقاف الصوت',
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: AppColors.accentGold,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.resume();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentTrack.subtitle,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white60 : AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'إغلاق أو مسح',
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => audioService.stop(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Quick Play Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAudioPill(
                    label: 'أذان مكة 🕋',
                    trackId: 'adhan_makkah',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAudioPill(
                    label: 'أذان المدينة 🕌',
                    trackId: 'adhan_madinah',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAudioPill(
                    label: 'أذان القاهرة 📻',
                    trackId: 'adhan_cairo_refaat',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAudioPill(
                    label: 'دعاء الشعراوي 🤲',
                    trackId: 'duaa_sharawi_post_prayer',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAudioPill(
                    label: 'أذان الأقصى 🇵🇸',
                    trackId: 'adhan_aqsa',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAudioPill(
                    label: 'صوت الإقامة 🔊',
                    trackId: 'iqamah_full',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAudioPill({
    required String label,
    required String trackId,
    required bool isDark,
  }) {
    final audioService = IslamicAudioService.instance;
    final isThisTrack = audioService.currentTrack?.id == trackId;
    final isPlaying = isThisTrack && audioService.isPlaying;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final track = IslamicAudioService.allTracks.firstWhere((t) => t.id == trackId, orElse: () => IslamicAudioService.allTracks.first);
          audioService.playTrack(track);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.primaryGreen
                : (isDark ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlaying
                  ? AppColors.accentGold
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
              width: isPlaying ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 14,
                color: isPlaying ? Colors.white : AppColors.primaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isPlaying ? Colors.white : (isDark ? Colors.white : AppColors.lightText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
