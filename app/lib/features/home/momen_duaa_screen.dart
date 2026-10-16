import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/settings_service.dart';

/// شاشة الدعاء والإهداء الدائم لروح المرحوم: مؤمن إبراهيم رحمهُ الله
/// تظهر ثابته عند كل فتح للتطبيق ولا تختفي إلا عندما يضغط المستخدم على زر «آمين» أسفل الشاشة.
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

    final settings = SettingsService.instance;
    // إذا لم يكمل المستخدم شاشات الشرح وكان خيار إظهارها مفعلاً يتوجه لشاشات الشرح، وإلا للرئيسية مباشرة
    final shouldShowTutorial = !settings.hasCompletedOnboarding && settings.showTutorialScreens;

    if (shouldShowTutorial) {
      try {
        context.go('/onboarding');
      } catch (_) {
        context.pushReplacement('/onboarding');
      }
    } else {
      try {
        context.go('/home');
      } catch (_) {
        context.pushReplacement('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1E19) : const Color(0xFFF7F9F6),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable Duaa Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Islamic Ornament Icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withAlpha(isDark ? 50 : 25),
                          border: Border.all(color: AppColors.accentGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGold.withAlpha(40),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.accentGold,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Golden Sadaqa Jariya Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accentGold, width: 1.2),
                        ),
                        child: const Text(
                          'صَدَقَةٌ جَارِيَةٌ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Dedication Subtitle
                      Text(
                        'عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.secondaryGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Name: مؤمن إبراهيم رحمهُ الله
                      const Text(
                        'مُؤْمِن إِبْرَاهِيم رحمهُ الله',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                          fontFamily: 'Amiri',
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Secondary Blessing: الله يرحمه
                      Text(
                        '«الله يرحمه ويغفر له ويسكنه فسيح جناته»',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.accentGold : const Color(0xFF996515),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main Prophetic Duaa Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF162B24) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentGold.withAlpha(120),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 60 : 15),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('۞ ', style: TextStyle(color: AppColors.accentGold, fontSize: 16)),
                                Text(
                                  'دُعَاءٌ لِلْمَيِّتِ مِنَ السُّنَّةِ النَّبَوِيَّةِ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                Text(' ۞', style: TextStyle(color: AppColors.accentGold, fontSize: 16)),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),
                            const Text(
                              '«اللَّهُمَّ اغْفِرْ لِمُؤْمِن إِبْرَاهِيم وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ، وَنَقِّهِ مِنَ الذُّنُوبِ وَالْخَطَايَا كَمَا يُنَقَّى الثَّوْبُ الأَبْيَضُ مِنَ الدَّنَسِ.»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Amiri',
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '«اللَّهُمَّ اجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ، وَلَا تَجْعَلْهُ حُفْرَةً مِنْ حُفَرِ النَّارِ، وَأَسْكِنْهُ الفِرْدَوْسَ الأَعْلَى مِنَ الجَنَّةِ مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاءِ وَالصَّالِحِينَ.»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '«اللَّهُمَّ اجْعَلْ كُلَّ آيَةٍ تُتْلَى وَتُحْفَظُ، وَكُلَّ صَلَاةٍ وَذِكْرٍ فِي هَذَا التَّطْبِيقِ نُوراً وَضِيَاءً فِي قَبْرِهِ، وَفِي مِيزَانِ حَسَنَاتِهِ إِلَى يَوْمِ القِيَامَةِ..»',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.8,
                                color: isDark ? AppColors.accentGold : const Color(0xFF8B6508),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Hadith Card on Sadaqa Jariya
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withAlpha(isDark ? 30 : 15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryGreen.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote_rounded, color: AppColors.primaryGreen, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'قال ﷺ: «إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ»',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.6,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.w500,
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
                  color: isDark ? const Color(0xFF13251F) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 80 : 25),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.accentGold, width: 1.5),
                          ),
                        ),
                        onPressed: () => _onAmenPressed(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism_rounded, color: AppColors.accentGold, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'آمين',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '🤲',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اضغط على زر آمين للدخول إلى التطبيق',
                      style: TextStyle(
                        fontSize: 12,
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
