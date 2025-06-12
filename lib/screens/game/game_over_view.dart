// ===============================
//  file: lib/screens/game/game_over_view.dart
// ===============================
import 'package:flutter/material.dart';

import '../../controllers/game_contoller.dart';

class GameOverView extends StatelessWidget {
  final GameController ctrl;
  const GameOverView({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final best = ctrl.players.map((p) => p.correctAnswers).reduce((a, b) => a > b ? a : b);
    final winners = ctrl.players.where((p) => p.correctAnswers == best);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gra zakończona!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...ctrl.players.map((p) => Row(children: [
          if (winners.contains(p)) const Icon(Icons.emoji_events, color: Colors.amber),
          const SizedBox(width: 6),
          Text(
            '${p.name}: ${p.correctAnswers}/${p.answeredCount}'
                '${ctrl.tournament ? '. Punktów: ${p.points}' : ''}',
          ),
        ])),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: ctrl.reset,
          child: const Text('Zagraj ponownie'),
        )
      ],
    );
  }
}