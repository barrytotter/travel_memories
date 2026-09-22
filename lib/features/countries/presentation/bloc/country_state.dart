part of 'country_bloc.dart';

abstract class CountryState {}

class CountryInitialState extends CountryState {}

class CountryLoadingState extends CountryState {}

class CountryLoadedState extends CountryState {
  final String countryCode;
  final bool isVisited;
  final CountryRating? rating;
  final DateTime? visitedAt;

  CountryLoadedState({
    required this.countryCode,
    required this.isVisited,
    this.rating,
    this.visitedAt,
  });

  CountryLoadedState copyWith({
    bool? isVisited,
    CountryRating? rating,
    DateTime? visitedAt,
  }) {
    return CountryLoadedState(
      countryCode: countryCode,
      isVisited: isVisited ?? this.isVisited,
      rating: rating ?? this.rating,
      visitedAt: visitedAt ?? this.visitedAt,
    );
  }
}

class CountryErrorState extends CountryState {
  final String message;
  CountryErrorState(this.message);
}
