enum ZakatNisabBasis {
  gold, // 85 grams of pure 24k gold
  silver, // 595 grams of pure silver
}

/// Model encapsulating all inputs and calculations for Islamic Zakat (FR-ZKT)
class ZakatCalculation {
  final double cashOnHand;
  final double gold24Grams;
  final double gold21Grams;
  final double gold18Grams;
  final double silverGrams;
  final double tradeGoods;
  final double debtsReceivable;
  final double debtsPayable;
  final double goldPricePerGram24;
  final double silverPricePerGram;
  final String currency;
  final ZakatNisabBasis nisabBasis;
  final DateTime? hawlDate;

  const ZakatCalculation({
    this.cashOnHand = 0.0,
    this.gold24Grams = 0.0,
    this.gold21Grams = 0.0,
    this.gold18Grams = 0.0,
    this.silverGrams = 0.0,
    this.tradeGoods = 0.0,
    this.debtsReceivable = 0.0,
    this.debtsPayable = 0.0,
    this.goldPricePerGram24 = 3800.0,
    this.silverPricePerGram = 45.0,
    this.currency = 'ج.م',
    this.nisabBasis = ZakatNisabBasis.gold,
    this.hawlDate,
  });

  /// Total equivalent weight in pure 24-karat gold
  /// 21 karat = 21/24 pure gold, 18 karat = 18/24 pure gold
  double get totalPureGoldGrams =>
      gold24Grams + (gold21Grams * 21.0 / 24.0) + (gold18Grams * 18.0 / 24.0);

  /// Monetary value of all eligible gold
  double get goldMonetaryValue => totalPureGoldGrams * goldPricePerGram24;

  /// Monetary value of all eligible silver
  double get silverMonetaryValue => silverGrams * silverPricePerGram;

  /// Gross Zakatable Assets (إجمالي الأصول الزكوية)
  double get grossAssets =>
      cashOnHand + goldMonetaryValue + silverMonetaryValue + tradeGoods + debtsReceivable;

  /// Net Zakatable Wealth after deducting immediately due debts (وعاء الزكاة الصافي)
  double get netZakatableWealth {
    final net = grossAssets - debtsPayable;
    return net > 0 ? net : 0.0;
  }

  /// Nisab threshold value in currency based on selected basis (gold = 85g, silver = 595g)
  double get nisabThresholdValue {
    if (nisabBasis == ZakatNisabBasis.gold) {
      return 85.0 * goldPricePerGram24;
    } else {
      return 595.0 * silverPricePerGram;
    }
  }

  /// Whether net wealth reached or exceeded the Nisab threshold
  bool get isNisabReached =>
      netZakatableWealth >= nisabThresholdValue && netZakatableWealth > 0;

  /// Zakat amount due (2.5% = 1/40th of net wealth)
  double get zakatDue => isNisabReached ? (netZakatableWealth * 0.025) : 0.0;

  ZakatCalculation copyWith({
    double? cashOnHand,
    double? gold24Grams,
    double? gold21Grams,
    double? gold18Grams,
    double? silverGrams,
    double? tradeGoods,
    double? debtsReceivable,
    double? debtsPayable,
    double? goldPricePerGram24,
    double? silverPricePerGram,
    String? currency,
    ZakatNisabBasis? nisabBasis,
    DateTime? hawlDate,
    bool clearHawlDate = false,
  }) {
    return ZakatCalculation(
      cashOnHand: cashOnHand ?? this.cashOnHand,
      gold24Grams: gold24Grams ?? this.gold24Grams,
      gold21Grams: gold21Grams ?? this.gold21Grams,
      gold18Grams: gold18Grams ?? this.gold18Grams,
      silverGrams: silverGrams ?? this.silverGrams,
      tradeGoods: tradeGoods ?? this.tradeGoods,
      debtsReceivable: debtsReceivable ?? this.debtsReceivable,
      debtsPayable: debtsPayable ?? this.debtsPayable,
      goldPricePerGram24: goldPricePerGram24 ?? this.goldPricePerGram24,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
      currency: currency ?? this.currency,
      nisabBasis: nisabBasis ?? this.nisabBasis,
      hawlDate: clearHawlDate ? null : (hawlDate ?? this.hawlDate),
    );
  }

  Map<String, dynamic> toJson() => {
        'cash_on_hand': cashOnHand,
        'gold_24_grams': gold24Grams,
        'gold_21_grams': gold21Grams,
        'gold_18_grams': gold18Grams,
        'silver_grams': silverGrams,
        'trade_goods': tradeGoods,
        'debts_receivable': debtsReceivable,
        'debts_payable': debtsPayable,
        'gold_price_per_gram_24': goldPricePerGram24,
        'silver_price_per_gram': silverPricePerGram,
        'currency': currency,
        'nisab_basis': nisabBasis.name,
        'hawl_date': hawlDate?.toIso8601String(),
      };

  factory ZakatCalculation.fromJson(Map<String, dynamic> json) {
    return ZakatCalculation(
      cashOnHand: (json['cash_on_hand'] as num?)?.toDouble() ?? 0.0,
      gold24Grams: (json['gold_24_grams'] as num?)?.toDouble() ?? 0.0,
      gold21Grams: (json['gold_21_grams'] as num?)?.toDouble() ?? 0.0,
      gold18Grams: (json['gold_18_grams'] as num?)?.toDouble() ?? 0.0,
      silverGrams: (json['silver_grams'] as num?)?.toDouble() ?? 0.0,
      tradeGoods: (json['trade_goods'] as num?)?.toDouble() ?? 0.0,
      debtsReceivable: (json['debts_receivable'] as num?)?.toDouble() ?? 0.0,
      debtsPayable: (json['debts_payable'] as num?)?.toDouble() ?? 0.0,
      goldPricePerGram24: (json['gold_price_per_gram_24'] as num?)?.toDouble() ?? 3800.0,
      silverPricePerGram: (json['silver_price_per_gram'] as num?)?.toDouble() ?? 45.0,
      currency: json['currency'] as String? ?? 'ج.م',
      nisabBasis: json['nisab_basis'] == 'silver' ? ZakatNisabBasis.silver : ZakatNisabBasis.gold,
      hawlDate: json['hawl_date'] != null ? DateTime.tryParse(json['hawl_date'].toString()) : null,
    );
  }
}
