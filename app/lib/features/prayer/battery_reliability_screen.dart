import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class OemStep {
  final String title;
  final String description;
  final String recommendedSetting;
  final IconData? icon;

  const OemStep({
    required this.title,
    required this.description,
    required this.recommendedSetting,
    this.icon,
  });
}

class OemGuide {
  final String id;
  final String name;
  final String subTitle;
  final String badge;
  final IconData icon;
  final List<OemStep> steps;

  const OemGuide({
    required this.id,
    required this.name,
    required this.subTitle,
    required this.badge,
    required this.icon,
    required this.steps,
  });
}

class BatteryReliabilityScreen extends StatefulWidget {
  const BatteryReliabilityScreen({super.key});

  static const List<OemGuide> oemGuides = [
    OemGuide(
      id: 'xiaomi',
      name: 'شاومي / بوكو / ريدمي',
      subTitle: 'واجهة MIUI و HyperOS',
      badge: 'الأكثر تأثراً بقاتل التطبيقات',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. تفعيل البدء التلقائي (Autostart)',
          description: 'الإعدادات > التطبيقات > إدارة التطبيقات > اختر "المؤمن" > فعّل خيار "البدء التلقائي" (Autostart).',
          recommendedSetting: 'مفعّل دائمًا',
          icon: Icons.power_settings_new,
        ),
        OemStep(
          title: '٢. ضبط موفر البطارية على "لا توجد قيود"',
          description: 'في نفس صفحة التطبيق، اضغط على "موفر البطارية" (Battery Saver) واختر "لا توجد قيود" (No Restrictions).',
          recommendedSetting: 'لا توجد قيود',
          icon: Icons.battery_charging_full,
        ),
        OemStep(
          title: '٣. قفل التطبيق في قائمة التطبيقات الأخيرة',
          description: 'افتح قائمة المهام الأخيرة (Recent Apps)، اضغط مطولاً على نافذة تطبيق نور المؤمن ثم اضغط على أيقونة "القفل 🔒" حتى لا يتم إغلاقه عند تنظيف الذاكرة.',
          recommendedSetting: 'مقفل برمز القفل 🔒',
          icon: Icons.lock_outline,
        ),
      ],
    ),
    OemGuide(
      id: 'samsung',
      name: 'سامسونج (Samsung)',
      subTitle: 'واجهة One UI (أندرويد 9 - 15)',
      badge: 'شائع الاستخدام',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. تعيين استخدام البطارية إلى "غير مقيد"',
          description: 'الإعدادات > التطبيقات > المؤمن > البطارية > اختر "غير مقيد" (Unrestricted) بدلاً من "مُحسَّن".',
          recommendedSetting: 'غير مقيد (Unrestricted)',
          icon: Icons.battery_alert,
        ),
        OemStep(
          title: '٢. استثناء من "وضع السكون العميق"',
          description: 'الإعدادات > العناية بالجهاز > البطارية > حدود استخدام الخلفية > أضف المؤمن إلى قائمة "تطبيقات لا تدخل وضع السكون أبداً" (Never sleeping apps).',
          recommendedSetting: 'تطبيق لا ينام أبداً',
          icon: Icons.nightlight_round,
        ),
        OemStep(
          title: '٣. إيقاف "وضع التطبيقات غير المستخدمة في السكون"',
          description: 'تأكد من إلغاء تفعيل "وضع التطبيقات غير المستخدمة في وضع السكون" حتى لا يعطل النظام التنبيهات إذا مرت فترة دون فتح التطبيق.',
          recommendedSetting: 'معطّل',
          icon: Icons.pause_circle_outline,
        ),
      ],
    ),
    OemGuide(
      id: 'huawei',
      name: 'هواوي وهونر (Huawei / Honor)',
      subTitle: 'واجهة EMUI و HarmonyOS و MagicOS',
      badge: 'حماية صارمة',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. ضبط إدارة بدء التشغيل يدوياً (App Launch)',
          description: 'الإعدادات > البطارية > تشغيل التطبيقات (App Launch) > ابحث عن "المؤمن" وأوقف التشغيل التلقائي للدخول في "الإدارة اليدوية".',
          recommendedSetting: 'إدارة يدوية (Manage manually)',
          icon: Icons.tune,
        ),
        OemStep(
          title: '٢. تفعيل كافة خيارات التشغيل الثلاثة',
          description: 'فعّل: [١] البدء التلقائي (Auto-launch) + [٢] البدء الثانوي (Secondary launch) + [٣] التشغيل في الخلفية (Run in background).',
          recommendedSetting: 'جميع الخيارات مفعّلة',
          icon: Icons.checklist,
        ),
        OemStep(
          title: '٣. تجاهل تحسينات البطارية',
          description: 'الإعدادات > التطبيقات > الوصول الخاص > تحسين البطارية > غير المسموح بها > اختر "السماح" لتطبيق نور المؤمن.',
          recommendedSetting: 'مسموح دائماً',
          icon: Icons.battery_saver,
        ),
      ],
    ),
    OemGuide(
      id: 'oppo_realme',
      name: 'أوبو وريلمي وون بلس (Oppo / Realme)',
      subTitle: 'واجهات ColorOS و Realme UI و OxygenOS',
      badge: 'تجميد ذكي',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. السماح بالنشاط في الخلفية',
          description: 'الإعدادات > التطبيقات > إدارة التطبيقات > المؤمن > استخدام البطارية > فعّل "السماح بالنشاط في الخلفية" (Allow background activity).',
          recommendedSetting: 'مفعّل',
          icon: Icons.play_arrow_outlined,
        ),
        OemStep(
          title: '٢. السماح بالبدء التلقائي (Auto-launch)',
          description: 'فعّل خيار "السماح بالبدء التلقائي" (Allow auto-launch) ليعيد التطبيق جدولة الأذان تلقائياً بعد إعادة التشغيل.',
          recommendedSetting: 'مفعّل',
          icon: Icons.autorenew,
        ),
        OemStep(
          title: '٣. إيقاف التجميد السريع في الخلفية',
          description: 'في إعدادات البطارية المتقدمة، تأكد من عدم تضمين المؤمن في قائمة "تجميد التطبيقات السريع" (Quick Freeze).',
          recommendedSetting: 'مستثنى من التجميد',
          icon: Icons.ac_unit,
        ),
      ],
    ),
    OemGuide(
      id: 'vivo',
      name: 'فيفو (Vivo / iQOO)',
      subTitle: 'واجهة Funtouch OS و OriginOS',
      badge: 'إدارة طاقة خلفية',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. السماح باستهلاك الطاقة العالي في الخلفية',
          description: 'الإعدادات > البطارية > استهلاك طاقة عالي في الخلفية (High background power consumption) > فعّل تطبيق نور المؤمن.',
          recommendedSetting: 'مسموح',
          icon: Icons.flash_on,
        ),
        OemStep(
          title: '٢. تفعيل البدء التلقائي',
          description: 'الإعدادات > التطبيقات والأذونات > إدارة الأذونات > البدء التلقائي > السماح لتطبيق نور المؤمن بالبدء التلقائي.',
          recommendedSetting: 'مفعّل',
          icon: Icons.power_settings_new,
        ),
      ],
    ),
    OemGuide(
      id: 'infinix_tecno',
      name: 'إنفينيكس وتكنو (Infinix / Tecno)',
      subTitle: 'واجهات XOS و HiOS',
      badge: 'تطبيق Phone Master',
      icon: Icons.phone_android,
      steps: [
        OemStep(
          title: '١. فتح Phone Master والبدء التلقائي',
          description: 'افتح تطبيق Phone Master المثبت مسبقاً > صندوق الأدوات (Toolbox) > إدارة البدء التلقائي (Auto-start) > فعّل تطبيق نور المؤمن.',
          recommendedSetting: 'مفعّل في Phone Master',
          icon: Icons.shield_outlined,
        ),
        OemStep(
          title: '٢. استثناء من منظف الذاكرة العشوائية',
          description: 'في مدير تسريع الهاتف (Phone Boost)، أضف تطبيق نور المؤمن إلى القائمة البيضاء (Whitelist) حتى لا يتم إغلاقه عند تنظيف الرام.',
          recommendedSetting: 'في القائمة البيضاء',
          icon: Icons.cleaning_services_outlined,
        ),
      ],
    ),
    OemGuide(
      id: 'stock_android',
      name: 'أندرويد الخام وجوجل بكسل وموتورولا',
      subTitle: 'Stock Android / Pixel / Motorola',
      badge: 'الضبط القياسي',
      icon: Icons.android,
      steps: [
        OemStep(
          title: '١. تعيين استخدام البطارية إلى "غير مقيد"',
          description: 'الإعدادات > التطبيقات > تطبيق نور المؤمن > البطارية > اختر "غير مقيد" (Unrestricted) لتسمح بعمل الأذان في أي وقت.',
          recommendedSetting: 'غير مقيد (Unrestricted)',
          icon: Icons.battery_std,
        ),
        OemStep(
          title: '٢. إيقاف إيقاف التطبيق المؤقت عند عدم الاستخدام',
          description: 'في صفحة معلومات التطبيق، أوقف تفعيل خيار "إيقاف نشاط التطبيق إذا لم يُستخدم" (Pause app activity if unused).',
          recommendedSetting: 'معطّل',
          icon: Icons.timer_off_outlined,
        ),
      ],
    ),
  ];

  @override
  State<BatteryReliabilityScreen> createState() => _BatteryReliabilityScreenState();
}

class _BatteryReliabilityScreenState extends State<BatteryReliabilityScreen> {
  String _selectedOemId = 'xiaomi';
  final Set<String> _completedStepKeys = {};

  bool _isNotificationGranted = false;
  bool _isBatteryOptimizationIgnored = false;
  bool _isExactAlarmGranted = false;
  bool _isLoadingChecks = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() => _isLoadingChecks = true);
    final prefs = await SharedPreferences.getInstance();

    final savedSteps = prefs.getStringList('oem_completed_steps') ?? [];
    _completedStepKeys.clear();
    _completedStepKeys.addAll(savedSteps);

    try {
      final notifStatus = await Permission.notification.status;
      final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
      final alarmStatus = await Permission.scheduleExactAlarm.status;

      if (mounted) {
        setState(() {
          _isNotificationGranted = notifStatus.isGranted;
          _isBatteryOptimizationIgnored = batteryStatus.isGranted;
          _isExactAlarmGranted = alarmStatus.isGranted;
        });
      }
    } catch (_) {
      // Graceful fallback in testing or unsupported environments
    } finally {
      if (mounted) {
        setState(() => _isLoadingChecks = false);
      }
    }
  }

  Future<void> _toggleStep(String oemId, int stepIndex) async {
    final key = '${oemId}_$stepIndex';
    setState(() {
      if (_completedStepKeys.contains(key)) {
        _completedStepKeys.remove(key);
      } else {
        _completedStepKeys.add(key);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('oem_completed_steps', _completedStepKeys.toList());
  }

  bool _isStepDone(String oemId, int stepIndex) {
    return _completedStepKeys.contains('${oemId}_$stepIndex');
  }

  int _getOemCompletedCount(String oemId) {
    final guide = BatteryReliabilityScreen.oemGuides.firstWhere((g) => g.id == oemId, orElse: () => BatteryReliabilityScreen.oemGuides.first);
    int count = 0;
    for (int i = 0; i < guide.steps.length; i++) {
      if (_isStepDone(oemId, i)) count++;
    }
    return count;
  }

  Future<void> _requestNotification() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() {
        _isNotificationGranted = status.isGranted;
      });
    }
  }

  Future<void> _requestBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    if (mounted) {
      setState(() {
        _isBatteryOptimizationIgnored = status.isGranted;
      });
    }
  }

  Future<void> _requestExactAlarm() async {
    final status = await Permission.scheduleExactAlarm.request();
    if (mounted) {
      setState(() {
        _isExactAlarmGranted = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGuide = BatteryReliabilityScreen.oemGuides.firstWhere(
      (g) => g.id == _selectedOemId,
      orElse: () => BatteryReliabilityScreen.oemGuides.first,
    );
    final completedCount = _getOemCompletedCount(currentGuide.id);
    final totalSteps = currentGuide.steps.length;
    final progress = totalSteps > 0 ? (completedCount / totalSteps) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل تثبيت الأذان وإعدادات البطارية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة فحص الأذونات',
            onPressed: _loadState,
          ),
        ],
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Header Explanation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.bolt, color: AppColors.accentGold, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لماذا يحتاج التطبيق لهذه الإعدادات؟',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'تقوم أنظمة أندرويد الحديثة وخاصة (شاومي، سامسونج، هواوي، وأوبو) بإيقاف التطبيقات في الخلفية لتوفير البطارية، مما قد يمنع انطلاق الأذان في وقته. اتبع الخطوات أدناه لضمان صدح الأذان بدقة ١٠٠٪ دون تأخير.',
                          style: TextStyle(color: AppColors.softGold, fontSize: 12.5, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Live Status Checklist
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'فحص الأذونات الحيوية لنظام الهاتف',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                const Spacer(),
                if (_isLoadingChecks)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 10),

            // Card 1: Notification Permission
            _buildCheckCard(
              title: 'إذن إشعارات الأذان (Notifications)',
              subtitle: 'ضروري لعرض وتنبيه أوقات الصلاة على الشاشة',
              isGranted: _isNotificationGranted,
              onFix: _requestNotification,
              icon: Icons.notifications_active_outlined,
            ),
            const SizedBox(height: 8),

            // Card 2: Battery Optimization
            _buildCheckCard(
              title: 'استثناء من توفير البطارية (Battery Optimization)',
              subtitle: 'يمنع نظام أندرويد من قتل خدمة الأذان أثناء قفل الشاشة',
              isGranted: _isBatteryOptimizationIgnored,
              onFix: _requestBatteryOptimization,
              icon: Icons.battery_charging_full_outlined,
            ),
            const SizedBox(height: 8),

            // Card 3: Exact Alarm Permission
            _buildCheckCard(
              title: 'إذن المنبه الدقيق بالثانية (Exact Alarms)',
              subtitle: 'يضمن إطلاق الأذان بالدقيقة والثانية دون أي تأخير',
              isGranted: _isExactAlarmGranted,
              onFix: _requestExactAlarm,
              icon: Icons.alarm_on_outlined,
            ),
            const SizedBox(height: 12),

            // Direct button to open App System Settings
            OutlinedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings_suggest, color: AppColors.primaryGreen),
              label: const Text(
                'فتح صفحة إعدادات تطبيق نور المؤمن بالنظام مباشرة',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: OEM Specific Guides
            Row(
              children: [
                const Icon(Icons.phone_android, color: AppColors.primaryGreen, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'دليل ضبط الهاتف حسب الشركة المصنعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'اختر نوع هاتفك واقرأ الخطوات المخصصة له، واضغط على المربع عند إتمام كل خطوة:',
              style: TextStyle(fontSize: 13, color: AppColors.lightText),
            ),
            const SizedBox(height: 12),

            // Horizontal Brand Selector
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: BatteryReliabilityScreen.oemGuides.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final guide = BatteryReliabilityScreen.oemGuides[index];
                  final isSelected = guide.id == _selectedOemId;
                  final brandDone = _getOemCompletedCount(guide.id);
                  final brandTotal = guide.steps.length;

                  return ChoiceChip(
                    avatar: Icon(
                      guide.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.primaryGreen,
                    ),
                    label: Text(
                      '${guide.name} ${brandDone > 0 ? "($brandDone/$brandTotal)" : ""}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.08),
                    onSelected: (val) {
                      if (val) setState(() => _selectedOemId = guide.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Active OEM Guide Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.accentGold.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_android, color: AppColors.primaryGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentGuide.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                currentGuide.subTitle,
                                style: const TextStyle(fontSize: 12, color: AppColors.lightText),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentGuide.badge,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Indicator
                    Row(
                      children: [
                        Text(
                          'إنجاز خطوات ${currentGuide.name}: ',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$completedCount من $totalSteps',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      ),
                    ),
                    const Divider(height: 24),

                    // Steps List
                    ...currentGuide.steps.asMap().entries.map((entry) {
                      final stepIndex = entry.key;
                      final step = entry.value;
                      final isDone = _isStepDone(currentGuide.id, stepIndex);

                      return InkWell(
                        onTap: () => _toggleStep(currentGuide.id, stepIndex),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primaryGreen.withOpacity(0.05) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDone ? AppColors.primaryGreen.withOpacity(0.3) : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isDone,
                                activeColor: AppColors.primaryGreen,
                                onChanged: (_) => _toggleStep(currentGuide.id, stepIndex),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        color: isDone ? AppColors.primaryGreen : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      step.description,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.4,
                                        color: isDone ? Colors.grey.shade600 : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'الضبط المطلوب: ${step.recommendedSetting}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: General Best Practices
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: AppColors.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text('نصائح عامة لضمان استقرار الأذان', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• بعد ضبط الإعدادات أعلاه لأول مرة، يُنصح بإعادة تشغيل الهاتف (Restart) لاعتماد التغييرات بالنظام.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    Text(
                      '• تأكد من أن مستوى صوت "الوسائط" و"التنبيهات" ليس صامتاً في أوقات الصلاة.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                    Text(
                      '• في حال تفعيل وضع "عدم الإزعاج" (Do Not Disturb)، يرجى استثناء تطبيق نور المؤمن ليصدح الأذان في أوقاته.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckCard({
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onFix,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isGranted ? Colors.green.shade300 : Colors.amber.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGranted ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? Colors.green.shade700 : Colors.amber.shade900,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.lightText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isGranted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('مفعّل', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: onFix,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('طلب الإذن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
