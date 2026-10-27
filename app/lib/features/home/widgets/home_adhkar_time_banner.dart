import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../adhkar/adhkar_screen.dart';

class HomeAdhkarTimeBanner extends StatelessWidget {
  const HomeAdhkarTimeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isMorning = hour >= 4 && hour < 16;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdhkarScreen(initialCategoryIndex: isMorning ? 0 : 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isMorning
                  ? [const Color(0xFFD4AF37).withOpacity(0.2), const Color(0xFFE9D8A6).withOpacity(0.3)]
                  : [const Color(0xFF2C3E50).withOpacity(0.2), const Color(0xFF34495E).withOpacity(0.3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMorning ? const Color(0xFFD4AF37) : const Color(0xFF2C3E50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMorning ? 'حان وقت أذكار الصباح' : 'حان وقت أذكار المساء',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMorning
                          ? 'حصن يومك بذكر الله وانشراح الصدر والبركة'
                          : 'أمسى وأمسى الملك لله، حفظ ووقاية ليلتك',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
