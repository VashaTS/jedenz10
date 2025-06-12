import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_contoller.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final Color bgColor;

  const PlayerCard({super.key, required this.player, this.onTap, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final bool isTournament = context.select<GameController, bool>((c) => c.tournament);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        width: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(backgroundImage: player.icon, radius: 24),
            const SizedBox(height: 8),
            Text(
              player.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(
                player.lives,
                    (_) => Container(width: 15, height: 15, color: Colors.yellow),
              ),
            ),
            if(!isTournament) const SizedBox(height: 10),
            if(!isTournament) Text("Odp ${player.correctAnswers} / ${player.answeredCount}"),
            if(isTournament) const SizedBox(height: 10),
            if(isTournament) Text("Pkt: ${player.points}")
          ],
        ),
      ),
    );
  }
}
