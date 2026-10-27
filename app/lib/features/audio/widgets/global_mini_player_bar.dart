import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/theme/app_theme.dart';
import 'full_screen_studio_player.dart';

/// Global Mini Player Bar docked above the bottom navigation bar across the entire app.
class GlobalMiniPlayerBar extends StatefulWidget {
  const GlobalMiniPlayerBar({super.key});

  @override
  State<GlobalMiniPlayerBar> createState() => _GlobalMiniPlayerBarState();
}

class _GlobalMiniPlayerBarState extends State<GlobalMiniPlayerBar>
    with SingleTickerProviderStateMixin {
  final IslamicAudioService _audioService = IslamicAudioService.instance;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _audioService.addListener(_onAudioStateChange);
    if (_audioService.isPlaying) {
      _rotationController.repeat();
    }
  }

  void _onAudioStateChange() {
    if (!mounted) return;
    if (_audioService.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!_audioService.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChange);
    _rotationController.dispose();
    super.dispose();
  }

  IconData _getTrackIcon(IslamicAudioType type) {
    switch (type) {
      case IslamicAudioType.quran:
        return Icons.menu_book_rounded;
      case IslamicAudioType.story:
      case IslamicAudioType.lesson:
        return Icons.record_voice_over_rounded;
      case IslamicAudioType.adhan:
        return Icons.mosque_rounded;
      case IslamicAudioType.iqamah:
        return Icons.timer_rounded;
      case IslamicAudioType.adhkar:
      case IslamicAudioType.tasbih:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = _audioService.currentTrack;
    if (track == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pos = _audioService.position.inMilliseconds.toDouble();
    final dur = _audioService.duration.inMilliseconds.toDouble();
    final progress = dur > 0 ? (pos / dur).clamp(0.0, 1.0) : 0.0;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FullScreenStudioPlayer.show(context);
          },
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D18) : const Color(0xFFFAFAF7),
              border: Border(
                top: BorderSide(
                  color: AppColors.accentGold.withOpacity(0.4),
                  width: 1.5,
                ),
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Top Linear Progress Line
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 2.5,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  ),
                ),

                // 2. Bar Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      // Rotating Medallion Icon
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                            ),
                            border: Border.all(
                              color: AppColors.accentGold,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getTrackIcon(track.type),
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title & Reciter Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              track.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.softGold : AppColors.secondaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Control Buttons Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 10s Rewind
                          IconButton(
                            iconSize: 22,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: 'ترجيع ١٠ ثوانٍ',
                            icon: const Icon(Icons.replay_10_rounded),
                            color: isDark ? Colors.white70 : Colors.black54,
                            onPressed: () => _audioService.seekBackward(seconds: 10),
                          ),
                          const SizedBox(width: 4),

                          // Play / Pause Button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.accentGold, AppColors.softGold],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentGold.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 26,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              tooltip: _audioService.isPlaying ? 'إيقاف مؤقت' : 'استئناف',
                              icon: Icon(
                                _audioService.isBuffering
                                    ? Icons.hourglass_top_rounded
                                    : (_audioService.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded),
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                if (_audioService.isPlaying) {
                                  _audioService.pause();
                                } else {
                                  _audioService.resume();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),

                          // 10s Forward
                          IconButton(
                            iconSize: 22,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: 'تقديم ١٠ ثوانٍ',
                            icon: const Icon(Icons.forward_10_rounded),
                            color: isDark ? Colors.white70 : Colors.black54,
                            onPressed: () => _audioService.seekForward(seconds: 10),
                          ),
                          const SizedBox(width: 4),

                          // Close Button
                          IconButton(
                            iconSize: 18,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: 'إغلاق المشغل',
                            icon: const Icon(Icons.close_rounded),
                            color: isDark ? Colors.white38 : Colors.grey,
                            onPressed: () => _audioService.stop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
