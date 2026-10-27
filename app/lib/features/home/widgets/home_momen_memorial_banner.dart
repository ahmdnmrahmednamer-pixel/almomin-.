import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../momen_duaa_screen.dart';

class HomeMomenMemorialBanner extends StatelessWidget {
  const HomeMomenMemorialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MomenDuaaScreen(isFromInsideApp: true),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF072D1E), Color(0xFF0F4E37), Color(0xFF072D1E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accentGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGold.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism_rounded, size: 18, color: AppColors.accentGold),
            SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'صدقة جارية عن روح المرحوم بإذن الله: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFE680),
                      ),
                    ),
                    TextSpan(
                      text: 'مؤمن إبراهيم رحمهُ الله',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    TextSpan(
                      text: ' (الله يرحمه) 🤲 (اضغط للدعاء)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFE680),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
