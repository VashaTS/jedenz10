// ===============================
//  file: lib/screens/game/player_setup_view.dart
// ===============================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/game_contoller.dart';

class PlayerSetupView extends StatefulWidget {
  final GameController ctrl;
  const PlayerSetupView({super.key, required this.ctrl});

  @override
  State<PlayerSetupView> createState() => _PlayerSetupViewState();
}

class _PlayerSetupViewState extends State<PlayerSetupView> {
  final picker = ImagePicker();

  Future<void> _pick(int idx) async {
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    widget.ctrl.updatePlayer(idx, avatar: FileImage(File(xFile.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: widget.ctrl.players.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = widget.ctrl.players[i];
              return Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Imię gracza'),
                    onChanged: (v) => widget.ctrl.updatePlayer(i, name: v),
                  ),
                ),
                IconButton(
                  onPressed: () => _pick(i),
                  icon: CircleAvatar(backgroundImage: p.icon, radius: 20),
                ),
              ]);
            },
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () =>
                  widget.ctrl.setPhase(GamePhase.setupLives), // back to step 0
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
              child: const Text('Wróć'),
            ),
            ElevatedButton(
              onPressed: widget.ctrl.addEmptyPlayer,
              child: const Text('Dodaj gracza'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: widget.ctrl.startGame,
              child: const Text('Start gry'),
            )
          ],
        ),
      ],
    );
  }
}