import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/prayer_service.dart';
import '../prayer/battery_reliability_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selected values in onboarding
  String _selectedCityName = 'القاهرة، مصر';
  double _fontSize = 24.0;
  String _selectedReciterId = 'minshawi_murattal';
  bool _enableNotifications = true;
  bool _dontShowAgain = true;

  @override
  void initState() {
    super.initState();
    _fontSize = SettingsService.instance.mushafFontSize;
    _selectedReciterId = SettingsService.instance.selectedReciterId;
    _enableNotifications = SettingsService.instance.adhanAlertsEnabled;
    _dontShowAgain = !SettingsService.instance.showTutorialScreens;
    if (!SettingsService.instance.hasCompletedOnboarding) {
      _dontShowAgain = true; // By default checked so user won't be bothered again unless they uncheck
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await SettingsService.instance.setShowTutorialScreens(!_dontShowAgain);
    await SettingsService.instance.completeOnboarding();
    await SettingsService.instance.setMushafFontSize(_fontSize);
    await SettingsService.instance.setSelectedReciter(_selectedReciterId);
    await SettingsService.instance.toggleAdhanAlerts(_enableNotifications);

    if (mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        try {
          context.go('/home');
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: SafeArea(
          child: Column(
            children: [
              // Header with Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mosque, color: AppColors.primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'نور المؤمن',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          color: AppColors.secondaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  children: [
                    _buildDedicationAndWelcomePage(),
                    _buildPersonalizationPage(),
                    _buildNotificationsAndReadinessPage(),
                  ],
                ),
              ),

              // Checkbox: Don't show tutorial again
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        activeColor: AppColors.primaryGreen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) => setState(() => _dontShowAgain = val ?? true),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'عدم إظهار شاشات شرح البرنامج مرة أخرى',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation & Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button or empty space
                    if (_currentPage > 0)
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_forward_ios, size: 14),
                        label: const Text('السابق'),
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      )
                    else
                      const SizedBox(width: 60),

                    // Page Indicator Dots
                    Row(
                      children: List.generate(3, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.accentGold : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next or Finish Button
                    if (_currentPage < 2)
                      ElevatedButton(
                        onPressed: () {
                          if (_pageController.hasClients) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Row(
                          children: [
                            Text('التالي', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_back_ios, size: 12),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _finishOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ابدأ الآن 🕌', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // 1. Welcome & Noble Dedication Page
  Widget _buildDedicationAndWelcomePage() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGold.withOpacity(0.3),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(Icons.mosque, size: 68, color: AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'مرحباً بك في تطبيق نور المؤمن',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Prominent Dedication Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D3326), Color(0xFF1B4D3E), Color(0xFF285E4D)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism_rounded, color: AppColors.accentGold, size: 24),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'إهداء ودعاء مبارك 🕊️',
                      style: TextStyle(color: AppColors.softGold, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'إِهْدَاءٌ وَدُعَاءٌ عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى:\nمؤمن إبراهيم رحمهُ الله\n(الله يرحمه ويغفر له ويسكنه فسيح جناته ورضوانه)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.softGold.withOpacity(0.25)),
                ),
                child: const Column(
                  children: [
                    Text(
                      '«اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ، وَوَسِّعْ مُدْخَلَهُ، وَاغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ، وَنَقِّهِ مِنَ الذُّنُوبِ وَالْخَطَايَا كَمَا يُنَقَّى الثَّوْبُ الأَبْيَضُ مِنَ الدَّنَسِ.\n\nاللَّهُمَّ اجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ، وَافْسَحْ لَهُ فِيهِ مَدَّ بَصَرِهِ، وَآنِسْ وَحْشَتَهُ، وَاجْعَلْ كُلَّ حَرْفٍ يُتْلَى مِنْ كِتَابِكَ الكَرِيمِ نُوراً فِي قَبْرِهِ وَرِفْعَةً فِي دَرَجَاتِهِ يَوْمَ يَلْقَاكَ.. آمِينَ»',
                      style: TextStyle(
                        color: AppColors.softGold,
                        fontSize: 13,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 14, color: AppColors.accentGold),
                        SizedBox(width: 6),
                        Text(
                          'نسألكم الدعاء له بالرحمة والمغفرة 🤲',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
        const SizedBox(height: 18),

        // App Feature Highlights
        _buildFeatureRow(
          icon: Icons.menu_book,
          title: 'مصحف المدينة المنورة 604 صفحات',
          subtitle: 'تلاوة وتدبر بالرسم العثماني المعتمد، مشفوعاً بالتفسير الميسر وإعراب الآيات دون الحاجة للإنترنت.',
        ),
        const SizedBox(height: 10),
        _buildFeatureRow(
          icon: Icons.access_time_filled,
          title: 'مواقيت الصلاة والأذان والقبلة',
          subtitle: 'حساب فلكي دقيق بالمعايير الشرعية، واستوديو نداء الأذان مع بوصلة القبلة التفاعلية ثلاثية الأبعاد.',
        ),
        const SizedBox(height: 10),
        _buildFeatureRow(
          icon: Icons.block,
          title: 'مجاني تماماً وبلا إعلانات قط',
          subtitle: 'تطبيق وقفي خالص لوجه الله تعالى، خالٍ من أي إعلانات أو تعقب، يصون صفاء العبادة والخصوصية.',
        ),
      ],
    );
  }

  // 2. Personalization Page (City, Reciter, Font Size)
  Widget _buildPersonalizationPage() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'تخصيص تجربتك في التطبيق',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'يمكنك ضبط مدينتك وقارئك المفضل الآن، وتستطيع تغييرها بأي وقت من الإعدادات:',
          style: TextStyle(fontSize: 13, color: AppColors.lightText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // City Selection
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_city, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text('المدينة لمواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: PrayerService.famousCities.take(6).map((city) {
                    final isSelected = _selectedCityName == city.name;
                    return ChoiceChip(
                      label: Text(city.name, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedCityName = city.name);
                          PrayerService.instance.setManualCity(city);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Default Reciter Selection
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.record_voice_over, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text('القارئ الافتراضي للتلاوة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: SettingsService.availableReciters.any((r) => r.id == _selectedReciterId)
                      ? _selectedReciterId
                      : SettingsService.availableReciters.first.id,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: SettingsService.availableReciters.map((r) {
                    return DropdownMenuItem<String>(
                      value: r.id,
                      child: Text(r.nameAr, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedReciterId = val);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Font Size Preview
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_size, color: AppColors.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text('حجم خط المصحف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Text('${_fontSize.toInt()} نقطة', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _fontSize.clamp(18.0, 38.0),
                  min: 18.0,
                  max: 38.0,
                  divisions: 9,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (val) => setState(() => _fontSize = val),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Notifications and Readiness Page
  Widget _buildNotificationsAndReadinessPage() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const Text(
          'تنبيهات الأذان والجاهزية',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'لضمان صدح الأذان في موعده الدقيق دون أي تأخير تفرضه قيود النظام:',
          style: TextStyle(fontSize: 13, color: AppColors.lightText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Notifications Switch
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: AppColors.primaryGreen),
            title: const Text('تفعيل تنبيهات الأذان ومواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: const Text('إطلاق الأذان عند دخول وقت الفريضة', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primaryGreen,
            value: _enableNotifications,
            onChanged: (val) => setState(() => _enableNotifications = val),
          ),
        ),
        const SizedBox(height: 12),

        // Battery Reliability Recommendation Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentGold, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: AppColors.accentGold, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'تثبيت الأذان على هاتفك (شاومي، سامسونج، هواوي)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'تقوم أنظمة أندرويد الحديثة بإيقاف التطبيقات في الخلفية لتوفير البطارية. أعددنا لك دليلاً تفاعلياً سهلاً لضبط هاتفك بنقرة واحدة.',
                style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings, size: 16, color: AppColors.primaryGreen),
                label: const Text('فتح دليل إعدادات البطارية وتثبيت الأذان', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BatteryReliabilityScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Ready Button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'ابدأ استخدام تطبيق نور المؤمن 🕌',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.lightText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
