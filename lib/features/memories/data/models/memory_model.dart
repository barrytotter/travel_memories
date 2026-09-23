import 'package:hive_ce/hive_ce.dart';

part 'memory_model.g.dart';

@HiveType(typeId: 2)
class MemoryModel extends HiveObject {
  static String? normalizeCountryIso(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    return trimmed.toUpperCase();
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final double? latitude;

  @HiveField(6)
  final double? longitude;

  @HiveField(7)
  final String? countryIso;

  MemoryModel({
    required this.id,
    required this.imagePath,
    required this.category,
    required this.description,
    required this.createdAt,
    this.latitude,
    this.longitude,
    String? countryIso,
  }) : countryIso = normalizeCountryIso(countryIso);
}
