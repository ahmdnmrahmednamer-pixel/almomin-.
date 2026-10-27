import 'package:flutter/material.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/prayer_tracker_service.dart';
import '../../../core/theme/app_theme.dart';
import '../battery_reliability_screen.dart';
import '../prayer_tracker_screen.dart';
import '../qibla_compass_screen.dart';
import '../../zakat/zakat_screen.dart';
import '../../ramadan/ramadan_screen.dart';

/// Prayer & Sunnah Rawatib Tracker card (FR-PRY-009)
class PrayerTrackerOverviewCard extends StatelessWidget {
  final bool isDark;

  const PrayerTrackerOverviewCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PrayerTrackerService.instance,
      builder: (context, _) {
        final todayRecord = PrayerTrackerService.instance.todayRecord;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
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
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1E3A2E), const Color(0xFF162920)]
                                    : [AppColors.primaryGreen.withOpacity(0.15), AppColors.emeraldLight.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.fact_check_rounded, color: AppColors.primaryGreen, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'سجل متابعة الصلوات والسنن (FR-PRY-009)',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('التفاصيل', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الصلوات المنجزة: ${todayRecord.completedObligatoryCount} من 5',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'السنن الرواتب: ${todayRecord.completedRawatibRakats} / 12 ركعة',
                        style: const TextStyle(fontSize: 13, color: AppColors.accentGold, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (todayRecord.completedObligatoryCount / 5.0).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Interactive Qibla direction card with compass degree
class PrayerQiblaOverviewCard extends StatelessWidget {
  final PrayerData? data;

  const PrayerQiblaOverviewCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('اتجاه القبلة الشريفة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                          ),
                          child: const Text('بوصلة تفاعلية 🧭', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data?.qiblaDegrees.toStringAsFixed(1) ?? "136.0"}° من جهة الشمال (اضغط لفتح البوصلة)',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'فتح البوصلة',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick access card for Islamic Zakat Calculator (FR-ZKT)
class PrayerZakatOverviewCard extends StatelessWidget {
  const PrayerZakatOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ZakatScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('حاسبة الزكاة الشرعية الذكية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('ركن الإسلام 💰', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'حساب زكاة المال والذهب والفضة والتجارة وفق النصاب الشرعي',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25), width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calculate_rounded, color: AppColors.primaryGreen, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'احسب الآن',
                      style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ramadan & Imsakiyyah Overview Card (FR-CAL-004)
class PrayerRamadanOverviewCard extends StatelessWidget {
  const PrayerRamadanOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RamadanScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('إمساكية ومحراب رمضان المبارك', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('شهر القرآن 🌙', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'مواقيت الإمساك والإفطار، دعاء الصائم، وأوراد الشهر الفضيل',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.nightlight_round, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'الإمساكية',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Battery & Adhan reliability settings guide card
class PrayerBatteryOverviewCard extends StatelessWidget {
  final bool isDark;

  const PrayerBatteryOverviewCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.primaryGreen.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.accentGold, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.accentGold, size: 24),
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
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('مهم جداً ⚡', style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'دليل ضبط إعدادات البطارية لتجاوز قيود شاومي وسامسونج وهواوي',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.lightText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
