import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import '../mushaf/surah_reader_screen.dart';
import '../mushaf/page_mode_mushaf_screen.dart';
import '../mushaf/mushaf_screen.dart';
import '../prayer/prayer_screen.dart';
import '../search/quran_search_screen.dart';
import '../adhkar/adhkar_screen.dart';
import '../adhkar/tasbih_screen.dart';
import '../prayer/qibla_compass_screen.dart';
import '../prayer/hijri_calendar_screen.dart';
import '../../core/services/khatma_service.dart';
import '../khatma/khatma_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../core/services/ayah_notes_service.dart';
import '../mushaf/quran_notes_screen.dart';
import '../../core/services/memorization_service.dart';
import '../mushaf/memorization_screen.dart';
import '../../core/services/zakat_service.dart';
import '../zakat/zakat_screen.dart';
import '../../core/services/hadith_service.dart';
import '../hadith/hadith_library_screen.dart';
import '../hadith/hadith_detail_screen.dart';
import '../../core/services/quran_topic_service.dart';
import '../topics/quran_topics_screen.dart';
import '../topics/topic_detail_screen.dart';

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
    KhatmaService.instance.init();
    MemorizationService.instance.init();
    ZakatService.instance.init();
    HadithService.instance.init();
    QuranTopicService.instance.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!SettingsService.instance.hasCompletedOnboarding && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
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
          animation: Listenable.merge([PrayerService.instance, SettingsService.instance, KhatmaService.instance]),
          builder: (context, _) {
            final prayerData = PrayerService.instance.currentData;
            final dayName = HijriDateHelper.getDayOfWeek();
            final hijriStr = HijriDateHelper.getHijriDateString();
            final gregStr = HijriDateHelper.getGregorianDateString();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Islamic Header Card with Gregorian & Hijri Dates
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
                    );
                  },
                  child: Container(
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  gregStr,
                                  style: const TextStyle(color: AppColors.softGold, fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, color: AppColors.softGold, size: 12),
                              ],
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
                ),
                const SizedBox(height: 12),

                // Noble Dedication Banner for Momin Ibrahim
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          title: const Row(
                            children: [
                              Icon(Icons.volunteer_activism_rounded, color: AppColors.accentGold, size: 24),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'دعاء لمؤمن إبراهيم رحمه الله',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                          content: const Text(
                            '«اللَّهُمَّ اغْفِرْ لِعَبْدِكَ مُؤْمِن إِبْرَاهِيم وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ، وَنَقِّهِ مِنَ الذُّنُوبِ كَمَا يُنَقَّى الثَّوْبُ الأَبْيَضُ مِنَ الدَّنَسِ.\n\nاللَّهُمَّ اجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ، وَافْسَحْ لَهُ فِيهِ مَدَّ بَصَرِهِ، وَاجْعَلْ كُلَّ آيَةٍ تُتْلَى وَكُلَّ صَلَاةٍ وَتَسْبِيحَةٍ فِي هَذَا التَّطْبِيقِ نُوراً لَهُ فِي قَبْرِهِ وَفِي مِيزَانِ حَسَنَاتِهِ إِلَى يَوْمِ الدِّينِ.. آمِينَ يَا رَبَّ العَالَمِينَ» 🤲',
                            style: TextStyle(fontSize: 13.5, height: 1.7),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('آمِينَ يَا رَبَّ العَالَمِينَ 🤲'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volunteer_activism_rounded, size: 16, color: AppColors.primaryGreen),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'صدقة جارية عن روح المرحوم بإذن الله: مؤمن إبراهيم رحمه الله 🤲 (اضغط للدعاء)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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

                // Time-Aware Daily Adhkar Banner
                Builder(
                  builder: (context) {
                    final hour = DateTime.now().hour;
                    final isMorning = hour >= 4 && hour < 16;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdhkarScreen(initialCategoryIndex: isMorning ? 0 : 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: isMorning
                                  ? [const Color(0xFFD4AF37).withOpacity(0.2), const Color(0xFFE9D8A6).withOpacity(0.3)]
                                  : [const Color(0xFF2C3E50).withOpacity(0.2), const Color(0xFF34495E).withOpacity(0.3)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMorning ? const Color(0xFFD4AF37) : const Color(0xFF2C3E50),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMorning ? 'حان وقت أذكار الصباح' : 'حان وقت أذكار المساء',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isMorning
                                          ? 'حصن يومك بذكر الله وانشراح الصدر والبركة'
                                          : 'أمسى وأمسى الملك لله، حفظ ووقاية ليلتك',
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Quick Row: Adhkar & Smart Tasbih
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdhkarScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 24),
                                ),
                                const SizedBox(height: 8),
                                const Text('حصن المسلم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                const Text('الأذكار والأدعية', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TasbihScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryGreen, size: 24),
                                ),
                                const SizedBox(height: 8),
                                const Text('السبحة الذكية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                const Text('عداد الورد والتسبيح', style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dynamic Quran Reading Continue Card (FR-MSH-004 / T-106)
                AnimatedBuilder(
                  animation: SettingsService.instance,
                  builder: (context, _) {
                    final lastSurah = SettingsService.instance.lastReadSurahName;
                    final lastAyah = SettingsService.instance.lastReadAyahNumber;
                    final lastPage = SettingsService.instance.lastReadPageNumber;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                        title: const Text('متابعة قراءة القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          'آخر موضع: سورة $lastSurah (آية $lastAyah) — صفحة $lastPage',
                          style: const TextStyle(fontSize: 13, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.list_alt_rounded, color: AppColors.primaryGreen, size: 22),
                              tooltip: 'فهرس المصحف والأجزاء',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MushafScreen()),
                                );
                              },
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageModeMushafScreen(initialPage: lastPage),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Khatma Planner Card (Appendix C)
                AnimatedBuilder(
                  animation: KhatmaService.instance,
                  builder: (context, _) {
                    final plan = KhatmaService.instance.activePlan;
                    final hasPlan = KhatmaService.instance.hasActivePlan;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KhatmaScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_stories_rounded, color: AppColors.primaryGreen, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          hasPlan ? plan!.title : 'مخطط الختمات والورد اليومي',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        if (hasPlan)
                                          Text(
                                            '${(plan!.progressPercentage * 100).toInt()}%',
                                            style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasPlan
                                          ? 'ورد اليوم: صفحة ${plan!.currentPage} إلى ${(plan.currentPage + plan.pagesPerDay).clamp(1, 604)}'
                                          : 'ابدأ خطتك لختم القرآن الكريم في ٣٠ أو ٦٠ يوماً مع تتبع الإنجاز',
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                                    ),
                                    if (hasPlan) ...[
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: plan!.progressPercentage,
                                          backgroundColor: Colors.grey.withOpacity(0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

                // Quranic Reflections & Notes Card (FR-BKM-004 / T-110)
                AnimatedBuilder(
                  animation: AyahNotesService.instance,
                  builder: (context, _) {
                    final count = AyahNotesService.instance.notesCount;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.rate_review_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                        title: const Text('تدبراتي وخواطري القرآنية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          count > 0 ? '$count خاطرة وتدبر مسجل على آيات الذكر الحكيم' : 'دوّن ما يفيض به قلبك من تدبرات الآيات',
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuranNotesScreen()),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Quran Memorization & Ayah Loop Card (FR-MEM-001..003)
                AnimatedBuilder(
                  animation: MemorizationService.instance,
                  builder: (context, _) {
                    final tracked = MemorizationService.instance.totalTrackedAyahs;
                    final mastered = MemorizationService.instance.totalMasteredCount;
                    final due = MemorizationService.instance.dueReviewsCount;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.repeat_one_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                        title: const Text('المحفظ القرآني وتكرار الآيات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          tracked > 0
                              ? '$mastered آية متقنة · $due للمراجعة اليوم'
                              : 'تكرار ذكي، إخفاء الكلمات لاختبار الحفظ، وجدولة المراجعة',
                          style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Prayers Shortcut
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
                      child: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('مواقيت الصلاة وتنبيهات الأذان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(prayerData?.locationName ?? 'حساب أوقات الصلوات والتنبيهات الدقيقة بدون إنترنت'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrayerScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Qibla Compass Shortcut
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.explore, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('بوصلة القبلة التفاعلية الحية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('تحديد اتجاه الكعبة المشرفة بدقة الحساس المغناطيسي (${prayerData?.qiblaDegrees.toStringAsFixed(1) ?? "136.0"}°)'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QiblaCompassScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Islamic Zakat Calculator Shortcut (FR-ZKT)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calculate_outlined, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: const Text('حاسبة الزكاة الشرعية الذكية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('حساب زكاة المال والذهب والفضة والتجارة وفق النصاب'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ZakatScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Hadith Library Shortcut (FR-LIB-005)
                AnimatedBuilder(
                  animation: HadithService.instance,
                  builder: (context, _) {
                    final hadithToday = HadithService.instance.getHadithOfTheDay();
                    final favCount = HadithService.instance.favoriteIds.length;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HadithLibraryScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'مكتبة الأحاديث النبوية الشريفة',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          favCount > 0
                                              ? 'الأربعون النووية ورياض الصالحين · $favCount في المفضلة'
                                              : 'الأربعون النووية ورياض الصالحين مع التخريج والدرجة',
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'حديث اليوم: «${hadithToday.title}» (${hadithToday.grading})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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

                // Quran Thematic Index Shortcut (FR-TPC-001)
                AnimatedBuilder(
                  animation: QuranTopicService.instance,
                  builder: (context, _) {
                    final featured = QuranTopicService.instance.getFeaturedTopic();
                    final totalTopics = QuranTopicService.instance.totalTopicsCount;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuranTopicsScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.category_rounded, color: AppColors.primaryGreen, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'الفهرس الموضوعي لآيات القرآن',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          '$totalTopics موضوعاً قرآنياً في العقيدة والأخلاق والمعاملات',
                                          style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.accentGold.withOpacity(0.25)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wb_twilight_rounded, color: AppColors.accentGold, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'موضوع اليوم: «${featured.title}» (${featured.ayahCount} آيات)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
