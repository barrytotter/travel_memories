import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_memories/core/di/injection.dart';
import 'package:travel_memories/core/router/app_router.gr.dart';
import 'package:travel_memories/features/countries/data/datasources/country_local_datasource.dart';
import 'package:travel_memories/features/map/domain/travel_statistics.dart';
import 'package:travel_memories/features/map/presentation/widgets/interactive_world_map.dart';
import 'package:travel_memories/features/map/utils/country_helper.dart';
import 'package:travel_memories/l10n/generated/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            WorldMap(
              visitedCodes: _visitedCodes,
              onCountrySelect: (countryCode) {
                _openCountryScreen(countryCode);
              },
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 76,
              child: _Statistics(
                visitedCount: _visitedCodes.length,
              ),
            ),
            Positioned.fill(
              child: _VisitedCountriesSheet(
                countryCodes: _visitedCodes,
                onCountrySelect: _openCountryScreen,
              ),
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
    final localizations = AppLocalizations.of(context)!;
    final locale = localizations.localeName;
    final worldProgress =
        TravelStatistics.calculateWorldProgress(
          visitedCount,
        );
    final travelPercentile =
        TravelStatistics.calculateTravelPercentile(
          visitedCount,
        );
    final formattedPercentile = NumberFormat(
      travelPercentile < 1 ? '0.#' : '0',
      locale,
    ).format(travelPercentile);
    final formattedWorldProgress = NumberFormat(
      '0.#',
      locale,
    ).format(worldProgress * 100);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: localizations.visitedCountryCount(
                  visitedCount,
                ),
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$visitedCount',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        localizations.visitedCountryNoun(
                          visitedCount,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                visitedCount == 0
                    ? localizations.belowTravelersPercentile
                    : localizations.topTravelers(
                        formattedPercentile,
                      ),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: worldProgress,
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.countriesOutOfTotal(
                        visitedCount,
                        TravelStatistics.totalCountries,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.worldProgressPercentage(
                      formattedWorldProgress,
                    ),
                    maxLines: 1,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitedCountriesSheet extends StatelessWidget {
  final Set<String> countryCodes;
  final ValueChanged<String> onCountrySelect;

  const _VisitedCountriesSheet({
    required this.countryCodes,
    required this.onCountrySelect,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final sortedCountryCodes = countryCodes.toList()
      ..sort(
        (a, b) => CountryHelper.getNameRu(
          a,
        ).compareTo(CountryHelper.getNameRu(b)),
      );

    return DraggableScrollableSheet(
      initialChildSize: 0.12,
      minChildSize: 0.12,
      maxChildSize: 0.78,
      snap: true,
      snapSizes: const [0.12, 0.5, 0.78],
      builder: (context, scrollController) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 12,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          localizations
                              .visitedCountriesTeaser(
                                countryCodes.length,
                              ),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (sortedCountryCodes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      localizations.noVisitedCountries,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                    context,
                    index,
                  ) {
                    final code = sortedCountryCodes[index];
                    final name = CountryHelper.getNameRu(
                      code,
                    );
                    final displayName =
                        name.toLowerCase() == code
                        ? localizations.unknownCountry
                        : name;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                      minLeadingWidth: 48,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                        child: SizedBox(
                          width: 42,
                          height: 28,
                          child: SvgPicture.asset(
                            'assets/flags/$code.svg',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                                  context,
                                  error,
                                  stackTrace,
                                ) => ColoredBox(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Center(
                                    child: Text(
                                      CountryHelper.getFlagEmoji(
                                        code,
                                      ),
                                      style:
                                          const TextStyle(
                                            fontSize: 20,
                                          ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      title: Text(displayName),
                      onTap: () => onCountrySelect(code),
                    );
                  }, childCount: sortedCountryCodes.length),
                ),
            ],
          ),
        );
      },
    );
  }
}
