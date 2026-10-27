import '../../core/services/settings_service.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/notifications/prayer_notification_service.dart';
import '../../core/services/adhan_sensor_gesture_service.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/prayer_tracker_service.dart';
import '../../core/theme/app_theme.dart';
import '../settings/widgets/settings_adhan_voice_modal.dart';

class _PrayerAtmosphereTheme {
  final List<Color> backgroundColors;
  final Color primaryAccent;
  final Color secondaryAccent;
  final String atmosphereTitle;
  final String spiritualQuote;
  final IconData celestialIcon;

  const _PrayerAtmosphereTheme({
    required this.backgroundColors,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.atmosphereTitle,
    required this.spiritualQuote,
    required this.celestialIcon,
  });
}

class AdhanControlScreen extends StatefulWidget {
  final String prayerName;
  final bool isIqamah;
  final bool autoPlay;

  const AdhanControlScreen({
    super.key,
    this.prayerName = 'الظهر',
    this.isIqamah = false,
    this.autoPlay = true,
  });

  @override
  State<AdhanControlScreen> createState() => _AdhanControlScreenState();
}

class _AdhanControlScreenState extends State<AdhanControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _equalizerController;

  Timer? _clockTimer;
  Timer? _iqamahCountdownTimer;
  int _iqamahRemainingSeconds = 0;
  int _iqamahTotalSeconds = 15 * 60;
  bool _isIqamahCountdownActive = false;
  DateTime _currentTime = DateTime.now();
  String? _lastGestureTriggered;
  bool _isMutedOrStopped = false;
  bool _isPrayerLogged = false;
  bool _showDedicatedStopView = false;

  final audioService = IslamicAudioService.instance;
  final sensorService = AdhanSensorGestureService.instance;
  final notifService = PrayerNotificationService.instance;
  final trackerService = PrayerTrackerService.instance;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _checkPrayerLoggedState();

    // Start motion sensor gestures
    _initSensorGestures();

    // Auto-play Adhan/Iqamah if requested and not already playing
    if (widget.autoPlay && !audioService.isPlaying) {
      _startAudioPlayback();
    }
  }

  void _checkPrayerLoggedState() {
    final record = trackerService.todayRecord;
    switch (widget.prayerName) {
      case 'الفجر':
        _isPrayerLogged = record.fajr;
        break;
      case 'الظهر':
        _isPrayerLogged = record.dhuhr;
        break;
      case 'العصر':
        _isPrayerLogged = record.asr;
        break;
      case 'المغرب':
        _isPrayerLogged = record.maghrib;
        break;
      case 'العشاء':
        _isPrayerLogged = record.isha;
        break;
      default:
        _isPrayerLogged = false;
    }
  }

  void _initSensorGestures() {
    sensorService.startListening(
      onShake: () {
        if (!mounted || _isMutedOrStopped) return;
        _handleGestureStop(isShake: true);
      },
      onFlip: () {
        if (!mounted || _isMutedOrStopped) return;
        _handleGestureStop(isShake: false);
      },
    );
  }

  Future<void> _startAudioPlayback() async {
    final isFajr = widget.prayerName.contains('الفجر');
    final String trackId;
    if (widget.isIqamah) {
      trackId = notifService.selectedIqamahVoice;
    } else {
      final prayerSpecific = notifService.getPrayerVoice(widget.prayerName);
      if (isFajr && notifService.fajrDistinctVoiceEnabled && prayerSpecific == notifService.selectedAdhanVoice) {
        trackId = notifService.selectedFajrVoice;
      } else {
        trackId = prayerSpecific;
      }
    }
    await audioService.playTrackById(trackId);
    if (mounted) setState(() {});
  }

  Future<void> _triggerStopVibration() async {
    if (notifService.vibrateOnStop) {
      try {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 90));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 90));
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  void _handleGestureStop({required bool isShake}) {
    _triggerStopVibration();
    audioService.stop();
    setState(() {
      _isMutedOrStopped = true;
      _showDedicatedStopView = true;
      _lastGestureTriggered = isShake
          ? 'تم إيقاف الأذان بنجاح عبر هز الهاتف 📳'
          : 'تم كتم الأذان بنجاح عند قلب الهاتف على وجهه 📱';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _lastGestureTriggered!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _stopAdhanManually() {
    _triggerStopVibration();
    audioService.stop();
    setState(() {
      _isMutedOrStopped = true;
      _showDedicatedStopView = true;
      _lastGestureTriggered = 'تم إيقاف الأذان يدوياً ⏹️';
    });
  }

  void _togglePlayPause() {
    if (SettingsService.instance.hapticEnabled) HapticFeedback.lightImpact();
    if (audioService.isPlaying) {
      audioService.pause();
    } else {
      audioService.resume();
      setState(() {
        _isMutedOrStopped = false;
        _showDedicatedStopView = false;
      });
    }
    setState(() {});
  }

  void _snoozeAdhan(int minutes) {
    _triggerStopVibration();
    audioService.stop();
    notifService.snoozeAdhan(minutes, widget.prayerName);

    setState(() {
      _isMutedOrStopped = true;
      _lastGestureTriggered = 'تم تفعيل الغفوة: سيعاد التنبيه بعد $minutes دقائق ⏰';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تأجيل أذان ${widget.prayerName} لمدة $minutes دقائق ⏰'),
        backgroundColor: AppColors.accentGold,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startIqamahCountdown(int minutes) {
    if (SettingsService.instance.hapticEnabled) HapticFeedback.selectionClick();
    _iqamahCountdownTimer?.cancel();
    setState(() {
      _isIqamahCountdownActive = true;
      _iqamahTotalSeconds = minutes * 60;
      _iqamahRemainingSeconds = minutes * 60;
    });

    _iqamahCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_iqamahRemainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isIqamahCountdownActive = false;
          _iqamahRemainingSeconds = 0;
        });
        // Play Iqamah sound
        audioService.playTrackById(notifService.selectedIqamahVoice);
      } else {
        setState(() {
          _iqamahRemainingSeconds--;
        });
      }
    });
  }

  Future<void> _logPrayerPerformance(bool isCongregation) async {
    if (SettingsService.instance.hapticEnabled) HapticFeedback.heavyImpact();
    await trackerService.toggleObligatory(widget.prayerName);
    setState(() {
      _isPrayerLogged = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCongregation
              ? 'تقبل الله صلاتكم في جماعة! كُتبت لك ٢٧ درجة مضاعفة 🕌✨'
              : 'هنيئاً لك! تم تسجيل أداء صلاة ${widget.prayerName} في سجل حسناتك 🤲',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  _PrayerAtmosphereTheme _getAtmosphereTheme(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF070E1A),
            Color(0xFF0F1E36),
            Color(0xFF1E3250),
            Color(0xFF1B2838),
          ],
          primaryAccent: Color(0xFF60A5FA),
          secondaryAccent: Color(0xFFFDE047),
          atmosphereTitle: 'غسق الفجر وانبلاج نور الصباح المبارك 🌄',
          spiritualQuote: '«إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا»',
          celestialIcon: Icons.wb_twilight_rounded,
        );
      case 'الشروق':
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF181005),
            Color(0xFF2C1A06),
            Color(0xFF452B0B),
            Color(0xFF2E1C07),
          ],
          primaryAccent: Color(0xFFF59E0B),
          secondaryAccent: Color(0xFFFDE68A),
          atmosphereTitle: 'إشراق شمس يوم جديد بذكر الله تعالى ☀️',
          spiritualQuote: '«وَسَبِّحْ بِحَمْدِ رَبِّكَ قَبْلَ طُلُوعِ الشَّمْسِ»',
          celestialIcon: Icons.wb_sunny_rounded,
        );
      case 'الظهر':
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF06180E),
            Color(0xFF0D2D1B),
            Color(0xFF14452A),
            Color(0xFF0A2214),
          ],
          primaryAccent: Color(0xFF10B981),
          secondaryAccent: AppColors.accentGold,
          atmosphereTitle: 'ظهيرة مباركة وساعة نداء الحق واستجابة الدعاء 🕌',
          spiritualQuote: '«أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ»',
          celestialIcon: Icons.wb_sunny_outlined,
        );
      case 'العصر':
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF1C1204),
            Color(0xFF332007),
            Color(0xFF52330A),
            Color(0xFF2B1A05),
          ],
          primaryAccent: Color(0xFFF59E0B),
          secondaryAccent: Color(0xFFFCD34D),
          atmosphereTitle: 'أصيل العصر — موعد الصلاة الوسطى والسكينة ⏳',
          spiritualQuote: '«حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ»',
          celestialIcon: Icons.hourglass_bottom_rounded,
        );
      case 'المغرب':
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF1A0914),
            Color(0xFF331023),
            Color(0xFF4F1836),
            Color(0xFF2A0D1F),
          ],
          primaryAccent: Color(0xFFFB7185),
          secondaryAccent: Color(0xFFFBBF24),
          atmosphereTitle: 'شفق المغرب وحلول وقت الإجابة وأوبة الذاكرين 🌇',
          spiritualQuote: '«فَسُبْحَانَ اللَّهِ حِينَ تُمْسُونَ وَحِينَ تُصْبِحُونَ»',
          celestialIcon: Icons.nights_stay_rounded,
        );
      case 'العشاء':
      default:
        return const _PrayerAtmosphereTheme(
          backgroundColors: [
            Color(0xFF050B14),
            Color(0xFF0B192C),
            Color(0xFF142942),
            Color(0xFF081424),
          ],
          primaryAccent: Color(0xFF38BDF8),
          secondaryAccent: AppColors.accentGold,
          atmosphereTitle: 'سكينة الليل ونداء صلاة العشاء والوتر 🌙',
          spiritualQuote: '«وَمِنَ اللَّيْلِ فَاسْجُدْ لَهُ وَسَبِّحْهُ لَيْلًا طَوِيلًا»',
          celestialIcon: Icons.bedtime_rounded,
        );
    }
  }

  void _showDuaaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E17),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 22),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'دعاء ما بعد الأذان (الوسيلة)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                ),
                child: const Text(
                  '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّدًا الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ»',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'عن جابر بن عبد الله رضي الله عنهما أن رسول الله ﷺ قال: "مَن قال حين يَسمع النداء... حلَّت له شفاعتي يوم القيامة" [صحيح البخاري]',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (SettingsService.instance.hapticEnabled) HapticFeedback.mediumImpact();
                  Clipboard.setData(const ClipboardData(
                    text:
                        'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّدًا الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
                  )).catchError((_) {});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ الدعاء المبارك بنجاح ✨'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text(
                  'نسخ الدعاء المبارك',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdhanOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final isMaster = notifService.masterEnabled;
          final currentMode = notifService.soundMode;
          final isMuted = notifService.isTemporarilyMuted;
          final vibrateOnStop = notifService.vibrateOnStop;
          final shakeEnabled = sensorService.shakeToStopEnabled;
          final flipEnabled = sensorService.flipToMuteEnabled;

          return Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1E17),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, color: AppColors.accentGold, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'خيارات تفعيل وإيقاف الأذان والتنبيهات',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'إغلاق أو مسح',
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // 1. MASTER TOGGLE & TEMPORARY MUTE
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          isMaster ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                                          color: isMaster ? AppColors.accentGold : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isMaster ? 'تنبيه الأذان العام مفعّل' : 'تنبيه الأذان العام معطّل',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: isMaster,
                                    activeColor: AppColors.primaryGreen,
                                    onChanged: (val) async {
                                      await notifService.toggleMaster(val);
                    if (!mounted) return;
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white12, height: 18),

                              // Quick Temporary Mute Chips
                              const Text(
                                'كتم مؤقت (وضع الاجتماعات والنوم):',
                                style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  ChoiceChip(
                                    label: const Text('ساعتان'),
                                    selected: isMuted,
                                    onSelected: (_) async {
                                      await notifService.muteForDuration(const Duration(hours: 2));
                    if (!mounted) return;
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('٤ ساعات'),
                                    selected: false,
                                    onSelected: (_) async {
                                      await notifService.muteForDuration(const Duration(hours: 4));
                    if (!mounted) return;
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('حتى الغد'),
                                    selected: false,
                                    onSelected: (_) async {
                                      await notifService.muteForDuration(const Duration(hours: 12));
                    if (!mounted) return;
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  ),
                                  if (isMuted)
                                    ActionChip(
                                      avatar: const Icon(Icons.cancel_rounded, size: 16, color: Colors.redAccent),
                                      label: const Text('إلغاء الكتم'),
                                      onPressed: () async {
                                        await notifService.cancelTemporaryMute();
                    if (!mounted) return;
                                        setModalState(() {});
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 2. SOUND MODE SELECTION
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.volume_up_rounded, color: AppColors.accentGold, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'نمط صوت تنبيه الأذان',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...[
                                {
                                  'mode': AdhanSoundMode.fullAdhan,
                                  'title': 'أذان كامل (صوت نداء الحق كاملاً)',
                                  'desc': 'ينطلق صوت المؤذن كاملاً عند دخول وقت كل صلاة',
                                  'icon': Icons.volume_up_rounded,
                                },
                                {
                                  'mode': AdhanSoundMode.takbeerat,
                                  'title': 'تكبيرات فقط (الله أكبر الله أكبر)',
                                  'desc': 'نغمة تكبيرات مختصرة وسريعة بدلاً من الأذان المطول',
                                  'icon': Icons.campaign_rounded,
                                },
                                {
                                  'mode': AdhanSoundMode.softBeep,
                                  'title': 'نغمة إشعار هادئة (إشعار النظام)',
                                  'desc': 'تنبيه بصوت إشعار الهاتف القياسي دون تشغيل الأذان',
                                  'icon': Icons.notifications_active_outlined,
                                },
                                {
                                  'mode': AdhanSoundMode.vibrateOnly,
                                  'title': 'اهتزاز قوي فقط 📳 (بدون رنين)',
                                  'desc': 'اهتزاز متكرر عند دخول الوقت دون تشغيل مكبر الصوت',
                                  'icon': Icons.vibration_rounded,
                                },
                                {
                                  'mode': AdhanSoundMode.silent,
                                  'title': 'تنبيه صامت 🔕 (بدون صوت ولا اهتزاز)',
                                  'desc': 'إشعار بصري فقط على شاشة القفل دون أي إزعاج',
                                  'icon': Icons.notifications_off_outlined,
                                },
                              ].map((item) {
                                final isSelected = currentMode == item['mode'];
                                return InkWell(
                                  onTap: () async {
                                    await notifService.setSoundMode(item['mode'] as AdhanSoundMode);
                    if (!mounted) return;
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryGreen.withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryGreen : Colors.white12,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item['icon'] as IconData,
                                          color: isSelected ? AppColors.accentGold : Colors.white70,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title'] as String,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                  color: isSelected ? Colors.white : Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                item['desc'] as String,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  showSettingsAdhanVoiceModal(context);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.library_music_rounded, color: AppColors.accentGold, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'تصفح المكتبة الصوتية للأذان والمؤذنين 🎵',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white),
                                            ),
                                            Text(
                                              'المؤذن المعتمد: ${getAdhanVoiceName(notifService.selectedAdhanVoice)}',
                                              style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.7)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. VIBRATION & SENSOR GESTURE TOGGLES
                        Material(
                          color: Colors.white.withOpacity(0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.sensors_rounded, color: Colors.greenAccent, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'خيارات الاهتزاز ومستشعرات الحركة',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Vibrate on Stop Toggle
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.primaryGreen,
                                  secondary: const Icon(Icons.vibration_rounded, color: Colors.white70, size: 18),
                                  title: const Text(
                                    'الاهتزاز اللمسي عند الإيقاف 📳',
                                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'إطلاق نبض اهتزازي ثلاثي لتأكيد إيقاف نداء الصلاة',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.5),
                                  ),
                                  value: vibrateOnStop,
                                  onChanged: (val) async {
                                    await notifService.toggleVibrateOnStop(val);
                    if (!mounted) return;
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                                const Divider(color: Colors.white10, height: 8),

                                // Shake to Stop Toggle
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.primaryGreen,
                                  secondary: const Icon(Icons.screen_lock_rotation_rounded, color: Colors.white70, size: 18),
                                  title: const Text(
                                    'إيقاف الأذان عند هز الهاتف 📳',
                                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'هز الهاتف باليد يوقف الأذان فوراً',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.5),
                                  ),
                                  value: shakeEnabled,
                                  onChanged: (val) async {
                                    await sensorService.toggleShakeToStop(val);
                    if (!mounted) return;
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                                const Divider(color: Colors.white10, height: 8),

                                // Flip to Mute Toggle
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.primaryGreen,
                                  secondary: const Icon(Icons.phone_android_rounded, color: Colors.white70, size: 18),
                                  title: const Text(
                                    'كتم الأذان عند قلب الهاتف 📱',
                                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'قلب الهاتف على شاشته يكتم الصوت',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.5),
                                  ),
                                  value: flipEnabled,
                                  onChanged: (val) async {
                                    await sensorService.toggleFlipToMute(val);
                    if (!mounted) return;
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4. PER-PRAYER TOGGLES
                        Material(
                          color: Colors.white.withOpacity(0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.mosque_rounded, color: AppColors.accentGold, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'تفعيل / إيقاف كل صلاة على حدة',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...notifService.prayerToggles.keys.map((prayer) {
                                  final isEnabled = notifService.isPrayerEnabled(prayer);
                                  return SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppColors.primaryGreen,
                                    title: Text(
                                      'أذان صلاة $prayer',
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    value: isEnabled,
                                    onChanged: (val) async {
                                      await notifService.togglePrayer(prayer, val);
                    if (!mounted) return;
                                      setModalState(() {});
                                      setState(() {});
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _iqamahCountdownTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _equalizerController.dispose();
    sensorService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _getAtmosphereTheme(widget.prayerName);
    final timeStr =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}';
    final activeVoiceTitle = widget.isIqamah
        ? getIqamahVoiceName(notifService.selectedIqamahVoice)
        : getAdhanVoiceName(notifService.getPrayerVoice(widget.prayerName));

    final currentData = PrayerService.instance.currentData;
    final locationName = currentData?.locationName ?? 'موقعك الحالي';
    final hijriStr = HijriDateHelper.getHijriDateString(_currentTime);
    final qiblaDegrees = currentData?.qiblaDegrees ?? 136.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeData.backgroundColors,
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: Column(
              children: [
                // Custom App Bar with Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        tooltip: 'إغلاق والعودة',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      // Top pill badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: themeData.primaryAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeData.primaryAccent.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(themeData.celestialIcon, size: 16, color: themeData.primaryAccent),
                            const SizedBox(width: 6),
                            Text(
                              widget.isIqamah ? 'شاشة إقامة الصلاة' : 'شاشة تحكم نداء الحق',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: themeData.primaryAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: Colors.white),
                            tooltip: 'خيارات تفعيل وإيقاف الأذان',
                            onPressed: () => _showAdhanOptionsModal(context),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up_rounded, color: themeData.secondaryAccent),
                            tooltip: 'استوديو الأصوات والمؤذنين',
                            onPressed: () => showSettingsAdhanVoiceModal(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Interactive Body (Switchable between Live View & Dedicated Stop View)
                Expanded(
                  child: _showDedicatedStopView
                      ? _buildDedicatedStopView(themeData, timeStr, hijriStr, locationName, qiblaDegrees)
                      : _buildLiveAdhanView(themeData, timeStr, hijriStr, locationName, activeVoiceTitle, qiblaDegrees),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Live Adhan Player View
  Widget _buildLiveAdhanView(
    _PrayerAtmosphereTheme themeData,
    String timeStr,
    String hijriStr,
    String locationName,
    String activeVoiceTitle,
    double qiblaDegrees,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // Dedication Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: themeData.secondaryAccent.withOpacity(0.3)),
            ),
            child: const Text(
              'نداء الأذان المبارك — حيّ على الصلاة',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Prayer Headline & Spiritual Atmosphere Title
          Text(
            widget.isIqamah
                ? 'حان الآن موعد إقامة صلاة ${widget.prayerName}'
                : 'الله أكبر.. حان الآن أذان ${widget.prayerName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            themeData.atmosphereTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: themeData.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Live Clock & Date
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: themeData.secondaryAccent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '$hijriStr • $locationName',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),

          // Sacred Islamic Geometric Pulse Visualizer
          _buildIslamicGeometricVisualizer(themeData),
          const SizedBox(height: 16),

          // Muezzin Title Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeData.secondaryAccent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, color: themeData.secondaryAccent, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        activeVoiceTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_lastGestureTriggered != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _lastGestureTriggered!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeData.secondaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Iqamah Countdown Banner if active
          if (_isIqamahCountdownActive) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.lightBlueAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'العد التنازلي لإقامة الصلاة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(_iqamahRemainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_iqamahRemainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _iqamahTotalSeconds > 0
                          ? ((_iqamahTotalSeconds - _iqamahRemainingSeconds) / _iqamahTotalSeconds).clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Sensor Gesture Live Badges
          _buildSensorGestureCard(),
          const SizedBox(height: 16),

          // Interactive Prayer Logger Card
          _buildPrayerLogCard(themeData),
          const SizedBox(height: 16),

          // Quick Qibla Card
          _buildQuickQiblaCard(qiblaDegrees, themeData),
          const SizedBox(height: 20),

          // PRIMARY STOP BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMutedOrStopped
                    ? Colors.grey.shade700
                    : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isMutedOrStopped ? null : _stopAdhanManually,
              icon: const Icon(Icons.stop_circle_rounded, size: 26),
              label: Text(
                _isMutedOrStopped ? 'تم إيقاف الأذان' : 'إيقاف الأذان فوراً',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Action Controls Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Play / Pause
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _togglePlayPause,
                icon: Icon(
                  audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(audioService.isPlaying ? 'إيقاف مؤقت' : 'استئناف'),
              ),

              // Snooze 5 min
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentGold,
                  side: BorderSide(color: AppColors.accentGold.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _snoozeAdhan(5),
                icon: const Icon(Icons.snooze_rounded, size: 18),
                label: const Text('غفوة ٥ دقائق'),
              ),

              // Start Iqamah Countdown
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.lightBlueAccent,
                  side: BorderSide(color: Colors.lightBlueAccent.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _startIqamahCountdown(notifService.iqamahOffsetMinutes),
                icon: const Icon(Icons.hourglass_bottom_rounded, size: 18),
                label: const Text('بدء عداد الإقامة'),
              ),

              // Duaa after Adhan
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondaryGreen,
                  side: BorderSide(color: AppColors.secondaryGreen.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _showDuaaModal,
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('دعاء الأذان 🤲'),
              ),

              // Adhan Options Modal
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _showAdhanOptionsModal(context),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('خيارات الأذان'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Dedicated Stop & Serenity Screen (شاشة الإيقاف وسكينة ما بعد الأذان)
  Widget _buildDedicatedStopView(
    _PrayerAtmosphereTheme themeData,
    String timeStr,
    String hijriStr,
    String locationName,
    double qiblaDegrees,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Serenity Mosque & Crescent Icon
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.2),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 44),
            ),
          ),
          const SizedBox(height: 14),

          // Stop Confirmation Headline
          const Text(
            'تم إيقاف الأذان بنجاح ⏹️',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'نسأل الله العظيم أن يتقبل صلاتكم وطاعتكم بسكينة وخشوع 🤲',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Prominent Duaa Al-Wasila Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, color: AppColors.accentGold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'دعاء ما بعد الأذان (الوسيلة)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّدًا الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16.5,
                      height: 1.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'قال رسول الله ﷺ: "مَن قال حين يَسمع النداء... حلَّت له شفاعتي يوم القيامة" [صحيح البخاري]',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Colors.white60),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (SettingsService.instance.hapticEnabled) HapticFeedback.mediumImpact();
                    Clipboard.setData(const ClipboardData(
                      text:
                          'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّدًا الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
                    )).catchError((_) {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الدعاء المبارك بنجاح ✨'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('نسخ الدعاء المبارك', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Interactive Prayer Logger Card
          _buildPrayerLogCard(themeData),
          const SizedBox(height: 14),

          // Quick Qibla Card
          _buildQuickQiblaCard(qiblaDegrees, themeData),
          const SizedBox(height: 16),

          // Post-Stop Quick Actions Matrix
          Row(
            children: [
              // Resume Adhan Button (if stopped by mistake)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _showDedicatedStopView = false;
                      _isMutedOrStopped = false;
                    });
                    _startAudioPlayback();
                  },
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('استئناف الأذان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ),
              const SizedBox(width: 10),

              // Start Iqamah Countdown Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    setState(() {
                      _showDedicatedStopView = false;
                    });
                    _startIqamahCountdown(notifService.iqamahOffsetMinutes);
                  },
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('بدء عداد الإقامة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Return to Live View or Dismiss Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGold,
                    side: BorderSide(color: AppColors.accentGold.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showAdhanOptionsModal(context),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('خيارات الأذان المتقدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('العودة للتطبيق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIslamicGeometricVisualizer(_PrayerAtmosphereTheme themeData) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotationController, _equalizerController]),
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.07);
        final glowOpacity = 0.25 + (_pulseController.value * 0.35);

        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Aura
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      themeData.primaryAccent.withOpacity(glowOpacity),
                      Colors.transparent,
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Rotating 8-Pointed Star Canvas
              Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: _RubElHizbStarPainter(
                    color: themeData.secondaryAccent.withOpacity(0.4),
                  ),
                ),
              ),

              // Central Action Core
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isMutedOrStopped
                      ? Colors.grey.shade800
                      : themeData.primaryAccent,
                  boxShadow: [
                    BoxShadow(
                      color: (_isMutedOrStopped
                              ? Colors.grey
                              : themeData.primaryAccent)
                          .withOpacity(0.55),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isMutedOrStopped
                            ? Icons.volume_off_rounded
                            : Icons.graphic_eq_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      if (audioService.isPlaying && !_isMutedOrStopped) ...[
                        const SizedBox(height: 4),
                        // 5 Animated Equalizer Bars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final barHeight = 4.0 +
                                math.sin((_equalizerController.value * math.pi) + (index * 0.8))
                                        .abs() *
                                    10.0;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 3,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSensorGestureCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_rounded, color: Colors.greenAccent, size: 16),
              SizedBox(width: 6),
              Text(
                'مستشعرات الحركة نشطة وتعمل الآن',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              // Shake Badge & Simulation Button
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  sensorService.triggerSimulatedShake();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sensorService.shakeToStopEnabled
                        ? AppColors.primaryGreen.withOpacity(0.25)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sensorService.shakeToStopEnabled
                          ? AppColors.primaryGreen
                          : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vibration_rounded, color: Colors.white, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        sensorService.shakeToStopEnabled
                            ? 'هز الهاتف للإيقاف 📳 (تجربة)'
                            : 'الهز معطل',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Flip Badge & Simulation Button
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  sensorService.triggerSimulatedFlip();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sensorService.flipToMuteEnabled
                        ? AppColors.accentGold.withOpacity(0.25)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sensorService.flipToMuteEnabled
                          ? AppColors.accentGold
                          : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.screen_rotation_rounded, color: Colors.white, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        sensorService.flipToMuteEnabled
                            ? 'اقلب الهاتف للكتم 📱 (تجربة)'
                            : 'القلب معطل',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerLogCard(_PrayerAtmosphereTheme themeData) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPrayerLogged
              ? AppColors.primaryGreen.withOpacity(0.6)
              : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _isPrayerLogged ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      color: _isPrayerLogged ? AppColors.primaryGreen : themeData.secondaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isPrayerLogged
                            ? 'تم تسجيل أداء صلاة ${widget.prayerName} بنجاح ✨'
                            : 'هل صليت ${widget.prayerName}؟',
                        style: TextStyle(
                          color: _isPrayerLogged ? AppColors.primaryGreen : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isPrayerLogged) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'مكتوبة 🤲',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!_isPrayerLogged) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _logPrayerPerformance(true),
                    icon: const Icon(Icons.groups_rounded, size: 16),
                    label: const Text(
                      'جماعة بالمسجد 🕌',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _logPrayerPerformance(false),
                    icon: const Icon(Icons.person_rounded, size: 16),
                    label: const Text(
                      'صليت حاضراً 🤲',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickQiblaCard(double qiblaDegrees, _PrayerAtmosphereTheme themeData) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push('/qibla');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeData.primaryAccent.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: qiblaDegrees * (math.pi / 180.0),
                child: Icon(Icons.navigation_rounded, color: themeData.primaryAccent, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اتجاه القبلة نحو الكعبة المشرفة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'زاوية القبلة: ${qiblaDegrees.toStringAsFixed(0)}° • اضغط للمعاينة بالبوصلة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the 8-pointed star (Rub El Hizb)
class _RubElHizbStarPainter extends CustomPainter {
  final Color color;

  _RubElHizbStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw first square
    final path1 = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90.0) * (math.pi / 180.0);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw second square rotated 45 degrees
    final path2 = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90.0 + 45.0) * (math.pi / 180.0);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _RubElHizbStarPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
