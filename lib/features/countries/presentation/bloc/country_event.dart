part of 'country_bloc.dart';

abstract class CountryEvent {}

class LoadCountryDetailsEvent extends CountryEvent {
  final String countryCode;
  final bool initialIsVisited;

  LoadCountryDetailsEvent({
    required this.countryCode,
    required this.initialIsVisited,
  });
}

class ToggleVisitedStatusEvent extends CountryEvent {
  final bool isVisited;

  ToggleVisitedStatusEvent(this.isVisited);
}

class SaveCountryRatingEvent extends CountryEvent {
  final CountryRating rating;

  SaveCountryRatingEvent(this.rating);
}
