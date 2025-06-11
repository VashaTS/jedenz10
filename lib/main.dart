import 'package:firebase_core/firebase_core.dart';
import 'package:jeden_z_dziesieciu/repositories/question_repository.dart';
import 'controllers/game_contoller.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/screens/hiscore_screen.dart';
import 'package:provider/provider.dart';

import 'models/game_settings.dart';
import 'screens/game/game_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await GameSettings.load();
  // await settings.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // 0️⃣  the single, already-loaded instance
        ChangeNotifierProvider.value(value: settings),

        // 1️⃣  repository that depends on GameSettings
        ChangeNotifierProvider(
          create: (_) => QuestionRepository(settings)..load(),
        ),

        // 2️⃣  controller that needs BOTH settings & repo
        ChangeNotifierProxyProvider<QuestionRepository, GameController>(
          create: (ctx) => GameController(
            ctx.read<GameSettings>(),
            ctx.read<QuestionRepository>(),
          ),
          update: (_, __, ctrl) => ctrl!,
        ),
      ],
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
