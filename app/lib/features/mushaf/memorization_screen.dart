import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/surah.dart';
import '../../core/models/ayah.dart';
import '../../core/models/memorization_item.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/memorization_service.dart';
import '../../core/theme/app_theme.dart';

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
    _player.playerStateStream.listen((state) {
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
      final surah = surahs.firstWhere(
        (s) => s.id == _selectedSurahId,
        orElse: () => surahs.first,
      );

      final ayahs = await QuranRepository.getAyahsForSurah(surah.id);

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
      final surah = _surahs.firstWhere((s) => s.id == newSurahId);
      final ayahs = await QuranRepository.getAyahsForSurah(surah.id);

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
      await _player.setUrl(url);
      await _player.play();
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
    setState(() {
      _isPlaying = false;
      _isDelaying = false;
    });
  }

  Future<void> _stopPlayback() async {
    _delayTimer?.cancel();
    await _player.stop();
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
    // Optional smooth scrolling to currently active item
    final key = _ayahKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
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
          textDirection: TextDirection.rtl,
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
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
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
              onPressed: () => _showDedicationDialog(context),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : Column(
                children: [
                  // Dedicated Top Sticky Controls Panel
                  _buildControlsPanel(isDark),

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
                                return _buildDedicationHeader(context);
                              }

                              final ayahIndex = index - 1;
                              final ayah = _rangeAyahs[ayahIndex];
                              _ayahKeys[ayahIndex] ??= GlobalKey();

                              final isCurrentPlaying = _isPlaying && _currentAyahIndex == ayahIndex;

                              return Container(
                                key: _ayahKeys[ayahIndex],
                                margin: const EdgeInsets.only(bottom: 12),
                                child: _buildAyahCard(ayah, ayahIndex, isCurrentPlaying, isDark),
                              );
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: _buildBottomPlaybackBar(isDark),
      ),
    );
  }

  Widget _buildDedicationHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صدقة جارية عن مؤمن إبراهيم رحمه الله',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
                ),
                Text(
                  'اللهم اجعل القرآن الكريم نوراً له وأنيساً في قبره ورفعة لدرجاته',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.accentGold, size: 20),
            onPressed: () => _showDedicationDialog(context),
            tooltip: 'دعاء لمؤمن إبراهيم',
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(bool isDark) {
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
                      value: _selectedSurahId,
                      items: _surahs.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            '${s.id}. ${s.nameAr}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && val != _selectedSurahId) {
                          _onSurahChanged(val);
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
                  value: _fromAyah,
                  max: _currentSurah?.ayahCount ?? 7,
                  onChanged: (val) {
                    setState(() {
                      _fromAyah = val;
                      _clampRange(_currentSurah?.ayahCount ?? 7);
                      _filterRangeAyahs();
                    });
                  },
                ),
              ),
              const SizedBox(width: 6),

              // To Ayah Picker
              Expanded(
                flex: 2,
                child: _buildNumberSelector(
                  label: 'إلى آية',
                  value: _toAyah,
                  max: _currentSurah?.ayahCount ?? 7,
                  onChanged: (val) {
                    setState(() {
                      _toAyah = val;
                      _clampRange(_currentSurah?.ayahCount ?? 7);
                      _filterRangeAyahs();
                    });
                  },
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
                value: _ayahRepeatTarget >= 999 ? 'مستمر' : '${_ayahRepeatTarget}x',
                options: [1, 3, 5, 7, 10, 999],
                onSelected: (val) => setState(() => _ayahRepeatTarget = val),
              ),
              const SizedBox(width: 8),
              _buildCompactBadge(
                title: 'تكرار المقطع',
                value: _rangeRepeatTarget >= 999 ? 'مستمر' : '${_rangeRepeatTarget}x',
                options: [1, 2, 3, 5, 999],
                onSelected: (val) => setState(() => _rangeRepeatTarget = val),
              ),
              const SizedBox(width: 8),
              _buildCompactBadge(
                title: 'وقفة الترديد',
                value: _delaySeconds == 0 ? 'بدون' : '$_delaySeconds ث',
                options: [0, 1, 2, 3, 5],
                onSelected: (val) => setState(() => _delaySeconds = val),
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
                if (_hideMode != MemorizationHideMode.none) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('كشف الكل', style: TextStyle(fontSize: 11)),
                    onPressed: _revealAllWords,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('إخفاء الكل', style: TextStyle(fontSize: 11)),
                    onPressed: _hideAllWords,
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
              value: value.clamp(1, max),
              items: List.generate(max, (i) => i + 1).map((num) {
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
    final isSelected = _hideMode == mode;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _hideMode = mode;
            _revealedWords.clear();
          });
        }
      },
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.primaryGreen),
      label: Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      visualDensity: VisualDensity.compact,
    );
  }

  // --- Ayah Card & Interactive Masked Words ---

  Widget _buildAyahCard(Ayah ayah, int ayahIndex, bool isCurrentPlaying, bool isDark) {
    final memItem = MemorizationService.instance.getItem(_selectedSurahId, ayah.ayahNumber);
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
                          _isDelaying
                              ? 'وقفة للترديد ($_remainingDelaySeconds ث)'
                              : 'تكرار $_currentAyahRepeat من ${_ayahRepeatTarget >= 999 ? "∞" : _ayahRepeatTarget}',
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
                final isRevealed = _revealedWords.contains('${ayah.ayahNumber}:$wordIdx');
                final isMasked = MemorizationMaskHelper.isWordMasked(
                  wordIndex: wordIdx,
                  totalWords: words.length,
                  mode: _hideMode,
                  isRevealed: isRevealed,
                );

                if (isMasked) {
                  // Interactive blurred / hidden pill
                  return InkWell(
                    onTap: () => _toggleWordReveal(ayah.ayahNumber, wordIdx),
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
                    // Tap on visible word toggles hiding in test modes
                    if (_hideMode != MemorizationHideMode.none) {
                      _toggleWordReveal(ayah.ayahNumber, wordIdx);
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
                    onTap: () => _rateAyah(ayah, MemorizationRating.easy),
                  ),
                  _buildRatingButton(
                    label: 'تثبيت',
                    icon: Icons.timelapse,
                    color: Colors.amber.shade800,
                    onTap: () => _rateAyah(ayah, MemorizationRating.hard),
                  ),
                  _buildRatingButton(
                    label: 'نسيت',
                    icon: Icons.replay,
                    color: Colors.redAccent,
                    onTap: () => _rateAyah(ayah, MemorizationRating.forgot),
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

  // --- Bottom Playback Control Bar ---

  Widget _buildBottomPlaybackBar(bool isDark) {
    final currentAyahNumber = _rangeAyahs.isNotEmpty && _currentAyahIndex < _rangeAyahs.length
        ? _rangeAyahs[_currentAyahIndex].ayahNumber
        : _fromAyah;

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
                  _isPlaying
                      ? 'الآية: $currentAyahNumber · مقطع $_currentRangeRepeat/${_rangeRepeatTarget >= 999 ? "∞" : _rangeRepeatTarget}'
                      : 'المقطع: $_fromAyah إلى $_toAyah',
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
                  onPressed: _isPlaying ? _stopPlayback : null,
                ),
                const SizedBox(width: 12),

                // Previous Ayah
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 30),
                  tooltip: 'الآية السابقة',
                  onPressed: _prevAyah,
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
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    tooltip: _isPlaying ? 'إيقاف مؤقت' : 'بدء التكرار والتحفيظ',
                    onPressed: () {
                      if (_isPlaying) {
                        _pausePlayback();
                      } else {
                        _startPlayback();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Next Ayah
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 30),
                  tooltip: 'الآية التالية',
                  onPressed: _nextAyah,
                ),
                const SizedBox(width: 12),

                // Quick Reciter change
                IconButton(
                  icon: const Icon(Icons.tune, size: 24),
                  tooltip: 'اختيار قارئ آخر',
                  onPressed: _showReciterSelector,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.volunteer_activism, color: AppColors.accentGold),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'صدقة جارية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هذا المحفظ القرآني والتطبيق بالكامل صدقة جارية عن روح المرحوم بإذن الله تعالى: مؤمن إبراهيم رحمه الله تعالى رحمة واسعة.',
                style: TextStyle(height: 1.6, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '«اللهم اجعل كل آية تُتلى، وكل حرف يُحفظ في ميزان حسنات مؤمن إبراهيم، ونوراً وضياءً له في قبره، وشفيعاً له يوم القيامة، واجمعنا به في الفردوس الأعلى من الجنة بلا حساب ولا سابق عذاب.»',
                style: TextStyle(fontWeight: FontWeight.bold, height: 1.7, color: AppColors.primaryGreen, fontSize: 13.5),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('آمين يا رب العالمين', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
