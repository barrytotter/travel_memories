import 'package:flutter/material.dart';
import 'package:travel_memories/core/di/injection.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const TravelMemoriesApp());
}
