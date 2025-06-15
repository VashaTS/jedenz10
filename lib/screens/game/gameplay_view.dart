// ===============================
//  file: lib/screens/game/gameplay_view.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/widgets/player_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/game_contoller.dart';
import '../../models/game_settings.dart';
import '../../services/audio_service.dart';

class GameplayView extends StatelessWidget {
  // final GameController ctrl;
  const GameplayView({super.key});

  @override
  Widget build(BuildContext context) {
    final gs   = context.watch<GameSettings>();
    final ctrl  = context.watch<GameController>();

    String tourRoundLabel(TourRound r) {
      switch (r) {
        case TourRound.finale: return 'Finał';
        case TourRound.round1: return 'Runda 1';
        case TourRound.round2: return 'Runda 2';
        default:               return '';
      }
    }

    String capitalize(String s) =>
        s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;


    // ── AUTO-ASK for tournament round-1 ────────────────────────────────
    if (ctrl.tournament &&
        ctrl.tourRound == TourRound.round1 &&
        ctrl.currentQuestion == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // use read() so we don’t trigger another rebuild
        ctrl.nextAutoQuestion();
      });
    }

    final alive            = ctrl.players.where((p) => p.lives > 0).toList();
    final distinctCounts   = alive.map((p) => p.answeredCount).toSet().toList()
      ..sort();                                   // ascending

    const Color startClr   = Colors.blue;         //  lowest answeredCount
    const Color endClr     = Color(0xFF32CD32);   //  highest answeredCount
    const int   steps      = 5;                   //  palette granularity

    final palette = List<Color>.generate(
      steps,
          (i) => Color.lerp(startClr, endClr, i / (steps - 1))!,
    );

    final Map<int, Color> countColor = {};
    for (var i = 0; i < distinctCounts.length; i++) {
      countColor[distinctCounts[i]] = palette[i % palette.length];
    }
    if (ctrl.currentQuestion == null) {
      return Column(
        children: [
          Row(
              children: [ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Nowa gra"),
                onPressed: ctrl.reset,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
                const SizedBox(width: 12),
                if (ctrl.LastAction != null && !ctrl.tournament)                     // pokaż tylko gdy jest co cofnąć
                  ElevatedButton.icon(
                    onPressed: ctrl.undoLast,
                    icon: const Icon(Icons.undo),
                    label: const Text("Zmień ost. Odp"),
                  ),
                const SizedBox(width: 12),
                if(ctrl.tournament) Text(tourRoundLabel(ctrl.tourRound)),
                const SizedBox(width: 12),
                if(ctrl.tourRound==TourRound.finale) Text('${ctrl.finaleLeft}', style: TextStyle(fontWeight: FontWeight.bold),)
              ]
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
                  bgColor: p.lives == 0
                      ? Colors.grey.shade700                         // dead → grey
                      : countColor[p.answeredCount] ?? Colors.blue,  // alive → gradient
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
            Text('Pytanie dla: ${ctrl.currentPlayer!.name}'),
            const SizedBox(width: 20),
            if(ctrl.tournament) Text(tourRoundLabel(ctrl.tourRound))
          ],
          ),
          const SizedBox(height: 12),
          Text(q.category.isEmpty ? '' : 'Kategoria: ${q.category}',
              style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(capitalize(q.text), style: const TextStyle(fontSize: 20)),
          if (q.musicAsset != null)             // ④ replay button
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Odtwórz ponownie'),
                onPressed: () => ctrl.playClip(q.musicAsset!),
              ),
            ),
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
                  'Pytanie: ${q.text}\nOdpowiedź: ${q.answer}\n\nTwoje uwagi:\n\n\n\n--\nWersja aplikacji: 1.4.0\n--',
                );

                final uri = Uri.parse(
                  'mailto:sajmon313@gmail.com'
                      '?subject=Błąd w pytaniu'
                      '&cc=kamil.wysocki101997@gmail.com'
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
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Dobra'),
              onPressed: () => ctrl.answer(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Zła'),
              onPressed: () => ctrl.answer(false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

            ),
          ])
        ],
      ),
    );
  }
}