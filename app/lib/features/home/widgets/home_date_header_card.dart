import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../prayer/hijri_calendar_screen.dart';

class HomeDateHeaderCard extends StatelessWidget {
  final String dayName;
  final String hijriStr;
  final String gregStr;

  const HomeDateHeaderCard({
    super.key,
    required this.dayName,
    required this.hijriStr,
    required this.gregStr,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.softGold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      dayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gregStr,
                      style: const TextStyle(color: AppColors.softGold, fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.softGold, size: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hijriStr,
              style: const TextStyle(color: AppColors.softGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
