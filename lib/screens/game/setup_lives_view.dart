// ===============================
//  file: lib/screens/setup_lives_step.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/game_contoller.dart';
import '../../models/caregory_result.dart';
import '../../repositories/question_repository.dart';
import '../category_screen.dart';

// First wizard‑like step where the user selects the number of lives and may
// open the category picker or stats / hiscore.
class SetupLivesView extends StatefulWidget {
  final GameController ctrl;
  const SetupLivesView({super.key, required this.ctrl});

  @override
  State<SetupLivesView> createState() => _SetupLivesStepState();
}

class _SetupLivesStepState extends State<SetupLivesView> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<GameController>();
    _c = TextEditingController(text: ctrl.lives.toString());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _openCategory() async {
    final repo = context.read<QuestionRepository>();
    final res = await Navigator.push<CategoryResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          allCategories: repo.allCategories,
          initialSelection: repo.selectedCategories,
          includeAI: repo.includeAI,
          counts: repo.categoryCounts,
        ),
      ),
    );

    if (res != null) {
      repo.applyCategorySelection(res.sel, res.ai);
    }
  }

  @override
  Widget build(BuildContext context) {
    // listen to repository to repaint counts once loaded / filtered
    final repo = context.watch<QuestionRepository>();
    final ctrl  = context.watch<GameController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!repo.isReady)
          const Text('Ładowanie pytań…')
        else
          Text(
            'Załadowano ${repo.availableCount} pytań (użytych ${repo.recentCount})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (repo.isReady)
              ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Kategorie'),
                onPressed: _openCategory,
              ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/hiscore'),
              child: const Text('Hiscore'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Wybierz liczbę szans:'),
        const SizedBox(height: 8),
        TextField(
          controller: _c,
          enabled: !ctrl.tournament,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'np. 3'),
          onChanged: (v) {
            final n = int.tryParse(v);
            if (n != null) ctrl.setLives(n);
          },
        ),
        const SizedBox(height: 12),
        if (!ctrl.tournament) Wrap(
          spacing: 10,
          children: List.generate(
            5,
                (i) => ElevatedButton(
              onPressed: () {
                final v = i + 2; // buttons 2‑6
                ctrl.setLives(v);
                if (ctrl.players.isEmpty) {
                  ctrl.addEmptyPlayer();
                }
                ctrl.setPhase(GamePhase.setupPlayers);
              },
              child: Text('${i + 2}'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                final v = int.tryParse(_c.text) ?? ctrl.lives;
                ctrl.setLives(v);
                if (ctrl.players.isEmpty) ctrl.addEmptyPlayer();
                ctrl.setPhase(GamePhase.setupPlayers);
              },
              child: const Text('Dalej'),
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                const Text('Turniej'),
                Switch(
                  value: ctrl.tournament,
                  onChanged: (v) {
                    ctrl.setTournament(v);             // updates lives too
                    if (v) {
                      _c.text = '3';                   // reflect in field
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}