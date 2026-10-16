import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/prayer_service.dart';
import '../prayer/battery_reliability_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../backup/backup_restore_screen.dart';
import 'contact_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showReciterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'اختر القارئ الافتراضي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: SettingsService.availableReciters.length,
                    itemBuilder: (ctx, index) {
                      final r = SettingsService.availableReciters[index];
                      final isSelected = SettingsService.instance.selectedReciterId == r.id;
                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.person_outline,
                          color: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                        ),
                        title: Text(
                          r.nameAr,
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        trailing: isSelected
                            ? const Text('محدد', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold))
                            : null,
                        onTap: () async {
                          await SettingsService.instance.setSelectedReciter(r.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم ضبط القارئ الافتراضي: ${r.nameAr}')),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFontSizePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (ctx, setLocalState) {
              final currentSize = SettingsService.instance.mushafFontSize;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'حجم خط المصحف الشريف',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: currentSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('أ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Slider(
                            value: currentSize,
                            min: 18.0,
                            max: 38.0,
                            divisions: 10,
                            activeColor: AppColors.primaryGreen,
                            inactiveColor: AppColors.accentGold.withOpacity(0.4),
                            onChanged: (val) {
                              setLocalState(() {});
                              SettingsService.instance.setMushafFontSize(val);
                            },
                          ),
                        ),
                        const Text('أ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('${currentSize.toInt()} نقطة', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mutedText)),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showMethodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'طريقة حساب مواقيت الصلاة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ...SettingsService.calculationMethods.map((m) {
                  final isSelected = SettingsService.instance.calculationMethod == m['id'];
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.accentGold : AppColors.mutedText,
                    ),
                    title: Text(m['name']!, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    onTap: () async {
                      await SettingsService.instance.setCalculationMethod(m['id']!);
                      PrayerService.instance.init();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم تعديل طريقة الحساب إلى: ${m['name']}')),
                        );
                      }
                    },
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cities = PrayerService.famousCities.where((c) {
              if (filter.isEmpty) return true;
              return c.name.contains(filter);
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'اختيار المدينة يدوياً',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مدينتك (مثل: القاهرة، مكة، دبي...)',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                        filled: true,
                        fillColor: AppColors.primaryGreen.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          filter = val.trim();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final city = cities[idx];
                          final isCurrent = PrayerService.instance.currentData?.locationName == city.name;
                          return ListTile(
                            leading: Icon(
                              Icons.location_city,
                              color: isCurrent ? AppColors.accentGold : AppColors.primaryGreen,
                            ),
                            title: Text(
                              city.name,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? AppColors.primaryGreen : null,
                              ),
                            ),
                            trailing: isCurrent
                                ? const Icon(Icons.check_circle, color: AppColors.accentGold)
                                : null,
                            onTap: () async {
                              await PrayerService.instance.setManualCity(city);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم ضبط الموقع على: ${city.name} وتحديث المواقيت'),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.mosque, color: AppColors.primaryGreen, size: 28),
              SizedBox(width: 8),
              Text('عن تطبيق المؤمن', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'صَدَقَةٌ جَارِيَةٌ عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى:\nمُؤْمِن إِبْرَاهِيم (رَحِمَهُ اللَّهُ)',
                      style: TextStyle(height: 1.5, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '«اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ، وَأَكْرِمْ نُزُلَهُ وَوَسِّعْ مُدْخَلَهُ، وَاجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ» 🤲',
                      style: TextStyle(height: 1.5, fontSize: 12, color: Color(0xFF8B6B00)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('✨ مميزات التطبيق:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
              SizedBox(height: 6),
              Text('• يعمل بدون إنترنت (Offline-First) لكامل نصوص وتفاسير القرآن ومواقيت الصلاة.'),
              Text('• خالٍ تماماً وبشكل دائم من أي إعلانات أو تتبع للبيانات.'),
              Text('• نصوص القرآن الشريف بالرسم العثماني المعتمد من مجمع الملك فهد.'),
              Text('• التفسير الميسر وإعراب الآيات مدمج بالكامل.'),
              Text('• حساب دقيق لمواقيت الصلاة والقبلة عبر نظام GPS الفعلي.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedBuilder(
          animation: SettingsService.instance,
          builder: (context, _) {
            final reciter = SettingsService.instance.currentReciter;
            final method = SettingsService.calculationMethods.firstWhere(
              (m) => m['id'] == SettingsService.instance.calculationMethod,
            );

            return ListView(
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.record_voice_over, color: AppColors.primaryGreen),
                  title: const Text('القارئ الافتراضي للتلاوة', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(reciter.nameAr, style: const TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showReciterPicker(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.format_size, color: AppColors.primaryGreen),
                  title: const Text('حجم خط المصحف الشريف', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${SettingsService.instance.mushafFontSize.toInt()} نقطة', style: const TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showFontSizePicker(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined, color: AppColors.primaryGreen),
                  title: const Text('طريقة حساب مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(method['name']!, style: const TextStyle(color: AppColors.secondaryGreen), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showMethodPicker(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city, color: AppColors.primaryGreen),
                  title: const Text('اختيار المدينة يدوياً', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(PrayerService.instance.currentData?.locationName ?? 'اختر مدينتك من قائمة المدن الشهيرة', style: const TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showCityPicker(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.my_location, color: AppColors.primaryGreen),
                  title: const Text('تحديث الموقع الجغرافي (GPS)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(PrayerService.instance.currentData?.locationName ?? 'تحديد الموقع الفعلي عبر الأقمار الصناعية'),
                  trailing: const Icon(Icons.refresh, color: AppColors.accentGold),
                  onTap: () async {
                    final ok = await PrayerService.instance.requestGpsLocation();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'تم تحديث الموقع ومواقيت الصلاة بنجاح' : (PrayerService.instance.errorMessage ?? 'تعذر التحديث')),
                          backgroundColor: ok ? AppColors.primaryGreen : Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryGreen),
                  title: const Text('تنبيهات مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('تنبيه عند دخول وقت الصلاة'),
                  activeColor: AppColors.primaryGreen,
                  value: SettingsService.instance.adhanAlertsEnabled,
                  onChanged: (val) {
                    SettingsService.instance.toggleAdhanAlerts(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bolt, color: AppColors.accentGold),
                  title: const Text('دليل تثبيت الأذان وإعدادات البطارية', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('خطوات منع إيقاف الأذان لهواتف شاومي، سامسونج، وهواوي', style: TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BatteryReliabilityScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism, color: AppColors.primaryGreen),
                  title: const Text('جولة تعريفية وإهداء التطبيق', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('صدقة جارية عن مؤمن إبراهيم رحمه الله · شاشة التهيئة الأولى', style: TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_rounded, color: AppColors.primaryGreen),
                  title: const Text('النسخ الاحتياطي والاستعادة (FR-BKM-003)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('حفظ واسترجاع العلامات المرجعية والختمة والإعدادات', style: TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen),
                  title: const Text('الدعم والتواصل مع المطور', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('إرسال اقتراح، ملاحظة، أو إبلاغ عن مشكلة بريدياً للمطور', style: TextStyle(color: AppColors.secondaryGreen)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.accentGold),
                  title: const Text('عن تطبيق المؤمن', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('صدقة جارية · مجاني تماماً · بدون إعلانات'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
