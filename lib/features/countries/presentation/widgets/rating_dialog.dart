import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:travel_memories/features/countries/domain/models/country_rating.dart';

class RatingBottomSheet extends StatefulWidget {
  final String countryName;
  final CountryRating? initialRating;
  final Function(CountryRating rating) onSave;

  const RatingBottomSheet({
    super.key,
    required this.countryName,
    this.initialRating,
    required this.onSave,
  });

  @override
  State<RatingBottomSheet> createState() =>
      _RatingBottomSheetState();
}

class _RatingBottomSheetState
    extends State<RatingBottomSheet> {
  late double _food;
  late double _entertainment;
  late double _nature;
  late double _comfort;
  late double _price;

  @override
  void initState() {
    super.initState();
    _food = widget.initialRating?.food ?? 5.0;
    _entertainment =
        widget.initialRating?.entertainment ?? 5.0;
    _nature = widget.initialRating?.nature ?? 5.0;
    _comfort = widget.initialRating?.comfort ?? 5.0;
    _price = widget.initialRating?.price ?? 3.0;
  }

  double get _calculatedOverall =>
      (_food +
          _entertainment +
          _nature +
          _comfort +
          _price) /
      5.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How was ${widget.countryName}?',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStarSlider(
            '🍜 Food',
            _food,
            (v) => setState(() => _food = v),
          ),
          _buildStarSlider(
            '🎭 Entertainment',
            _entertainment,
            (v) => setState(() => _entertainment = v),
          ),
          _buildStarSlider(
            '🌿 Nature',
            _nature,
            (v) => setState(() => _nature = v),
          ),
          _buildStarSlider(
            '🏠 Comfort',
            _comfort,
            (v) => setState(() => _comfort = v),
          ),
          _buildStarSlider(
            '💰 Price availability',
            _price,
            (v) => setState(() => _price = v),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⭐ Calculated Overall:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '★ ${_calculatedOverall.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.onSave(
                  CountryRating(
                    food: _food,
                    entertainment: _entertainment,
                    nature: _nature,
                    comfort: _comfort,
                    price: _price,
                  ),
                );
                context.router.maybePop();
              },
              child: const Text(
                'SAVE RATING',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () =>
                    onChanged(starValue.toDouble()),
                child: Icon(
                  index < value
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
