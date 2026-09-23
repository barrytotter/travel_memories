import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/countries/data/models/country_details_model.dart';
import 'package:travel_memories/features/countries/domain/models/country_rating.dart';
import 'package:travel_memories/features/map/utils/country_helper.dart';
import 'package:travel_memories/features/memories/data/models/memory_model.dart';
import 'package:travel_memories/features/memories/data/services/memory_capture_service.dart';
import 'package:travel_memories/features/memories/presentation/widgets/create_memory_bottom_sheet.dart';

@RoutePage()
class CountryScreen extends StatefulWidget {
  final String countryCode;
  final bool initialIsVisited;

  const CountryScreen({
    super.key,
    @pathParam required this.countryCode,
    this.initialIsVisited = false,
  });

  @override
  State<CountryScreen> createState() =>
      _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  bool _isVisited = false;
  CountryRating? _rating;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isVisited = widget.initialIsVisited;
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final details = await getIt<CountryLocalDataSource>()
        .getCountryDetails(widget.countryCode);

    if (!mounted) return;

    setState(() {
      _isVisited =
          details?.isVisited ?? widget.initialIsVisited;
      _rating = details == null
          ? null
          : CountryRating(
              food: details.foodRating ?? 0,
              entertainment:
                  details.entertainmentRating ?? 0,
              nature: details.natureRating ?? 0,
              comfort: details.comfortRating ?? 0,
              price: details.priceRating ?? 0,
            );
      _isLoading = false;
    });
  }

  Future<void> _saveRating(CountryRating rating) async {
    final model = CountryDetailsModel(
      countryCode: widget.countryCode.toLowerCase(),
      isVisited: true,
      foodRating: rating.food,
      entertainmentRating: rating.entertainment,
      natureRating: rating.nature,
      comfortRating: rating.comfort,
      priceRating: rating.price,
      visitedAt: DateTime.now(),
    );

    await getIt<CountryLocalDataSource>()
        .saveCountryDetails(model);

    if (!mounted) return;

    setState(() {
      _isVisited = true;
      _rating = rating;
    });
  }

  Future<void> _toggleVisited(bool value) async {
    final dataSource = getIt<CountryLocalDataSource>();
    final existing = await dataSource.getCountryDetails(
      widget.countryCode,
    );
    final savedRating =
        _rating ??
        (existing == null
            ? CountryRating.zero()
            : CountryRating(
                food: existing.foodRating ?? 0,
                entertainment:
                    existing.entertainmentRating ?? 0,
                nature: existing.natureRating ?? 0,
                comfort: existing.comfortRating ?? 0,
                price: existing.priceRating ?? 0,
              ));

    final model = CountryDetailsModel(
      countryCode: widget.countryCode.toLowerCase(),
      isVisited: value,
      foodRating: savedRating.food,
      entertainmentRating: savedRating.entertainment,
      natureRating: savedRating.nature,
      comfortRating: savedRating.comfort,
      priceRating: savedRating.price,
      visitedAt: existing?.visitedAt ?? DateTime.now(),
    );

    await dataSource.saveCountryDetails(model);

    if (!mounted) return;

    setState(() {
      _isVisited = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flag = CountryHelper.getFlagEmoji(
      widget.countryCode,
    );
    final name = CountryHelper.getNameRu(
      widget.countryCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text('$flag $name')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '$flag ${widget.countryCode.toUpperCase()}',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Посещена'),
                    value: _isVisited,
                    onChanged: _toggleVisited,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Оценка',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _RatingCard(
                    rating: _rating ?? CountryRating.zero(),
                    onSave: _saveRating,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Воспоминания и фото',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  MemoriesGalleryWidget(
                    countryCode: widget.countryCode,
                    isVisited: _isVisited,
                  ),
                ],
              ),
            ),
    );
  }
}

class _RatingCard extends StatefulWidget {
  final CountryRating rating;
  final ValueChanged<CountryRating> onSave;

  const _RatingCard({
    required this.rating,
    required this.onSave,
  });

  @override
  State<_RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard> {
  late CountryRating _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void didUpdateWidget(covariant _RatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _rating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(
              'Еда',
              _rating.food,
              (value) => setState(
                () =>
                    _rating = _rating.copyWith(food: value),
              ),
            ),
            _field(
              'Развлечения',
              _rating.entertainment,
              (value) => setState(
                () => _rating = _rating.copyWith(
                  entertainment: value,
                ),
              ),
            ),
            _field(
              'Природа',
              _rating.nature,
              (value) => setState(
                () => _rating = _rating.copyWith(
                  nature: value,
                ),
              ),
            ),
            _field(
              'Комфорт',
              _rating.comfort,
              (value) => setState(
                () => _rating = _rating.copyWith(
                  comfort: value,
                ),
              ),
            ),
            _field(
              'Цена',
              _rating.price,
              (value) => setState(
                () => _rating = _rating.copyWith(
                  price: value,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Общая оценка'),
                Text('${_rating.overall} / 5.0'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => widget.onSave(_rating),
                child: const Text('Сохранить оценку'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(0.0, 5.0),
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 36,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(value.toStringAsFixed(1)),
            ),
          ),
        ],
      ),
    );
  }
}

enum MemorySortOption { newest, oldest, country }

class MemoriesGalleryWidget extends StatefulWidget {
  final String countryCode;
  final bool isVisited;

  const MemoriesGalleryWidget({
    super.key,
    required this.countryCode,
    required this.isVisited,
  });

  @override
  State<MemoriesGalleryWidget> createState() =>
      _MemoriesGalleryWidgetState();
}

class _MemoriesGalleryWidgetState
    extends State<MemoriesGalleryWidget> {
  MemorySortOption _sortOption = MemorySortOption.newest;

  @override
  Widget build(BuildContext context) {
    final normalizedCountryCode =
        MemoryModel.normalizeCountryIso(widget.countryCode);
    final memoryBox = getIt<Box<MemoryModel>>();

    if (!widget.isVisited) {
      return Card(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Отметьте страну как посещенную, чтобы добавлять воспоминания и фотографии',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: memoryBox.listenable(),
      builder: (context, Box<MemoryModel> box, _) {
        final memories = _sortMemories(
          box.values
              .where(
                (memory) =>
                    MemoryModel.normalizeCountryIso(
                      memory.countryIso,
                    ) ==
                    normalizedCountryCode,
              )
              .toList(),
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Галерея поездки',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        PopupMenuButton<MemorySortOption>(
                          tooltip: 'Сортировка',
                          initialValue: _sortOption,
                          onSelected: (value) {
                            setState(
                              () => _sortOption = value,
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value:
                                  MemorySortOption.newest,
                              child: Text('Сначала новые'),
                            ),
                            const PopupMenuItem(
                              value:
                                  MemorySortOption.oldest,
                              child: Text('Сначала старые'),
                            ),
                            const PopupMenuItem(
                              value:
                                  MemorySortOption.country,
                              child: Text('По стране'),
                            ),
                          ],
                          child: const Icon(Icons.sort),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () =>
                              _captureMemory(context),
                          icon: const Icon(
                            Icons.add_a_photo,
                          ),
                          tooltip: 'Добавить фото',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (memories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Text(
                      'Пока нет фото для этой страны.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: memories.length,
                    itemBuilder: (context, index) {
                      final memory = memories[index];
                      final file = File(memory.imagePath);

                      return GestureDetector(
                        onTap: () => _showMemoryDetails(
                          context,
                          memory,
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color:
                                      Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<MemoryModel> _sortMemories(
    List<MemoryModel> memories,
  ) {
    final sorted = List<MemoryModel>.from(memories);

    switch (_sortOption) {
      case MemorySortOption.newest:
        sorted.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        break;
      case MemorySortOption.oldest:
        sorted.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
        break;
      case MemorySortOption.country:
        sorted.sort(
          (a, b) => (a.countryIso ?? '').compareTo(
            b.countryIso ?? '',
          ),
        );
        break;
    }

    return sorted;
  }

  Future<void> _captureMemory(BuildContext context) async {
    final capture = await getIt<MemoryCaptureService>()
        .capture();
    if (capture == null || !context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalContext) => CreateMemoryBottomSheet(
        capture: capture,
        currentCountryIso: widget.countryCode.toUpperCase(),
        onSave: (memory) async {
          final memoryBox = getIt<Box<MemoryModel>>();
          await memoryBox.put(memory.id, memory);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Фото сохранено в галерею'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  void _showMemoryDetails(
    BuildContext context,
    MemoryModel memory,
  ) {
    final file = File(memory.imagePath);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (file.existsSync())
                SizedBox(
                  width: double.infinity,
                  height: 280,
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (memory.description.isNotEmpty)
                      Text(
                        memory.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Дата: ${memory.createdAt.toString().split('.')[0]}',
                    ),
                    if (memory.countryIso != null)
                      Text('Страна: ${memory.countryIso}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                              _showFullScreenImage(
                                context,
                                memory,
                              );
                            },
                            icon: const Icon(
                              Icons.fullscreen,
                            ),
                            label: const Text(
                              'Полный экран',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () => _deleteMemory(
                            dialogContext,
                            memory,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          tooltip: 'Удалить фото',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    MemoryModel memory,
  ) {
    final file = File(memory.imagePath);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            if (file.existsSync())
              Image.file(file, fit: BoxFit.contain)
            else
              const Center(
                child: Icon(Icons.broken_image, size: 64),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMemory(
    BuildContext dialogContext,
    MemoryModel memory,
  ) async {
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text(
          'Фотография будет удалена из галереи и с устройства.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final box = getIt<Box<MemoryModel>>();
    await box.delete(memory.id);

    final file = File(memory.imagePath);
    if (file.existsSync()) {
      await file.delete();
    }

    if (dialogContext.mounted) {
      Navigator.of(dialogContext).pop();
    }

    if (dialogContext.mounted) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(
          content: Text('Фото удалено'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
