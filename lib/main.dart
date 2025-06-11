import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/screens/hiscore_screen.dart';
import 'package:provider/provider.dart';

import 'models/game_settings.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = GameSettings();
  await settings.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/hiscore': (_) => const HighscoreScreen(),
      },
    );
  }
}
