import '../../../core/services/settings_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/prophet_story.dart';
import '../../../core/services/stories_service.dart';
import '../../../core/audio/fast_audio_service.dart';
import '../../../core/theme/app_theme.dart';

/// Full-featured Audio Player Sheet for Prophet Stories (مشغل قصص الأنبياء الصوتي)
class ProphetStoryPlayerSheet extends StatefulWidget {
  final ProphetAudioStory story;

  const ProphetStoryPlayerSheet({super.key, required this.story});

  static Future<void> show(BuildContext context, ProphetAudioStory story) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProphetStoryPlayerSheet(story: story),
    );
  }

  @override
  State<ProphetStoryPlayerSheet> createState() => _ProphetStoryPlayerSheetState();
}

class _ProphetStoryPlayerSheetState extends State<ProphetStoryPlayerSheet> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isBuffering = true;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  Timer? _sleepTimer;
  int? _sleepTimerMinutes;
  bool _isOfflinePlaying = false;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final localPath = StoriesService.instance.getLocalAudioPath(widget.story.id);

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = Duration.zero;
        }
      });
    });

    _posSub = _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });

    _durSub = _player.durationStream.listen((dur) {
      if (!mounted || dur == null) return;
      setState(() => _duration = dur);
    });

    try {
      _isOfflinePlaying = localPath != null;
      final cacheKey = 'story_${widget.story.id}';
      final source = await FastAudioService.instance.getFastAudioSource(
        widget.story.audioUrl,
        cacheKey: cacheKey,
        localDownloadedPath: localPath,
      );

      await FastAudioService.instance.playWithZeroDelay(
        _player,
        source,
        speed: _playbackSpeed,
        onStopCallback: () async {
          try {
            await _player.stop();
          } catch (_) {}
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        },
      );
    } catch (e) {
      debugPrint('Playback error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المقطع الصوتي: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _playerStateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
          title: const Text('مؤقت إيقاف القصة تلقائياً'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sleepTimerMinutes != null)
                ListTile(
                  leading: const Icon(Icons.timer_off, color: Colors.redAccent),
                  title: const Text('إلغاء المؤقت الحالي'),
                  onTap: () {
                    _sleepTimer?.cancel();
                    setState(() {
                      _sleepTimer = null;
                      _sleepTimerMinutes = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ...[15, 30, 45, 60].map((mins) => ListTile(
                    leading: const Icon(Icons.bedtime_outlined, color: AppColors.primaryGreen),
                    title: Text('إيقاف بعد $mins دقيقة'),
                    onTap: () {
                      _sleepTimer?.cancel();
                      setState(() {
                        _sleepTimerMinutes = mins;
                        _sleepTimer = Timer(Duration(minutes: mins), () {
                          _player.pause();
                          if (!mounted) return;
                          setState(() {
                            _sleepTimer = null;
                            _sleepTimerMinutes = null;
                          });
                        });
                      });
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _cycleSpeed() {
    final speeds = [0.75, 1.0, 1.25, 1.5];
    final nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final newSpeed = speeds[nextIdx];
    _player.setSpeed(newSpeed);
    setState(() => _playbackSpeed = newSpeed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final story = widget.story;
    final isDownloaded = StoriesService.instance.isDownloaded(story.id);
    final isDownloading = StoriesService.instance.isDownloading(story.id);
    final downloadProgress = StoriesService.instance.getDownloadProgress(story.id);

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header Row: Offline Badge & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOfflinePlaying
                        ? Colors.green.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isOfflinePlaying ? Colors.green : Colors.blueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOfflinePlaying ? Icons.offline_pin_rounded : Icons.cloud_outlined,
                        size: 14,
                        color: _isOfflinePlaying ? Colors.green : Colors.blueAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isOfflinePlaying ? 'استماع أوفلاين دون إنترنت ⚡' : 'بث مباشر من الإنترنت',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isOfflinePlaying ? Colors.green : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Download action in player
                    if (!isDownloaded)
                      isDownloading
                          ? SizedBox(
                              width: 32,
                              height: 32,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: downloadProgress.clamp(0.0, 1.0),
                                    strokeWidth: 2.5,
                                    color: AppColors.accentGold,
                                  ),
                                  Text(
                                    '${(downloadProgress * 100).toInt()}%',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.accentGold),
                              tooltip: 'تحميل القصة للاستماع دون إنترنت',
                              onPressed: () async {
                                final ok = await StoriesService.instance.downloadStory(story.id);
                                if (ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم تنزيل القصة بنجاح للاستماع دون إنترنت')),
                                  );
                                  setState(() => _isOfflinePlaying = true);
                                }
                              },
                            ),
                    IconButton(
                      icon: Icon(
                        _sleepTimerMinutes != null ? Icons.alarm_on : Icons.alarm,
                        color: _sleepTimerMinutes != null ? AppColors.accentGold : null,
                      ),
                      tooltip: 'مؤقت النوم',
                      onPressed: _showSleepTimerDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'إغلاق',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prophet Avatar & Titles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'صوت: ${story.narrator}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'المدة التقريبية: ${story.duration} • الحجم: ${story.formattedSize}',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Progress Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accentGold,
                inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade300,
                thumbColor: AppColors.accentGold,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 4,
              ),
              child: Slider(
                value: _duration.inMilliseconds > 0
                    ? _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble()
                    : 0.0,
                max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                onChanged: (val) {
                  _player.seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),

            // Time labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_format(_position), style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
                  Text(
                    _duration > Duration.zero ? _format(_duration) : story.duration,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Playback Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Speed Button
                TextButton(
                  onPressed: _cycleSpeed,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),

                // Skip -10s
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, size: 28),
                  tooltip: 'رجوع ١٠ ثوانٍ',
                  onPressed: () {
                    final newPos = _position - const Duration(seconds: 10);
                    _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                ),
                const SizedBox(width: 8),

                // Play / Pause Button
                _isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryGreen),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                        child: IconButton(
                          tooltip: 'تشغيل أو إيقاف الصوت',
                          iconSize: 36,
                          color: Colors.white,
                          icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          onPressed: () {
                            if (_isPlaying) {
                              _player.pause();
                            } else {
                              _player.play();
                            }
                          },
                        ),
                      ),
                const SizedBox(width: 8),

                // Skip +10s
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, size: 28),
                  tooltip: 'تقديم ١٠ ثوانٍ',
                  onPressed: () {
                    final newPos = _position + const Duration(seconds: 10);
                    if (_duration > Duration.zero && newPos > _duration) {
                      _player.seek(_duration);
                    } else {
                      _player.seek(newPos);
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Stop / Reset Button
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, size: 26),
                  tooltip: 'إيقاف وإعادة للبداية',
                  onPressed: () {
                    _player.pause();
                    _player.seek(Duration.zero);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
