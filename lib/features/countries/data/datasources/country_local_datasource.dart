import 'package:hive_ce/hive.dart';
import '../models/country_details_model.dart';

abstract class CountryLocalDataSource {
  Future<Set<String>> getVisitedCountryCodes();

  Future<CountryDetailsModel?> getCountryDetails(
    String countryCode,
  );
  Future<void> saveCountryDetails(
    CountryDetailsModel details,
  );
}

class CountryLocalDataSourceImpl
    implements CountryLocalDataSource {
  final Box<CountryDetailsModel> countryBox;

  CountryLocalDataSourceImpl(this.countryBox);

  String _normalizeCode(String countryCode) =>
      countryCode.trim().toLowerCase();

  @override
  Future<Set<String>> getVisitedCountryCodes() async {
    return countryBox.values
        .where((details) => details.isVisited)
        .map(
          (details) => _normalizeCode(details.countryCode),
        )
        .toSet();
  }

  @override
  Future<CountryDetailsModel?> getCountryDetails(
    String countryCode,
  ) async {
    return countryBox.get(_normalizeCode(countryCode));
  }

  @override
  Future<void> saveCountryDetails(
    CountryDetailsModel details,
  ) async {
    final normalized = CountryDetailsModel(
      countryCode: _normalizeCode(details.countryCode),
      isVisited: details.isVisited,
      foodRating: details.foodRating,
      entertainmentRating: details.entertainmentRating,
      natureRating: details.natureRating,
      comfortRating: details.comfortRating,
      priceRating: details.priceRating,
      visitedAt: details.visitedAt,
    );
    await countryBox.put(
      normalized.countryCode,
      normalized,
    );
  }
}
