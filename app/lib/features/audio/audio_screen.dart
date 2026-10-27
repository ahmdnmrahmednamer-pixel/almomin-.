import '../../core/text/arabic_normalizer.dart';
import 'scholars_audio_library_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/surah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/audio_download_service.dart';
import '../../core/audio/fast_audio_service.dart';
import '../../core/theme/app_theme.dart';
import 'downloads_manager_screen.dart';
import 'widgets/islamic_audio_player_sheet.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoadingSurahs = true;
  String _searchQuery = '';

  // Currently playing state
  Surah? _currentSurah;
  ReciterInfo? _currentReciter;
  String? _playingReciterId;
  bool _isBuffering = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Advanced Audio Features
  double _playbackSpeed = 1.0;
  bool _repeatSingle = false;
  Timer? _sleepTimer;
  int? _sleepTimerMinutes;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  @override
  void initState() {
    super.initState();
    _currentReciter = SettingsService.instance.currentReciter;
    AudioDownloadService.instance.init();
    AudioDownloadService.instance.addListener(_onDownloadServiceUpdate);
    _loadSurahs();
    _initAudioListeners();
  }

  void _onDownloadServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _initAudioListeners() {
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        if (state.processingState == ProcessingState.completed) {
          if (_repeatSingle && _currentSurah != null) {
            _playSurah(_currentSurah!);
          } else {
            _playNextSurah();
          }
        }
      });
    });

    _posSub = _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _currentPosition = pos);
    });

    _durSub = _audioPlayer.durationStream.listen((dur) {
      if (!mounted) return;
      setState(() => _totalDuration = dur ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    AudioDownloadService.instance.removeListener(_onDownloadServiceUpdate);
    _sleepTimer?.cancel();
    _playerStateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    final list = await QuranRepository.loadSurahs();
    if (!mounted) return;
    setState(() {
      _allSurahs = list;
      _filteredSurahs = list;
      _isLoadingSurahs = false;
    });
  }

  void _filterSurahs(String query) {
    setState(() {
      _searchQuery = query.trim();
      if (_searchQuery.isEmpty) {
        _filteredSurahs = _allSurahs;
      } else {
        final normQ = ArabicNormalizer.normalize(_searchQuery, loose: true);
        _filteredSurahs = _allSurahs.where((s) {
          return s.nameAr.contains(_searchQuery) ||
              ArabicNormalizer.normalize(s.nameAr, loose: true).contains(normQ) ||
              s.nameSimple.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.id.toString() == normQ;
        }).toList();
      }
    });
  }

  Future<void> _playSurah(Surah surah, {bool forceReload = false}) async {
    final reciter = _currentReciter ?? SettingsService.instance.currentReciter;

    // Only toggle play/pause if the EXACT same surah AND the EXACT same reciter are already loaded
    if (!forceReload &&
        _currentSurah?.id == surah.id &&
        _playingReciterId == reciter.id) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      if (!mounted) return;
      setState(() {});
      return;
    }

    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() {
      _currentSurah = surah;
      _playingReciterId = reciter.id;
      _isBuffering = true;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });

    try {
      final localPath = AudioDownloadService.instance.getLocalAudioPath(reciter.id, surah.id);
      final url = SettingsService.instance.getSurahAudioUrl(surah.id, reciter.id);
      final cacheKey = 'surah_${reciter.id}_${surah.id}';

      final source = await FastAudioService.instance.getFastAudioSource(
        url,
        cacheKey: cacheKey,
        localDownloadedPath: localPath,
      );

      await FastAudioService.instance.playWithZeroDelay(
        _audioPlayer,
        source,
        speed: _playbackSpeed,
        onStopCallback: () async {
          try {
            await _audioPlayer.stop();
          } catch (_) {}
          if (mounted) {
            setState(() {});
          }
        },
      );

      // Pre-warm the next surah in background for instant transition
      if (surah.id < 114) {
        final nextSurahId = surah.id + 1;
        final nextUrl = SettingsService.instance.getSurahAudioUrl(nextSurahId, reciter.id);
        final nextKey = 'surah_${reciter.id}_$nextSurahId';
        unawaited(FastAudioService.instance.prefetchAudio(nextUrl, nextKey));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                if (localPath != null) ...[
                  const Icon(Icons.offline_pin_rounded, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    localPath != null
                        ? 'استماع بدون إنترنت (تخزين محلي) — سورة ${surah.nameAr} بصوت ${reciter.nameAr}'
                        : 'بدء تشغيل سورة ${surah.nameAr} — بصوت ${reciter.nameAr}',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تشغيل التلاوة. يرجى التحقق من الملف أو الاتصال بالإنترنت.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() {
          _isBuffering = false;
        });
      }
    }
  }

  void _playNextSurah() {
    if (_currentSurah == null || _allSurahs.isEmpty) return;
    final nextId = _currentSurah!.id < 114 ? _currentSurah!.id + 1 : 1;
    final next = _allSurahs.firstWhere((s) => s.id == nextId, orElse: () => _allSurahs.first);
    _playSurah(next);
  }

  void _playPreviousSurah() {
    if (_currentSurah == null || _allSurahs.isEmpty) return;
    final prevId = _currentSurah!.id > 1 ? _currentSurah!.id - 1 : 114;
    final prev = _allSurahs.firstWhere((s) => s.id == prevId, orElse: () => _allSurahs.first);
    _playSurah(prev);
  }

  void _showReciterPicker() {
    String reciterSearch = '';
    String selectedCategory = 'الكل';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final all = SettingsService.availableReciters;
            final filtered = all.where((r) {
              final normRec = ArabicNormalizer.normalize(reciterSearch, loose: true);
              final matchesQuery = reciterSearch.isEmpty ||
                  r.nameAr.contains(reciterSearch) ||
                  ArabicNormalizer.normalize(r.nameAr, loose: true).contains(normRec) ||
                  r.id.contains(reciterSearch.toLowerCase());
              final matchesCat = selectedCategory == 'الكل' || r.style == selectedCategory;
              return matchesQuery && matchesCat;
            }).toList();

            return Directionality(
              textDirection: SettingsService.instance.textDirection,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'اختر القارئ (٦١ قارئاً معتمداً)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${filtered.length} قارئ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم القارئ (مثل: الحصري، المنشاوي، عبد الباسط)...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.06),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          reciterSearch = val.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Category Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['الكل', 'مرتل', 'مجود', 'المعلم', 'تلاوة خاشعة'].map((cat) {
                          final isSel = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSel,
                              selectedColor: AppColors.accentGold.withOpacity(0.25),
                              checkmarkColor: AppColors.primaryGreen,
                              onSelected: (_) {
                                setModalState(() {
                                  selectedCategory = cat;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final reciter = filtered[idx];
                          final isSelected = (_currentReciter?.id ?? SettingsService.instance.selectedReciterId) == reciter.id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? AppColors.accentGold : AppColors.primaryGreen.withOpacity(0.1),
                              child: Icon(
                                Icons.record_voice_over,
                                color: isSelected ? Colors.white : AppColors.primaryGreen,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              reciter.nameAr,
                              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text(
                              'رواية حفص عن عاصم — ${reciter.style}',
                              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                                : null,
                            onTap: () async {
                              await SettingsService.instance.setSelectedReciter(reciter.id);
                              if (!mounted) return;
                              setState(() {
                                _currentReciter = reciter;
                              });
                              Navigator.pop(ctx);
                              final targetSurah = _currentSurah ?? (_allSurahs.isNotEmpty ? _allSurahs.first : null);
                              if (targetSurah != null) {
                                await _playSurah(targetSurah, forceReload: true);
                              }
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
      },
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: AlertDialog(
            title: const Text('سرعة التلاوة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [0.75, 1.0, 1.25, 1.5].map((s) {
                return RadioListTile<double>(
                  value: s,
                  groupValue: _playbackSpeed,
                  title: Text('${s}x ${s == 1.0 ? "(السرعة العادية)" : ""}'),
                  activeColor: AppColors.primaryGreen,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _playbackSpeed = val;
                      });
                      _audioPlayer.setSpeed(val);
                      Navigator.pop(ctx);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: AlertDialog(
            title: const Text('مؤقت النوم (إيقاف تلقائي)'),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إلغاء مؤقت النوم')),
                      );
                    },
                  ),
                ...[15, 30, 45, 60].map((m) {
                  return ListTile(
                    leading: const Icon(Icons.bedtime_outlined, color: AppColors.primaryGreen),
                    title: Text('إيقاف بعد $m دقيقة'),
                    onTap: () {
                      _sleepTimer?.cancel();
                      setState(() {
                        _sleepTimerMinutes = m;
                        _sleepTimer = Timer(Duration(minutes: m), () {
                          _audioPlayer.pause();
                          setState(() {
                            _sleepTimer = null;
                            _sleepTimerMinutes = null;
                          });
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('سيتم إيقاف التلاوة بعد $m دقيقة تلقائياً')),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final reciter = _currentReciter ?? SettingsService.instance.currentReciter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة الصوتية والتلاوات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'إدارة التنزيلات والاستماع دون إنترنت',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DownloadsManagerScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _sleepTimerMinutes != null ? Icons.alarm_on : Icons.alarm,
              color: _sleepTimerMinutes != null ? AppColors.accentGold : Colors.white,
            ),
            tooltip: 'مؤقت النوم',
            onPressed: _showSleepTimerDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_search),
            tooltip: 'تغيير القارئ (٦١ قارئاً معتمداً)',
            onPressed: _showReciterPicker,
          ),
          IconButton(
            icon: const Icon(Icons.mic_external_on_rounded),
            tooltip: 'موسوعة دروس ومحاضرات الشيوخ والعلماء (١١٥ شيخاً)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScholarsAudioLibraryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'الأذكار والأدعية الصوتية',
            onPressed: () => IslamicAudioPlayerSheet.show(context),
          ),
        ],
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Column(
          children: [
            // Quick Portal Banner to 115+ Scholars Audio Lectures Library
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScholarsAudioLibraryScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mic_external_on_rounded, color: AppColors.primaryGreen, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'موسوعة دروس ومحاضرات الشيوخ والعلماء (١١٥ شيخاً وداعية)',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.primaryGreen),
                            ),
                            Text(
                              'سمير مصطفى • نبيل العوضي • محمود الحسنات • الشعراوي • الحويني • كشك (أكثر من ٧٠٠ درس مقسمة حسب المحتوى)',
                              style: TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 15, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
            ),
            // Reciter Info Banner
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over, color: AppColors.softGold, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'القارئ الحالي للتلاوة:',
                          style: TextStyle(color: AppColors.softGold, fontSize: 11),
                        ),
                        Text(
                          reciter.nameAr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'رواية حفص عن عاصم — ${reciter.style}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.softGold),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.softGold),
                    label: const Text('تغيير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _showReciterPicker,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث باسم السورة (مثل: الكهف، يس، البقرة)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                        tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.clear),
                          onPressed: () => _filterSurahs(''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: _filterSurahs,
              ),
            ),
            const SizedBox(height: 8),

            // Surahs List
            Expanded(
              child: _isLoadingSurahs
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSurahs.isEmpty
                      ? const Center(child: Text('لا توجد سور مطابقة لبحثك'))
                      : ListView.separated(
                          itemCount: _filteredSurahs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final surah = _filteredSurahs[idx];
                            final isPlayingThis = _currentSurah?.id == surah.id;
                            final isDownloaded = AudioDownloadService.instance.isDownloaded(reciter.id, surah.id);
                            final isDownloading = AudioDownloadService.instance.isDownloading(reciter.id, surah.id);
                            final downloadProgress = AudioDownloadService.instance.getDownloadProgress(reciter.id, surah.id);

                            return ListTile(
                              tileColor: isPlayingThis
                                  ? (isDark ? AppColors.accentGold.withOpacity(0.15) : AppColors.accentGold.withOpacity(0.12))
                                  : null,
                              leading: CircleAvatar(
                                backgroundColor: isPlayingThis
                                    ? AppColors.accentGold
                                    : (isDark ? Colors.white12 : AppColors.primaryGreen.withOpacity(0.08)),
                                child: Text(
                                  '${surah.id}',
                                  style: TextStyle(
                                    color: isPlayingThis ? Colors.black : (isDark ? AppColors.softGold : AppColors.primaryGreen),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Text(
                                'سورة ${surah.nameAr}',
                                style: TextStyle(
                                  fontWeight: isPlayingThis ? FontWeight.bold : FontWeight.w600,
                                  color: isPlayingThis ? AppColors.secondaryGreen : null,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    '${surah.isMakki ? "مكية" : "مدنية"} — آياتها ${surah.ayahCount} — ص ${surah.pageStart}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                                  ),
                                  if (isDownloaded) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, size: 10, color: Colors.green),
                                          SizedBox(width: 3),
                                          Text(
                                            'أوفلاين',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isDownloading)
                                    SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: downloadProgress > 0 ? downloadProgress.clamp(0.0, 1.0) : null,
                                            strokeWidth: 2.5,
                                            color: AppColors.primaryGreen,
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                                            tooltip: 'إلغاء التحميل',
                                            onPressed: () {
                                              AudioDownloadService.instance.cancelDownload(reciter.id, surah.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (isDownloaded)
                                    IconButton(
                                      icon: const Icon(Icons.offline_pin_rounded, color: Colors.green, size: 22),
                                      tooltip: 'السورة محملة (استماع بدون إنترنت)',
                                      onPressed: () => _playSurah(surah),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.mutedText, size: 22),
                                      tooltip: 'تحميل للاستماع بدون إنترنت',
                                      onPressed: () async {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('بدء تحميل سورة ${surah.nameAr} بصوت ${reciter.nameAr}...'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                        final ok = await AudioDownloadService.instance.downloadSurah(
                                          reciterId: reciter.id,
                                          surahId: surah.id,
                                          surahName: 'سورة ${surah.nameAr}',
                                        );
                                        if (mounted && ok) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('تم اكتمال تحميل سورة ${surah.nameAr} بنجاح ✓'),
                                              backgroundColor: AppColors.primaryGreen,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    tooltip: 'تشغيل أو إيقاف الصوت',
                                    icon: Icon(
                                      isPlayingThis && _audioPlayer.playing
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_fill,
                                      color: isPlayingThis ? AppColors.accentGold : AppColors.primaryGreen,
                                      size: 34,
                                    ),
                                    onPressed: () => _playSurah(surah),
                                  ),
                                ],
                              ),
                              onTap: () => _playSurah(surah),
                            );
                          },
                        ),
            ),

            // Bottom Player Bar
            if (_currentSurah != null)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2522) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                  border: const Border(
                    top: BorderSide(color: AppColors.accentGold, width: 2),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress Slider
                        Row(
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                            ),
                            Expanded(
                              child: Slider(
                                value: _currentPosition.inSeconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      _totalDuration.inSeconds > 0
                                          ? _totalDuration.inSeconds.toDouble()
                                          : 1.0,
                                    ),
                                max: _totalDuration.inSeconds > 0
                                    ? _totalDuration.inSeconds.toDouble()
                                    : 1.0,
                                activeColor: AppColors.accentGold,
                                inactiveColor: AppColors.accentGold.withOpacity(0.3),
                                onChanged: (val) {
                                  _audioPlayer.seek(Duration(seconds: val.toInt()));
                                },
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                            ),
                          ],
                        ),

                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'سورة ${_currentSurah!.nameAr}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    reciter.nameAr,
                                    style: const TextStyle(color: AppColors.secondaryGreen, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Speed button
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    minimumSize: Size.zero,
                                  ),
                                  onPressed: _showSpeedDialog,
                                  child: Text('${_playbackSpeed}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                                ),
                                // Repeat toggle
                                IconButton(
                                  icon: Icon(
                                    _repeatSingle ? Icons.repeat_one : Icons.repeat,
                                    size: 20,
                                    color: _repeatSingle ? AppColors.accentGold : AppColors.mutedText,
                                  ),
                                  tooltip: _repeatSingle ? 'تكرار السورة مفعل' : 'تكرار السورة معطل',
                                  onPressed: () {
                                    setState(() {
                                      _repeatSingle = !_repeatSingle;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous),
                                  tooltip: 'السورة السابقة',
                                  onPressed: _playPreviousSurah,
                                ),
                                IconButton(
                                  tooltip: 'تشغيل أو إيقاف الصوت',
                                  icon: _isBuffering
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                                        )
                                      : Icon(
                                          _audioPlayer.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                          size: 40,
                                          color: AppColors.primaryGreen,
                                        ),
                                  onPressed: () {
                                    if (_audioPlayer.playing) {
                                      _audioPlayer.pause();
                                    } else {
                                      _audioPlayer.play();
                                    }
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  tooltip: 'السورة التالية',
                                  onPressed: _playNextSurah,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  tooltip: 'إيقاف التلاوة',
                                  onPressed: () {
                                    _audioPlayer.stop();
                                    setState(() {
                                      _currentSurah = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
