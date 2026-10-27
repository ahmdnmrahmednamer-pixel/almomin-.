import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'memorization_dedication_dialog.dart';

/// Top banner dedicating the Quran memorizer as ongoing charity for Momen Ibrahim (رحمه الله).
class MemorizationDedicationBanner extends StatelessWidget {
  const MemorizationDedicationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إهداء ودعاء للمرحوم مؤمن إبراهيم رحمه الله',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
                ),
                Text(
                  'اللهم اجعل القرآن الكريم نوراً له وأنيساً في قبره ورفعة لدرجاته',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.accentGold, size: 20),
            onPressed: () => showMemorizationDedicationDialog(context),
            tooltip: 'دعاء لمؤمن إبراهيم',
          ),
        ],
      ),
    );
  }
}
