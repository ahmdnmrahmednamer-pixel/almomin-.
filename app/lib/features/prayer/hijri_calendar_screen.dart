import 'package:flutter/material.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';

import '../ramadan/ramadan_screen.dart';

class IslamicOccasion {
  final String title;
  final int hijriMonth;
  final int hijriDay;
  final String description;
  final IconData icon;

  const IslamicOccasion({
    required this.title,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
    required this.icon,
  });
}

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  int _hijriAdjustment = 0; // ±2 days persisted in SettingsService
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _hijriAdjustment = SettingsService.instance.hijriAdjustmentDays;
    SettingsService.instance.addListener(_onSettingsUpdated);
  }

  void _onSettingsUpdated() {
    if (mounted && _hijriAdjustment != SettingsService.instance.hijriAdjustmentDays) {
      setState(() {
        _hijriAdjustment = SettingsService.instance.hijriAdjustmentDays;
      });
    }
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsUpdated);
    super.dispose();
  }

  static const List<IslamicOccasion> occasions = [
    IslamicOccasion(
      title: 'رأس السنة الهجرية',
      hijriMonth: 1,
      hijriDay: 1,
      description: 'بداية العام الهجري الجديد واستذكار الهجرة النبوية الشريفة',
      icon: Icons.brightness_auto,
    ),
    IslamicOccasion(
      title: 'يوم عاشوراء',
      hijriMonth: 1,
      hijriDay: 10,
      description: 'نجاة نبي الله موسى عليه السلام، ويستحب صيامه وتاسوعاء قبله',
      icon: Icons.wb_twighlight,
    ),
    IslamicOccasion(
      title: 'المولد النبوي الشريف',
      hijriMonth: 3,
      hijriDay: 12,
      description: 'مولد خير الأنام محمد ﷺ رحمة للعالمين',
      icon: Icons.star_rounded,
    ),
    IslamicOccasion(
      title: 'الإسراء والمعراج',
      hijriMonth: 7,
      hijriDay: 27,
      description: 'معجزة الإسراء بالرسول ﷺ وفرض الصلوات الخمس',
      icon: Icons.mosque,
    ),
    IslamicOccasion(
      title: 'ليلة النصف من شعبان',
      hijriMonth: 8,
      hijriDay: 15,
      description: 'تحويل القبلة إلى المسجد الحرام وليلة المغفرة والرحمة',
      icon: Icons.nightlight_round,
    ),
    IslamicOccasion(
      title: 'أول أيام شهر رمضان المبارك',
      hijriMonth: 9,
      hijriDay: 1,
      description: 'شهر الصيام والقرآن وليلة القدر التي هي خير من ألف شهر',
      icon: Icons.nights_stay,
    ),
    IslamicOccasion(
      title: 'عيد الفطر المبارك',
      hijriMonth: 10,
      hijriDay: 1,
      description: 'فرحة إتمام الصيام وجائزة العابدين وزكاة الفطر',
      icon: Icons.celebration,
    ),
    IslamicOccasion(
      title: 'يوم عرفة',
      hijriMonth: 12,
      hijriDay: 9,
      description: 'خير يوم طلعت عليه الشمس، وصيامه يكفر سنة ماضية وقادمة',
      icon: Icons.terrain,
    ),
    IslamicOccasion(
      title: 'عيد الأضحى المبارك',
      hijriMonth: 12,
      hijriDay: 10,
      description: 'يوم النحر وأيام التشريق وذكر الله وذبح الأضاحي',
      icon: Icons.festival,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Pass adjustmentDays explicitly to avoid double-adding _hijriAdjustment (Bug #18 fix)
    final hijri = HijriDateHelper.toHijri(_selectedDate, adjustmentDays: _hijriAdjustment);
    final currentHijriMonth = hijri['month']!;
    final currentHijriDay = hijri['day']!;
    final currentHijriYear = hijri['year']!;
    final monthName = HijriDateHelper.hijriMonths[currentHijriMonth - 1];

    // Build rolling 12-month upcoming occasions list so late Dhu al-Hijjah wraps into next Hijri year (Bug #17 fix)
    final thisYearOccasions = occasions
        .where((occ) =>
            occ.hijriMonth > currentHijriMonth ||
            (occ.hijriMonth == currentHijriMonth && occ.hijriDay >= currentHijriDay))
        .map((occ) => MapEntry(occ, currentHijriYear))
        .toList();

    final nextYearOccasions = occasions
        .where((occ) =>
            occ.hijriMonth < currentHijriMonth ||
            (occ.hijriMonth == currentHijriMonth && occ.hijriDay < currentHijriDay))
        .map((occ) => MapEntry(occ, currentHijriYear + 1))
        .toList();

    final upcomingEntries = [...thisYearOccasions, ...nextYearOccasions];

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقويم الهجري والمناسبات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.nightlight_round, color: AppColors.accentGold),
              tooltip: 'إمساكية ومحراب رمضان المبارك',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RamadanScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'تعديل رؤية الهلال (± يومين)',
              onPressed: _showAdjustmentDialog,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Main Hijri Banner Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    HijriDateHelper.getDayOfWeek(_selectedDate),
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currentHijriDay $monthName $currentHijriYear هـ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الموافق ${HijriDateHelper.getGregorianDateString(_selectedDate)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  if (_hijriAdjustment != 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'تعديل الرؤية الشرعية محفوظ: ${_hijriAdjustment > 0 ? "+$_hijriAdjustment" : _hijriAdjustment} يوم',
                        style: const TextStyle(color: AppColors.softGold, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  // White days & Sunnah fasting indicators
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWhiteDaysBadge(currentHijriDay),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildFastingDayBadge(_selectedDate.weekday),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date Navigation Controls
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('اليوم السابق'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickGregorianDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('اختر تاريخاً'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('اليوم التالي'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upcoming Islamic Occasions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المناسبات الإسلامية القادمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  '$currentHijriYear - ${currentHijriYear + 1} هـ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Occasions List
            ...upcomingEntries.map((entry) {
              final occ = entry.key;
              final occYear = entry.value;
              final isCurrent = occYear == currentHijriYear &&
                  occ.hijriMonth == currentHijriMonth &&
                  occ.hijriDay == currentHijriDay;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isCurrent ? AppColors.accentGold : Colors.transparent,
                    width: isCurrent ? 1.5 : 0,
                  ),
                ),
                color: isCurrent
                    ? (isDark ? const Color(0xFF263228) : const Color(0xFFF0F8F2))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.accentGold
                              : AppColors.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          occ.icon,
                          color: isCurrent ? Colors.black : AppColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    occ.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isCurrent ? AppColors.primaryGreen : null,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.softGold.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${occ.hijriDay} ${HijriDateHelper.hijriMonths[occ.hijriMonth - 1]} $occYear هـ',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              occ.description,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.white70 : AppColors.mutedText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteDaysBadge(int currentDay) {
    final isWhiteDay = currentDay == 13 || currentDay == 14 || currentDay == 15;
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isWhiteDay ? Colors.greenAccent : Colors.white38,
        ),
        const SizedBox(width: 6),
        Text(
          isWhiteDay ? 'اليوم من الأيام البيض المستحبة' : 'الأيام البيض: ١٣، ١٤، ١٥',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFastingDayBadge(int weekday) {
    final isMonThu = weekday == DateTime.monday || weekday == DateTime.thursday;
    return Row(
      children: [
        Icon(
          Icons.restaurant_menu,
          size: 14,
          color: isMonThu ? AppColors.softGold : Colors.white38,
        ),
        const SizedBox(width: 6),
        Text(
          isMonThu ? 'سنة صيام الإثنين والخميس' : 'صيام الإثنين والخميس',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _pickGregorianDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: AlertDialog(
            title: const Text('تعديل تقويم الرؤية الشرعية'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وفقاً لإعلانات دار الإفتاء وهيئات الرؤية الشرعية، قد يختلف التاريخ الهجري بمقدار يوم أو يومين عن الحساب الفلكي:',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'إضافة أو زيادة',
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _hijriAdjustment > -2
                          ? () {
                              setState(() => _hijriAdjustment--);
                              SettingsService.instance.setHijriAdjustmentDays(_hijriAdjustment);
                              setDialogState(() {});
                            }
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_hijriAdjustment > 0 ? "+$_hijriAdjustment" : "$_hijriAdjustment"} يوم',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ),
                    IconButton(
                      tooltip: 'إضافة أو زيادة',
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: _hijriAdjustment < 2
                          ? () {
                              setState(() => _hijriAdjustment++);
                              SettingsService.instance.setHijriAdjustmentDays(_hijriAdjustment);
                              setDialogState(() {});
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حفظ التعديل'),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}
