import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/game_settings.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = GameSettings();
  await settings.load();

  runApp(
    ChangeNotifierProvider<GameSettings>.value(
      value: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeden z Dziesięciu V3',
      debugShowCheckedModeBanner: false,
      routes: {
        '/':        (_) => const GameScreen(),
        '/settings':(_) => const SettingsScreen(),
      },
    );
  }
}
