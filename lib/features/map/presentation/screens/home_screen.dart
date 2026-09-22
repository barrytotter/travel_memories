import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/core/router/app_router.gr.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/map/utils/country_helper.dart';
import 'package:travel_memories/features/map/presentation/widgets/interactive_world_map.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _countries = [];
  Set<String> _visitedCodes = {};

  @override
  void initState() {
    super.initState();
    _loadVisitedCountries();
  }

  Future<void> _loadVisitedCountries() async {
    final visited = await getIt<CountryLocalDataSource>()
        .getVisitedCountryCodes();
    if (mounted) {
      setState(() {
        _visitedCodes = visited
            .map((code) => code.toLowerCase())
            .toSet();
      });
    }
  }

  Future<void> _openCountryScreen(
    String countryCode,
  ) async {
    final isVisited = _visitedCodes.contains(countryCode);

    await context.router.push(
      CountryRoute(
        countryCode: countryCode,
        initialIsVisited: isVisited,
      ),
    );

    await _loadVisitedCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: TravelsDrawer(
        countries: _countries,
        onCountrySelect: (countryCode) {
          context.router.maybePop();
          _openCountryScreen(countryCode);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Statistics(
                  visitedCount: _visitedCodes.length,
                ),
                Expanded(
                  child: WorldMap(
                    visitedCodes: _visitedCodes,
                    onCountriesLoaded: (countries) {
                      setState(() {
                        _countries = countries;
                      });
                    },
                    onCountrySelect: (countryCode) {
                      _openCountryScreen(countryCode);
                    },
                  ),
                ),
              ],
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: _MenuButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Statistics extends StatelessWidget {
  final int visitedCount;

  const _Statistics({this.visitedCount = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 70, 10),
      child: Row(
        children: [
          _Statistic(
            value: '$visitedCount',
            label: 'countries',
          ),
          const SizedBox(width: 32),
          const _Statistic(value: '0', label: 'memories'),
        ],
      ),
    );
  }
}

class _Statistic extends StatelessWidget {
  final String value;
  final String label;

  const _Statistic({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        borderRadius: BorderRadius.circular(14),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.menu),
        ),
      ),
    );
  }
}

class TravelsDrawer extends StatelessWidget {
  final List<String> countries;
  final ValueChanged<String> onCountrySelect;

  const TravelsDrawer({
    super.key,
    required this.countries,
    required this.onCountrySelect,
  });

  @override
  Widget build(BuildContext context) {
    final sortedCountries = List<String>.from(countries)
      ..sort(
        (a, b) => CountryHelper.getNameRu(
          a,
        ).compareTo(CountryHelper.getNameRu(b)),
      );

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'Все страны',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...sortedCountries.map((code) {
            final flag = CountryHelper.getFlagEmoji(code);
            final nameRu = CountryHelper.getNameRu(code);

            return ListTile(
              leading: Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(nameRu),
              subtitle: Text(
                code,
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => onCountrySelect(code),
            );
          }),
        ],
      ),
    );
  }
}
