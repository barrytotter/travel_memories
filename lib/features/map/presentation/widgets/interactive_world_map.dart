import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/features/memories/data/models/memory_model.dart';
import 'package:travel_memories/features/memories/data/services/memory_capture_service.dart';
import 'package:travel_memories/features/memories/presentation/widgets/create_memory_bottom_sheet.dart';

import 'map_painter.dart';

class CountryPathModel {
  final String id;
  final String code;
  final Path path;

  CountryPathModel({
    required this.id,
    required this.code,
    required this.path,
  });
}

class WorldMap extends StatefulWidget {
  final Set<String> visitedCodes;
  final ValueChanged<String> onCountrySelect;
  final ValueChanged<List<String>>? onCountriesLoaded;

  const WorldMap({
    super.key,
    this.visitedCodes = const {},
    required this.onCountrySelect,
    this.onCountriesLoaded,
  });

  @override
  State<WorldMap> createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap>
    with SingleTickerProviderStateMixin {
  List<CountryPath> _countries = [];
  final Map<String, PictureInfo> _visitedFlags = {};
  Rect _mapBounds = Rect.zero;
  bool _isLoading = true;

  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  static const double _zoomThreshold = 2.0;
  static const double _targetZoom = 3.5;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 350),
        )..addListener(() {
          if (_animation != null) {
            _transformationController.value =
                _animation!.value;
          }
        });

    _loadSvgMap();
  }

  @override
  void didUpdateWidget(covariant WorldMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitedCodes != widget.visitedCodes) {
      _loadVisitedFlags();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    for (final flag in _visitedFlags.values) {
      flag.picture.dispose();
    }
    super.dispose();
  }

  Future<void> _loadVisitedFlags() async {
    final visitedCodes = widget.visitedCodes
        .map((code) => code.toLowerCase())
        .toSet();

    for (final code in visitedCodes) {
      if (_visitedFlags.containsKey(code)) continue;

      try {
        final svgString = await rootBundle.loadString(
          'assets/flags/$code.svg',
        );
        final pictureInfo = await vg.loadPicture(
          SvgStringLoader(svgString),
          null,
        );
        _visitedFlags[code] = pictureInfo;
      } catch (_) {}
    }

    _visitedFlags.removeWhere((code, pictureInfo) {
      if (visitedCodes.contains(code)) return false;
      pictureInfo.picture.dispose();
      return true;
    });

    if (mounted) setState(() {});
  }

  Future<void> _loadSvgMap() async {
    try {
      final svgString = await rootBundle.loadString(
        'assets/maps/world.svg',
      );
      final document = XmlDocument.parse(svgString);
      final paths = document.findAllElements('path');

      final List<CountryPath> loadedCountries = [];
      Path combinedPath = Path();

      for (var element in paths) {
        final rawId = element.getAttribute('id') ?? '';
        final pathData = element.getAttribute('d') ?? '';

        if (rawId.isNotEmpty && pathData.isNotEmpty) {
          var countryCode = rawId.toLowerCase();

          if (countryCode == 'fx' ||
              countryCode == 'fr-f' ||
              countryCode == 'gf') {
            countryCode = 'fr';
          }

          if (countryCode == 'fr') {
            final subPathRegex = RegExp(r'[Mm][^Mm]+');
            final matches = subPathRegex.allMatches(
              pathData,
            );

            int subIndex = 0;
            for (var match in matches) {
              final subData = match.group(0);
              if (subData != null &&
                  subData.trim().isNotEmpty) {
                try {
                  final path = parseSvgPathData(subData);
                  if (!path.getBounds().isEmpty) {
                    loadedCountries.add(
                      CountryPath(
                        id: '${rawId}_$subIndex',
                        code: countryCode,
                        path: path,
                      ),
                    );
                    combinedPath.addPath(path, Offset.zero);
                    subIndex++;
                  }
                } catch (_) {}
              }
            }
          } else {
            final path = parseSvgPathData(pathData);
            loadedCountries.add(
              CountryPath(
                id: rawId,
                code: countryCode,
                path: path,
              ),
            );
            combinedPath.addPath(path, Offset.zero);
          }
        }
      }

      final countryCodes =
          loadedCountries
              .map((c) => c.code)
              .toSet()
              .toList()
            ..sort();

      if (mounted) {
        setState(() {
          _countries = loadedCountries;
          _mapBounds = combinedPath.getBounds();
          _isLoading = false;
        });
      }

      await _loadVisitedFlags();
      widget.onCountriesLoaded?.call(countryCodes);
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _findCountryAtPoint(
    Offset viewportPoint,
    BoxConstraints constraints,
  ) {
    if (_mapBounds.isEmpty) return null;

    final Matrix4 inverseMatrix = Matrix4.zero();
    final double determinant = inverseMatrix.copyInverse(
      _transformationController.value,
    );

    Offset scenePoint = viewportPoint;
    if (determinant != 0.0) {
      scenePoint = MatrixUtils.transformPoint(
        inverseMatrix,
        viewportPoint,
      );
    }

    final scaleX = constraints.maxWidth / _mapBounds.width;
    final scaleY =
        constraints.maxHeight / _mapBounds.height;
    final scale = min(scaleX, scaleY);

    final dx =
        (constraints.maxWidth - _mapBounds.width * scale) /
            2 -
        _mapBounds.left * scale;
    final dy =
        (constraints.maxHeight -
                _mapBounds.height * scale) /
            2 -
        _mapBounds.top * scale;

    final svgPoint = Offset(
      (scenePoint.dx - dx) / scale,
      (scenePoint.dy - dy) / scale,
    );

    for (var country in _countries.reversed) {
      if (country.path.contains(svgPoint)) {
        return country.code;
      }
    }
    return null;
  }

  void _handleTap(
    TapDownDetails details,
    BoxConstraints constraints,
  ) {
    final currentScale = _transformationController.value
        .getMaxScaleOnAxis();
    final tappedCountryCode = _findCountryAtPoint(
      details.localPosition,
      constraints,
    );

    if (currentScale >= _zoomThreshold) {
      if (tappedCountryCode != null) {
        widget.onCountrySelect(tappedCountryCode);
      }
      return;
    }

    if (tappedCountryCode != null) {
      _zoomToPoint(details.localPosition);
    }
  }

  void _zoomToPoint(Offset position) {
    final Matrix4 currentMatrix =
        _transformationController.value;
    final double x = -position.dx * (_targetZoom - 1);
    final double y = -position.dy * (_targetZoom - 1);

    final Matrix4 endMatrix = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(
        _targetZoom,
        _targetZoom,
        _targetZoom,
        1,
      );

    _animation =
        Matrix4Tween(
          begin: currentMatrix,
          end: endMatrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward(from: 0);
  }

  void _resetZoom() {
    _animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: Matrix4.identity(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward(from: 0);
  }

  Future<void> _handleCaptureMemory() async {
    final captureService = getIt<MemoryCaptureService>();
    final result = await captureService.capture();

    if (result == null || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (modalContext) => CreateMemoryBottomSheet(
        capture: result,
        onSave: (memory) async {
          final memoryBox = getIt<Box<MemoryModel>>();
          await memoryBox.put(memory.id, memory);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Memory saved!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            GestureDetector(
              onTapDown: (details) =>
                  _handleTap(details, constraints),
              child: InteractiveViewer(
                transformationController:
                    _transformationController,
                minScale: 1.0,
                maxScale: 6.0,
                child: CustomPaint(
                  size: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                  painter: MapPainter(
                    countries: _countries,
                    mapBounds: _mapBounds,
                    visitedFlags: Map.from(_visitedFlags),
                  ),
                ),
              ),
            ),

            // Кнопка сброса зума (слева внизу)
            ValueListenableBuilder<Matrix4>(
              valueListenable: _transformationController,
              builder: (context, matrix, child) {
                final isZoomed =
                    matrix.getMaxScaleOnAxis() > 1.2;
                if (!isZoomed) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'reset_zoom_map_fab',
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                    onPressed: _resetZoom,
                    child: const Icon(Icons.zoom_out_map),
                  ),
                );
              },
            ),

            // Кнопка моментального сохранения снимка/воспоминания (справа внизу)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'add_memory_map_fab',
                onPressed: _handleCaptureMemory,
                child: const Icon(Icons.add_a_photo),
              ),
            ),
          ],
        );
      },
    );
  }
}
