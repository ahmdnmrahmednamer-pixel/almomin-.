import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../../features/adhkar/spiritual_mood_remedy_screen.dart';
import '../../features/audio/scholars_audio_library_screen.dart';
import '../../features/library/screens/hajj_umrah_companion_screen.dart';
import '../../features/library/screens/islamic_mutoon_screen.dart';
import '../../features/library/screens/riyad_alsalihin_screen.dart';
import '../../features/mushaf/comparative_tafsir_screen.dart';
import '../../features/mushaf/gharib_quran_screen.dart';
import '../../features/mushaf/tadabbur_journal_screen.dart';
import '../../features/prayer/sunan_rawatib_screen.dart';
import '../../features/prayer/voluntary_fasting_screen.dart';
import '../../features/settings/contact_support_screen.dart';
import '../../features/settings/widgets/settings_about_modal.dart';
import '../../features/settings/widgets/settings_language_modal.dart';
import '../../features/zakat/kaffarah_fidyah_screen.dart';
import '../../features/zakat/mawarith_calculator_screen.dart';

/// القائمة الجانبية الإيمانية (AppNavigationDrawer) — منظمة في ٤ مجموعات روحانية واضحة بجميع اللغات الـ ٦
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  void _shareApp(BuildContext context) {
    try {
      Share.share(
      'تطبيق «نور المؤمن» 🕌 — رحاب القرآن الكريم، مجالس العلماء، محراب الصلاة، وأنس الذاكرين.\n'
      'تطبيق مجاني 100% لوجه الله تعالى وبدون أي إعلانات.',
      subject: 'تطبيق نور المؤمن',
    );
    } catch (_) {}
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined,
                color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(context.tr('privacy_policy')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'تطبيق «نور المؤمن» صُمم وطُوّر ابتغاء مرضاة الله تعالى ليكون رفيقاً إيمانياً نقياً:\n\n'
            '• خالٍ تماماً من الإعلانات التجارية (Zero Ads).\n'
            '• خالٍ تماماً من أي أدوات تتبع أو جمع بيانات (Zero Tracking).\n'
            '• كافة أورادك وختماتك وتدبراتك محفوظة بأمان على جهازك فقط.',
            style: TextStyle(height: 1.6, fontSize: 13.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('close')),
          ),
        ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final s = SettingsService.instance;

        return Drawer(
          child: Directionality(
            textDirection: s.textDirection,
            child: Material(
              color: isDark ? const Color(0xFF0F1A15) : Colors.white,
              child: SafeArea(
                bottom: true,
                top: false,
                child: Column(
                  children: [
                    // 1. Serene Spiritual Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF0B2B20),
                                  const Color(0xFF071C15)
                                ]
                              : [
                                  const Color(0xFF0F5B45),
                                  const Color(0xFF093E2F)
                                ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentGold.withOpacity(0.18),
                                  border: Border.all(
                                      color: AppColors.accentGold, width: 2),
                                ),
                                child: const Icon(
                                  Icons.mosque_rounded,
                                  color: AppColors.accentGold,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('app_name'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.tr('app_subtitle'),
                                      style: const TextStyle(
                                        color: AppColors.softGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showSettingsLanguageModal(context);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        AppColors.accentGold.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language_rounded,
                                      color: AppColors.accentGold, size: 15),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      s.languageName,
                                      style: const TextStyle(
                                        color: Color(0xFFFFEFA6),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Organized 4 Spiritual Groups in Drawer
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        children: [
                          // ================= البطاقة التوجيهية: فهرس الشاشات ودليل الأبواب الشامل =================
                          Container(
                            margin: const EdgeInsets.fromLTRB(6, 4, 6, 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F5B45), Color(0xFF1B6B4E)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentGold.withOpacity(0.5),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/app-directory');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.accentGold.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.accentGold,
                                            width: 1.2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.dashboard_customize_rounded,
                                          color: AppColors.accentGold,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'دليل وفهرس الشاشات الشامل',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'خريطة لكافة أبواب وخدمات التطبيق (٥٨ شاشة)',
                                              style: TextStyle(
                                                color: Color(0xFFFFEFA6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.accentGold,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ================= المجموعة ١: المقامات الإيمانية الخمسة =================
                          _buildGroupLabel(context.tr('drawer_group_sanctuaries')),
                          _buildDrawerTile(
                            icon: Icons.wb_sunny_rounded,
                            title: context.tr('nav_home'),
                            subtitle: context.tr('tooltip_home'),
                            color: AppColors.primaryGreen,
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/home');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.menu_book_rounded,
                            title: context.tr('holy_quran'),
                            subtitle: context.tr('tooltip_quran'),
                            color: const Color(0xFF1B6B4E),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/mushaf');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.mosque_rounded,
                            title: context.tr('nav_prayer'),
                            subtitle: context.tr('tooltip_prayer'),
                            color: const Color(0xFF23825F),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/prayer');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.favorite_rounded,
                            title: context.tr('adhkar_hub'),
                            subtitle: context.tr('tooltip_adhkar'),
                            color: const Color(0xFFB8893A),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/adhkar-hub');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.auto_stories_rounded,
                            title: context.tr('islamic_library'),
                            subtitle: context.tr('tooltip_library'),
                            color: const Color(0xFF34495E),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/library');
                            },
                          ),

                          const Divider(height: 18),

                          // ================= المجموعة ٢: مسارات القرب والعمل اليومي =================
                          _buildGroupLabel(context.tr('drawer_group_companions')),
                          _buildDrawerTile(
                            icon: Icons.favorite_border_rounded,
                            title: context.tr('spiritual_mood_remedy'),
                            subtitle:
                                'آيات السكينة والأدعية النبوية حسب ما يشعر به قلبك',
                            color: const Color(0xFF1E8260),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/spiritual-mood');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.alarm_on_rounded,
                            title: context.tr('dawn_awakening'),
                            subtitle: context.tr('dawn_awakening_sub'),
                            color: const Color(0xFF0F5B45),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/fajr-qiyam-alarm');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.fact_check_rounded,
                            title: context.tr('prayer_tracker'),
                            subtitle: 'متابعة الصلوات الخمس وتدارك ما فات بعزيمة',
                            color: const Color(0xFFB88917),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/prayer-tracker');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.stars_rounded,
                            title: context.tr('sunan_rawatib'),
                            subtitle: 'ثنتا عشرة ركعة في اليوم والليلة بيت في الجنة',
                            color: const Color(0xFF0F5B45),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/sunan-rawatib');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.wb_twilight_rounded,
                            title: context.tr('voluntary_fasting'),
                            subtitle:
                                'الإثنين والخميس • الأيام البيض • الست من شوال • عرفة',
                            color: const Color(0xFFB88917),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/voluntary-fasting');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.psychology_alt_rounded,
                            title: context.tr('tadabbur_journal'),
                            subtitle: 'تدوين الهدايات والعمل بالآيات ومحاسبة النفس',
                            color: const Color(0xFF1565C0),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/tadabbur-journal');
                            },
                          ),

                          const Divider(height: 18),

                          // ================= المجموعة ٣: رياض العلم ومجالس العلماء =================
                          _buildGroupLabel(context.tr('drawer_group_knowledge')),
                          _buildDrawerTile(
                            icon: Icons.mic_external_on_rounded,
                            title: context.tr('scholars_gatherings'),
                            subtitle: context.tr('scholars_gatherings_sub'),
                            color: const Color(0xFF0F5B45),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/scholars-audio');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.compare_arrows_rounded,
                            title: context.tr('comparative_tafsir'),
                            subtitle: 'مقارنة ٩ تفاسير معتمدة مع الإعراب وأسباب النزول',
                            color: const Color(0xFF1B4332),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/comparative-tafsir');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.translate_rounded,
                            title: context.tr('gharib_quran_dict'),
                            subtitle: 'معاني الكلمات القرآنية وجذورها واختبار الفهم',
                            color: const Color(0xFF1565C0),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/gharib-quran');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.collections_bookmark_rounded,
                            title: context.tr('riyad_salihin'),
                            subtitle: 'كتب وأبواب رياض الصالحين مع الشرح والفوائد',
                            color: const Color(0xFF0F5B45),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/riyad-alsalihin');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.school_rounded,
                            title: context.tr('islamic_mutoon'),
                            subtitle:
                                'تحفة الأطفال • الجزرية • القواعد الفقهية • الطحاوية',
                            color: const Color(0xFF8E6C18),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/islamic-mutoon');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.explore_rounded,
                            title: context.tr('hajj_umrah_companion'),
                            subtitle:
                                'مناسك الحج والعمرة وعدّاد أشواط الطواف والسعي',
                            color: const Color(0xFF0F5B45),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/hajj-umrah');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.volunteer_activism_rounded,
                            title: context.tr('kaffarah_fidyah_calc'),
                            subtitle:
                                'زكاة الفطر وفدية الصيام وكفارة اليمين والمواريث',
                            color: const Color(0xFF27AE60),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/kaffarah-fidyah');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.balance_rounded,
                            title: context.tr('mawarith_calc'),
                            subtitle:
                                'تقسيم الأنصبة الشرعية بالأدلة من سورة النساء',
                            color: const Color(0xFF27AE60),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/mawarith-calculator');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.radio_rounded,
                            title: context.tr('egypt_heritage'),
                            subtitle:
                                'إذاعة 98.2 FM • الابتهالات • الشعراوي • دار الإفتاء',
                            color: const Color(0xFF0D5C46),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/egypt-heritage');
                            },
                          ),

                          const Divider(height: 18),

                          // ================= المجموعة ٤: تهيئة التطبيق والعناية =================
                          _buildGroupLabel(context.tr('drawer_group_serenity')),
                          _buildDrawerTile(
                            icon: Icons.tune_rounded,
                            title: context.tr('settings_title'),
                            subtitle: 'اللغات، المظهر، القارئ، والتنبيهات',
                            color: const Color(0xFF2C5E43),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/settings');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.language_rounded,
                            title: context.tr('app_language'),
                            subtitle: s.languageName,
                            color: const Color(0xFF1E8260),
                            onTap: () {
                              Navigator.pop(context);
                              showSettingsLanguageModal(context);
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.backup_rounded,
                            title: context.tr('backup_restore'),
                            subtitle: 'حفظ واسترجاع الأوراد والختمات',
                            color: const Color(0xFF5E4E8C),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/backup');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.headset_mic_rounded,
                            title: context.tr('contact_support'),
                            subtitle: 'المقترحات والتواصل مع فريق التطوير',
                            color: const Color(0xFF25739B),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/support');
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.info_outline_rounded,
                            title: context.tr('about_app'),
                            subtitle: 'الإصدار العاشر (v10.0) ورسالة العمل',
                            color: AppColors.accentGold,
                            onTap: () {
                              Navigator.pop(context);
                              showSettingsAboutModal(context);
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.volunteer_activism_rounded,
                            title: 'الدعاء للمرحوم مؤمن إبراهيم',
                            subtitle: 'صدقة جارية ودعاء بالرحمة والمغفرة',
                            color: AppColors.accentGold,
                            onTap: () {
                              Navigator.pop(context);
                              showSettingsAboutModal(context);
                            },
                          ),
                          _buildDrawerTile(
                            icon: Icons.share_rounded,
                            title: context.tr('share_app'),
                            subtitle: 'انشر الخير وشارك الأجر والثواب',
                            color: const Color(0xFF1E7051),
                            onTap: () => _shareApp(context),
                          ),
                          _buildDrawerTile(
                            icon: Icons.privacy_tip_outlined,
                            title: context.tr('privacy_policy'),
                            subtitle: 'نقاء تام بدون إعلانات وبدون تتبع',
                            color: Colors.grey,
                            onTap: () => _showPrivacyDialog(context),
                          ),
                        ],
                      ),
                    ),

                    // 3. Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? const Color(0xFF1A2A22)
                                : const Color(0xFFE5EDE8),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'إصدار v10.0 (رسمي)',
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11.5),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite,
                                  color: AppColors.accentGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'لوجه الله تعالى',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.accentGold
                                      : AppColors.primaryGreen,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.accentGold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.8),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing:
          const Icon(Icons.chevron_left_rounded, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}
