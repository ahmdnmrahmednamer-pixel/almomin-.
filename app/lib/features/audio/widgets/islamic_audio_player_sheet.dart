import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/notifications/prayer_notification_service.dart';
import '../../../core/theme/app_theme.dart';

class IslamicAudioPlayerSheet extends StatefulWidget {
  final IslamicAudioType? initialFilter;

  const IslamicAudioPlayerSheet({
    super.key,
    this.initialFilter,
  });

  static Future<void> show(BuildContext context, {IslamicAudioType? filter}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IslamicAudioPlayerSheet(initialFilter: filter),
    );
  }

  @override
  State<IslamicAudioPlayerSheet> createState() => _IslamicAudioPlayerSheetState();
}

class _IslamicAudioPlayerSheetState extends State<IslamicAudioPlayerSheet> {
  late IslamicAudioType? _selectedType;
  final IslamicAudioService _audioService = IslamicAudioService.instance;
  final PrayerNotificationService _notifService = PrayerNotificationService.instance;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilter;
    _audioService.addListener(_onServiceUpdate);
    _notifService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onServiceUpdate);
    _notifService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTracks = IslamicAudioService.allTracks;
    final filteredTracks = _selectedType == null
        ? allTracks
        : allTracks.where((t) => t.type == _selectedType).toList();

    final currentTrack = _audioService.currentTrack;
    final isPlaying = _audioService.isPlaying;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أصوات الأذان والإقامة والأذكار',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'أصوات نقية مدمجة بالكامل تعمل بدون إنترنت 🎧',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق أو مسح',
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('الكل (${allTracks.length})', null, Icons.all_inclusive_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'الأذان المبارك (${_audioService.getTracksByType(IslamicAudioType.adhan).length})',
                    IslamicAudioType.adhan,
                    Icons.mosque_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'إقامة الصلاة (${_audioService.getTracksByType(IslamicAudioType.iqamah).length})',
                    IslamicAudioType.iqamah,
                    Icons.notifications_active_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'الأذكار الصوتية (${_audioService.getTracksByType(IslamicAudioType.adhkar).length})',
                    IslamicAudioType.adhkar,
                    Icons.auto_stories_rounded,
                  ),
                ],
              ),
            ),

            const Divider(height: 16),

            // Track List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredTracks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final track = filteredTracks[idx];
                  final isCurrent = currentTrack?.id == track.id;
                  final isCurrentlyPlaying = isCurrent && isPlaying;
                  final isDefaultAdhan = _notifService.selectedAdhanVoice == track.rawNotificationSound;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? (isDark ? const Color(0xFF1B3D2F) : const Color(0xFFE8F5E9))
                          : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.accentGold
                            : (isDark ? Colors.white12 : Colors.grey.shade200),
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent
                              ? AppColors.accentGold.withOpacity(0.15)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: isCurrent ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Play/Pause Action Button
                            GestureDetector(
                              onTap: () => _audioService.playTrack(track),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isCurrentlyPlaying
                                        ? [const Color(0xFFD4AF37), const Color(0xFFB89628)]
                                        : [AppColors.primaryGreen, AppColors.secondaryGreen],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isCurrentlyPlaying ? AppColors.accentGold : AppColors.primaryGreen)
                                          .withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    isCurrentlyPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Track Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          track.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (track.assetPath != null || _audioService.isDownloaded(track.id))
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'أوفلاين ⚡',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.green,
                                            ),
                                          ),
                                        )
                                      else if (_audioService.isDownloading(track.id))
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            value: _audioService.getDownloadProgress(track.id).clamp(0.0, 1.0),
                                            strokeWidth: 2,
                                            color: AppColors.accentGold,
                                          ),
                                        )
                                      else if (track.remoteUrl != null)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'بث مباشر 🌐',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.download_for_offline_outlined, size: 18, color: AppColors.primaryGreen),
                                              tooltip: 'تحميل للاستماع دون إنترنت',
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () async {
                                                final ok = await _audioService.downloadTrack(track.id);
                                                if (ok && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('تم تنزيل ' + track.title + ' بنجاح للاستماع دون إنترنت')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white60 : AppColors.mutedText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Inline Progress Bar when Track is Active
                        if (isCurrent) ...[
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3.5,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  activeTrackColor: AppColors.primaryGreen,
                                  inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade300,
                                  thumbColor: AppColors.accentGold,
                                ),
                                child: Slider(
                                  value: _audioService.position.inSeconds
                                      .toDouble()
                                      .clamp(0.0, (_audioService.duration.inSeconds > 0
                                          ? _audioService.duration.inSeconds.toDouble()
                                          : 1.0)),
                                  max: _audioService.duration.inSeconds > 0
                                      ? _audioService.duration.inSeconds.toDouble()
                                      : 1.0,
                                  onChanged: (val) {
                                    _audioService.seek(Duration(seconds: val.toInt()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_audioService.position),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      _formatDuration(_audioService.duration),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white54 : AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Footer Buttons: Default Adhan Setter
                        if (track.rawNotificationSound != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isDefaultAdhan)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accentGold),
                                      SizedBox(width: 5),
                                      Text(
                                        'نغمة التنبيه المعتمدة للصلوات',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.accentGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async {
                                    await _notifService.setSelectedAdhanVoice(track.rawNotificationSound!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('تم اعتماد "${track.title}" كنغمة التنبيه للصلوات 🕌'),
                                          backgroundColor: AppColors.primaryGreen,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.primaryGreen),
                                        SizedBox(width: 5),
                                        Text(
                                          'تعيين كنغمة التنبيه',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
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

  Widget _buildFilterChip(String label, IslamicAudioType? type, IconData icon) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.white12 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.mutedText),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
