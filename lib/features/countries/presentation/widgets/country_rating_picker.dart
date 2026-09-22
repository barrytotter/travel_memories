import 'package:flutter/material.dart';
import 'package:travel_memories/features/countries/domain/models/country_rating.dart';

class CountryRatingPicker extends StatefulWidget {
  final CountryRating initialRating;
  final ValueChanged<CountryRating> onRatingChanged;
  final VoidCallback? onSkip;

  const CountryRatingPicker({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    this.onSkip,
  });

  @override
  State<CountryRatingPicker> createState() =>
      _CountryRatingPickerState();
}

class _CountryRatingPickerState
    extends State<CountryRatingPicker> {
  late CountryRating _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  void _updateRating(CountryRating newRating) {
    setState(() {
      _rating = newRating;
    });
    widget.onRatingChanged(_rating);
  }

  void _handleSkip() {
    final emptyRating = CountryRating.zero();
    setState(() {
      _rating = emptyRating;
    });
    widget.onRatingChanged(emptyRating);
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRatingRow(
          emoji: '🍜',
          title: 'Еда',
          value: _rating.food,
          onChanged: (val) =>
              _updateRating(_rating.copyWith(food: val)),
        ),
        _buildRatingRow(
          emoji: '🎭',
          title: 'Развлечения',
          value: _rating.entertainment,
          onChanged: (val) => _updateRating(
            _rating.copyWith(entertainment: val),
          ),
        ),
        _buildRatingRow(
          emoji: '🌿',
          title: 'Природа',
          value: _rating.nature,
          onChanged: (val) =>
              _updateRating(_rating.copyWith(nature: val)),
        ),
        _buildRatingRow(
          emoji: '🏠',
          title: 'Комфорт',
          subtitle: 'Транспорт, интернет, чистота',
          value: _rating.comfort,
          onChanged: (val) =>
              _updateRating(_rating.copyWith(comfort: val)),
        ),
        _buildRatingRow(
          emoji: '💰',
          title: 'Цена',
          subtitle: '★ — дорого, ★★★★★ — доступно',
          value: _rating.price,
          onChanged: (val) =>
              _updateRating(_rating.copyWith(price: val)),
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '⭐ Overall:',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              _rating.overall == 0
                  ? '—'
                  : '${_rating.overall} / 5.0',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        if (widget.onSkip != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _handleSkip,
            icon: const Icon(
              Icons.forward_rounded,
              size: 18,
            ),
            label: const Text('Пропустить (оценить позже)'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingRow({
    required String emoji,
    required String title,
    String? subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StarBar(
                rating: value,
                onSelected: onChanged,
              ),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 26.0),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StarBar extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onSelected;

  const _StarBar({
    required this.rating,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () => onSelected(
            rating == starValue ? 0.0 : starValue,
          ),
          child: Icon(
            index < rating
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }
}
