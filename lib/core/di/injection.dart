import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/countries/data/models/country_details_model.dart';
import 'package:travel_memories/features/countries/presentation/bloc/country_bloc.dart';
import 'package:travel_memories/features/memories/data/models/memory_model.dart';
import 'package:travel_memories/features/memories/data/services/memory_capture_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // 1. Инициализация Hive CE
  await Hive.initFlutter();

  // 2. Регистрация адаптеров
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CountryDetailsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MemoryModelAdapter());
  }

  // 3. Открытие Hive Boxes
  final countryBox =
      await Hive.openBox<CountryDetailsModel>(
        'country_details_box',
      );
  final memoryBox = await Hive.openBox<MemoryModel>(
    'memories_box',
  );

  // 4. Регистрация Boxes в GetIt
  if (!getIt.isRegistered<Box<CountryDetailsModel>>()) {
    getIt.registerSingleton<Box<CountryDetailsModel>>(
      countryBox,
    );
  }
  if (!getIt.isRegistered<Box<MemoryModel>>()) {
    getIt.registerSingleton<Box<MemoryModel>>(memoryBox);
  }

  // 5. Регистрация DataSources и Services
  if (!getIt.isRegistered<CountryLocalDataSource>()) {
    getIt.registerLazySingleton<CountryLocalDataSource>(
      () => CountryLocalDataSourceImpl(
        getIt<Box<CountryDetailsModel>>(),
      ),
    );
  }

  if (!getIt.isRegistered<MemoryCaptureService>()) {
    getIt.registerLazySingleton<MemoryCaptureService>(
      () => MemoryCaptureService(),
    );
  }

  // 6. Регистрация BLoC
  if (!getIt.isRegistered<CountryBloc>()) {
    getIt.registerFactory<CountryBloc>(
      () => CountryBloc(
        localDataSource: getIt<CountryLocalDataSource>(),
      ),
    );
  }
}
