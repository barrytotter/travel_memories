import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';

class CountryPath {
  final String id;
  final String code;
  final Path path;

  CountryPath({
    required this.id,
    required this.code,
    required this.path,
  });
}

class MapPainter extends CustomPainter {
  final List<CountryPath> countries;
  final Rect mapBounds;
  final Map<String, PictureInfo> visitedFlags;

  MapPainter({
    required this.countries,
    required this.mapBounds,
    required this.visitedFlags,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mapBounds.isEmpty) return;

    final scaleX = size.width / mapBounds.width;
    final scaleY = size.height / mapBounds.height;
    final scale = min(scaleX, scaleY);

    final dx =
        (size.width - mapBounds.width * scale) / 2 -
        mapBounds.left * scale;
    final dy =
        (size.height - mapBounds.height * scale) / 2 -
        mapBounds.top * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final basePaint = Paint()
      ..color = Colors.blueGrey.shade200
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    for (final country in countries) {
      final flagPicture =
          visitedFlags[country.code.toLowerCase()];

      if (flagPicture == null) {
        canvas.drawPath(country.path, basePaint);
      } else {
        canvas.save();
        canvas.clipPath(country.path);

        final destination = country.path.getBounds();
        canvas.translate(destination.left, destination.top);
        canvas.scale(
          destination.width / flagPicture.size.width,
          destination.height / flagPicture.size.height,
        );
        canvas.drawPicture(flagPicture.picture);
        canvas.restore();
      }

      canvas.drawPath(
        country.path,
        borderPaint..strokeWidth = 0.5 / scale,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) =>
      oldDelegate.mapBounds != mapBounds ||
      oldDelegate.countries != countries ||
      oldDelegate.visitedFlags != visitedFlags;
}
