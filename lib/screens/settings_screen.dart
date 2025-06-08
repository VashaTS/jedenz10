import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameSettings>();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Ustawienia'),
          backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- sound ---
          SwitchListTile(
            title: const Text('Dźwięk'),
            value: gs.soundEnabled,
            onChanged: (_) => gs.toggleSound(),
          ),
          const Divider(),

          // --- timer master switch ---
          SwitchListTile(
            title: const Text('Używaj licznika czasu'),
            value: gs.useTimer,
            onChanged: (_) => gs.toggleTimer(),
          ),

          // seconds picker – enabled only if timer ON
          ListTile(
            enabled: gs.useTimer,
            title: const Text('Czas na pytanie (sekundy)'),
            trailing: DropdownButton<int>(
              value: gs.timeSeconds,
              onChanged: gs.useTimer
                  ? (v) {
                if (v != null) gs.setTimeSeconds(v);
              }
                  : null,
              items: const [
                5, 10, 15, 20, 25, 30
              ].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
            ),
          ),

          const Divider(),

          // --- default lives ---
          Row(
            children: [
              const Text('Domyślna liczba szans:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: gs.defaultLives,
                items: List.generate(
                  10,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) gs.setDefaultLives(v);
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Text('Pytania nie powtórzą się przez:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: gs.recencyWindow,
                items: const [10, 20, 30, 50, 75, 100, 200]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) gs.setRecencyWindow(v);
                },
              ),
              const Text(' pytań'),
            ],
          ),
        ],
      ),
    );
  }
}

