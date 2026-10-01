// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String visitedCountryNoun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'countries visited',
      one: 'country visited',
    );
    return '$_temp0';
  }

  @override
  String visitedCountryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '$count country',
    );
    return '$_temp0';
  }

  @override
  String topTravelers(String percentage) {
    return 'Top ~$percentage% of travelers';
  }

  @override
  String get belowTravelersPercentile =>
      'Below roughly the 75th percentile of travelers';

  @override
  String countriesOutOfTotal(int visited, int total) {
    return '$visited of $total countries';
  }

  @override
  String worldProgressPercentage(String percentage) {
    return '$percentage% of the world';
  }

  @override
  String visitedCountriesTeaser(int count) {
    return 'Visited countries • $count';
  }

  @override
  String get noVisitedCountries => 'No visited countries yet';

  @override
  String get unknownCountry => 'Unknown country';
}
