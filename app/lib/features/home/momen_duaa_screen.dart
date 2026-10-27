import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// شاشة الدعاء والإهداء الدائم لروح المرحوم: مؤمن إبراهيم رحمهُ الله
/// تظهر ثابتة عند كل فتح للتطبيق ولا تختفي إلا عندما يضغط المستخدم على زر «آمين» أسفل الشاشة.
/// تم تطويرها بخطوط ثلاثية الأبعاد بارزة وحبر إسلامي ثقيل واسم المرحوم باللون الأبيض الصافي.
class MomenDuaaScreen extends StatelessWidget {
  final bool isFromInsideApp;

  const MomenDuaaScreen({
    super.key,
    this.isFromInsideApp = false,
  });

  void _onAmenPressed(BuildContext context) {
    if (isFromInsideApp && Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    try {
      context.go('/home');
    } catch (_) {
      context.pushReplacement('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان الحبر الثقيل الفاخر
    final heavyInkColor = isDark ? const Color(0xFFF2FBF6) : const Color(0xFF07120C);
    final secondaryInkColor = isDark ? const Color(0xFFE2EFE8) : const Color(0xFF14241C);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1612) : const Color(0xFFF4F7F3),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Duaa Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Islamic Ornament Icon with Golden Aura
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF11382A), const Color(0xFF082219)]
                                : [const Color(0xFFE8F2EC), const Color(0xFFD4E6DC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: AppColors.accentGold, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withAlpha(isDark ? 70 : 45),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.accentGold,
                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 1. كلمة «صَدَقَةٌ جَارِيَةٌ» بحجم كبير وبتصميم كتابة ثلاثية الأبعاد (3D Depth Typography)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D3D2C), Color(0xFF1A6B4E), Color(0xFF0D3D2C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppColors.accentGold, width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 6),
                              blurRadius: 14,
                            ),
                            BoxShadow(
                              color: Color(0x33FFD700),
                              offset: Offset(0, 1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          'صَدَقَةٌ جَارِيَةٌ',
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            letterSpacing: 2.5,
                            fontFamily: 'Amiri',
                            shadows: [
                              Shadow(color: Color(0xFF4A3800), offset: Offset(1.5, 1.5), blurRadius: 1),
                              Shadow(color: Color(0xFF2E2200), offset: Offset(3.0, 3.0), blurRadius: 2),
                              Shadow(color: Color(0xFF140F00), offset: Offset(4.5, 4.5), blurRadius: 3),
                              Shadow(color: Colors.black54, offset: Offset(5, 5), blurRadius: 8),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. تكبير «عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى» بخط عريض وواضح
                      Text(
                        'عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD6E8DE) : AppColors.secondaryGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          fontFamily: 'Amiri',
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(isDark ? 80 : 30),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 3. اسم «مُؤْمِن إِبْرَاهِيم رحمهُ الله» بحجم كبير جداً ولون أبيض ناصع في لوحة إسلامية ملكية
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF062C1E),
                              Color(0xFF0F513A),
                              Color(0xFF062C1E),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.accentGold, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 140 : 70),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.accentGold.withAlpha(60),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // اسم مؤمن إبراهيم بلون أبيض ناصع وخط كبير مميز
                            const Text(
                              'مُؤْمِن إِبْرَاهِيم رحمهُ الله',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white, // أبيض ناصع ظاهر وبارز
                                fontFamily: 'Amiri',
                                letterSpacing: 0.8,
                                height: 1.3,
                                shadows: [
                                  Shadow(color: Colors.black87, offset: Offset(2, 3), blurRadius: 6),
                                  Shadow(color: AppColors.accentGold, offset: Offset(0, 0), blurRadius: 12),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // صيغة «الله يرحمه»
                            const Text(
                              '«الله يرحمه ويغفر له ويسكنه فسيح جناته»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFE680), // ذهبي ناصع متباين مع الخلفية
                                fontFamily: 'Amiri',
                                shadows: [
                                  Shadow(color: Colors.black54, offset: Offset(1, 2), blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 4. بطاقة باقي الدعاء بخط كبير وثقيل كالحبر العربي الأسود الفاخر (Heavy Calligraphic Ink)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF132720) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.accentGold.withAlpha(140),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 90 : 25),
                              blurRadius: 18,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('۞ ', style: TextStyle(color: AppColors.accentGold, fontSize: 18)),
                                Text(
                                  'دُعَاءٌ وَرَجَاءٌ لِرَفِيعِ الدَّرَجَاتِ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    fontFamily: 'Amiri',
                                    color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                                  ),
                                ),
                                const Text(' ۞', style: TextStyle(color: AppColors.accentGold, fontSize: 18)),
                              ],
                            ),
                            const Divider(height: 26, thickness: 1.2),

                            // الدعاء المأثور والمبارك
                            Text(
                              '«اللَّهُمَّ يَا حَنَّانُ يَا مَنَّانُ، يَا بَدِيعَ السَّمَاوَاتِ وَالأَرْضِ، يَا ذَا الجَلَالِ وَالإِكْرَامِ.. أَنْزِلْ عَلَى عَبْدِكَ "مُؤْمِن إِبْرَاهِيم" الضِّيَاءَ وَالنُّورَ، وَالفُسْحَةَ وَالسُّرُورَ، وَالبَهْجَةَ وَالحُبُورَ، وَاجْعَلْ قَبْرَهُ رَوْضَةً نَدِيَّةً مِنْ رِيَاضِ الجَنَّةِ، تَهَبُّ عَلَيْهِ مِنْ نَسَائِمِهَا وَرَيْحَانِهَا إِلَى يَوْمِ الدِّينِ.»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19.5, // خط مكبر
                                height: 2.1,
                                fontWeight: FontWeight.w900, // خط ثقيل حبر كثيف
                                fontFamily: 'Amiri',
                                color: heavyInkColor, // حبر غامق جداً وفاخر
                                letterSpacing: 0.3,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // الفقرة الثانية: المغفرة وتثبيت السؤال ورفعة المنازل
                            Text(
                              '«اللَّهُمَّ جَازِهِ بِالإِحْسَانِ إِحْسَاناً، وَعَنِ السَّيِّئَاتِ عَفْواً وَغُفْرَاناً، وَأَبْدِلْهُ دَاراً خَيْراً مِنْ دَارِهِ، وَأَهْلاً خَيْراً مِنْ أَهْلِهِ، وَثَبِّتْهُ عِنْدَ السُّؤَالِ، وَيَمِّنْ كِتَابَهُ، وَيَسِّرْ حِسَابَهُ، وَارْفَعْ فِي أَعْلَى عِلِّيِّينَ دَرَجَتَهُ فِي الفِرْدَوْسِ الأَعْلَى مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاءِ وَالصَّالِحِينَ.»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                height: 2.0,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Amiri',
                                color: secondaryInkColor,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ختام الدعاء بأثر العمل والقرآن والدعاء لوالديه (حفظهما الله وبارك في عمرهما)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withAlpha(isDark ? 35 : 18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.accentGold.withAlpha(90),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '«اللَّهُمَّ احْفَظْ وَالِدَيْهِ بِحِفْظِكَ التَّامِّ، وَبَارِكْ فِي عُمُرِهِمَا عَلَى طَاعَتِكَ، وَأَلْبِسْهُمَا لِبَاسَ الصِّحَّةِ وَالعَافِيَةِ، وَارْبِطْ عَلَى قُلُوبِهِمَا بِالصَّبْرِ وَالسَّكِينَةِ وَالاحْتِسَابِ، وَاجْزِهِمَا عَنْهُ خَيْرَ مَا جَزَيْتَ وَالِداً عَنْ وَلَدِهِ، وَاجْعَلْهُ لَهُمَا فَرَطاً وَذُخْراً وَشَفِيعاً مُجَاباً عِنْدَكَ..»',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      height: 1.9,
                                      color: isDark ? AppColors.accentGold : const Color(0xFF7A5504),
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Amiri',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F3A2A) : const Color(0xFFE8F4EC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      '«اللَّهُمَّ اجْعَلْ كُلَّ آيَةٍ تُتْلَى، وَكُلَّ صَلَاةٍ وَذِكْرٍ وَتَسْبِيحَةٍ فِي هَذَا التَّطْبِيقِ نُوراً يَسْعَى بَيْنَ يَدَيْ عَبْدِكَ "مُؤْمِن"، وَبَرَكَةً وَأَجْراً وَذُخْراً لِوَالِدَيْهِ فِي دِينِهِمَا وَدُنْيَاهُمَا، وَشَفِيعاً لَهُمْ يَوْمَ العَرْضِ عَلَيْكَ.. آمِينَ يَا رَبَّ العَالَمِينَ 🤲»',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        height: 1.85,
                                        color: isDark ? Colors.white : AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Hadith Card on Sadaqa Jariya
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withAlpha(isDark ? 35 : 18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryGreen.withAlpha(70),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote_rounded, color: AppColors.primaryGreen, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'قال ﷺ: «إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ» (رواه مسلم)',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.7,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Area with "آمين" Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1E19) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 100 : 30),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: AppColors.accentGold, width: 2),
                          ),
                        ),
                        onPressed: () => _onAmenPressed(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism_rounded, color: AppColors.accentGold, size: 26),
                            SizedBox(width: 12),
                            Text(
                              'آمين',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '🤲',
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اضغط على زر آمين للدخول إلى التطبيق',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
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
  }
}
