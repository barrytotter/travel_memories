import 'package:geolocator/geolocator.dart';

class MemoryCaptureResult {
  final String imagePath;
  final DateTime createdAt;
  final Position? position;
  final String? detectedCountryIso;

  MemoryCaptureResult({
    required this.imagePath,
    required this.createdAt,
    this.position,
    this.detectedCountryIso,
  });
}
