// ===============================
//  file: lib/screens/game/game_screen.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeden_z_dziesieciu/models/game_settings.dart';
import '../../controllers/game_contoller.dart';
import '../../repositories/question_repository.dart';
import 'setup_lives_view.dart';
import 'player_setup_view.dart';
import 'gameplay_view.dart';
import 'game_over_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final repo = context.watch<QuestionRepository>();
    return ChangeNotifierProvider(
      create: (_) => GameController(context.read<GameSettings>(),context.read<QuestionRepository>()),
      builder: (context, _) {
        final ctrl = context.watch<GameController>();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Jeden z dziesięciu'),
            backgroundColor: Colors.blue,
              leading: ctrl.phase == GamePhase.setupPlayers
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => ctrl.setPhase(GamePhase.setupLives),
                  )
                   : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: switch (ctrl.phase) {
              GamePhase.setupLives   => SetupLivesView(ctrl: ctrl),
              GamePhase.setupPlayers => PlayerSetupView(ctrl: ctrl),
              GamePhase.playing      => GameplayView(),
              GamePhase.finished     => GameOverView(ctrl: ctrl),
            },
          ),
        );
      },
    );
  }
}