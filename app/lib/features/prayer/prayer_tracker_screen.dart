import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/prayer_tracker_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل متابعة الصلوات والسنن'),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: PrayerTrackerService.instance,
          builder: (context, _) {
            final record = PrayerTrackerService.instance.getRecordForDate(_selectedDate);
            final recentDays = PrayerTrackerService.instance.getRecent7Days();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Noble Dedication Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD4AF37), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'صدقة جارية عن روح المرحوم بإذن الله: مؤمن إبراهيم رحمه الله',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                      tooltip: 'اليوم التالي',
                      onPressed: _isToday ? null : _nextDay,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 7-Day Weekly Strip
                _buildWeeklyStrip(recentDays),
                const SizedBox(height: 16),

                // Today's Progress Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: record.isAllObligatoryCompleted
                                    ? Colors.green.withOpacity(0.15)
                                    : AppColors.accentGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${record.completedObligatoryCount} من 5 صلوات',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: record.isAllObligatoryCompleted ? Colors.green.shade800 : const Color(0xFF8B6B00),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Linear progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: record.completedObligatoryCount / 5.0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('السنن الرواتب (12 ركعة):', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Text(
                              '${record.completedRawatibRakats} / 12 ركعة',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: AppColors.accentGold, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  PrayerTrackerService.instance.getGentleEncouragement(),
                                  style: const TextStyle(fontSize: 12.5, height: 1.4),
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

                // Checklist Section Title
                const Text(
                  'قائمة الصلوات المفروضة والسنن الرواتب',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Fajr Card
                _buildPrayerChecklistTile(
                  prayerName: 'الفجر',
                  rakats: 'ركعتان مفروضتان',
                  isObligatoryDone: record.fajr,
                  onToggleObligatory: () =>
                      PrayerTrackerService.instance.toggleObligatory('الفجر', _selectedDate),
                  sunnahKey: 'fajr_sunnah',
                  sunnahName: 'سنة الفجر القبلية (ركعتان مؤكدتان)',
                  isSunnahDone: record.fajrSunnah,
                  onToggleSunnah: () =>
                      PrayerTrackerService.instance.toggleSunnah('fajr_sunnah', _selectedDate),
                ),

                // Dhuhr Card
                _buildDhuhrTile(record),

                // Asr Card
                _buildPrayerChecklistTile(
                  prayerName: 'العصر',
                  rakats: 'أربع ركعات مفروضة',
                  isObligatoryDone: record.asr,
                  onToggleObligatory: () =>
                      PrayerTrackerService.instance.toggleObligatory('العصر', _selectedDate),
                  sunnahName: 'سنة قبلية مستحبة (أربع ركعات)',
                  isSunnahDone: false,
                  hasSunnahRawatib: false,
                ),

                // Maghrib Card
                _buildPrayerChecklistTile(
                  prayerName: 'المغرب',
                  rakats: 'ثلاث ركعات مفروضة',
                  isObligatoryDone: record.maghrib,
                  onToggleObligatory: () =>
                      PrayerTrackerService.instance.toggleObligatory('المغرب', _selectedDate),
                  sunnahKey: 'maghrib_sunnah',
                  sunnahName: 'سنة المغرب البعدية (ركعتان راتبة)',
                  isSunnahDone: record.maghribSunnah,
                  onToggleSunnah: () =>
                      PrayerTrackerService.instance.toggleSunnah('maghrib_sunnah', _selectedDate),
                ),

                // Isha Card
                _buildPrayerChecklistTile(
                  prayerName: 'العشاء',
                  rakats: 'أربع ركعات مفروضة',
                  isObligatoryDone: record.isha,
                  onToggleObligatory: () =>
                      PrayerTrackerService.instance.toggleObligatory('العشاء', _selectedDate),
                  sunnahKey: 'isha_sunnah',
                  sunnahName: 'سنة العشاء البعدية (ركعتان راتبة)',
                  isSunnahDone: record.ishaSunnah,
                  onToggleSunnah: () =>
                      PrayerTrackerService.instance.toggleSunnah('isha_sunnah', _selectedDate),
                ),

                const SizedBox(height: 14),

                // Extra Voluntary Prayers
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نوافل مباركة إضافية',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 4),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('صلاة الضحى (ركعتان إلى ثمان)'),
                          subtitle: const Text('تجزئ عن صدقة كل مفصل من مفاصل الجسد', style: TextStyle(fontSize: 11)),
                          value: record.duha,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              PrayerTrackerService.instance.toggleSunnah('duha', _selectedDate),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('صلاة الوتر (ركعة إلى ثلاث أو أكثر)'),
                          subtitle: const Text('«إن الله وتر يحب الوتر» · خاتمة صلاة الليل', style: TextStyle(fontSize: 11)),
                          value: record.witr,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              PrayerTrackerService.instance.toggleSunnah('witr', _selectedDate),
                        ),
                        const Divider(height: 1),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('قيام الليل والتهجد'),
                          subtitle: const Text('شرف المؤمن في قيام الليل والقرب من الله', style: TextStyle(fontSize: 11)),
                          value: record.qiyam,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (_) =>
                              PrayerTrackerService.instance.toggleSunnah('qiyam', _selectedDate),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Hadith Card on 12 Sunan Rawatib
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_stories_rounded, color: Color(0xFFB8860B), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'فضل السنن الرواتب الاثنتي عشرة ركعة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB8860B)),
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
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyStrip(List<DailyPrayerRecord> days) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          final isSelected = d.dateStr == PrayerTrackerService.formatDateKey(_selectedDate);
          final completed = d.completedObligatoryCount;
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              final parts = d.dateStr.split('-');
              if (parts.length == 3) {
                final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                setState(() => _selectedDate = dt);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    d.dateStr.substring(8), // day number
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed == 5
                          ? Colors.green
                          : (completed > 0 ? AppColors.accentGold : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      completed.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: completed > 0 ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerChecklistTile({
    required String prayerName,
    required String rakats,
    required bool isObligatoryDone,
    required VoidCallback onToggleObligatory,
    String? sunnahKey,
    String? sunnahName,
    bool isSunnahDone = false,
    VoidCallback? onToggleSunnah,
    bool hasSunnahRawatib = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'صلاة $prayerName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isObligatoryDone ? TextDecoration.none : null,
                ),
              ),
              subtitle: Text(rakats, style: const TextStyle(fontSize: 11.5)),
              value: isObligatoryDone,
              activeColor: AppColors.primaryGreen,
              onChanged: (_) => onToggleObligatory(),
            ),
            if (hasSunnahRawatib && sunnahName != null) ...[
              const Divider(height: 1),
              CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(right: 16),
                title: Text(
                  sunnahName,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isSunnahDone ? AppColors.primaryGreen : Colors.grey.shade700,
                  ),
                ),
                value: isSunnahDone,
                activeColor: AppColors.accentGold,
                onChanged: onToggleSunnah != null ? (_) => onToggleSunnah() : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDhuhrTile(DailyPrayerRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('صلاة الظهر', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('أربع ركعات مفروضة', style: TextStyle(fontSize: 11.5)),
              value: record.dhuhr,
              activeColor: AppColors.primaryGreen,
              onChanged: (_) =>
                  PrayerTrackerService.instance.toggleObligatory('الظهر', _selectedDate),
            ),
            const Divider(height: 1),
            CheckboxListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 16),
              title: const Text('سنة الظهر القبلية (أربع ركعات راتبة)', style: TextStyle(fontSize: 12.5)),
              value: record.dhuhrSunnahBefore,
              activeColor: AppColors.accentGold,
              onChanged: (_) =>
                  PrayerTrackerService.instance.toggleSunnah('dhuhr_sunnah_before', _selectedDate),
            ),
            const Divider(height: 1),
            CheckboxListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(right: 16),
              title: const Text('سنة الظهر البعدية (ركعتان راتبة)', style: TextStyle(fontSize: 12.5)),
              value: record.dhuhrSunnahAfter,
              activeColor: AppColors.accentGold,
              onChanged: (_) =>
                  PrayerTrackerService.instance.toggleSunnah('dhuhr_sunnah_after', _selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}
