import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/fajr_qiyam_alarm_service.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

/// شاشة ضبط «منبّه الاستعداد لصلاة الفجر ومنبّه قيام الليل الذكي»
class FajrQiyamAlarmScreen extends StatefulWidget {
  const FajrQiyamAlarmScreen({super.key});

  @override
  State<FajrQiyamAlarmScreen> createState() => _FajrQiyamAlarmScreenState();
}

class _FajrQiyamAlarmScreenState extends State<FajrQiyamAlarmScreen> {
  final FajrQiyamAlarmService _alarmService = FajrQiyamAlarmService.instance;
  final IslamicAudioService _audioService = IslamicAudioService.instance;
  String? _previewingToneId;

  @override
  void initState() {
    super.initState();
    _alarmService.init();
  }

  @override
  void dispose() {
    _audioService.stop();
    super.dispose();
  }

  Future<void> _toggleTonePreview(String toneId) async {
    if (_previewingToneId == toneId && _audioService.isPlaying) {
      await _audioService.stop();
      await _audioService.stopSfx();
      if (mounted) setState(() => _previewingToneId = null);
      return;
    }
    setState(() => _previewingToneId = toneId);
    await _alarmService.previewTone(toneId);
    if (!mounted) return;
    final tone = _alarmService.getToneById(toneId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري سماع نغمة: ${tone.title} 🔊'),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickFixedQiyamTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _alarmService.qiyamFixedHour,
        minute: _alarmService.qiyamFixedMinute,
      ),
      helpText: 'اختر موعد الاستيقاظ لقيام الليل',
    );
    if (picked != null) {
      await _alarmService.setQiyamFixedTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('dawn_awakening')),
          actions: [
            IconButton(
              tooltip: 'إيقاف الصوت الحالي',
              icon: const Icon(Icons.volume_off_rounded),
              onPressed: () async {
                await _audioService.stop();
                if (!mounted) return;
                await _audioService.stopSfx();
                if (!mounted) return;
                setState(() => _previewingToneId = null);
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _alarmService,
            PrayerService.instance,
            _audioService,
          ]),
          builder: (context, _) {
            final prayerData = PrayerService.instance.currentData;
            final nextFajr = _alarmService.getNextFajrTime(prayerData);
            final nextPreFajrWake =
                _alarmService.getNextPreFajrWakeTime(prayerData);
            final nextQiyamWake =
                _alarmService.getNextQiyamWakeTime(prayerData);
            final lastThirdStart =
                _alarmService.getLastThirdOfNightStart(prayerData);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Live Astronomical Times Summary Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B3B2D), Color(0xFF172738)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            color: AppColors.accentGold,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'مواقيت الاستيقاظ المحسوبة تلقائياً لموقعك',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeStatBox(
                              label: 'موعد أذان الفجر القادم',
                              timeStr: _alarmService.formatTimeAr(nextFajr),
                              icon: Icons.wb_twilight_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeStatBox(
                              label: 'منبّه الاستعداد للفجر',
                              timeStr: _alarmService.preFajrEnabled
                                  ? _alarmService.formatTimeAr(nextPreFajrWake)
                                  : 'متوقف',
                              icon: Icons.notifications_active_rounded,
                              highlight: _alarmService.preFajrEnabled,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeStatBox(
                              label: 'منبّه قيام الليل',
                              timeStr: _alarmService.qiyamEnabled
                                  ? _alarmService.formatTimeAr(nextQiyamWake)
                                  : 'متوقف',
                              icon: Icons.nights_stay_rounded,
                              highlight: _alarmService.qiyamEnabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // SECTION 1: Pre-Fajr Wake-Up Alarm Card
                _buildPreFajrSectionCard(isDark, nextPreFajrWake),
                const SizedBox(height: 18),

                // SECTION 2: Qiyam Al-Layl Wake-Up Alarm Card
                _buildQiyamSectionCard(isDark, nextQiyamWake, lastThirdStart),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeStatBox({
    required String label,
    required String timeStr,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accentGold.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.accentGold : Colors.white24,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: Colors.white70),
          ),
          const SizedBox(height: 3),
          Text(
            timeStr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreFajrSectionCard(bool isDark, DateTime nextPreFajrWake) {
    final mins = _alarmService.preFajrMinutesBefore;
    final selectedToneId = _alarmService.preFajrToneId;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.wb_twilight_rounded,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '١. منبّه الاستيقاظ والاستعداد قبل صلاة الفجر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'يوقظك قبل الفجر بـ $mins دقيقة (${_alarmService.formatTimeAr(nextPreFajrWake)}) لتتوضأ وتدرك الصلاة في وقتها',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _alarmService.preFajrEnabled,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) => _alarmService.setPreFajrEnabled(v),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'حدد الوقت قبل أذان الفجر (بالدقائق):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            AppDropdownField<int>(
              label: 'اختر مدة الاستيقاظ قبل أذان الفجر',
              value: [10, 15, 20, 25, 30, 45, 60, 90].contains(mins) ? mins : 30,
              dense: true,
              prefixIcon: Icons.alarm_on_rounded,
              options: [10, 15, 20, 25, 30, 45, 60, 90]
                  .map((m) => AppDropdownOption<int>(
                        value: m,
                        label: 'قبل صلاة الفجر بـ $m دقيقة',
                      ))
                  .toList(),
              onChanged: (m) => _alarmService.setPreFajrMinutesBefore(m),
            ),
            Slider(
              value: mins.toDouble().clamp(5.0, 120.0),
              min: 5,
              max: 120,
              divisions: 23,
              activeColor: AppColors.primaryGreen,
              label: '$mins دقيقة قبل الفجر',
              onChanged: (val) =>
                  _alarmService.setPreFajrMinutesBefore(val.round()),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر نغمة منبّه الاستعداد للفجر (اضغط 🔊 لسماع النغمة فوراً):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            ...FajrQiyamAlarmService.availableTones.map((tone) {
              final isSelected = selectedToneId == tone.id;
              final isPreviewing =
                  _previewingToneId == tone.id && _audioService.isPlaying;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGold
                        : Colors.grey.withValues(alpha: 0.25),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Radio<String>(
                    value: tone.id,
                    groupValue: selectedToneId,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (v) {
                      if (v != null) _alarmService.setPreFajrTone(v);
                    },
                  ),
                  title: Text(
                    tone.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  subtitle: Text(tone.subtitle, style: const TextStyle(fontSize: 11.5)),
                  trailing: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isPreviewing ? Colors.white : AppColors.primaryGreen,
                      backgroundColor: isPreviewing
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: Icon(
                      isPreviewing ? Icons.stop_rounded : Icons.volume_up_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isPreviewing ? 'إيقاف' : 'سماع 🔊',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _toggleTonePreview(tone.id),
                  ),
                  onTap: () => _alarmService.setPreFajrTone(tone.id),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.notifications_active_rounded),
                label: const Text(
                  'تجربة رنين منبّه الاستعداد للفجر الآن 🔔',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () =>
                    _alarmService.triggerImmediateTestAlarm(isQiyam: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiyamSectionCard(
    bool isDark,
    DateTime nextQiyamWake,
    DateTime lastThirdStart,
  ) {
    final mode = _alarmService.qiyamMode;
    final selectedToneId = _alarmService.qiyamToneId;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.nights_stay_rounded,
                    color: AppColors.accentGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '٢. منبّه قيام الليل والتهجد الذكي (الثلث الأخير)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'موعد التنبيه القادم: ${_alarmService.formatTimeAr(nextQiyamWake)} (بداية الثلث الأخير: ${_alarmService.formatTimeAr(lastThirdStart)})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _alarmService.qiyamEnabled,
                  activeColor: AppColors.accentGold,
                  onChanged: (v) => _alarmService.setQiyamEnabled(v),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'نظام تحديد وقت الاستيقاظ لقيام الليل:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            AppDropdownField<String>(
              label: 'نظام تحديد وقت الاستيقاظ لقيام الليل',
              value: mode,
              dense: true,
              prefixIcon: Icons.nights_stay_rounded,
              options: const [
                AppDropdownOption(
                  value: 'last_third',
                  label: 'بداية الثلث الأخير من الليل تلقائياً 🌙',
                ),
                AppDropdownOption(
                  value: 'before_fajr',
                  label: 'قبل أذان الفجر بمدة محددة ⏳',
                ),
                AppDropdownOption(
                  value: 'fixed_time',
                  label: 'وقت ثابت أختاره بنفسي ⏰',
                ),
              ],
              onChanged: (val) => _alarmService.setQiyamMode(val),
            ),
            const SizedBox(height: 12),
            if (mode == 'before_fajr') ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [45, 60, 75, 90, 120].map((m) {
                  final sel = _alarmService.qiyamMinutesBeforeFajr == m;
                  return ChoiceChip(
                    label: Text('قبل الفجر بـ $m دقيقة'),
                    selected: sel,
                    selectedColor: AppColors.accentGold,
                    onSelected: (_) =>
                        _alarmService.setQiyamMinutesBeforeFajr(m),
                  );
                }).toList(),
              ),
            ] else if (mode == 'fixed_time') ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.schedule_rounded),
                label: Text(
                  'الوقت المحدد: ${_alarmService.qiyamFixedHour.toString().padLeft(2, '0')}:${_alarmService.qiyamFixedMinute.toString().padLeft(2, '0')} ص — اضغط للتغيير',
                ),
                onPressed: _pickFixedQiyamTime,
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'نغمة منبّه قيام الليل:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            const SizedBox(height: 8),
            ...FajrQiyamAlarmService.availableTones.take(5).map((tone) {
              final isSelected = selectedToneId == tone.id;
              final isPreviewing =
                  _previewingToneId == tone.id && _audioService.isPlaying;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Radio<String>(
                  value: tone.id,
                  groupValue: selectedToneId,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (v) {
                    if (v != null) _alarmService.setQiyamTone(v);
                  },
                ),
                title: Text(
                  tone.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                trailing: IconButton(
                  tooltip: 'تشغيل أو إيقاف الصوت',
                  icon: Icon(
                    isPreviewing ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  onPressed: () => _toggleTonePreview(tone.id),
                ),
                onTap: () => _alarmService.setQiyamTone(tone.id),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.nights_stay_rounded),
                label: const Text(
                  'تجربة رنين منبّه قيام الليل الآن 🌙',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () =>
                    _alarmService.triggerImmediateTestAlarm(isQiyam: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
