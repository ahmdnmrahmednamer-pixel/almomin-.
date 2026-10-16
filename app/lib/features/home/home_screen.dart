import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import '../mushaf/surah_reader_screen.dart';
import '../prayer/prayer_screen.dart';
import '../search/quran_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    PrayerService.instance.init();
    SettingsService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق المؤمن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث في القرآن الكريم',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuranSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: Listenable.merge([PrayerService.instance, SettingsService.instance]),
          builder: (context, _) {
            final prayerData = PrayerService.instance.currentData;
            final dayName = HijriDateHelper.getDayOfWeek();
            final hijriStr = HijriDateHelper.getHijriDateString();
            final gregStr = HijriDateHelper.getGregorianDateString();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Islamic Header Card with Gregorian & Hijri Dates
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.softGold, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                dayName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            gregStr,
                            style: const TextStyle(color: AppColors.softGold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hijriStr,
                        style: const TextStyle(color: AppColors.softGold, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Next Prayer Live Banner Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrayerScreen()),
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
                              Text(
                                prayerData?.nextPrayer != null
                                    ? 'الصلاة القادمة: ${prayerData!.nextPrayer!.name}'
                                    : 'الصلاة القادمة: الظهر',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    prayerData != null
                                        ? 'متبقي ${PrayerService.instance.formatCountdown(prayerData.timeToNextPrayer)}'
                                        : 'جاري الحساب...',
                                    style: const TextStyle(fontSize: 14, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quran Reading Continue Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_book, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('قراءة القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('المصحف الشريف بالرسم العثماني كاملاً بدون إنترنت'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final surah = await QuranRepository.getSurahById(1);
                      if (context.mounted && surah != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SurahReaderScreen(surah: surah)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Search Quran Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('البحث القرآني اللحظي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('بحث فوري بالكلمات والجذور عبر 6236 آية'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuranSearchScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Qibla & Prayers Shortcut
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.explore, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('مواقيت الصلاة والقبلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(prayerData?.locationName ?? 'تحديد أوقات الصلوات والقبلة الدقيقة عبر GPS'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrayerScreen()),
                      );
                    },
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
