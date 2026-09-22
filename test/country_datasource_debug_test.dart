import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/countries/data/models/country_details_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'datasource persists and reads lowercase visited codes',
    () async {
      await Hive.initFlutter();
      Hive.registerAdapter(CountryDetailsModelAdapter());
      final box = await Hive.openBox<CountryDetailsModel>(
        'debug_country_box_test',
      );
      final ds = CountryLocalDataSourceImpl(box);

      await ds.saveCountryDetails(
        CountryDetailsModel(
          countryCode: 'US',
          isVisited: true,
          foodRating: 5,
        ),
      );

      final codes = await ds.getVisitedCountryCodes();
      expect(codes, contains('us'));
      expect(await ds.getCountryDetails('US'), isNotNull);
      expect(await ds.getCountryDetails('us'), isNotNull);

      await box.close();
    },
  );
}
