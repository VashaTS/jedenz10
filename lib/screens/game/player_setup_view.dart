// ===============================
//  file: lib/screens/game/player_setup_view.dart
// ===============================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/game_contoller.dart';
import '../../widgets/nameFIeld.dart';

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
              return Row(
                  key: ValueKey('player_$i'),
                  children: [
                Expanded(
                  child: NameField(
                    key: ValueKey('name_$i'),        // keep state when list rebuilds
                    initial: p.name,
                    label: 'Gracz ${i + 1}',
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
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Dodaj'),
              onPressed: widget.ctrl.addEmptyPlayer,
            ),
            if(widget.ctrl.players.length>1) const SizedBox(width: 5),
            if(widget.ctrl.players.length>1) ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Usuń'),
              onPressed: widget.ctrl.removeLastPlayer,
            ),
            const SizedBox(width: 5),
            ElevatedButton.icon(
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Start gry'),
              onPressed: widget.ctrl.startGame,
            )
          ],
        ),
      ],
    );
  }
}