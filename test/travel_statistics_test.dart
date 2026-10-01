import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_memories/features/map/domain/travel_statistics.dart';
import 'package:travel_memories/l10n/generated/app_localizations.dart';

void main() {
  group('TravelStatistics', () {
    test(
      'calculates geographic progress independently',
      () {
        expect(
          TravelStatistics.calculateWorldProgress(4),
          closeTo(4 / 195, 0.000001),
        );
        expect(
          TravelStatistics.calculateWorldProgress(195),
          1,
        );
      },
    );

    test(
      'uses the requested travel percentile anchors',
      () {
        expect(
          TravelStatistics.calculateTravelPercentile(0),
          75,
        );
        expect(
          TravelStatistics.calculateTravelPercentile(4),
          47.5,
        );
        expect(
          TravelStatistics.calculateTravelPercentile(8),
          25,
        );
        expect(
          TravelStatistics.calculateTravelPercentile(10),
          20,
        );
        expect(
          TravelStatistics.calculateTravelPercentile(195),
          0.1,
        );
      },
    );

    test(
      'interpolates values between percentile anchors',
      () {
        expect(
          TravelStatistics.calculateTravelPercentile(22),
          11.5,
        );
        expect(
          TravelStatistics.calculateTravelPercentile(23),
          11,
        );
      },
    );

    test('clamps counts outside the geographic range', () {
      expect(
        TravelStatistics.calculateWorldProgress(-2),
        0,
      );
      expect(
        TravelStatistics.calculateTravelPercentile(-2),
        75,
      );
      expect(
        TravelStatistics.calculateWorldProgress(200),
        1,
      );
      expect(
        TravelStatistics.calculateTravelPercentile(200),
        0.1,
      );
    });

    test(
      'localizes country plural forms and statistics labels',
      () {
        final russian = lookupAppLocalizations(
          const Locale('ru'),
        );
        final english = lookupAppLocalizations(
          const Locale('en'),
        );

        expect(russian.visitedCountryCount(1), '1 страна');
        expect(russian.visitedCountryCount(2), '2 страны');
        expect(russian.visitedCountryCount(5), '5 стран');
        expect(english.visitedCountryCount(1), '1 country');
        expect(
          english.visitedCountryCount(2),
          '2 countries',
        );
        expect(
          russian.topTravelers('25'),
          'Топ ~25% путешественников',
        );
        expect(
          english.topTravelers('25'),
          'Top ~25% of travelers',
        );
        expect(
          russian.countriesOutOfTotal(4, 195),
          '4 из 195 стран',
        );
        expect(
          english.countriesOutOfTotal(4, 195),
          '4 of 195 countries',
        );
        expect(
          russian.worldProgressPercentage('2,1'),
          '≈ 2,1% мира',
        );
        expect(
          english.worldProgressPercentage('2.1'),
          '2.1% of the world',
        );
      },
    );
  });
}
