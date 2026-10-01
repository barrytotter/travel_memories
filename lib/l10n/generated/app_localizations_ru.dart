// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String visitedCountryNoun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'страны посещены',
      many: 'стран посещено',
      few: 'страны посещены',
      one: 'страна посещена',
    );
    return '$_temp0';
  }

  @override
  String visitedCountryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страны',
      many: '$count стран',
      few: '$count страны',
      one: '$count страна',
    );
    return '$_temp0';
  }

  @override
  String topTravelers(String percentage) {
    return 'Топ ~$percentage% путешественников';
  }

  @override
  String get belowTravelersPercentile =>
      'Ориентировочно ниже ~75-го процентиля путешественников';

  @override
  String countriesOutOfTotal(int visited, int total) {
    return '$visited из $total стран';
  }

  @override
  String worldProgressPercentage(String percentage) {
    return '≈ $percentage% мира';
  }

  @override
  String visitedCountriesTeaser(int count) {
    return 'Посещённые страны • $count';
  }

  @override
  String get noVisitedCountries => 'Нет посещённых стран';

  @override
  String get unknownCountry => 'Неизвестная страна';
}
