import 'package:flutter/material.dart';
import 'package:travel_memories/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';

class TravelMemoriesApp extends StatelessWidget {
  static final _appRouter = AppRouter();

  const TravelMemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Travel Memories',
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
