/// Approximate travel percentiles based on Pew Research Center's 2023 survey,
/// "How experience with international travel varies across 24 countries."
/// https://www.pewresearch.org/global/2023/12/06/international-travel/
/// The survey covered 30,861 adults in 24 countries. Its median country-level
/// figures are not a global distribution; these estimates must not be
/// presented as exact worldwide statistics.
class TravelStatistics {
  static const int totalCountries = 195;

  static const Map<int, double> _percentileAnchors = {
    1: 100, // 100% были хотя бы в 1 стране (родной)
    2: 17.0, // Выезжали в 1+ чужую страну
    3: 11.0, // В 2+ чужие страны
    4: 7.5,
    5: 5.2,
    6: 4.0, // В 5+ чужих стран
    7: 3.2,
    8: 2.6,
    9: 2.1,
    10: 1.8,
    11: 1.5, // В 10+ чужих стран
    12: 1.25,
    13: 1.05,
    14: 0.9,
    15: 0.78,
    16: 0.68,
    17: 0.59,
    18: 0.51,
    19: 0.44,
    20: 0.38,
    25: 0.22,
    30: 0.12,
    35: 0.07,
    40: 0.045,
    50: 0.025, // 50+ стран
    60: 0.015,
    75: 0.007,
    100: 0.002, // 100+ стран (~160 тыс. человек)
    125: 0.0008,
    150: 0.0003,
    175: 0.00008,
    195: 0.000006, // Все страны мира (~500 человек)
  };

  static const List<int> _anchorCounts = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    25,
    30,
    35,
    40,
    50,
    60,
    75,
    100,
    125,
    150,
    175,
    195,
  ];

  static double calculateWorldProgress(
    int visitedCountries,
  ) {
    return _boundedCountryCount(visitedCountries) /
        totalCountries;
  }

  static double calculateTravelPercentile(
    int visitedCountries,
  ) {
    final count = _boundedCountryCount(visitedCountries);
    final exactValue = _percentileAnchors[count];
    if (exactValue != null) return exactValue;

    for (
      var index = 0;
      index < _anchorCounts.length - 1;
      index++
    ) {
      final lowerCount = _anchorCounts[index];
      final upperCount = _anchorCounts[index + 1];
      if (count > lowerCount && count < upperCount) {
        final lowerPercentile =
            _percentileAnchors[lowerCount]!;
        final upperPercentile =
            _percentileAnchors[upperCount]!;
        final progress =
            (count - lowerCount) /
            (upperCount - lowerCount);
        return lowerPercentile +
            (upperPercentile - lowerPercentile) * progress;
      }
    }

    return _percentileAnchors[totalCountries]!;
  }

  static int _boundedCountryCount(int count) =>
      count.clamp(0, totalCountries);
}
