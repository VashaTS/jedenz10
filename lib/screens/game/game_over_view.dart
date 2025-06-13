// ===============================
//  file: lib/screens/game/game_over_view.dart
// ===============================
import 'dart:math';

import 'package:flutter/material.dart';

import '../../controllers/game_contoller.dart';
import '../../models/player.dart';

class GameOverView extends StatelessWidget {
  final GameController ctrl;
  const GameOverView({super.key, required this.ctrl});

  // ────────────────────────── helpers ──────────────────────────
  List<Player> _tournamentWinners() {
    final alive = ctrl.players.where((p) => p.lives > 0).toList();

    // 1️⃣  At least one life left → last survivor wins
    if (alive.length == 1) return alive;

    // 2️⃣  40-question limit reached → most points wins
    final maxPts = ctrl.players.map((p) => p.points).reduce(max);
    return ctrl.players.where((p) => p.points == maxPts).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ───────────────── winner list ─────────────────
    final List<Player> winners = ctrl.tournament
        ? _tournamentWinners()
        : () {
      final bestCA =
      ctrl.players.map((p) => p.correctAnswers).reduce(max);
      return ctrl.players
          .where((p) => p.correctAnswers == bestCA)
          .toList();
    }();

    // ───────────────── UI ─────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gra zakończona!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...ctrl.players.map(
              (p) => Row(
            children: [
              if (winners.contains(p))
                const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                ctrl.tournament
                    ? '${p.name}: ${p.correctAnswers}/${p.answeredCount}. '
                    'Punktów: ${p.points}'
                    : '${p.name}: ${p.correctAnswers}/${p.answeredCount}',
                style: TextStyle(
                  fontWeight: winners.contains(p)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: ctrl.reset,
          child: const Text('Zagraj ponownie'),
        ),
      ],
    );
  }
}
