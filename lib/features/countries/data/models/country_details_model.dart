import 'package:hive_ce/hive.dart';

part 'country_details_model.g.dart';

@HiveType(typeId: 1)
class CountryDetailsModel extends HiveObject {
  @HiveField(0)
  final String countryCode;

  @HiveField(1)
  final bool isVisited;

  @HiveField(2)
  final double? foodRating;

  @HiveField(3)
  final double? entertainmentRating;

  @HiveField(4)
  final double? natureRating;

  @HiveField(5)
  final double? comfortRating;

  @HiveField(6)
  final double? priceRating;

  @HiveField(7)
  final DateTime? visitedAt;

  CountryDetailsModel({
    required this.countryCode,
    required this.isVisited,
    this.foodRating,
    this.entertainmentRating,
    this.natureRating,
    this.comfortRating,
    this.priceRating,
    this.visitedAt,
  });
}
