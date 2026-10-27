import '../../../core/services/settings_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/islamic_audio_service.dart';
import '../../../core/theme/app_theme.dart';

/// Full-screen Luxury Islamic Audio Studio Player.
class FullScreenStudioPlayer extends StatefulWidget {
  const FullScreenStudioPlayer({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FullScreenStudioPlayer(),
    );
  }

  @override
  State<FullScreenStudioPlayer> createState() => _FullScreenStudioPlayerState();
}

class _FullScreenStudioPlayerState extends State<FullScreenStudioPlayer>
    with SingleTickerProviderStateMixin {
  final IslamicAudioService _audioService = IslamicAudioService.instance;
  late AnimationController _rotationController;
  Timer? _timerTicker;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _audioService.addListener(_onAudioUpdate);
    if (_audioService.isPlaying) {
      _rotationController.repeat();
    }

    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _audioService.sleepTimerMinutes != null) {
        setState(() {});
      }
    });
  }

  void _onAudioUpdate() {
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
    _audioService.removeListener(_onAudioUpdate);
    _rotationController.dispose();
    _timerTicker?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _showSpeedPicker() {
    final speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'سرعة التلاوة والصوت',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: speeds.map((speed) {
                  final isSelected = _audioService.playbackSpeed == speed;
                  return ChoiceChip(
                    label: Text(
                      '${speed}x',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    onSelected: (_) {
                      _audioService.setPlaybackSpeed(speed);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerPicker() {
    final options = [15, 30, 45, 60];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bedtime_rounded, color: AppColors.accentGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'مؤقت النوم الذكي (إيقاف تلقائي)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_audioService.sleepTimerMinutes != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'متبقي: ${_audioService.sleepTimerRemainingSeconds != null ? _formatDuration(Duration(seconds: _audioService.sleepTimerRemainingSeconds!)) : ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold),
                      ),
                      TextButton(
                        onPressed: () {
                          _audioService.cancelSleepTimer();
                          Navigator.pop(ctx);
                        },
                        child: const Text('إلغاء المؤقت', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ...options.map((mins) {
                    final isSel = _audioService.sleepTimerMinutes == mins;
                    return ActionChip(
                      avatar: const Icon(Icons.timer_outlined, size: 16),
                      label: Text('$mins دقيقة'),
                      backgroundColor: isSel ? AppColors.accentGold.withOpacity(0.3) : null,
                      onPressed: () {
                        _audioService.setSleepTimer(mins);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('سيتم إيقاف التشغيل تلقائياً بعد $mins دقيقة 🌙'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      },
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.stop_circle_outlined, size: 16),
                    label: const Text('عند نهاية السورة/المقطع'),
                    onPressed: () {
                      _audioService.setSleepTimer(999, stopAtTrackEnd: true);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('سيتم إيقاف التشغيل عند انتهاء المقطع الحالي 🌙'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueueSheet() {
    final queue = _audioService.queue;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.65,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قائمة التشغيل الحالية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${queue.length} مقطع',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: queue.isEmpty
                    ? const Center(child: Text('لا توجد مقاطع أخرى في قائمة الانتظار'))
                    : ListView.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, idx) {
                          final item = queue[idx];
                          final isCurrent = _audioService.currentTrack?.id == item.id;

                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? AppColors.accentGold
                                    : AppColors.primaryGreen.withOpacity(0.12),
                              ),
                              child: Icon(
                                isCurrent ? Icons.volume_up_rounded : Icons.audiotrack_rounded,
                                size: 18,
                                color: isCurrent ? Colors.black87 : AppColors.primaryGreen,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                color: isCurrent ? AppColors.secondaryGreen : null,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            trailing: Text(
                              item.durationFormatted,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            onTap: () {
                              _audioService.playTrack(item);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareCurrentTrack(IslamicAudioTrack track) {
    final text =
        'استمع الآن إلى ${track.title} (${track.subtitle}) عبر تطبيق «نور المؤمن» مجاناً وبدون إعلانات.\nhttps://almomin.app';
    try {
      Share.share(text, subject: track.title);
    } catch (_) {}
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
    final pos = _audioService.position;
    final dur = _audioService.duration;
    final posSec = pos.inSeconds.toDouble();
    final durSec = dur.inSeconds > 0 ? dur.inSeconds.toDouble() : 1.0;
    final isDownloaded = _audioService.isDownloaded(track.id);
    final isDownloading = _audioService.isDownloading(track.id);

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF09120C) : const Color(0xFF0F2016),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Top Bar & Minimize Button
                      Column(
                        children: [
                          Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: Colors.white),
                                tooltip: 'تصغير المشغل',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'المشغل الصوتي الاستوديو 🎙️',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'تطبيق نور المؤمن — استماع بدون إنترنت',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.queue_music_rounded, color: AppColors.accentGold),
                                tooltip: 'قائمة التشغيل',
                                onPressed: _showQueueSheet,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. Center: Spinning Geometric Islamic Medallion Disc
                      RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF1E3A2B),
                                Color(0xFF0F1E16),
                                Color(0xFF070E0A),
                              ],
                              stops: [0.3, 0.7, 1.0],
                            ),
                            border: Border.all(
                              color: AppColors.accentGold,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: AppColors.accentGold.withOpacity(0.2),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative concentric rings
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accentGold.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryGreen,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _getTrackIcon(track.type),
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 3. Track Info & Badges
                      Column(
                        children: [
                          Text(
                            track.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Badges Row
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                                ),
                                child: Text(
                                  track.categoryAr ?? 'محتوى إسلامي',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                                ),
                                child: Text(
                                  track.quality,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isDownloaded || track.isBundled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green.withOpacity(0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.offline_pin_rounded, size: 13, color: Colors.greenAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        'جاهز دون إنترنت',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 4. Scrubber / Slider
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accentGold,
                              inactiveTrackColor: Colors.white12,
                              thumbColor: AppColors.accentGold,
                              overlayColor: AppColors.accentGold.withOpacity(0.2),
                              trackHeight: 4.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: posSec.clamp(0.0, durSec),
                              min: 0.0,
                              max: durSec,
                              onChanged: (val) {
                                _audioService.seek(Duration(seconds: val.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(pos),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDuration(dur),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 5. Main Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle
                          IconButton(
                            iconSize: 24,
                            tooltip: 'خلط المقاطع',
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: _audioService.shuffleEnabled
                                  ? AppColors.accentGold
                                  : Colors.white38,
                            ),
                            onPressed: _audioService.toggleShuffle,
                          ),

                          // Previous / Rewind 10s
                          IconButton(
                            iconSize: 34,
                            tooltip: 'السابق / ترجيع ١٠ث',
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                            onPressed: () {
                              if (_audioService.hasPrevious) {
                                _audioService.playPrevious();
                              } else {
                                _audioService.seekBackward(seconds: 10);
                              }
                            },
                          ),

                          // Main Play / Pause Hero Button
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.accentGold, AppColors.softGold],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentGold.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: IconButton(
                                iconSize: 38,
                                padding: EdgeInsets.zero,
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
                          ),

                          // Next / Forward 10s
                          IconButton(
                            iconSize: 34,
                            tooltip: 'التالي / تقديم ١٠ث',
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                            onPressed: () {
                              if (_audioService.hasNext) {
                                _audioService.playNext();
                              } else {
                                _audioService.seekForward(seconds: 10);
                              }
                            },
                          ),

                          // Repeat Mode Toggle
                          IconButton(
                            iconSize: 24,
                            tooltip: 'نمط التكرار',
                            icon: Icon(
                              _audioService.loopMode == PlaybackLoopMode.single
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              color: _audioService.loopMode != PlaybackLoopMode.off
                                  ? AppColors.accentGold
                                  : Colors.white38,
                            ),
                            onPressed: _audioService.toggleLoopMode,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 6. Smart Actions Toolbar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Speed
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              onPressed: _showSpeedPicker,
                              icon: const Icon(Icons.speed_rounded, size: 17, color: AppColors.secondaryGreen),
                              label: Text(
                                '${_audioService.playbackSpeed}x',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Sleep Timer
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: _audioService.sleepTimerMinutes != null
                                    ? AppColors.accentGold
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                              onPressed: _showSleepTimerPicker,
                              icon: Icon(
                                Icons.bedtime_rounded,
                                size: 17,
                                color: _audioService.sleepTimerMinutes != null
                                    ? AppColors.accentGold
                                    : Colors.white70,
                              ),
                              label: Text(
                                _audioService.sleepTimerMinutes != null
                                    ? '${_audioService.sleepTimerRemainingSeconds != null ? _audioService.sleepTimerRemainingSeconds! ~/ 60 : _audioService.sleepTimerMinutes}د'
                                    : 'مؤقت',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Offline Download Button
                            if (!isDownloaded && !track.isBundled && track.remoteUrl != null)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                onPressed: isDownloading
                                    ? null
                                    : () async {
                                        final ok = await _audioService.downloadTrack(track.id);
                                        if (mounted && ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم اكتمال التحميل للاستخدام أوفلاين ✓')),
                                          );
                                        }
                                      },
                                icon: isDownloading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold),
                                      )
                                    : const Icon(Icons.download_rounded, size: 17, color: Colors.lightBlueAccent),
                                label: const Text('تحميل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),

                            // Share Track
                            IconButton(
                              icon: const Icon(Icons.share_rounded, size: 20, color: Colors.white70),
                              tooltip: 'مشاركة التلاوة',
                              onPressed: () => _shareCurrentTrack(track),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
