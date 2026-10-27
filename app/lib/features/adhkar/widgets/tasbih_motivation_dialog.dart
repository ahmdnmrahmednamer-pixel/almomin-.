import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/adhkar_service.dart';
import '../../../core/theme/app_theme.dart';

/// Motivational celebration dialog shown when a tasbih target is achieved.
/// Includes hadith/ayah quote and dedication to Momen Ibrahim (رحمه الله).
void showTasbihMotivationDialog(BuildContext context, {VoidCallback? onDismissed}) {
  final target = AdhkarService.instance.tasbihTarget;
  final totalCount = AdhkarService.instance.tasbihCount;
  final phrase = AdhkarService.instance.selectedTasbihPhrase;
  final cyclesCompleted = target > 0 ? (totalCount ~/ target) : 1;
  final quote = AdhkarService.instance.getMotivationQuoteForCycle(cyclesCompleted);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      bool amenClicked = false;
      return StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.accentGold, width: 1.5),
              ),
              backgroundColor: isDark ? const Color(0xFF16251C) : Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Celebration Badge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.accentGold, Color(0xFFFFF2B2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        size: 44,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      'مبارك! أتممت الورد بنجاح ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تقبّل الله طاعتك وأجزل لك المثوبة والأجر 🌸',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Achievement Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'الذكر المنجز',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : AppColors.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  phrase,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 28, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'العدد المكتمل',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : AppColors.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$target تسبيحة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 28, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'الدورة',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : AppColors.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'رقم $cyclesCompleted',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Inspiring Motivation Card (Hadith / Ayah)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E3327), const Color(0xFF16251C)]
                              : [const Color(0xFFF1F8F4), const Color(0xFFE8F4EC)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.accentGold),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  quote.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quote.hadithOrAyah,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamilyFallback: const ['Traditional Arabic', 'Amiri', 'serif'],
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: isDark ? Colors.white : const Color(0xFF132A20),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quote.inspiringMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '«${quote.reference}»',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Momen Ibrahim Duaa & Dedication Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B2A20) : const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accentGold.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '«مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ»',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'اللهم تقبل منا صالح الأعمال واجعلها خالصة لوجهك الكريم وثقّل بها موازيننا',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              setDialogState(() {
                                amenClicked = true;
                              });
                              if (AdhkarService.instance.hapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: amenClicked
                                    ? AppColors.primaryGreen
                                    : AppColors.accentGold.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accentGold,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    amenClicked ? Icons.check_circle_rounded : Icons.favorite_rounded,
                                    size: 14,
                                    color: amenClicked ? Colors.white : AppColors.accentGold,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    amenClicked ? 'تقبّل الله منا ومنكم' : 'آمين يا رب العالمين 🤲',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: amenClicked ? Colors.white : (isDark ? Colors.white : AppColors.primaryGreen),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    // 1. Primary: Continue Dhikr
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text(
                          'متابعة الذكر (دورة جديدة)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 2. Secondary actions: Reset or Share
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.grey.shade400,
                              ),
                            ),
                            onPressed: () {
                              AdhkarService.instance.resetTasbih();
                              Navigator.pop(dialogCtx);
                            },
                            icon: const Icon(Icons.restart_alt, size: 16),
                            label: const Text(
                              'تصفير العداد',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: AppColors.accentGold,
                              ),
                            ),
                            onPressed: () {
                              try {
                                Share.share(
                                'أتممت بفضل الله $target تسبيحة من ذكر ($phrase) عبر تطبيق نور المؤمن.\n\n«${quote.hadithOrAyah}»\n\n— تطبيق نور المؤمن للقرآن الكريم والعبادات',
                                subject: 'تطبيق نور المؤمن - إتمام ورد التسبيح',
                              );
                              } catch (_) {}
                            },
                            icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.accentGold),
                            label: const Text(
                              'مشاركة الأجر',
                              style: TextStyle(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    onDismissed?.call();
  });
}
