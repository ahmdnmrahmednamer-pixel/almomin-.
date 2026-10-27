import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/prayer_tracker_service.dart';
import '../../core/theme/app_theme.dart';
import 'fajr_qiyam_alarm_screen.dart';

class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    PrayerTrackerService.instance.init();
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.add(const Duration(days: 1)).isBefore(tomorrow)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  /// Opens the interactive dialog for writing/selecting why a prayer was missed or delayed
  Future<void> _showReasonEntryDialog({
    required String prayerName,
    required PrayerPerformanceStatus targetStatus,
    String? currentReason,
  }) async {
    final controller = TextEditingController(text: currentReason ?? '');
    String selectedQuickReason = '';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: SettingsService.instance.textDirection,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 20,
                  left: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            targetStatus == PrayerPerformanceStatus.missed
                                ? Icons.warning_amber_rounded
                                : Icons.schedule_rounded,
                            color: targetStatus == PrayerPerformanceStatus.missed
                                ? Colors.redAccent
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              targetStatus == PrayerPerformanceStatus.missed
                                  ? 'تسجيل سبب فوات صلاة $prayerName'
                                  : 'تسجيل سبب تأخير صلاة $prayerName (قضاء)',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'إغلاق أو مسح',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'اكتب بصراحة لماذا فاتتك أو تأخرت عن هذه الصلاة، حتى تراجع أسبابك في نهاية الأسبوع وتعالج المشكلة:',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'اختر سبباً سريعاً أو اكتب السبب بالتفصيل:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PrayerTrackerService.commonMissedReasons.map((r) {
                          final isSel = selectedQuickReason == r;
                          return ChoiceChip(
                            label: Text(r, style: const TextStyle(fontSize: 12)),
                            selected: isSel,
                            selectedColor: AppColors.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : null,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                selectedQuickReason = r;
                                if (controller.text.trim().isEmpty) {
                                  controller.text = r;
                                } else if (!controller.text.contains(r)) {
                                  controller.text = '${controller.text.trim()} — $r';
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'أنا لم أصلِّ / أخرت صلاة $prayerName بسبب...',
                          hintText:
                              'مثال: نمت متأخراً بعد الساعة ٢ ص ولم أسمع المنبه، أو انشغلت في اجتماع عمل...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save_rounded),
                          label: const Text(
                            'حفظ الحالة والسبب في سجل المحاسبة الأسبوعي',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    final enteredText = controller.text.trim();
    Future.delayed(const Duration(milliseconds: 350), controller.dispose);
    if (saved == true) {
      final reasonText = enteredText.isNotEmpty
          ? enteredText
          : (selectedQuickReason.isNotEmpty
              ? selectedQuickReason
              : 'لم يُحدد السبب');
      await PrayerTrackerService.instance.setPrayerFormStatus(
        prayerNameAr: prayerName,
        status: targetStatus,
        reasonText: reasonText,
        date: _selectedDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل متابعة الصلوات والسنن'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'منبّه الاستعداد للفجر وقيام الليل',
              icon: const Icon(Icons.alarm_on_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FajrQiyamAlarmScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: PrayerTrackerService.instance,
          builder: (context, _) {
            final service = PrayerTrackerService.instance;
            final record = service.getRecordForDate(_selectedDate);
            final recentDays = service.getRecent7Days();
            final weeklyReport = service.getWeeklyDiagnosticReport();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Noble dedication & motivation banner
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'حافظ على صلواتك في أوقاتها 🤲 صدقة جارية عن روح مؤمن إبراهيم رحمه الله',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
                // Quick Banner to Pre-Fajr & Qiyam Alarm
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FajrQiyamAlarmScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D5C46), Color(0xFF083B2C)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.alarm_on_rounded,
                          color: AppColors.accentGold,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'منبّه الاستعداد قبل الفجر ومنبّه قيام الليل 🌅🌙',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'اضبط منبهاً بنغمة خاصة ليوقظك قبل الفجر بوقت تحدده أو للثلث الأخير من الليل',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.accentGold,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Date Navigation Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      tooltip: 'اليوم السابق',
                      onPressed: _previousDay,
                    ),
                    Text(
                      _isToday
                          ? 'اليوم (${record.dateStr})'
                          : record.dateStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                      tooltip: 'اليوم التالي',
                      onPressed: _isToday ? null : _nextDay,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 7-Day Weekly Strip
                _buildWeeklyStrip(recentDays),
                const SizedBox(height: 14),

                // Today's Progress Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'إنجاز اليوم في الصلاة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: record.isAllObligatoryCompleted
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : AppColors.accentGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${record.completedObligatoryCount} من 5 صلوات',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: record.isAllObligatoryCompleted
                                      ? Colors.green.shade800
                                      : const Color(0xFF8B6B00),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (record.completedObligatoryCount / 5.0).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'السنن الرواتب (12 ركعة):',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            Text(
                              '${record.completedRawatibRakats} / 12 ركعة',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.accentGold,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service.getGentleEncouragement(),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION 1: Daily Prayer Form (فورم متابعة الصلوات الخمس اليومي وتسجيل أسباب الفوات)
                const Text(
                  'قائمة الصلوات المفروضة والسنن الرواتب (الفورم اليومي)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'حدد حالة كل فرض (في وقتها / قضاء / فاتتني) واكتب سبب الفوات أو التأخير لتشخيصه ومعالجته:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // Fajr Card
                _buildPrayerChecklistTile(
                  record: record,
                  prayerName: 'الفجر',
                  rakats: 'ركعتان مفروضتان',
                  isObligatoryDone: record.fajr,
                  onToggleObligatory: () =>
                      service.toggleObligatory('الفجر', _selectedDate),
                  sunnahKey: 'fajr_sunnah',
                  sunnahName: 'سنة الفجر القبلية (ركعتان مؤكدتان)',
                  isSunnahDone: record.fajrSunnah,
                  onToggleSunnah: () =>
                      service.toggleSunnah('fajr_sunnah', _selectedDate),
                ),

                // Dhuhr Card
                _buildDhuhrTile(record),

                // Asr Card
                _buildPrayerChecklistTile(
                  record: record,
                  prayerName: 'العصر',
                  rakats: 'أربع ركعات مفروضة',
                  isObligatoryDone: record.asr,
                  onToggleObligatory: () =>
                      service.toggleObligatory('العصر', _selectedDate),
                  sunnahName: 'سنة قبلية مستحبة (أربع ركعات)',
                  isSunnahDone: false,
                  hasSunnahRawatib: false,
                ),

                // Maghrib Card
                _buildPrayerChecklistTile(
                  record: record,
                  prayerName: 'المغرب',
                  rakats: 'ثلاث ركعات مفروضة',
                  isObligatoryDone: record.maghrib,
                  onToggleObligatory: () =>
                      service.toggleObligatory('المغرب', _selectedDate),
                  sunnahKey: 'maghrib_sunnah',
                  sunnahName: 'سنة المغرب البعدية (ركعتان راتبة)',
                  isSunnahDone: record.maghribSunnah,
                  onToggleSunnah: () =>
                      service.toggleSunnah('maghrib_sunnah', _selectedDate),
                ),

                // Isha Card
                _buildPrayerChecklistTile(
                  record: record,
                  prayerName: 'العشاء',
                  rakats: 'أربع ركعات مفروضة',
                  isObligatoryDone: record.isha,
                  onToggleObligatory: () =>
                      service.toggleObligatory('العشاء', _selectedDate),
                  sunnahKey: 'isha_sunnah',
                  sunnahName: 'سنة العشاء البعدية (ركعتان راتبة)',
                  isSunnahDone: record.ishaSunnah,
                  onToggleSunnah: () =>
                      service.toggleSunnah('isha_sunnah', _selectedDate),
                ),

                const SizedBox(height: 14),

                // Extra Voluntary Prayers
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نوافل مباركة إضافية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('صلاة الضحى (ركعتان إلى ثمان)'),
                          subtitle: const Text(
                            'تجزئ عن صدقة كل مفصل من مفاصل الجسد',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: record.duha,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              service.toggleSunnah('duha', _selectedDate),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('صلاة الوتر (ركعة إلى ثلاث أو أكثر)'),
                          subtitle: const Text(
                            '«إن الله وتر يحب الوتر» · خاتمة صلاة الليل',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: record.witr,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              service.toggleSunnah('witr', _selectedDate),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('قيام الليل والتهجد'),
                          subtitle: const Text(
                            'شرف المؤمن في قيام الليل والقرب من الله',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: record.qiyam,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              service.toggleSunnah('qiyam', _selectedDate),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Hadith Card on 12 Sunan Rawatib
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFFB8860B),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'فضل السنن الرواتب الاثنتي عشرة ركعة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'عن أم حبيبة رضي الله عنها قالت: سمعت رسول الله ﷺ يقول: «مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ: أَرْبَعًا قَبْلَ الظُّهْرِ، وَرَكْعَتَيْنِ بَعْدَهَا، وَرَكْعَتَيْنِ بَعْدَ الْمَغْرِبِ، وَرَكْعَتَيْنِ بَعْدَ الْعِشَاءِ، وَرَكْعَتَيْنِ قَبْلَ صَلَاةِ الْغَدَاةِ (الفجر)» [رواه مسلم].',
                        style: TextStyle(fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SECTION 2: Weekly Summary & Missed-Prayer Diagnostic Report
                _buildWeeklyDiagnosticSection(weeklyReport, isDark),

                const SizedBox(height: 24),
              ],
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyDiagnosticSection(
    WeeklyPrayerDiagnosticReport report,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'التقرير الأسبوعي وسجل تشخيص أسباب فوات الصلاة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'ملخص أدائك في آخر ٧ أيام (إجمالي ٣٥ صلاة مفروضة في الأسبوع):',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildWeeklyStatTile(
                    label: 'صليت في الأسبوع',
                    value: '${report.totalPrayedCount} / 35',
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWeeklyStatTile(
                    label: 'في وقتها',
                    value: '${report.prayedOnTimeCount}',
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWeeklyStatTile(
                    label: 'قضاء',
                    value: '${report.prayedQadaCount}',
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWeeklyStatTile(
                    label: 'فاتتك / مسجلة فائتة',
                    value: '${report.explicitlyMissedCount} (${report.missedOrUnprayedCount})',
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (report.diagnosticEntries.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '📋 سجل الأسباب التي كتبتها للصلوات الفائتة أو المتأخرة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              const SizedBox(height: 8),
              ...report.diagnosticEntries.take(8).map((entry) {
                final isMissed =
                    entry.status == PrayerPerformanceStatus.missed;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isMissed ? Colors.red : Colors.orange)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isMissed ? Colors.red : Colors.orange)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isMissed
                            ? Icons.error_outline_rounded
                            : Icons.history_toggle_off_rounded,
                        size: 18,
                        color: isMissed ? Colors.redAccent : Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'صلاة ${entry.prayerName} (${entry.dateStr}) — ${isMissed ? "فاتتني" : "قضاء"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'السبب المسجل: ${entry.reasonText}',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (report.reasonFrequency.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '🔍 أكثر أسباب الفوات والتأخير تكراراً عندك:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: report.reasonFrequency.entries.map((e) {
                  return Chip(
                    label: Text(
                      '${e.key} (${e.value} مرات)',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    backgroundColor: AppColors.accentGold.withValues(alpha: 0.14),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 خطة العلاج العملية المقترحة لك:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...report.actionableRemedies.map(
                    (rem) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(rem, style: const TextStyle(fontSize: 12, height: 1.45)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStrip(List<DailyPrayerRecord> recentDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: recentDays.map((r) {
        final isSelected = r.dateStr == PrayerTrackerService.formatDateKey(_selectedDate);
        final count = r.completedObligatoryCount;
        final parts = r.dateStr.split('-');
        final dayNum = parts.length == 3 ? parts[2] : r.dateStr;

        Color circleColor = Colors.grey.shade300;
        if (count == 5) {
          circleColor = AppColors.primaryGreen;
        } else if (count > 0) {
          circleColor = AppColors.accentGold;
        } else if (r.missedObligatoryCount > 0) {
          circleColor = Colors.redAccent;
        }

        return GestureDetector(
          onTap: () {
            final parsed = DateTime.tryParse(r.dateStr);
            if (parsed != null) {
              setState(() {
                _selectedDate = parsed;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primaryGreen, width: 1.5)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count/5',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: count > 0 || r.missedObligatoryCount > 0
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrayerFormStatusRow(DailyPrayerRecord record, String prayerName) {
    final currentStatus = record.getPrayerStatus(prayerName);
    final reason = record.getReasonForPrayer(prayerName);
    final service = PrayerTrackerService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('في وقتها ✅', style: TextStyle(fontSize: 11.5)),
              selected:
                  currentStatus == PrayerPerformanceStatus.onTimeCongregation ||
                      currentStatus == PrayerPerformanceStatus.onTimeIndividual,
              selectedColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: (currentStatus ==
                            PrayerPerformanceStatus.onTimeCongregation ||
                        currentStatus ==
                            PrayerPerformanceStatus.onTimeIndividual)
                    ? Colors.white
                    : null,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                service.setPrayerFormStatus(
                  prayerNameAr: prayerName,
                  status: PrayerPerformanceStatus.onTimeCongregation,
                  date: _selectedDate,
                );
              },
            ),
            ChoiceChip(
              label: const Text('قضاء ⏳', style: TextStyle(fontSize: 11.5)),
              selected: currentStatus == PrayerPerformanceStatus.lateQada,
              selectedColor: Colors.orange.shade700,
              labelStyle: TextStyle(
                color: currentStatus == PrayerPerformanceStatus.lateQada
                    ? Colors.white
                    : null,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                _showReasonEntryDialog(
                  prayerName: prayerName,
                  targetStatus: PrayerPerformanceStatus.lateQada,
                  currentReason: reason,
                );
              },
            ),
            ChoiceChip(
              label: const Text('فاتتني ❌', style: TextStyle(fontSize: 11.5)),
              selected: currentStatus == PrayerPerformanceStatus.missed,
              selectedColor: Colors.redAccent,
              labelStyle: TextStyle(
                color: currentStatus == PrayerPerformanceStatus.missed
                    ? Colors.white
                    : null,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) {
                _showReasonEntryDialog(
                  prayerName: prayerName,
                  targetStatus: PrayerPerformanceStatus.missed,
                  currentReason: reason,
                );
              },
            ),
            if (currentStatus == PrayerPerformanceStatus.missed ||
                currentStatus == PrayerPerformanceStatus.lateQada)
              ActionChip(
                avatar: const Icon(Icons.edit_note_rounded, size: 15),
                label: Text(
                  reason != null ? 'تعديل السبب' : 'كتابة سبب الفوات',
                  style: const TextStyle(fontSize: 11),
                ),
                onPressed: () {
                  _showReasonEntryDialog(
                    prayerName: prayerName,
                    targetStatus: currentStatus,
                    currentReason: reason,
                  );
                },
              ),
          ],
        ),
        if (reason != null) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              '📌 سبب عدم الصلاة في وقتها: $reason',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrayerChecklistTile({
    required DailyPrayerRecord record,
    required String prayerName,
    required String rakats,
    required bool isObligatoryDone,
    required VoidCallback onToggleObligatory,
    String? sunnahKey,
    required String sunnahName,
    required bool isSunnahDone,
    VoidCallback? onToggleSunnah,
    bool hasSunnahRawatib = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'صلاة $prayerName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                rakats,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              value: isObligatoryDone,
              activeColor: AppColors.primaryGreen,
              onChanged: (_) => onToggleObligatory(),
            ),
            _buildPrayerFormStatusRow(record, prayerName),
            if (hasSunnahRawatib && onToggleSunnah != null) ...[
              const Divider(height: 10),
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(right: 12),
                title: Text(sunnahName, style: const TextStyle(fontSize: 13)),
                value: isSunnahDone,
                activeColor: AppColors.accentGold,
                onChanged: (_) => onToggleSunnah(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDhuhrTile(DailyPrayerRecord record) {
    final service = PrayerTrackerService.instance;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'صلاة الظهر',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text(
                'أربع ركعات مفروضة',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              value: record.dhuhr,
              activeColor: AppColors.primaryGreen,
              onChanged: (_) => service.toggleObligatory('الظهر', _selectedDate),
            ),
            _buildPrayerFormStatusRow(record, 'الظهر'),
            const Divider(height: 10),
            CheckboxListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 12),
              title: const Text(
                'سنة الظهر القبلية (أربع ركعات راتبة)',
                style: TextStyle(fontSize: 13),
              ),
              value: record.dhuhrSunnahBefore,
              activeColor: AppColors.accentGold,
              onChanged: (_) =>
                  service.toggleSunnah('dhuhr_sunnah_before', _selectedDate),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 12),
              title: const Text(
                'سنة الظهر البعدية (ركعتان راتبة)',
                style: TextStyle(fontSize: 13),
              ),
              value: record.dhuhrSunnahAfter,
              activeColor: AppColors.accentGold,
              onChanged: (_) =>
                  service.toggleSunnah('dhuhr_sunnah_after', _selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}
