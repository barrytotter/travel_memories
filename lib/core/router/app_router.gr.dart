// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/material.dart' as _i4;
import 'package:travel_memories/features/countries/presentation/screens/country_screen.dart'
    as _i1;
import 'package:travel_memories/features/map/presentation/screens/home_screen.dart'
    as _i2;

/// generated route for
/// [_i1.CountryScreen]
class CountryRoute extends _i3.PageRouteInfo<CountryRouteArgs> {
  CountryRoute({
    _i4.Key? key,
    required String countryCode,
    bool initialIsVisited = false,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         CountryRoute.name,
         args: CountryRouteArgs(
           key: key,
           countryCode: countryCode,
           initialIsVisited: initialIsVisited,
         ),
         rawPathParams: {'countryCode': countryCode},
         initialChildren: children,
       );

  static const String name = 'CountryRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CountryRouteArgs>(
        orElse: () =>
            CountryRouteArgs(countryCode: pathParams.getString('countryCode')),
      );
      return _i1.CountryScreen(
        key: args.key,
        countryCode: args.countryCode,
        initialIsVisited: args.initialIsVisited,
      );
    },
  );
}

class CountryRouteArgs {
  const CountryRouteArgs({
    this.key,
    required this.countryCode,
    this.initialIsVisited = false,
  });

  final _i4.Key? key;

  final String countryCode;

  final bool initialIsVisited;

  @override
  String toString() {
    return 'CountryRouteArgs{key: $key, countryCode: $countryCode, initialIsVisited: $initialIsVisited}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CountryRouteArgs) return false;
    return key == other.key &&
        countryCode == other.countryCode &&
        initialIsVisited == other.initialIsVisited;
  }

  @override
  int get hashCode =>
      key.hashCode ^ countryCode.hashCode ^ initialIsVisited.hashCode;
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}
