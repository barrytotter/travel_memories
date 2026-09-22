import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_memories/features/countries/domain/models/country_rating.dart';
import '../../data/datasources/country_local_datasource.dart';
import '../../data/models/country_details_model.dart';

part 'country_event.dart';
part 'country_state.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  final CountryLocalDataSource localDataSource;

  CountryBloc({required this.localDataSource})
    : super(CountryInitialState()) {
    on<LoadCountryDetailsEvent>(_onLoadDetails);
    on<ToggleVisitedStatusEvent>(_onToggleVisited);
    on<SaveCountryRatingEvent>(_onSaveRating);
  }

  Future<void> _onLoadDetails(
    LoadCountryDetailsEvent event,
    Emitter<CountryState> emit,
  ) async {
    emit(CountryLoadingState());
    try {
      final savedData = await localDataSource
          .getCountryDetails(event.countryCode);

      if (savedData != null) {
        emit(
          CountryLoadedState(
            countryCode: event.countryCode,
            isVisited: savedData.isVisited,
            rating: CountryRating(
              food: savedData.foodRating ?? 5.0,
              entertainment:
                  savedData.entertainmentRating ?? 5.0,
              nature: savedData.natureRating ?? 5.0,
              comfort: savedData.comfortRating ?? 5.0,
              price: savedData.priceRating ?? 3.0,
            ),
            visitedAt: savedData.visitedAt,
          ),
        );
      } else {
        emit(
          CountryLoadedState(
            countryCode: event.countryCode,
            isVisited: event.initialIsVisited,
          ),
        );
      }
    } catch (e) {
      emit(
        CountryErrorState(
          'Failed to load country details: $e',
        ),
      );
    }
  }

  Future<void> _onToggleVisited(
    ToggleVisitedStatusEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is CountryLoadedState) {
      final currentState = state as CountryLoadedState;
      final updatedState = currentState.copyWith(
        isVisited: event.isVisited,
      );
      emit(updatedState);

      await _persist(updatedState);
    }
  }

  Future<void> _onSaveRating(
    SaveCountryRatingEvent event,
    Emitter<CountryState> emit,
  ) async {
    if (state is CountryLoadedState) {
      final currentState = state as CountryLoadedState;
      final updatedState = currentState.copyWith(
        rating: event.rating,
        isVisited:
            true, // При добавлении рейтинга отмечаем страну как посещенную
      );
      emit(updatedState);

      await _persist(updatedState);
    }
  }

  Future<void> _persist(CountryLoadedState state) async {
    final model = CountryDetailsModel(
      countryCode: state.countryCode,
      isVisited: state.isVisited,
      foodRating: state.rating?.food,
      entertainmentRating: state.rating?.entertainment,
      natureRating: state.rating?.nature,
      comfortRating: state.rating?.comfort,
      priceRating: state.rating?.price,
      visitedAt: state.visitedAt ?? DateTime.now(),
    );
    await localDataSource.saveCountryDetails(model);
  }
}
