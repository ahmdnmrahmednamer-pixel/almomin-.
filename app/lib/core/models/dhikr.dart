import 'package:flutter/material.dart';

class DhikrItem {
  final int id;
  final String text;
  final int targetCount;
  final String? source;
  final String? virtue;
  int currentCount;

  DhikrItem({
    required this.id,
    required this.text,
    required this.targetCount,
    this.source,
    this.virtue,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= targetCount;
  int get remaining => (targetCount - currentCount).clamp(0, targetCount);

  void increment() {
    if (currentCount < targetCount) {
      currentCount++;
    }
  }

  void reset() {
    currentCount = 0;
  }
}

class DhikrCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final List<DhikrItem> items;

  const DhikrCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.items,
  });

  int get totalCompleted => items.where((i) => i.isCompleted).length;
  int get totalItems => items.length;
  bool get isAllCompleted => totalCompleted == totalItems && totalItems > 0;
}
