import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../mushaf/page_mode_mushaf_screen.dart';
import '../../mushaf/mushaf_screen.dart';

class HomeQuranContinueCard extends StatelessWidget {
  const HomeQuranContinueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        final lastSurah = SettingsService.instance.lastReadSurahName;
        final lastAyah = SettingsService.instance.lastReadAyahNumber;
        final lastPage = SettingsService.instance.lastReadPageNumber;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PageModeMushafScreen(initialPage: lastPage),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.16),
                          AppColors.emeraldLight.withOpacity(0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('متابعة قراءة القرآن الكريم', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(
                          'آخر موضع: سورة $lastSurah (آية $lastAyah) — صفحة $lastPage',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryGreen, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.list_alt_rounded, color: AppColors.primaryGreen, size: 22),
                          tooltip: 'فهرس المصحف والأجزاء',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MushafScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGreen),
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
  }
}
