import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class TravelMemoriesApp extends StatelessWidget {
  static final _appRouter = AppRouter();

  const TravelMemoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Travel Memories',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
