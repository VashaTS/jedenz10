import 'package:firebase_core/firebase_core.dart';
import 'package:jeden_z_dziesieciu/repositories/question_repository.dart';
import 'package:jeden_z_dziesieciu/screens/about_screen.dart';
import 'package:jeden_z_dziesieciu/services/app_info_service.dart';
import 'package:jeden_z_dziesieciu/services/theme_service.dart';
import 'package:jeden_z_dziesieciu/widgets/web_view_screen.dart';
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
  final appInfo = AppInfoService();
  final settings = await GameSettings.load();
  // await settings.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppInfoService>(
          create: (_) {
            final svc = AppInfoService();
            svc.init();                       // fire-and-forget
            return svc;
          },
        ),
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
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDark;

    // --- colour seeds -----------------------------------------------------
    const seed = Colors.blue;
    final lightScheme = ColorScheme.fromSeed(seedColor: seed);
    final darkScheme  = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Jeden z Dziesięciu',
      debugShowCheckedModeBanner: false,
      // Material 3 is now requested via the helpers:
      theme:     ThemeData.from( colorScheme: lightScheme, useMaterial3: true ),
      darkTheme: ThemeData.from( colorScheme: darkScheme,  useMaterial3: true ),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/':        (_) => const GameScreen(),
        '/settings':(_) => const SettingsScreen(),
        '/hiscore': (_) => const HighscoreScreen(),
        '/about':     (_) => const AboutScreen(),
        '/privacy': (_) => const WebViewScreen(
          url: 'https://vashats.github.io/jedenz10/privacypolicy.html',
        ),
      },
    );

  }
}
