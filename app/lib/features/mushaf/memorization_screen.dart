import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/surah.dart';
import '../../core/models/ayah.dart';
import '../../core/models/memorization_item.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/audio/fast_audio_service.dart';
import '../../core/services/memorization_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/memorization_ayah_card.dart';
import 'widgets/memorization_controls_panel.dart';
import 'widgets/memorization_dedication_banner.dart';
import 'widgets/memorization_dedication_dialog.dart';
import 'widgets/memorization_playback_bar.dart';

class MemorizationScreen extends StatefulWidget {
  final int initialSurahId;
  final int initialFromAyah;
  final int initialToAyah;

  const MemorizationScreen({
    super.key,
    this.initialSurahId = 1,
    this.initialFromAyah = 1,
    this.initialToAyah = 7,
  });

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  // Audio Player & Playback State
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isPlaying = false;
  int _currentAyahIndex = 0; // index inside _rangeAyahs
  int _currentAyahRepeat = 1;
  int _currentRangeRepeat = 1;
  bool _isDelaying = false;
  int _remainingDelaySeconds = 0;
  Timer? _delayTimer;

  // Configuration
  late int _selectedSurahId;
  late int _fromAyah;
  late int _toAyah;
  final double _playbackSpeed = 1.0;
  int _ayahRepeatTarget = 3; // 1, 3, 5, 7, 10, 999 (continuous)
  int _rangeRepeatTarget = 2; // 1, 2, 3, 5, 999
  int _delaySeconds = 1; // 0, 1, 2, 3, 5
  MemorizationHideMode _hideMode = MemorizationHideMode.none;

  // Data
  List<Surah> _surahs = [];
  Surah? _currentSurah;
  List<Ayah> _allSurahAyahs = [];
  List<Ayah> _rangeAyahs = [];
  bool _isLoading = true;

  // Revealed words per Ayah: key = '${ayahNumber}:${wordIndex}'
  final Set<String> _revealedWords = {};

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedSurahId = widget.initialSurahId;
    _fromAyah = widget.initialFromAyah;
    _toAyah = widget.initialToAyah;

    _player = AudioPlayer();
    _initAudioListeners();
    _loadInitialData();
  }

  void _initAudioListeners() {
    _playerStateSub?.cancel();
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        _onAyahAudioCompleted();
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final surahs = await QuranRepository.loadSurahs();
      if (surahs.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final surah = surahs.firstWhere(
        (s) => s.id == _selectedSurahId,
        orElse: () => surahs.first,
      );

      final ayahs = await QuranRepository.getAyahsForSurah(surah.id);
      if (!mounted) return;
      setState(() {
        _surahs = surahs;
        _currentSurah = surah;
        _allSurahAyahs = ayahs;
        _clampRange(surah.ayahCount);
        _filterRangeAyahs();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('MemorizationScreen load error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _clampRange(int maxAyah) {
    if (_fromAyah < 1) _fromAyah = 1;
    if (_fromAyah > maxAyah) _fromAyah = maxAyah;
    if (_toAyah < _fromAyah) _toAyah = _fromAyah;
    if (_toAyah > maxAyah) _toAyah = maxAyah;
  }

  void _filterRangeAyahs() {
    _rangeAyahs = _allSurahAyahs.where((a) {
      return a.ayahNumber >= _fromAyah && a.ayahNumber <= _toAyah;
    }).toList();

    _currentAyahIndex = 0;
    _currentAyahRepeat = 1;
    _currentRangeRepeat = 1;
    _revealedWords.clear();
  }

  Future<void> _onSurahChanged(int newSurahId) async {
    await _stopPlayback();
    setState(() => _isLoading = true);

    try {
      final surah = _surahs.firstWhere((s) => s.id == newSurahId, orElse: () => _surahs.first);
      final ayahs = await QuranRepository.getAyahsForSurah(surah.id);
      if (!mounted) return;
      setState(() {
        _selectedSurahId = newSurahId;
        _currentSurah = surah;
        _allSurahAyahs = ayahs;
        _fromAyah = 1;
        _toAyah = (surah.ayahCount >= 5) ? 5 : surah.ayahCount;
        _filterRangeAyahs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- Audio Loop Playback Engine ---

  Future<void> _startPlayback() async {
    if (_rangeAyahs.isEmpty) return;

    if (_currentAyahIndex >= _rangeAyahs.length) {
      _currentAyahIndex = 0;
      _currentAyahRepeat = 1;
    }

    setState(() => _isPlaying = true);
    await _playCurrentAyah();
  }

  Future<void> _playCurrentAyah() async {
    if (_currentAyahIndex < 0 || _currentAyahIndex >= _rangeAyahs.length) {
      await _stopPlayback();
      return;
    }

    final ayah = _rangeAyahs[_currentAyahIndex];
    final url = SettingsService.instance.getAyahAudioUrl(_selectedSurahId, ayah.ayahNumber);

    try {
      _scrollToAyah(_currentAyahIndex);
      final reciterId = SettingsService.instance.selectedReciterId;
      final cacheKey = 'ayah_${reciterId}_${_selectedSurahId}_${ayah.ayahNumber}';
      final source = await FastAudioService.instance.getFastAudioSource(
        url,
        cacheKey: cacheKey,
      );
      await FastAudioService.instance.playWithZeroDelay(
        _player,
        source,
        speed: _playbackSpeed,
        onStopCallback: _stopPlayback,
      );
    } catch (e) {
      debugPrint('Memorization audio play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تشغيل التلاوة. يرجى التحقق من الاتصال بالإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      await _stopPlayback();
    }
  }

  Future<void> _pausePlayback() async {
    _delayTimer?.cancel();
    await _player.pause();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isDelaying = false;
    });
  }

  Future<void> _stopPlayback() async {
    _delayTimer?.cancel();
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isDelaying = false;
      _currentAyahIndex = 0;
      _currentAyahRepeat = 1;
      _currentRangeRepeat = 1;
    });
  }

  Future<void> _nextAyah() async {
    if (_rangeAyahs.isEmpty) return;
    _delayTimer?.cancel();
    _isDelaying = false;
    if (_currentAyahIndex < _rangeAyahs.length - 1) {
      setState(() {
        _currentAyahIndex++;
        _currentAyahRepeat = 1;
      });
      if (_isPlaying) {
        await _playCurrentAyah();
      }
    }
  }

  Future<void> _prevAyah() async {
    if (_rangeAyahs.isEmpty) return;
    _delayTimer?.cancel();
    _isDelaying = false;
    if (_currentAyahIndex > 0) {
      setState(() {
        _currentAyahIndex--;
        _currentAyahRepeat = 1;
      });
      if (_isPlaying) {
        await _playCurrentAyah();
      }
    }
  }

  void _onAyahAudioCompleted() {
    if (!_isPlaying || !mounted) return;

    final targetAyahRepeats = _ayahRepeatTarget;
    final targetRangeRepeats = _rangeRepeatTarget;

    // 1. Ayah still needs repetition
    if (_currentAyahRepeat < targetAyahRepeats) {
      _triggerDelayThen(() {
        if (!mounted || !_isPlaying) return;
        setState(() => _currentAyahRepeat++);
        _playCurrentAyah();
      });
      return;
    }

    // 2. Ayah repetitions finished, advance to next Ayah in range
    if (_currentAyahIndex < _rangeAyahs.length - 1) {
      _triggerDelayThen(() {
        if (!mounted || !_isPlaying) return;
        setState(() {
          _currentAyahIndex++;
          _currentAyahRepeat = 1;
        });
        _playCurrentAyah();
      });
      return;
    }

    // 3. Reached end of range; check range repetition target
    if (_currentRangeRepeat < targetRangeRepeats) {
      _triggerDelayThen(() {
        if (!mounted || !_isPlaying) return;
        setState(() {
          _currentRangeRepeat++;
          _currentAyahIndex = 0;
          _currentAyahRepeat = 1;
        });
        _playCurrentAyah();
      });
      return;
    }

    // 4. Completed all loops!
    _stopPlayback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 تم الانتهاء من دورة التكرار بنجاح! بارك الله في حفظك وزادك نوراً.'),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _triggerDelayThen(VoidCallback action) {
    if (_delaySeconds <= 0) {
      action();
      return;
    }

    setState(() {
      _isDelaying = true;
      _remainingDelaySeconds = _delaySeconds;
    });

    _delayTimer?.cancel();
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingDelaySeconds--;
      });

      if (_remainingDelaySeconds <= 0) {
        timer.cancel();
        setState(() => _isDelaying = false);
        action();
      }
    });
  }

  void _scrollToAyah(int index) {
    if (!mounted) return;
    final ctx = _ayahKeys[index]?.currentContext;
    if (ctx != null && ctx.mounted) {
      try {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      } catch (_) {}
    }
  }

  void _toggleWordReveal(int ayahNumber, int wordIndex) {
    final key = '$ayahNumber:$wordIndex';
    setState(() {
      if (_revealedWords.contains(key)) {
        _revealedWords.remove(key);
      } else {
        _revealedWords.add(key);
      }
    });
  }

  void _revealAllWords() {
    setState(() {
      for (final ayah in _rangeAyahs) {
        final words = MemorizationMaskHelper.splitAyahWords(ayah.textUthmani);
        for (int i = 0; i < words.length; i++) {
          _revealedWords.add('${ayah.ayahNumber}:$i');
        }
      }
    });
  }

  void _hideAllWords() {
    setState(() {
      _revealedWords.clear();
    });
  }

  void _rateAyah(Ayah ayah, MemorizationRating rating) async {
    final item = await MemorizationService.instance.recordReview(
      surahId: _selectedSurahId,
      ayahNumber: ayah.ayahNumber,
      surahName: _currentSurah?.nameAr ?? '',
      rating: rating,
    );

    if (mounted) {
      final ratingText = rating == MemorizationRating.easy
          ? 'متقن (الصندوق ${item.leitnerBox} - مراجعة بعد ${MemorizationItem.getIntervalForBox(item.leitnerBox).inDays} أيام)'
          : rating == MemorizationRating.hard
              ? 'يحتاج تثبيت (مراجعة بعد ${MemorizationItem.getIntervalForBox(item.leitnerBox).inDays} أيام)'
              : 'نسيت (تمت إعادتها للصندوق الأول للمراجعة غداً)';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تقييم آية ${ayah.ayahNumber}: $ratingText'),
          duration: const Duration(seconds: 2),
          backgroundColor: rating == MemorizationRating.easy
              ? AppColors.primaryGreen
              : rating == MemorizationRating.hard
                  ? Colors.amber.shade800
                  : Colors.red.shade700,
        ),
      );
    }
  }

  void _showReciterSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'اختر القارئ المفضل للتحفيظ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: SettingsService.availableReciters.length,
                    itemBuilder: (ctx, index) {
                      final r = SettingsService.availableReciters[index];
                      final isSelected = SettingsService.instance.selectedReciterId == r.id;
                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.person_outline,
                          color: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                        ),
                        title: Text(
                          r.nameAr,
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        trailing: isSelected
                            ? const Text('محدد', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold))
                            : null,
                        onTap: () async {
                          await SettingsService.instance.setSelectedReciter(r.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحفظ القرآني والتكرار الذكي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_search_outlined),
              tooltip: 'تغيير القارئ',
              onPressed: _showReciterSelector,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'عن المحفظ والإهداء',
              onPressed: () => showMemorizationDedicationDialog(context),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : Column(
                children: [
                  // Dedicated Top Sticky Controls Panel
                  MemorizationControlsPanel(
                    isDark: isDark,
                    surahs: _surahs,
                    selectedSurahId: _selectedSurahId,
                    currentSurah: _currentSurah,
                    fromAyah: _fromAyah,
                    toAyah: _toAyah,
                    ayahRepeatTarget: _ayahRepeatTarget,
                    rangeRepeatTarget: _rangeRepeatTarget,
                    delaySeconds: _delaySeconds,
                    hideMode: _hideMode,
                    onSurahChanged: _onSurahChanged,
                    onFromAyahChanged: (val) {
                      setState(() {
                        _fromAyah = val;
                        _clampRange(_currentSurah?.ayahCount ?? 7);
                        _filterRangeAyahs();
                      });
                    },
                    onToAyahChanged: (val) {
                      setState(() {
                        _toAyah = val;
                        _clampRange(_currentSurah?.ayahCount ?? 7);
                        _filterRangeAyahs();
                      });
                    },
                    onAyahRepeatChanged: (val) => setState(() => _ayahRepeatTarget = val),
                    onRangeRepeatChanged: (val) => setState(() => _rangeRepeatTarget = val),
                    onDelayChanged: (val) => setState(() => _delaySeconds = val),
                    onHideModeChanged: (mode) {
                      setState(() {
                        _hideMode = mode;
                        _revealedWords.clear();
                      });
                    },
                    onRevealAllWords: _revealAllWords,
                    onHideAllWords: _hideAllWords,
                  ),

                  // Ayahs Content List
                  Expanded(
                    child: _rangeAyahs.isEmpty
                        ? const Center(child: Text('لا توجد آيات محددة'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 80),
                            itemCount: _rangeAyahs.length + 1, // +1 for dedication banner at top
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return const MemorizationDedicationBanner();
                              }

                              final ayahIndex = index - 1;
                              final ayah = _rangeAyahs[ayahIndex];
                              _ayahKeys[ayahIndex] ??= GlobalKey();

                              final isCurrentPlaying = _isPlaying && _currentAyahIndex == ayahIndex;

                              return Container(
                                key: _ayahKeys[ayahIndex],
                                margin: const EdgeInsets.only(bottom: 12),
                                child: MemorizationAyahCard(
                                  ayah: ayah,
                                  surahId: _selectedSurahId,
                                  isCurrentPlaying: isCurrentPlaying,
                                  isDelaying: _isDelaying,
                                  remainingDelaySeconds: _remainingDelaySeconds,
                                  currentAyahRepeat: _currentAyahRepeat,
                                  ayahRepeatTarget: _ayahRepeatTarget,
                                  hideMode: _hideMode,
                                  revealedWords: _revealedWords,
                                  isDark: isDark,
                                  onToggleWordReveal: _toggleWordReveal,
                                  onRateAyah: _rateAyah,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: MemorizationPlaybackBar(
          isDark: isDark,
          isPlaying: _isPlaying,
          currentAyahNumber: _rangeAyahs.isNotEmpty && _currentAyahIndex < _rangeAyahs.length
              ? _rangeAyahs[_currentAyahIndex].ayahNumber
              : _fromAyah,
          fromAyah: _fromAyah,
          toAyah: _toAyah,
          currentRangeRepeat: _currentRangeRepeat,
          rangeRepeatTarget: _rangeRepeatTarget,
          onPlayPause: () {
            if (_isPlaying) {
              _pausePlayback();
            } else {
              _startPlayback();
            }
          },
          onStop: _isPlaying ? _stopPlayback : null,
          onPrev: _prevAyah,
          onNext: _nextAyah,
          onSelectReciter: _showReciterSelector,
        ),
      ),
    );
  }
}
