import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/notifications/prayer_notification_service.dart';
import 'qibla_compass_screen.dart';
import 'hijri_calendar_screen.dart';
import 'battery_reliability_screen.dart';
import 'prayer_tracker_screen.dart';
import '../../core/services/prayer_tracker_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  @override
  void initState() {
    super.initState();
    PrayerService.instance.init();
    PrayerNotificationService.instance.init();
    PrayerTrackerService.instance.init();
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cities = PrayerService.famousCities.where((c) {
              if (filter.isEmpty) return true;
              return c.name.contains(filter);
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                    const Text(
                      'اختيار المدينة يدوياً',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مدينتك (مثل: القاهرة، مكة، دبي...)',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                        filled: true,
                        fillColor: AppColors.primaryGreen.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          filter = val.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final city = cities[idx];
                          final isCurrent = PrayerService.instance.currentData?.locationName == city.name;
                          return ListTile(
                            leading: Icon(
                              Icons.location_city,
                              color: isCurrent ? AppColors.accentGold : AppColors.primaryGreen,
                            ),
                            title: Text(
                              city.name,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? AppColors.primaryGreen : null,
                              ),
                            ),
                            trailing: isCurrent
                                ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                                : null,
                            onTap: () async {
                              await PrayerService.instance.setManualCity(city);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم ضبط الموقع على: ${city.name} وتحديث المواقيت'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة والقبلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'بوصلة القبلة التفاعلية',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'التقويم الهجري والمناسبات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_city),
            tooltip: 'اختيار المدينة يدوياً',
            onPressed: () => _showCityPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'تحديث الموقع عبر GPS',
            onPressed: () async {
              final ok = await PrayerService.instance.requestGpsLocation();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'تم تحديث الموقع ومواقيت الصلاة بنجاح' : (PrayerService.instance.errorMessage ?? 'تعذر تحديث الموقع')),
                    backgroundColor: ok ? AppColors.primaryGreen : Colors.redAccent,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            PrayerService.instance,
            SettingsService.instance,
            PrayerNotificationService.instance,
          ]),
          builder: (context, _) {
            final data = PrayerService.instance.currentData;
            final hijriStr = HijriDateHelper.getHijriDateString();
            final gregStr = HijriDateHelper.getGregorianDateString();
            final dayStr = HijriDateHelper.getDayOfWeek();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Hijri and Gregorian Dates Card (Interactive link to calendar)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold.withOpacity(0.6), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: AppColors.primaryGreen, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    dayStr,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('المناسبات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                    SizedBox(width: 2),
                                    Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primaryGreen),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hijriStr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            gregStr,
                            style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location and Method Banner
                Card(
                  color: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.place, color: AppColors.softGold, size: 18),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          data?.locationName ?? 'جاري تحديد الموقع...',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'طريقة الحساب: ${SettingsService.calculationMethods.firstWhere((m) => m['id'] == SettingsService.instance.calculationMethod)['name']}',
                                    style: const TextStyle(color: AppColors.softGold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: AppColors.softGold),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                  ),
                                  icon: const Icon(Icons.location_city, size: 14, color: AppColors.softGold),
                                  label: const Text('تغيير المدينة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  onPressed: () => _showCityPicker(context),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentGold,
                                    foregroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                  ),
                                  icon: PrayerService.instance.isLoading
                                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen))
                                      : const Icon(Icons.refresh, size: 14),
                                  label: const Text('تحديث GPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  onPressed: PrayerService.instance.isLoading
                                      ? null
                                      : () async {
                                          final ok = await PrayerService.instance.requestGpsLocation();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(ok ? 'تم تحديث الإحداثيات عبر GPS' : (PrayerService.instance.errorMessage ?? 'فشل التحديث')),
                                                backgroundColor: ok ? AppColors.secondaryGreen : Colors.redAccent,
                                              ),
                                            );
                                          }
                                        },
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (data?.nextPrayer != null) ...[
                          const Divider(color: Colors.white24, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('الصلاة القادمة', style: TextStyle(color: AppColors.softGold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    data!.nextPrayer!.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('الوقت المتبقي', style: TextStyle(color: AppColors.softGold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    PrayerService.instance.formatCountdown(data.timeToNextPrayer),
                                    style: const TextStyle(color: AppColors.accentGold, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Prayers List
                if (data != null)
                  ...data.prayers.map((p) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: p.isNext ? 3 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: p.isNext ? AppColors.accentGold : Colors.transparent,
                          width: p.isNext ? 1.5 : 0,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: p.isNext ? AppColors.accentGold.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time_filled,
                            color: p.isNext ? AppColors.accentGold : AppColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(p.name, style: TextStyle(fontWeight: p.isNext ? FontWeight.bold : FontWeight.w600)),
                            if (p.isNext) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('القادمة', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p.formattedTime,
                              style: TextStyle(
                                color: p.isNext ? AppColors.primaryGreen : AppColors.lightText,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                PrayerNotificationService.instance.isPrayerEnabled(p.name)
                                    ? Icons.notifications_active
                                    : Icons.notifications_off_outlined,
                                size: 20,
                                color: PrayerNotificationService.instance.isPrayerEnabled(p.name)
                                    ? AppColors.accentGold
                                    : Colors.grey,
                              ),
                              tooltip: 'تفعيل/إلغاء التنبيه',
                              onPressed: () {
                                final curr = PrayerNotificationService.instance.isPrayerEnabled(p.name);
                                PrayerNotificationService.instance.togglePrayer(p.name, !curr);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                else
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),

                const SizedBox(height: 12),

                // Prayer Tracker & Sunan Rawatib Card (FR-PRY-009)
                AnimatedBuilder(
                  animation: PrayerTrackerService.instance,
                  builder: (context, _) {
                    final todayRecord = PrayerTrackerService.instance.todayRecord;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrayerTrackerScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.fact_check_outlined, color: AppColors.primaryGreen, size: 22),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'سجل متابعة الصلوات والسنن (FR-PRY-009)',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryGreen),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الصلوات المنجزة: ${todayRecord.completedObligatoryCount} من 5',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'السنن الرواتب: ${todayRecord.completedRawatibRakats} / 12 ركعة',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.accentGold, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: todayRecord.completedObligatoryCount / 5.0,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Qibla Direction Card (Interactive Link to Compass)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('اتجاه القبلة الشريفة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('بوصلة تفاعلية 🧭', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data?.qiblaDegrees.toStringAsFixed(1) ?? "136.0"}° من جهة الشمال (اضغط لفتح البوصلة)',
                                style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.explore, color: AppColors.primaryGreen, size: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Battery & Adhan Reliability Card (T-404)
                Card(
                  elevation: 2,
                  color: AppColors.primaryGreen.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.accentGold, width: 1.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BatteryReliabilityScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt, color: AppColors.accentGold, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'تثبيت الأذان وضمان التنبيهات',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.primaryGreen),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('مهم جداً ⚡', style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'دليل ضبط إعدادات البطارية لتجاوز قيود شاومي وسامسونج وهواوي',
                                  style: TextStyle(fontSize: 12, color: AppColors.lightText),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryGreen),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
