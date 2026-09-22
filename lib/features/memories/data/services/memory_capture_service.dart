import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:travel_memories/features/memories/data/models/memory_capture_result.dart';

class MemoryCaptureService {
  final ImagePicker _picker = ImagePicker();

  Future<MemoryCaptureResult?> capture() async {
    // 1. Открываем ТОЛЬКО камеру
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      requestFullMetadata: true,
    );

    if (photo == null) {
      return null; // Пользователь отменил съемку
    }

    final now = DateTime.now();

    // 2. Параллельный запрос GPS
    final positionFuture = _getQuickPosition();

    // 3. Сохраняем фото в закрытую папку приложения
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'mem_${now.millisecondsSinceEpoch}.jpg';
    final targetPath = p.join(
      appDir.path,
      'memories',
      fileName,
    );

    final file = File(targetPath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    // 4. Сжимаем изображение для экономии памяти
    final compressed =
        await FlutterImageCompress.compressAndGetFile(
          photo.path,
          targetPath,
          quality: 80,
          format: CompressFormat.jpeg,
        );

    final position = await positionFuture;

    return MemoryCaptureResult(
      imagePath: compressed?.path ?? photo.path,
      createdAt: now,
      position: position,
    );
  }

  Future<Position?> _getQuickPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }

      LocationPermission perm =
          await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          return null;
        }
      }
      if (perm == LocationPermission.deniedForever) {
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
}
