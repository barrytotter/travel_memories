import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/countries/data/models/country_details_model.dart';
import 'package:travel_memories/features/countries/domain/models/country_rating.dart';
import 'package:travel_memories/features/map/utils/country_helper.dart';

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

class MemoriesGalleryWidget extends StatelessWidget {
  final String countryCode;
  final bool isVisited;

  const MemoriesGalleryWidget({
    super.key,
    required this.countryCode,
    required this.isVisited,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisited) {
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
                IconButton.filledTonal(
                  onPressed: () {
                    // TODO: Добавить логику прикрепления фото (image_picker)
                  },
                  icon: const Icon(Icons.add_a_photo),
                  tooltip: 'Добавить фото',
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
              itemCount: 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return InkWell(
                    onTap: () {
                      // TODO: Добавить фото
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(height: 4),
                          Text(
                            'Загрузить',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey,
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
  }
}
