import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/text/arabic_normalizer.dart';

/// نموذج بيانات عنصر دليل وفهرس شاشات تطبيق نور المؤمن
class AppDirectoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String categoryKey;
  final String route;
  final IconData icon;
  final Color color;
  final List<String> keywords;

  const AppDirectoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryKey,
    required this.route,
    required this.icon,
    required this.color,
    this.keywords = const [],
  });
}

/// شاشة «دليل وفهرس شاشات وأبواب تطبيق نور المؤمن الشامل» (AppScreenDirectoryScreen)
/// توفر فهرسة هيكلية كاملة لجميع شاشات وخدمات التطبيق (58 شاشة وباباً إيمانياً)
class AppScreenDirectoryScreen extends StatefulWidget {
  const AppScreenDirectoryScreen({super.key});

  @override
  State<AppScreenDirectoryScreen> createState() =>
      _AppScreenDirectoryScreenState();
}

class _AppScreenDirectoryScreenState extends State<AppScreenDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppDirectoryItem> _getAllItems(BuildContext context) {
    return [
      // ================= المقام الأول: إشراقة اليوم والمتابعة الروحانية =================
      AppDirectoryItem(
        id: 'home_main',
        title: context.tr('nav_home'),
        subtitle: 'لوحة المتابعة اليومية، مواقيت النور، والزاد اللحظي',
        category: 'إشراقة اليوم',
        categoryKey: 'home',
        route: '/home',
        icon: Icons.wb_sunny_rounded,
        color: AppColors.primaryGreen,
        keywords: ['رئيسية', 'اليوم', 'مواقيت', 'أذكار الوقت', 'إشراقة'],
      ),
      AppDirectoryItem(
        id: 'momen_duaa',
        title: 'صفحة الوفاء والدعاء للمرحوم مؤمن إبراهيم',
        subtitle: 'صدقة جارية ودعاء جامع بالرحمة والمغفرة ونور القبر',
        category: 'إشراقة اليوم',
        categoryKey: 'home',
        route: '/momen-duaa',
        icon: Icons.volunteer_activism_rounded,
        color: AppColors.accentGold,
        keywords: ['مؤمن', 'إبراهيم', 'دعاء', 'صدقة جارية', 'وفاء', 'ميت'],
      ),
      AppDirectoryItem(
        id: 'daily_wird',
        title: context.tr('daily_wird'),
        subtitle: 'جدول أوراد العبادات الموزعة ومتابعة العمل الصالح اليومي',
        category: 'إشراقة اليوم',
        categoryKey: 'home',
        route: '/daily-wird',
        icon: Icons.checklist_rtl_rounded,
        color: const Color(0xFF1B6B4E),
        keywords: ['ورد', 'يومي', 'محاسبة', 'جدول', 'طاعة'],
      ),
      AppDirectoryItem(
        id: 'daawah_studio',
        title: context.tr('daawah_studio'),
        subtitle: 'تصميم بطاقات الآيات والأحاديث النبوية بخطوط وزخارف فاخرة',
        category: 'إشراقة اليوم',
        categoryKey: 'home',
        route: '/daawah-studio',
        icon: Icons.palette_rounded,
        color: const Color(0xFFB88917),
        keywords: ['بطاقات', 'تصميم', 'دعوة', 'مشاركة', 'استوديو'],
      ),
      AppDirectoryItem(
        id: 'onboarding',
        title: 'دليل البداية والتعريف بالمعالم',
        subtitle: 'جولة استكشافية لمعالم وخصائص تطبيق نور المؤمن',
        category: 'إشراقة اليوم',
        categoryKey: 'home',
        route: '/onboarding',
        icon: Icons.explore_rounded,
        color: const Color(0xFF25739B),
        keywords: ['ترحيب', 'بداية', 'شرح', 'تعليم'],
      ),

      // ================= المقام الثاني: رحاب القرآن الكريم وعلومه =================
      AppDirectoryItem(
        id: 'quran_hub',
        title: context.tr('holy_quran'),
        subtitle: 'البوابة الجامعة لخدمات وتلاوات وعلوم المصحف الشريف',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/mushaf',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['مصحف', 'قرآن', 'تلاوة', 'سور', 'أجزاء'],
      ),
      AppDirectoryItem(
        id: 'mushaf_pages',
        title: 'المصحف برواية حفص (عرض الصفحات ٦٠٤)',
        subtitle: 'المصحف الشريف مطابق لطبعة مجمع الملك فهد بالرسم العثماني',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/mushaf-pages',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF0A3D2E),
        keywords: ['صفحات', 'رسم عثماني', 'مجمع الملك فهد', 'قراءة'],
      ),
      AppDirectoryItem(
        id: 'surah_reader',
        title: 'قارئ السور والتلاوة والتدبر المفصل',
        subtitle: 'تلاوة الآيات متتابعة مع تشغيل الصوت والترتيل والتفسير',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/surah-reader',
        icon: Icons.chrome_reader_mode_rounded,
        color: const Color(0xFF1B6B4E),
        keywords: ['قارئ', 'آيات', 'تلاوة سورة', 'استماع', 'إعراب'],
      ),
      AppDirectoryItem(
        id: 'mushaf_interactive',
        title: 'المصحف التفاعلي المتقدم',
        subtitle: 'قراءة القرآن مع تدوين الفوائد واختيار القراء والمقامات',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/mushaf-reader',
        icon: Icons.menu_book_outlined,
        color: const Color(0xFF135A43),
        keywords: ['مصحف متقدم', 'تفاعل', 'قراءة حرة'],
      ),
      AppDirectoryItem(
        id: 'quran_search',
        title: context.tr('quran_search'),
        subtitle: 'بحث فوري ودقيق في نصوص القرآن بالجذور والتطابق اللفظي',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/search',
        icon: Icons.search_rounded,
        color: const Color(0xFF2E7D32),
        keywords: ['بحث', 'كلمات', 'آية', 'تطابق', 'جذور'],
      ),
      AppDirectoryItem(
        id: 'comparative_tafsir',
        title: context.tr('comparative_tafsir'),
        subtitle: 'مقارنة ٩ تفاسير معتمدة (ابن كثير، الطبري، السعدي، القرطبي، إلخ)',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/comparative-tafsir',
        icon: Icons.compare_arrows_rounded,
        color: const Color(0xFF8E6C18),
        keywords: ['تفسير', 'مقارنة', 'ابن كثير', 'الطبري', 'السعدي', 'إعراب'],
      ),
      AppDirectoryItem(
        id: 'gharib_quran',
        title: context.tr('gharib_quran_dict'),
        subtitle: 'شرح مفردات القرآن الغريبة وجذورها واختبارات قياس الفهم',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/gharib-quran',
        icon: Icons.translate_rounded,
        color: const Color(0xFF1565C0),
        keywords: ['غريب', 'معاني الكلمات', 'مفردات', 'لغة القرآن'],
      ),
      AppDirectoryItem(
        id: 'tadabbur_journal',
        title: context.tr('tadabbur_journal'),
        subtitle: 'تدوين ثمرات التدبر والعمل بالآيات ومحاسبة النفس الروحية',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/tadabbur-journal',
        icon: Icons.psychology_alt_rounded,
        color: const Color(0xFF283593),
        keywords: ['تدبر', 'مفكرة', 'خواطر', 'عمل بالآيات'],
      ),
      AppDirectoryItem(
        id: 'memorization',
        title: context.tr('memorization'),
        subtitle: 'المساعد الذكي للتحفيظ مع تكرار الآيات وتحديد المقاطع',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/memorization',
        icon: Icons.school_rounded,
        color: const Color(0xFF00695C),
        keywords: ['حفظ', 'تكرار', 'مراجعة', 'تحفيظ'],
      ),
      AppDirectoryItem(
        id: 'khatma',
        title: context.tr('khatma_tracker'),
        subtitle: 'سجل الختمات الزمنية واحتفالية ختم القرآن الكريم',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/khatma',
        icon: Icons.workspace_premium_rounded,
        color: AppColors.accentGold,
        keywords: ['ختمة', 'متابعة', 'دعاء الختم', 'ورد يومي'],
      ),
      AppDirectoryItem(
        id: 'quran_notes',
        title: 'مفكرة وتدوينات الآيات',
        subtitle: 'سجل الملاحظات الشخصية والفوائد المستنبطة عند كل آية',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/notes',
        icon: Icons.note_alt_rounded,
        color: const Color(0xFF4E342E),
        keywords: ['ملاحظات', 'فوائد', 'تدوين'],
      ),
      AppDirectoryItem(
        id: 'quran_sciences',
        title: context.tr('quran_sciences'),
        subtitle: 'أسباب النزول، الناسخ والمنسوخ، الوجوه والنظائر، والإعجاز',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/quran-sciences',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF004D40),
        keywords: ['علوم القرآن', 'أسباب النزول', 'الناسخ والمنسوخ'],
      ),
      AppDirectoryItem(
        id: 'tajweed',
        title: context.tr('tajweed_rules'),
        subtitle: 'أحكام التجويد الميسر بالصوت والأمثلة والتطبيقات العملية',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/tajweed',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFF33691E),
        keywords: ['تجويد', 'أحكام', 'نون ساكنة', 'مدود', 'مخارج'],
      ),
      AppDirectoryItem(
        id: 'quran_topics',
        title: context.tr('quran_topics'),
        subtitle: 'موسوعة الموضوعات القرآنية الجامعة (عقيدة، أخلاق، تشريع)',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/topics',
        icon: Icons.category_rounded,
        color: const Color(0xFF1A237E),
        keywords: ['موضوعات', 'عقيدة', 'معاملات', 'قصص القرآن'],
      ),
      AppDirectoryItem(
        id: 'quran_audio',
        title: 'المكتبة الصوتية لقراء القرآن (٦١ قارئاً)',
        subtitle: 'استماع وتنزيل تلاوات كاملة ومجودة لكبار قراء العالم الإسلامي',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/audio',
        icon: Icons.podcasts_rounded,
        color: const Color(0xFF004D40),
        keywords: ['صوتيات', 'قراء', 'المنشاوي', 'الحصري', 'عبدالباسط'],
      ),
      AppDirectoryItem(
        id: 'audio_downloads',
        title: 'مدير التنزيلات الصوتية',
        subtitle: 'إدارة الملفات المحفوظة للاستماع دون اتصال بالإنترنت',
        category: 'رحاب القرآن',
        categoryKey: 'quran',
        route: '/downloads',
        icon: Icons.download_for_offline_rounded,
        color: const Color(0xFF37474F),
        keywords: ['تنزيلات', 'بدون نت', 'أوفلاين', 'صوتيات محملة'],
      ),

      // ================= المقام الثالث: محراب الصلاة ومواقيت النور =================
      AppDirectoryItem(
        id: 'prayer_main',
        title: context.tr('nav_prayer'),
        subtitle: 'مواقيت الصلاة الدقيقة، العد التنازلي، والمدينة الحالية',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/prayer',
        icon: Icons.access_time_filled_rounded,
        color: AppColors.primaryGreen,
        keywords: ['صلاة', 'مواقيت', 'أذان', 'فجر', 'ظهر', 'عصر', 'مغرب', 'عشاء'],
      ),
      AppDirectoryItem(
        id: 'adhan_control',
        title: 'التحكم في الأذان والتنبيهات',
        subtitle: 'اختيار أصوات المؤذنين وضبط تنبيهات الإقامة لكل صلاة',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/adhan-control',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['أذان', 'إقامة', 'منبه', 'مؤذن', 'تنبيه'],
      ),
      AppDirectoryItem(
        id: 'qibla',
        title: context.tr('qibla_compass'),
        subtitle: 'بوصلة بصرية دقيقة لتحديد اتجاه الكعبة المشرفة بمستشعرات الهاتف',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/qibla',
        icon: Icons.explore_rounded,
        color: const Color(0xFFB88917),
        keywords: ['قبلة', 'بوصلة', 'كعبة', 'مكة', 'اتجاه'],
      ),
      AppDirectoryItem(
        id: 'hijri_calendar',
        title: context.tr('hijri_calendar'),
        subtitle: 'التقويم الهجري والميلادي وأيام الفضائل ومواسم الخير',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/calendar',
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF1E8260),
        keywords: ['تقويم', 'هجري', 'أيام بيض', 'مناسبات', 'أشهر حرم'],
      ),
      AppDirectoryItem(
        id: 'prayer_tracker',
        title: context.tr('prayer_tracker'),
        subtitle: 'سجل متابعة الصلوات الخمس في جماعة وقضاء ما فات بعزيمة',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/prayer-tracker',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFFB88917),
        keywords: ['متابع الصلوات', 'قضاء', 'جماعة', 'محاسبة'],
      ),
      AppDirectoryItem(
        id: 'fajr_qiyam_alarm',
        title: context.tr('dawn_awakening'),
        subtitle: 'منبه إيماني تصاعدي للاستيقاظ لصلاة الفجر وقيام الليل',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/fajr-qiyam-alarm',
        icon: Icons.alarm_on_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['فجر', 'قيام ليل', 'منبه فجر', 'تهجد'],
      ),
      AppDirectoryItem(
        id: 'sunan_rawatib',
        title: context.tr('sunan_rawatib'),
        subtitle: 'ثنتا عشرة ركعة في اليوم والليلة يبني الله لك بها بيتاً في الجنة',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/sunan-rawatib',
        icon: Icons.stars_rounded,
        color: const Color(0xFF1B4332),
        keywords: ['سنن', 'رواتب', 'ركعات', 'جنة', 'نوافل'],
      ),
      AppDirectoryItem(
        id: 'voluntary_fasting',
        title: context.tr('voluntary_fasting'),
        subtitle: 'الإثنين والخميس، الأيام البيض، عاشوراء، والست من شوال',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/voluntary-fasting',
        icon: Icons.wb_twilight_rounded,
        color: const Color(0xFFB88917),
        keywords: ['صيام', 'نوافل', 'أيام بيض', 'عرفة', 'عاشوراء'],
      ),
      AppDirectoryItem(
        id: 'battery_guide',
        title: 'دليل موثوقية الأذان والبطارية',
        subtitle: 'خطوات استثناء التطبيق من قيود توفير الطاقة لضمان انطلاق الأذان',
        category: 'محراب الصلاة',
        categoryKey: 'prayer',
        route: '/battery-guide',
        icon: Icons.battery_charging_full_rounded,
        color: const Color(0xFFE65100),
        keywords: ['بطارية', 'أذان لا يعمل', 'تنبيهات', 'خلفية'],
      ),

      // ================= المقام الرابع: أُنس الذاكرين وسكينة القلوب =================
      AppDirectoryItem(
        id: 'adhkar_hub',
        title: context.tr('adhkar_hub'),
        subtitle: 'البوابة الجامعة لأذكار اليوم والليلة والأدعية النبوية الجامعة',
        category: 'أُنس الذاكرين',
        categoryKey: 'adhkar',
        route: '/adhkar-hub',
        icon: Icons.favorite_rounded,
        color: const Color(0xFF1E8260),
        keywords: ['أذكار', 'تسبيح', 'صباح', 'مساء', 'دعاء'],
      ),
      AppDirectoryItem(
        id: 'adhkar_screen',
        title: 'موسوعة حصن المسلم الكاملة',
        subtitle: 'أذكار الصباح والمساء، النوم والاستيقاظ، الصلاة، والسفر',
        category: 'أُنس الذاكرين',
        categoryKey: 'adhkar',
        route: '/adhkar',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF135A43),
        keywords: ['حصن المسلم', 'صباح ومساء', 'أذكار النوم'],
      ),
      AppDirectoryItem(
        id: 'tasbih',
        title: context.tr('electronic_tasbih'),
        subtitle: 'المسبحة الإلكترونية الذكية مع ميزة الاهتزاز وحفظ العداد التلقائي',
        category: 'أُنس الذاكرين',
        categoryKey: 'adhkar',
        route: '/tasbih',
        icon: Icons.fingerprint_rounded,
        color: AppColors.accentGold,
        keywords: ['تسبيح', 'مسبحة', 'استغفار', 'عداد'],
      ),
      AppDirectoryItem(
        id: 'spiritual_mood',
        title: context.tr('spiritual_mood_remedy'),
        subtitle: 'طِبّ القلوب وسكينة المشاعر بالآيات والأدعية المناسبة لقلبك',
        category: 'أُنس الذاكرين',
        categoryKey: 'adhkar',
        route: '/spiritual-mood',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['مشاعر', 'حزن', 'ضيق', 'هم', 'سكينة', 'قلوب'],
      ),

      // ================= المقام الخامس: رياض العلم والهدي النبوي =================
      AppDirectoryItem(
        id: 'library_main',
        title: context.tr('islamic_library'),
        subtitle: 'البوابة الكبرى لكنوز العلم الشرعي والحديث النبوي والتراث',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/library',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF34495E),
        keywords: ['مكتبة', 'علم', 'فقه', 'حديث', 'سيرة'],
      ),
      AppDirectoryItem(
        id: 'hadith_library',
        title: context.tr('prophetic_hadiths'),
        subtitle: 'صحيح البخاري، مسلم، الأربعون النووية، ورياض الصالحين',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/hadith',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF1B6B4E),
        keywords: ['حديث', 'بخاري', 'مسلم', 'أربعين نووية', 'سنة'],
      ),
      AppDirectoryItem(
        id: 'riyad_salihin',
        title: context.tr('riyad_salihin'),
        subtitle: 'كتاب رياض الصالحين للإمام النووي مع الشرح والفوائد',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/riyad-alsalihin',
        icon: Icons.collections_bookmark_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['رياض الصالحين', 'النووي', 'أخلاق', 'أحاديث'],
      ),
      AppDirectoryItem(
        id: 'islamic_mutoon',
        title: context.tr('islamic_mutoon'),
        subtitle: 'المتون العلمية المنظومة: تحفة الأطفال، الجزرية، البيقونية',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/islamic-mutoon',
        icon: Icons.school_rounded,
        color: const Color(0xFF8E6C18),
        keywords: ['متون', 'تحفة الأطفال', 'الجزرية', 'حفظ متون'],
      ),
      AppDirectoryItem(
        id: 'stories',
        title: context.tr('prophets_stories'),
        subtitle: 'قصص الأنبياء والصحابة مسموعة ومقروءة بجودة صوتية نقية',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/stories',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFF1565C0),
        keywords: ['قصص', 'أنبياء', 'صحابة', 'سيرة', 'عبر'],
      ),
      AppDirectoryItem(
        id: 'fiqh_library',
        title: context.tr('fiqh_library'),
        subtitle: 'الموسوعة الفقهية الميسرة: أحكام الطهارة، الصلاة، الجنائز',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/fiqh-library',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF2E7D32),
        keywords: ['فقه', 'طهارة', 'وضوء', 'صلاة', 'أحكام'],
      ),
      AppDirectoryItem(
        id: 'asma_shamail',
        title: context.tr('asma_allah_shamail'),
        subtitle: 'أسماء الله الحسنى ومعانيها، والشمائل والأخلاق المحمدية',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/asma-shamail',
        icon: Icons.stars_rounded,
        color: AppColors.accentGold,
        keywords: ['أسماء الله الحسنى', 'شمائل', 'نبي', 'أوصاف'],
      ),
      AppDirectoryItem(
        id: 'islamic_history',
        title: context.tr('islamic_history'),
        subtitle: 'أطلس التاريخ الإسلامي: السيرة النبوية، الخلفاء الراشدون',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/islamic-history',
        icon: Icons.timeline_rounded,
        color: const Color(0xFF4E342E),
        keywords: ['تاريخ', 'سيرة', 'خلفاء راشدين', 'فتوحات'],
      ),
      AppDirectoryItem(
        id: 'hajj_umrah',
        title: context.tr('hajj_umrah_companion'),
        subtitle: 'رفيق الحج والعمرة التفاعلي مع عداد أشواط الطواف والسعي',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/hajj-umrah',
        icon: Icons.explore_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['حج', 'عمرة', 'طواف', 'سعي', 'مناسك'],
      ),
      AppDirectoryItem(
        id: 'ramadan',
        title: context.tr('ramadan_seasons'),
        subtitle: 'نفحات شهر رمضان المبارك، فقه الصيام، ليلة القدر، والاعتكاف',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/ramadan',
        icon: Icons.nightlight_round,
        color: const Color(0xFF1B6B4E),
        keywords: ['رمضان', 'صيام', 'تراويح', 'اعتكاف', 'ليلة القدر'],
      ),
      AppDirectoryItem(
        id: 'zakat',
        title: context.tr('zakat_faraid'),
        subtitle: 'حاسبة الزكاة الذكية: زكاة المال، الذهب والفضة، عروض التجارة',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/zakat',
        icon: Icons.calculate_rounded,
        color: const Color(0xFF27AE60),
        keywords: ['زكاة', 'مال', 'ذهب', 'فضة', 'نصاب'],
      ),
      AppDirectoryItem(
        id: 'mawarith_calc',
        title: context.tr('mawarith_calc'),
        subtitle: 'حاسبة المواريث الشرعية: توزيع الأنصبة وحجب الورثة بالأدلة',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/mawarith-calculator',
        icon: Icons.balance_rounded,
        color: const Color(0xFF1B4332),
        keywords: ['مواريث', 'تركة', 'أنصبة', 'ميراث', 'سورة النساء'],
      ),
      AppDirectoryItem(
        id: 'kaffarah_fidyah',
        title: context.tr('kaffarah_fidyah_calc'),
        subtitle: 'فقه الكفارات والفدية وزكاة الفطر والصدقات الواجبة',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/kaffarah-fidyah',
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFF2E7D32),
        keywords: ['كفارة', 'فدية', 'يمين', 'زكاة الفطر'],
      ),
      AppDirectoryItem(
        id: 'scholars_audio',
        title: context.tr('scholars_gatherings'),
        subtitle: 'مجالس كبار العلماء (١١٥ عالماً و ٧٠٨ محاضرات صوتية)',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/scholars-audio',
        icon: Icons.mic_external_on_rounded,
        color: const Color(0xFF0F5B45),
        keywords: ['علماء', 'شيوخ', 'محاضرات', 'ابن باز', 'ابن عثيمين', 'الشعراوي'],
      ),
      AppDirectoryItem(
        id: 'egypt_heritage',
        title: context.tr('egypt_heritage'),
        subtitle: 'إذاعة القرآن 98.2 FM • ابتهالات النقشبندي وطوبار • خواطر الشعراوي',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/egypt-heritage',
        icon: Icons.radio_rounded,
        color: const Color(0xFF0D5C46),
        keywords: ['إذاعة القاهرة', 'ابتهالات', 'نقشبندي', 'طوبار', 'شعراوي'],
      ),
      AppDirectoryItem(
        id: 'library_search',
        title: 'الكشاف الجامع في رياض العلم',
        subtitle: 'محرك بحث موحد في كتب الحديث والفقه والتفسير والتاريخ',
        category: 'رياض العلم',
        categoryKey: 'library',
        route: '/library-search',
        icon: Icons.manage_search_rounded,
        color: AppColors.primaryGreen,
        keywords: ['بحث شامل', 'كشاف', 'كتب', 'مكتبة كاملة'],
      ),

      // ================= المقام السادس: تهيئة التطبيق والعناية =================
      AppDirectoryItem(
        id: 'settings',
        title: context.tr('settings_title'),
        subtitle: 'ضبط اللغات، المظهر الداكن، خطوط المصحف، وتنبيهات الأذان',
        category: 'العناية والإعدادات',
        categoryKey: 'settings',
        route: '/settings',
        icon: Icons.tune_rounded,
        color: const Color(0xFF2C5E43),
        keywords: ['إعدادات', 'مظهر', 'خط', 'لغات', 'تهيئة'],
      ),
      AppDirectoryItem(
        id: 'backup',
        title: context.tr('backup_restore'),
        subtitle: 'حفظ واسترجاع سجلات الختمات والملاحظات والصلوات بأمان',
        category: 'العناية والإعدادات',
        categoryKey: 'settings',
        route: '/backup',
        icon: Icons.backup_rounded,
        color: const Color(0xFF5E4E8C),
        keywords: ['نسخ احتياطي', 'استرجاع', 'مزامنة', 'حفظ البيانات'],
      ),
      AppDirectoryItem(
        id: 'support',
        title: context.tr('contact_support'),
        subtitle: 'التواصل مع فريق التطوير وإرسال المقترحات والرسائل',
        category: 'العناية والإعدادات',
        categoryKey: 'settings',
        route: '/support',
        icon: Icons.headset_mic_rounded,
        color: const Color(0xFF25739B),
        keywords: ['دعم', 'تواصل', 'مقترحات', 'فريق البرمجة'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allItems = _getAllItems(context);

    // Apply Filter
    final filteredItems = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'all' ||
          item.categoryKey == _selectedCategory;
      if (!matchesCategory) return false;

      if (_searchQuery.isEmpty) return true;

      final normQuery =
          ArabicNormalizer.normalize(_searchQuery, loose: true).toLowerCase();
      final normTitle =
          ArabicNormalizer.normalize(item.title, loose: true).toLowerCase();
      final normSub =
          ArabicNormalizer.normalize(item.subtitle, loose: true).toLowerCase();

      final matchesText = normTitle.contains(normQuery) ||
          normSub.contains(normQuery) ||
          item.keywords.any((k) =>
              ArabicNormalizer.normalize(k, loose: true)
                  .toLowerCase()
                  .contains(normQuery));

      return matchesText;
    }).toList();

    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final s = SettingsService.instance;

        return Directionality(
          textDirection: s.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'فهرس ودليل الشاشات الشامل',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(105),
                child: Column(
                  children: [
                    // Search Field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'ابحث في كافة أبواب وخدمات التطبيق (٥٨ شاشة)...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              size: 20, color: AppColors.primaryGreen),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF13221C)
                              : Colors.grey.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          _buildFilterChip('الكل (${allItems.length})', 'all',
                              Icons.grid_view_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('إشراقة اليوم (٥)', 'home',
                              Icons.wb_sunny_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('رحاب القرآن (١٦)', 'quran',
                              Icons.menu_book_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('محراب الصلاة (٩)', 'prayer',
                              Icons.access_time_filled_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('أُنس الذاكرين (٤)', 'adhkar',
                              Icons.favorite_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('رياض العلم (١٦)', 'library',
                              Icons.auto_stories_rounded),
                          const SizedBox(width: 6),
                          _buildFilterChip('العناية والإعدادات (٣)', 'settings',
                              Icons.tune_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            body: filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'لم يتم العثور على أبواب تطابق: "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('إعادة عرض كافة الشاشات'),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'all';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF14221C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1F352C)
                                : const Color(0xFFE5EDE8),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: item.color.withOpacity(0.3)),
                              ),
                              child: Icon(item.icon,
                                  color: item.color, size: 22),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: item.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              context.push(item.route);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String key, IconData icon) {
    final isSelected = _selectedCategory == key;
    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 15,
        color: isSelected ? Colors.white : AppColors.primaryGreen,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
        color: isSelected ? Colors.white : null,
      ),
      selectedColor: AppColors.primaryGreen,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedCategory = key);
        }
      },
    );
  }
}
