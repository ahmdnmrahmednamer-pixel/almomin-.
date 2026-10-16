import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التلاوات والاستماع')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.record_voice_over, color: AppColors.primaryGreen, size: 32),
                title: const Text('محمود خليل الحصري (مرتل)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('رواية حفص عن عاصم — متاح دون إنترنت بعد التحميل'),
                trailing: const Icon(Icons.play_circle_fill, color: AppColors.primaryGreen, size: 36),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.record_voice_over, color: AppColors.primaryGreen, size: 32),
                title: const Text('محمد صديق المنشاوي (مرتل)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('رواية حفص عن عاصم'),
                trailing: const Icon(Icons.play_circle_fill, color: AppColors.primaryGreen, size: 36),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
