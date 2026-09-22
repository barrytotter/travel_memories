class CountryRating {
  final double food;
  final double entertainment;
  final double nature;
  final double comfort;
  final double price;

  const CountryRating({
    this.food = 0,
    this.entertainment = 0,
    this.nature = 0,
    this.comfort = 0,
    this.price = 0,
  });

  factory CountryRating.zero() => const CountryRating();

  bool get isEmpty =>
      food == 0 &&
      entertainment == 0 &&
      nature == 0 &&
      comfort == 0 &&
      price == 0;

  bool get isNotEmpty => !isEmpty;

  double get overall {
    final values = [
      food,
      entertainment,
      nature,
      comfort,
      price,
    ];
    final filledValues = values
        .where((v) => v > 0)
        .toList();
    if (filledValues.isEmpty) return 0.0;

    final sum = filledValues.reduce((a, b) => a + b);
    return double.parse(
      (sum / filledValues.length).toStringAsFixed(1),
    );
  }

  CountryRating copyWith({
    double? food,
    double? entertainment,
    double? nature,
    double? comfort,
    double? price,
  }) {
    return CountryRating(
      food: food ?? this.food,
      entertainment: entertainment ?? this.entertainment,
      nature: nature ?? this.nature,
      comfort: comfort ?? this.comfort,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'food': food,
      'entertainment': entertainment,
      'nature': nature,
      'comfort': comfort,
      'price': price,
    };
  }

  factory CountryRating.fromMap(Map<String, dynamic> map) {
    return CountryRating(
      food: (map['food'] as num?)?.toDouble() ?? 0,
      entertainment:
          (map['entertainment'] as num?)?.toDouble() ?? 0,
      nature: (map['nature'] as num?)?.toDouble() ?? 0,
      comfort: (map['comfort'] as num?)?.toDouble() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
