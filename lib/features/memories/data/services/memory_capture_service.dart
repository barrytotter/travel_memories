import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:travel_memories/features/memories/data/models/memory_capture_result.dart';

class MemoryCaptureService {
  final ImagePicker _picker = ImagePicker();

  Future<MemoryCaptureResult?> capture() async {
    // 1. Открываем камеру.
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
    );

    if (photo == null) {
      return null;
    }

    final now = DateTime.now();

    final positionFuture = _getQuickPosition();

    final appDir = await getApplicationDocumentsDirectory();

    final memoriesDirectory = Directory(
      p.join(appDir.path, 'memories'),
    );

    if (!await memoriesDirectory.exists()) {
      await memoriesDirectory.create(recursive: true);
    }

    final fileName =
        'mem_${now.millisecondsSinceEpoch}.jpg';

    final targetPath = p.join(
      memoriesDirectory.path,
      fileName,
    );

    // Сжимаем и сохраняем фотографию.
    final compressed =
        await FlutterImageCompress.compressAndGetFile(
          photo.path,
          targetPath,
          quality: 80,
          format: CompressFormat.jpeg,
        );

    final savedImagePath = compressed?.path ?? photo.path;

    final position = await positionFuture;

    final detectedCountryIso = position == null
        ? null
        : await _detectCountryIso(position);

    return MemoryCaptureResult(
      imagePath: savedImagePath,
      createdAt: now,
      position: position,
      detectedCountryIso: detectedCountryIso,
    );
  }

  Future<Position?> _getQuickPosition() async {
    try {
      final isLocationEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!isLocationEnabled) {
        return null;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 3),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _detectCountryIso(
    Position position,
  ) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding
          .placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

      if (placemarks.isEmpty) {
        return null;
      }

      final isoCode = placemarks.first.isoCountryCode;

      if (isoCode == null || isoCode.trim().isEmpty) {
        return null;
      }

      return isoCode.toUpperCase();
    } catch (_) {
      // Reverse geocoding может не сработать,
      // поэтому просто оставляем страну неопределённой.
      return null;
    }
  }
}
