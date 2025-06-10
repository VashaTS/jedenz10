import 'package:flutter/material.dart';
import '../services/highscore_service.dart';
import '../models/highscore_entry.dart';

class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  State<HighscoreScreen> createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen> {
  int _lives = 3;
  List<HighscoreEntry> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _list = await HighscoreService.load(_lives);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablica wyników'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text('Liczba żyć:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _lives,
                  items: List.generate(
                    10,
                        (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}'),
                    ),
                  ),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _lives = v);
                      _load();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: _list.isEmpty
                ? const Center(child: Text('Brak wyników 😔'))
                : ListView.separated(
              itemCount: _list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = _list[i];
                return ListTile(
                  leading: Text('#${i + 1}'),
                  title: Text(e.name),
                  trailing: Text('${e.score} pkt'),
                  subtitle: Text(
                    '${e.date.day}.${e.date.month}.${e.date.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
