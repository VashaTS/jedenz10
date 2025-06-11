// ===============================
//  file: lib/screens/game/gameplay_view.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/widgets/player_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/game_contoller.dart';
import '../../models/game_settings.dart';

class GameplayView extends StatelessWidget {
  // final GameController ctrl;
  const GameplayView({super.key});

  @override
  Widget build(BuildContext context) {
    // final repo = context.watch<QuestionRepository>();
    final gs   = context.watch<GameSettings>();
    final ctrl  = context.watch<GameController>();
    if (ctrl.currentQuestion == null) {
      return Column(
        children: [
          Row(
              children: [ElevatedButton(
                onPressed: ctrl.reset,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Nowa gra"),
              ),
                const SizedBox(width: 12),
                if (ctrl.LastAction != null)                     // pokaż tylko gdy jest co cofnąć
                  ElevatedButton.icon(
                    onPressed: ctrl.undoLast,
                    icon: const Icon(Icons.undo),
                    label: const Text("Zmień ost. Odp"),
                  )]
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: ctrl.players.map((p) {
                return PlayerCard(
                  player: p,
                  onTap: () {
                    if (p.lives > 0) ctrl.ask(p);
                  },
                  bgColor: p.lives == 0 ? Colors.grey : Colors.blue,
                );
              }).toList(),
            )
          )
        ]
      );
    }
    final q = ctrl.currentQuestion!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(backgroundImage: ctrl.currentPlayer!.icon),
            const SizedBox(width: 8),
            Text('Pytanie dla: ${ctrl.currentPlayer!.name}')
          ]),
          const SizedBox(height: 12),
          Text(q.category.isEmpty ? '' : 'Kategoria: ${q.category}',
              style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(q.text, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          if (gs.useTimer)
            Text('Czas: ${ctrl.remainingSeconds}s',
                style: TextStyle(
                    color: ctrl.remainingSeconds <= 3 ? Colors.red : Colors.black)),
          ElevatedButton(
            onPressed: ctrl.revealAnswer,
            child: const Text('Pokaż odpowiedź'),
          ),
          if (ctrl.showAnswer) ...[
            Text('Odpowiedź: ${q.answer}', style: const TextStyle(color: Colors.green)),
            ElevatedButton.icon(
              icon: const Icon(Icons.report),
              label: const Text('Zgłoś błąd w pytaniu'),
              onPressed: () {
                    '\nKategoria: ${q.category}';

                final body = Uri.encodeComponent(
                  'Pytanie: ${q.text}\nOdpowiedź: ${q.answer}\n\nTwoje uwagi:\n\n\n\n--\nWersja aplikacji: 1.3.0\n--',
                );

                final uri = Uri.parse(
                  'mailto:sajmon313@gmail.com'
                      '?subject=Błąd w pytaniu'
                      '&body=$body',
                );

                launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            const SizedBox(height: 12),

            // ------- POMIŃ PYTANIE -------
            ElevatedButton.icon(
              icon: const Icon(Icons.skip_next),
              label: const Text('Pomiń pytanie'),
              onPressed: ctrl.skipQuestion
            ),
          ],
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(
              onPressed: () => ctrl.answer(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Dobra'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => ctrl.answer(false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Zła'),
            ),
          ])
        ],
      ),
    );
  }
}