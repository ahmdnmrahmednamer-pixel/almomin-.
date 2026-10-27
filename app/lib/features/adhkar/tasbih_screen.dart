import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';
import 'widgets/tasbih_custom_dialogs.dart';
import 'widgets/tasbih_main_button.dart';
import 'widgets/tasbih_motivation_dialog.dart';
import 'widgets/tasbih_stats_bar.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _volumeChannel =
      MethodChannel('almomin/volume_tasbih');

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final FocusNode _keyboardFocusNode = FocusNode();
  final TextEditingController _customPhraseController = TextEditingController();
  final TextEditingController _customTargetController = TextEditingController();
  bool _soundEnabled = true;
  bool _isShowingMotivation = false;
  DateTime? _lastVolumeUpTriggerTime;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _setupVolumeButtonInterception();
    AdhkarService.instance.addListener(_syncVolumeInterceptionState);
  }

  void _setupVolumeButtonInterception() {
    _volumeChannel.setMethodCallHandler((call) async {
      if (call.method == 'onVolumeUpPressed') {
        if (mounted && AdhkarService.instance.volumeButtonTasbihEnabled) {
          _triggerSingleVolumeUpIncrement();
        }
      }
    });
    _syncVolumeInterceptionState();
  }

  void _syncVolumeInterceptionState() {
    final enabled = AdhkarService.instance.volumeButtonTasbihEnabled;
    try {
      _volumeChannel.invokeMethod('setVolumeInterception', {'enabled': enabled});
    } catch (_) {}
  }

  @override
  void dispose() {
    AdhkarService.instance.removeListener(_syncVolumeInterceptionState);
    try {
      _volumeChannel.invokeMethod('setVolumeInterception', {'enabled': false});
      _volumeChannel.setMethodCallHandler(null);
    } catch (_) {}
    _keyboardFocusNode.dispose();
    _animController.dispose();
    _customPhraseController.dispose();
    _customTargetController.dispose();
    super.dispose();
  }

  void _triggerSingleVolumeUpIncrement() {
    final now = DateTime.now();
    if (_lastVolumeUpTriggerTime != null &&
        now.difference(_lastVolumeUpTriggerTime!).inMilliseconds < 120) {
      return;
    }
    _lastVolumeUpTriggerTime = now;
    _onTapTasbih();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp ||
          event.physicalKey == PhysicalKeyboardKey.audioVolumeUp) {
        if (AdhkarService.instance.volumeButtonTasbihEnabled) {
          _triggerSingleVolumeUpIncrement();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  void _onTapTasbih() async {
    _animController.forward().then((_) {
      if (mounted) _animController.reverse();
    });

    // 1. Instant tactile vibration on each bead click
    if (AdhkarService.instance.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    // 2. Play bead click sound if enabled
    if (_soundEnabled) {
      IslamicAudioService.instance.playTasbihClick();
    }

    // 3. Increment counter and check if set target has been completed
    final reachedTarget = AdhkarService.instance.incrementTasbih();

    // 4. Trigger motivating celebration when target count is reached
    if (reachedTarget && !_isShowingMotivation) {
      _triggerCelebrationAndMotivation();
    }
  }

  void _onSliderChanged(double value) {
    final newStep = value.round();
    if (AdhkarService.instance.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
    if (_soundEnabled) {
      IslamicAudioService.instance.playTasbihClick();
    }
    final reachedTarget =
        AdhkarService.instance.updateTasbihFromSlider(newStep);
    if (reachedTarget && !_isShowingMotivation) {
      _triggerCelebrationAndMotivation();
    }
  }

  void _triggerCelebrationAndMotivation() {
    _isShowingMotivation = true;

    // Multi-pulse celebratory vibration
    if (AdhkarService.instance.hapticEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) HapticFeedback.vibrate();
      });
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) HapticFeedback.heavyImpact();
      });
    }

    // Short celebratory takbeerat sound
    if (_soundEnabled) {
      IslamicAudioService.instance.playTakbeeratShort();
    }

    showTasbihMotivationDialog(
      context,
      onDismissed: () {
        _isShowingMotivation = false;
      },
    );
  }

  void _showCustomPhraseDialog() {
    showTasbihCustomPhraseDialog(context, controller: _customPhraseController);
  }

  void _showCustomTargetDialog() {
    showTasbihCustomTargetDialog(context, controller: _customTargetController);
  }

  void _confirmResetSession() {
    confirmTasbihResetSession(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            AdhkarService.instance,
            SettingsService.instance,
          ]),
          builder: (context, _) {
            final service = AdhkarService.instance;
            final count = service.tasbihCount;
            final target = service.tasbihTarget;
            final totalToday = service.tasbihTotalToday;
            final phrase = service.selectedTasbihPhrase;
            final haptic = service.hapticEnabled;
            final volumeBtnEnabled = service.volumeButtonTasbihEnabled;
            final sliderEnabled = service.tasbihSliderEnabled;

            // Compute cycle and progress
            final effectiveSliderMax = target > 0 ? target : 33;
            final currentInCycle = target > 0
                ? (count % target)
                : (count % effectiveSliderMax);
            final progress =
                target > 0 ? (currentInCycle / target) : 0.0;
            final cyclesCompleted = target > 0 ? (count ~/ target) : 0;

            return Scaffold(
              appBar: AppBar(
                title: Text(context.tr('electronic_tasbih')),
                actions: [
                  IconButton(
                    icon: Icon(
                      volumeBtnEnabled
                          ? Icons.settings_remote_rounded
                          : Icons.phonelink_erase_rounded,
                    ),
                    tooltip: volumeBtnEnabled
                        ? 'التسبيح بزر رفع الصوت مفعل (+١)'
                        : 'التسبيح بزر رفع الصوت معطل',
                    color:
                        volumeBtnEnabled ? AppColors.accentGold : Colors.white70,
                    onPressed: () {
                      final nextState = !volumeBtnEnabled;
                      service.toggleVolumeButtonTasbih(nextState);
                      SettingsService.instance
                          .toggleTasbihVolumeButton(nextState);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nextState
                                ? 'تم تفعيل التسبيح بزر رفع الصوت (+١) 🔊'
                                : 'تم إيقاف التسبيح بزر رفع الصوت',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(_soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded),
                    tooltip: _soundEnabled
                        ? 'صوت التسبيح مفعل'
                        : 'صوت التسبيح مكتوم',
                    color:
                        _soundEnabled ? AppColors.accentGold : Colors.white70,
                    onPressed: () {
                      setState(() {
                        _soundEnabled = !_soundEnabled;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_soundEnabled
                              ? 'تم تفعيل نقرة التسبيح الصوتية 🔊'
                              : 'تم كتم الصوت 🔇'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                        haptic ? Icons.vibration : Icons.smartphone_outlined),
                    tooltip: haptic ? 'الاهتزاز مفعل' : 'الاهتزاز معطل',
                    color: haptic ? AppColors.accentGold : Colors.white70,
                    onPressed: () {
                      service.toggleHaptic(!haptic);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(haptic
                              ? 'تم تعطيل الاهتزاز 📴'
                              : 'تم تفعيل الاهتزاز في المسبحة 📳'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'تصفير العداد الحالي',
                    onPressed: _confirmResetSession,
                  ),
                ],
              ),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 680;
                    final buttonSize = isCompact ? 175.0 : 220.0;
                    final ringSize = buttonSize - 22.0;

                    return Column(
                      children: [
                        // 1. Famous Dhikr Dropdown Selector
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppDropdownField<String>(
                                  label:
                                      'اختر صيغة الذكر والتسبيح من القائمة المنسدلة',
                                  value: AdhkarService.famousTasbihPhrases
                                          .contains(phrase)
                                      ? phrase
                                      : AdhkarService.famousTasbihPhrases.first,
                                  dense: true,
                                  prefixIcon: Icons.fingerprint_rounded,
                                  options: [
                                    ...AdhkarService.famousTasbihPhrases.map(
                                      (p) => AppDropdownOption<String>(
                                          value: p, label: p),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    service.setSelectedTasbihPhrase(val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                tooltip: 'إضافة ذكر مخصص',
                                icon: const Icon(Icons.add_rounded),
                                onPressed: _showCustomPhraseDialog,
                              ),
                            ],
                          ),
                        ),

                        // 2. Active Dhikr Card Display
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.darkSurface,
                                      const Color(0xFF1E2B24)
                                    ]
                                  : [
                                      AppColors.primaryGreen.withOpacity(0.08),
                                      AppColors.softGold.withOpacity(0.15)
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accentGold.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  phrase,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamilyFallback: const [
                                      'Traditional Arabic',
                                      'Amiri',
                                      'serif'
                                    ],
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.accentGold
                                        : AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 20, color: AppColors.accentGold),
                                tooltip: 'تعديل الذكر',
                                onPressed: _showCustomPhraseDialog,
                              ),
                            ],
                          ),
                        ),

                        // 3. Target Selector Dropdown (33, 100, 1000, Unlimited)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppDropdownField<int>(
                                  label: 'هدف دورة التسبيح',
                                  value: [33, 100, 1000, 0].contains(target)
                                      ? target
                                      : 33,
                                  dense: true,
                                  prefixIcon: Icons.flag_rounded,
                                  options: const [
                                    AppDropdownOption(
                                        value: 33,
                                        label: '٣٣ تسبيحة (دبر الصلاة)'),
                                    AppDropdownOption(
                                        value: 100,
                                        label: '١٠٠ تسبيحة (الورد اليومي)'),
                                    AppDropdownOption(
                                        value: 1000,
                                        label: '١٠٠٠ تسبيحة (الورد الموسع)'),
                                    AppDropdownOption(
                                        value: 0,
                                        label: 'عداد مفتوح (بدون حد)'),
                                  ],
                                  onChanged: (val) {
                                    service.setTasbihTarget(val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                tooltip: 'تحديد هدف مخصص',
                                icon: const Icon(Icons.tune_rounded),
                                onPressed: _showCustomTargetDialog,
                              ),
                            ],
                          ),
                        ),

                        // 4. NEW: Interactive Tasbih Slider & Volume-Up (+1) Control Card
                        if (sliderEnabled)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF14221B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.28),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.volume_up_rounded,
                                      size: 18,
                                      color: AppColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'سليدر المسبحة • التسبيح بزر رفع الصوت (+١)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 28,
                                      child: Switch(
                                        value: volumeBtnEnabled,
                                        activeColor: AppColors.accentGold,
                                        activeTrackColor:
                                            AppColors.primaryGreen,
                                        onChanged: (val) {
                                          service.toggleVolumeButtonTasbih(val);
                                          SettingsService.instance
                                              .toggleTasbihVolumeButton(val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$currentInCycle / $effectiveSliderMax',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor:
                                              AppColors.primaryGreen,
                                          inactiveTrackColor: AppColors
                                              .primaryGreen
                                              .withOpacity(0.18),
                                          thumbColor: AppColors.accentGold,
                                          overlayColor: AppColors.accentGold
                                              .withOpacity(0.2),
                                          trackHeight: 6,
                                        ),
                                        child: Slider(
                                          value: currentInCycle
                                              .clamp(0, effectiveSliderMax)
                                              .toDouble(),
                                          min: 0,
                                          max: effectiveSliderMax.toDouble(),
                                          divisions: effectiveSliderMax > 0
                                              ? effectiveSliderMax
                                              : 33,
                                          label: 'التسبيحة $currentInCycle',
                                          onChanged: _onSliderChanged,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: volumeBtnEnabled
                                          ? _onTapTasbih
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: volumeBtnEnabled
                                              ? AppColors.primaryGreen
                                              : Colors.grey.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.volume_up_rounded,
                                                size: 14, color: Colors.white),
                                            SizedBox(width: 3),
                                            Text(
                                              '+١',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
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
                          ),

                        const Spacer(),

                        // 5. Large Interactive Tactile Tasbih Button
                        TasbihMainButton(
                          onTap: _onTapTasbih,
                          scaleAnimation: _scaleAnimation,
                          count: count,
                          target: target,
                          currentInCycle: currentInCycle,
                          progress: progress,
                          isDark: isDark,
                          buttonSize: buttonSize,
                          ringSize: ringSize,
                        ),

                        const Spacer(),

                        // 6. Bottom Stats Card (Cycles, Today's Total, Fast Reset)
                        TasbihStatsBar(
                          cyclesCompleted: cyclesCompleted,
                          totalToday: totalToday,
                          isDark: isDark,
                          onReset: _confirmResetSession,
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
