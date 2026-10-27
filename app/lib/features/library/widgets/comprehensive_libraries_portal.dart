import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';
import '../../../core/ui/app_dropdown_field.dart';
import '../../adhkar/spiritual_mood_remedy_screen.dart';
import '../../audio/scholars_audio_library_screen.dart';
import '../../egypt/egyptian_heritage_screen.dart';
import '../../hadith/hadith_library_screen.dart';
import '../../mushaf/comparative_tafsir_screen.dart';
import '../../mushaf/gharib_quran_screen.dart';
import '../../mushaf/tadabbur_journal_screen.dart';
import '../../prayer/sunan_rawatib_screen.dart';
import '../../prayer/voluntary_fasting_screen.dart';
import '../../stories/stories_screen.dart';
import '../../studio/daawah_card_studio_screen.dart';
import '../../tajweed/tajweed_screen.dart';
import '../../topics/quran_topics_screen.dart';
import '../../wird/daily_wird_screen.dart';
import '../../zakat/kaffarah_fidyah_screen.dart';
import '../../zakat/mawarith_calculator_screen.dart';
import '../screens/asma_allah_shamail_screen.dart';
import '../screens/fiqh_library_screen.dart';
import '../screens/hajj_umrah_companion_screen.dart';
import '../screens/islamic_history_screen.dart';
import '../screens/islamic_mutoon_screen.dart';
import '../screens/quran_sciences_screen.dart';
import '../screens/riyad_alsalihin_screen.dart';
import '../screens/unified_library_search_screen.dart';

/// بوابة «رياض العلم والهدي النبوي» — مقسمة بتناغم إلى ٥ رياض علمية وروحانية بجميع اللغات الـ ٦
class ComprehensiveLibrariesPortal extends StatefulWidget {
  final ScreenStructureMode layoutMode;
  final ValueChanged<ScreenStructureMode> onModeChanged;

  const ComprehensiveLibrariesPortal({
    super.key,
    required this.layoutMode,
    required this.onModeChanged,
  });

  @override
  State<ComprehensiveLibrariesPortal> createState() =>
      _ComprehensiveLibrariesPortalState();
}

class _ComprehensiveLibrariesPortalState
    extends State<ComprehensiveLibrariesPortal> {
  String _selectedGarden = 'garden_all';

  List<StructuredScreenItem> _buildAllLibraryItems(BuildContext context) {
    void push(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    final gScholars = context.tr('garden_scholars');
    final gProphethood = context.tr('garden_prophethood');
    final gQuran = context.tr('garden_quran_sciences');
    final gFiqh = context.tr('garden_fiqh_wealth');
    final gHearts = context.tr('garden_heart_seasons');

    return [
      // ================= الروضة ١: مجالس العلماء والتراث الصوتي =================
      StructuredScreenItem(
        id: 'lib_scholars_audio_v8',
        title: context.tr('scholars_gatherings'),
        subtitle: context.tr('scholars_gatherings_sub'),
        badgeText: '١١٥ عالماً',
        category: gScholars,
        icon: Icons.mic_external_on_rounded,
        accentColor: const Color(0xFF0F5B45),
        onTap: () => push(const ScholarsAudioLibraryScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_egypt_heritage',
        title: context.tr('egypt_heritage'),
        subtitle:
            'إذاعة القرآن 98.2 FM • ابتهالات النقشبندي وطوبار • خواطر الشعراوي',
        badgeText: 'إذاعة القاهرة',
        category: gScholars,
        icon: Icons.radio_rounded,
        accentColor: const Color(0xFF0A4D3C),
        onTap: () => push(const EgyptianHeritageScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_unified_search',
        title: 'الكشاف الجامع في رياض العلم',
        subtitle:
            'ابحث في آنٍ واحد في الحديث والفقه وعلوم القرآن والسيرة والتراث',
        badgeText: 'كشاف شامل',
        category: gScholars,
        icon: Icons.manage_search_rounded,
        accentColor: AppColors.primaryGreen,
        onTap: () => push(const UnifiedLibrarySearchScreen()),
      ),

      // ================= الروضة ٢: مشكاة النبوة والسيرة والقصص =================
      StructuredScreenItem(
        id: 'lib_riyad_salihin',
        title: context.tr('riyad_salihin'),
        subtitle:
            'جميع كتب وأبواب رياض الصالحين مع الشرح والفوائد والأدب المفرد',
        badgeText: '١٩ كتاباً',
        category: gProphethood,
        icon: Icons.collections_bookmark_rounded,
        accentColor: const Color(0xFF0F5B45),
        onTap: () => push(const RiyadAlSalihinScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_hadith',
        title: context.tr('hadith_library'),
        subtitle:
            'صحيح البخاري، صحيح مسلم، رياض الصالحين، والأربعون النووية',
        badgeText: 'كتب السنة',
        category: gProphethood,
        icon: Icons.auto_stories_rounded,
        accentColor: AppColors.primaryGreen,
        onTap: () => push(const HadithLibraryScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_asma_shamail',
        title: 'أسماء الله الحسنى والشمائل المحمدية',
        subtitle:
            'معاني الأسماء الحسنى والدعاء بها مع شمائل النبي ﷺ وأخلاقه',
        badgeText: '٩٩ اسماً',
        category: gProphethood,
        icon: Icons.stars_rounded,
        accentColor: const Color(0xFFB88917),
        onTap: () => push(const AsmaAllahShamailScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_islamic_history',
        title: 'السيرة النبوية وتراجم الصحابة والأعلام',
        subtitle:
            'الغزوات، الخلفاء الراشدون، أمهات المؤمنين، وأئمة الهدى',
        badgeText: 'السيرة والتاريخ',
        category: gProphethood,
        icon: Icons.history_edu_rounded,
        accentColor: const Color(0xFF6B4C35),
        onTap: () => push(const IslamicHistoryScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_stories',
        title: context.tr('prophet_stories'),
        subtitle: 'قصص الأنبياء والمرسلين وعِبر الوحي مقروءة ومسموعة',
        badgeText: 'صوت ونص',
        category: gProphethood,
        icon: Icons.record_voice_over_rounded,
        accentColor: const Color(0xFF2E5A44),
        onTap: () => push(const StoriesScreen()),
      ),

      // ================= الروضة ٣: بصائر القرآن والمتون العلمية =================
      StructuredScreenItem(
        id: 'lib_comparative_tafsir',
        title: context.tr('comparative_tafsir'),
        subtitle:
            'مقارنة الآيات بين الميسر والسعدي وابن كثير والجلالين والقرطبي والطبري والشعراوي والبغوي',
        badgeText: '٩ تفاسير',
        category: gQuran,
        icon: Icons.compare_arrows_rounded,
        accentColor: const Color(0xFF1B4332),
        onTap: () => push(const ComparativeTafsirScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_gharib_quran',
        title: context.tr('gharib_quran_dict'),
        subtitle:
            'بيان الكلمات القرآنية وجذورها اللغوية ولطائفها البلاغية مع اختبار الفهم',
        badgeText: 'بيان ومعجم',
        category: gQuran,
        icon: Icons.translate_rounded,
        accentColor: const Color(0xFF1565C0),
        onTap: () => push(const GharibQuranScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_quran_sciences',
        title: 'علوم القرآن وأسباب النزول ومقاصد السور',
        subtitle: 'أسباب النزول المحققة، المكي والمدني، وفضائل السور',
        badgeText: 'علوم التنزيل',
        category: gQuran,
        icon: Icons.menu_book_rounded,
        accentColor: const Color(0xFF1F6E58),
        onTap: () => push(const QuranSciencesScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_islamic_mutoon',
        title: context.tr('islamic_mutoon'),
        subtitle:
            'تحفة الأطفال، المقدمة الجزرية، القواعد الفقهية الكبرى، والعقيدة الطحاوية',
        badgeText: 'متون الحفظ',
        category: gQuran,
        icon: Icons.school_rounded,
        accentColor: const Color(0xFF8E6C18),
        onTap: () => push(const IslamicMutoonScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_tajweed_topics',
        title: context.tr('tajweed_rules'),
        subtitle:
            'أحكام التجويد الميسرة والأمثلة التطبيقية وهدايات القرآن الموضوعية',
        badgeText: 'حلية التلاوة',
        category: gQuran,
        icon: Icons.graphic_eq_rounded,
        accentColor: const Color(0xFF1565C0),
        onTap: () => push(const TajweedScreen()),
      ),

      // ================= الروضة ٤: فقه العبادات وطُهرة المال والمناسك =================
      StructuredScreenItem(
        id: 'lib_hajj_umrah',
        title: context.tr('hajj_umrah_companion'),
        subtitle:
            'مناسك العمرة والحج خطوة بخطوة مع عدّاد الطواف والسعي وأدعية كل شوط',
        badgeText: 'مناسك الحرمين',
        category: gFiqh,
        icon: Icons.explore_rounded,
        accentColor: const Color(0xFF0F5B45),
        onTap: () => push(const HajjUmrahCompanionScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_fiqh',
        title: 'فقه العبادات والمعاملات على المذاهب الأربعة',
        subtitle:
            'الطهارة، الصلاة، الصيام، الزكاة، الحج، والمعاملات بأسلوب ميسر',
        badgeText: '٤ مذاهب',
        category: gFiqh,
        icon: Icons.balance_rounded,
        accentColor: const Color(0xFF0D5C46),
        onTap: () => push(const FiqhLibraryScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_kaffarah_fidyah',
        title: context.tr('kaffarah_fidyah_calc'),
        subtitle:
            'حساب زكاة الفطر بالصاع والنقد، وفدية الصيام، وكفارة اليمين بالأدلة',
        badgeText: 'فقه الزكاة',
        category: gFiqh,
        icon: Icons.volunteer_activism_rounded,
        accentColor: const Color(0xFF27AE60),
        onTap: () => push(const KaffarahFidyahScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_mawarith_calc',
        title: context.tr('mawarith_calc'),
        subtitle:
            'حساب الفروض والتركات بالأدلة القرآنية من سورة النساء',
        badgeText: 'علم الفرائض',
        category: gFiqh,
        icon: Icons.calculate_rounded,
        accentColor: const Color(0xFF27AE60),
        onTap: () => push(const MawarithCalculatorScreen()),
      ),

      // ================= الروضة ٥: تزكية القلوب ومواسم الخيرات =================
      StructuredScreenItem(
        id: 'lib_spiritual_mood',
        title: context.tr('spiritual_mood_remedy'),
        subtitle:
            'الآيات الشافية والأدعية النبوية للسكينة عند القلق والحزن وضيق الرزق',
        badgeText: 'سكينة الروح',
        category: gHearts,
        icon: Icons.favorite_rounded,
        accentColor: const Color(0xFF1E8260),
        onTap: () => push(const SpiritualMoodRemedyScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_tadabbur_journal',
        title: context.tr('tadabbur_journal'),
        subtitle:
            'تدوين الرسالة الإيمانية والعمل التطبيقي والدعاء المستنبط من الآيات',
        badgeText: 'عمل بالقرآن',
        category: gHearts,
        icon: Icons.psychology_alt_rounded,
        accentColor: const Color(0xFF1565C0),
        onTap: () => push(const TadabburJournalScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_sunan_rawatib',
        title: context.tr('sunan_rawatib'),
        subtitle:
            'المواظبة على السنن الرواتب الاثنتي عشرة وصلاة الضحى والوتر لبناء بيت في الجنة',
        badgeText: '١٢ ركعة',
        category: gHearts,
        icon: Icons.mosque_rounded,
        accentColor: const Color(0xFF0F5B45),
        onTap: () => push(const SunanRawatibScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_voluntary_fasting',
        title: context.tr('voluntary_fasting'),
        subtitle:
            'صيام الإثنين والخميس، الأيام البيض، الست من شوال، عرفة، وعاشوراء',
        badgeText: 'باب الريّان',
        category: gHearts,
        icon: Icons.wb_twilight_rounded,
        accentColor: const Color(0xFFB88917),
        onTap: () => push(const VoluntaryFastingScreen()),
      ),
      StructuredScreenItem(
        id: 'lib_daily_wird_studio',
        title: context.tr('daily_wird'),
        subtitle:
            'متابعة أوراد القرب اليومية ومرسم الكلمة الطيبة والبطاقات الدعوية',
        badgeText: 'وِرد القرب',
        category: gHearts,
        icon: Icons.task_alt_rounded,
        accentColor: const Color(0xFF8E6C18),
        onTap: () => push(const DailyWirdScreen()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _buildAllLibraryItems(context);
    final selectedGardenLabel =
        _selectedGarden == 'garden_all' ? null : context.tr(_selectedGarden);
    final filteredItems = selectedGardenLabel == null
        ? allItems
        : allItems
            .where((item) => item.category == selectedGardenLabel)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row of 2 Dropdowns: Spiritual Garden Filter + Screen Layout Mode
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppDropdownField<String>(
                label: context.tr('lib_tab_gardens'),
                value: _selectedGarden,
                dense: true,
                prefixIcon: Icons.spa_rounded,
                options: [
                  AppDropdownOption(
                    value: 'garden_all',
                    label: '🌿 ${context.tr('garden_all')} (${allItems.length})',
                  ),
                  AppDropdownOption(
                    value: 'garden_scholars',
                    label: '🎙️ ${context.tr('garden_scholars')}',
                  ),
                  AppDropdownOption(
                    value: 'garden_prophethood',
                    label: '🕌 ${context.tr('garden_prophethood')}',
                  ),
                  AppDropdownOption(
                    value: 'garden_quran_sciences',
                    label: '📖 ${context.tr('garden_quran_sciences')}',
                  ),
                  AppDropdownOption(
                    value: 'garden_fiqh_wealth',
                    label: '⚖️ ${context.tr('garden_fiqh_wealth')}',
                  ),
                  AppDropdownOption(
                    value: 'garden_heart_seasons',
                    label: '🤍 ${context.tr('garden_heart_seasons')}',
                  ),
                ],
                onChanged: (val) => setState(() => _selectedGarden = val),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: AdaptiveLayoutSwitcherBar(
                currentMode: widget.layoutMode,
                onModeChanged: widget.onModeChanged,
                title: context.tr('screen_layout'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Spiritual Companions Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.task_alt_rounded, size: 17),
                label: Text(
                  context.tr('daily_wird'),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DailyWirdScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.palette_outlined, size: 17),
                label: Text(
                  context.tr('daawah_studio'),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DaawahCardStudioScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.category_outlined, size: 17),
                label: Text(
                  context.tr('thematic_index'),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuranTopicsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        AdaptiveStructuredCollectionView(
          mode: widget.layoutMode,
          items: filteredItems,
        ),
      ],
    );
  }
}
