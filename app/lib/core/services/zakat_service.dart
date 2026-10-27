import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zakat_calculation.dart';

/// Service managing Islamic Zakat calculations, persistence and Hawl reminders (FR-ZKT)
class ZakatService extends ChangeNotifier {
  static final ZakatService instance = ZakatService._internal();
  ZakatService._internal();

  static const String _storageKey = 'zakat_calculation_draft_v1';

  static const List<String> supportedCurrencies = [
    'ج.م', // Egyptian Pound
    'ر.س', // Saudi Riyal
    'د.إ', // UAE Dirham
    'د.ك', // Kuwaiti Dinar
    'ر.ق', // Qatari Riyal
    'د.ب', // Bahraini Dinar
    'ر.ع', // Omani Rial
    'د.أ', // Jordanian Dinar
    'د.ت', // Tunisian Dinar
    'د.ج', // Algerian Dinar
    'درهم', // Moroccan Dirham
    '\$', // US Dollar
    '€', // Euro
  ];

  ZakatCalculation _calculation = const ZakatCalculation();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  ZakatCalculation get calculation => _calculation;

  /// Initializes the service from persistent storage
  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(jsonStr);
        _calculation = ZakatCalculation.fromJson(data);
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('ZakatService init error: $e');
      _isInitialized = true;
    }
  }

  /// Updates and persists the current calculation draft
  Future<void> updateCalculation(ZakatCalculation calculation) async {
    _calculation = calculation;
    await _persist();
    notifyListeners();
  }

  /// Sets the Hawl reminder date
  Future<void> setHawlDate(DateTime? date) async {
    _calculation = _calculation.copyWith(hawlDate: date);
    await _persist();
    notifyListeners();
  }

  /// Resets all calculation fields to zero
  Future<void> reset() async {
    _calculation = ZakatCalculation(
      currency: _calculation.currency,
      goldPricePerGram24: _calculation.goldPricePerGram24,
      silverPricePerGram: _calculation.silverPricePerGram,
      nisabBasis: _calculation.nisabBasis,
    );
    await _persist();
    notifyListeners();
  }

  /// Exports current calculation state for backup
  Map<String, dynamic> exportData() {
    return _calculation.toJson();
  }

  /// Restores calculation state from backup
  Future<void> importData(Map<String, dynamic> data) async {
    await init();
    try {
      _calculation = ZakatCalculation.fromJson(data);
      await _persist();
      notifyListeners();
    } catch (e) {
      debugPrint('ZakatService import error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_calculation.toJson()));
    } catch (e) {
      debugPrint('ZakatService persist error: $e');
    }
  }
}
