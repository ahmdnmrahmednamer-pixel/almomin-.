import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../adhkar/adhkar_screen.dart';
import '../../adhkar/tasbih_screen.dart';

class HomeAdhkarTasbihRow extends StatelessWidget {
  const HomeAdhkarTasbihRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdhkarScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Column(
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
                      child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text('حصن المسلم', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                    const SizedBox(height: 3),
                    const Text('الأذكار والأدعية', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.mutedText)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasbihScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text('السبحة الذكية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
                    const SizedBox(height: 3),
                    const Text('عداد الورد والتسبيح', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.mutedText)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
