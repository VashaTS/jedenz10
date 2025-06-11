import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/highscore_service.dart';   // local storage
import '../models/highscore_entry.dart';

class HighscoreScreen extends StatefulWidget {
  const HighscoreScreen({super.key});

  @override
  State<HighscoreScreen> createState() => _HighscoreScreenState();
}

class _HighscoreScreenState extends State<HighscoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  int _lives = 3;
  List<HighscoreEntry> _local = [];
  List<HighscoreEntry> _online = [];
  bool _onlineLoading = false;
  String? _onlineError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadLocal();
    _loadOnline();
  }

  /* ───────────────────────────────── Local ──────────────────────────────── */

  Future<void> _loadLocal() async {
    _local = await HighscoreService.load(_lives);
    if (mounted) setState(() {});
  }

  /* ──────────────────────────────── Online ─────────────────────────────── */

  Future<void> _loadOnline() async {
    setState(() {
      _onlineLoading = true;
      _onlineError   = null;
    });

    try {
      final qs = await FirebaseFirestore.instance
          .collection('highscore')
          .doc(_lives.toString())
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      _online = qs.docs
          .map((d) {
          final data = d.data();
      return HighscoreEntry(
        data['name']  as String,                         // 1-st param
        data['score'] as int,                            // 2-nd param
        (data['date'] as Timestamp?)?.toDate()           // 3-rd param
            ?? DateTime.now(),                           // fallback
      );
    })
          .toList();
    } catch (e) {
      _onlineError = 'Błąd pobierania wyników';
    } finally {
      if (mounted) {
        _onlineLoading = false;
        setState(() {});
      }
    }
  }

  /* ──────────────────────────────── Build ──────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tablica wyników'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lokalne'),
              Tab(text: 'Online'),
            ],
          ),
        ),
        body: Column(
          children: [
            _livesSelector(), // lives dropdown is shared
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(_local),
                  _buildOnlineTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ░░░░░░░░░░░░░░░░░░  Widgets  ░░░░░░░░░░░░░░░░░░ */

  Widget _livesSelector() => Padding(
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
              _loadLocal();
              _loadOnline();
            }
          },
        ),
      ],
    ),
  );

  Widget _buildList(List<HighscoreEntry> data) => data.isEmpty
      ? const Center(child: Text('Brak wyników 😔'))
      : ListView.separated(
    itemCount: data.length,
    separatorBuilder: (_, __) => const Divider(height: 1),
    itemBuilder: (_, i) {
      final e = data[i];
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
  );

  Widget _buildOnlineTab() {
    if (_onlineLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_onlineError != null) {
      return Center(child: Text(_onlineError!));
    }
    return _buildList(_online);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
