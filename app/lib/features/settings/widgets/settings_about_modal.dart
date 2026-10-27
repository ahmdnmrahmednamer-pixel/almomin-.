import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

void showSettingsAboutModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mosque, color: AppColors.primaryGreen, size: 26),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عن تطبيق نور المؤمن',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'منظومة إسلامية شاملة · صدقة جارية',
                    style: TextStyle(fontSize: 11.5, color: AppColors.lightText, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dedication Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E2822), const Color(0xFF163026)]
                            : [AppColors.accentGold.withOpacity(0.15), AppColors.primaryGreen.withOpacity(0.08)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.45)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'صَدَقَةٌ جَارِيَةٌ عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى:\nمُؤْمِن إِبْرَاهِيم (رَحِمَهُ اللَّهُ)',
                          style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                            fontSize: 13.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '«اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ وَوَسِّعْ مُدْخَلَهُ، وَاجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ» 🤲',
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 12,
                            color: isDark ? AppColors.softGold : const Color(0xFF8B6B00),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section Header
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'مميزات التطبيق ومعالمه الكبرى:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 1. Quran
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF1E7E34),
                    title: 'محراب القرآن الكريم وتدبر علومه',
                    description: 'المصحف الشريف كاملاً (604 صفحات) بالرسم العثماني المعتمد من مجمع الملك فهد، مشفوعاً بالتفسير الميسر، وإعراب الآيات النحوي والبلاغي، ومصحف التجويد الملون، والمحفّظ الذكي، والبحث الفوري بنمط يعمل بدون إنترنت (Offline-First).',
                  ),

                  // 2. Prayer & Adhan Studio
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFFD97706),
                    title: 'مواقيت الصلاة واستوديو الأذان والإقامة',
                    description: 'حساب فلكي دقيق بالمعايير المعتمدة لـ 22 دولة، مع استوديو نداء الأذان والإقامة بأصوات الحرمين الشريفين والمسجد الأقصى المبارك ومصر والشيخ الحصري، وشاشة تحكم عائمة تدعم إيماءات الهز وقلب الهاتف لكتم النداء.',
                  ),

                  // 3. Audio Library & Reciters
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.record_voice_over_rounded,
                    iconColor: const Color(0xFF2563EB),
                    title: 'المكتبة الصوتية وديوان كبار القراء',
                    description: 'ديوان تلاوات خاشعة لـ 61 قارئاً من أساطين التلاوة في العالم الإسلامي (بتقديم فضيلة الشيخ محمد صديق المنشاوي كقارئ افتراضي)، مع مشغل استوديو متكامل يعمل في الخلفية ويدعم الاستماع دون إنترنت.',
                  ),

                  // 4. Adhkar, Hadith & Smart Tasbih
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.fingerprint_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    title: 'حصن المسلم والسنة النبوية والسبحة الذكية',
                    description: 'الأذكار اليومية المستوعبة لكتاب حصن المسلم، وصحاح الأحاديث من جامعي البخاري ومسلم والأربعين النووية، مع مسبحة إلكترونية ذكية تمنح تفاعلاً حسياً نابضاً وإحصائيات تحفيزية للأوراد اليومية.',
                  ),

                  // 5. Worship Services, Qibla & Zakat
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.explore_rounded,
                    iconColor: const Color(0xFF059669),
                    title: 'محاريب العبادات والقبلة والزكاة والأنبياء',
                    description: 'رادار القبلة التفاعلي ثلاثي الأبعاد، وحاسبة الزكاة الشرعية لجميع الأوجه والأنصبة الفقهية، ومحراب رمضان المبارك بإمساكية منضبطة ومتابعة الختمات، وموسوعة قصص الأنبياء (38 قصة تفصيلية).',
                  ),

                  // 6. Purity of Purpose & No-Ads Pledge
                  _buildFeaturePillar(
                    isDark: isDark,
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFF0F766E),
                    title: 'صفاء المقصد ونقاء العهد الوقفـي',
                    description: 'عمل وقفي لوجه الله تعالى مجاني تماماً وبصورة دائمة ومطلقة، خالٍ كلياً من أي إعلانات تجارية أو نوافذ ترويجية أو تتبع لخصوصية المستخدم، ليصون نقاء اللحظة الإيمانية وخشوع العابد.',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFeaturePillar({
  required bool isDark,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String description,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E2824) : const Color(0xFFFBFBFB),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppColors.softGold : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.8,
                  height: 1.55,
                  color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
