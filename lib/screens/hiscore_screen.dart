// ===============================
//  file: lib/screens/highscore_screen.dart
// ===============================
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

  /// -1  → tournament bucket
  int _bucket = 3;                 // default: 3 lives
  List<HighscoreEntry> _local  = [];
  List<HighscoreEntry> _online = [];

  bool   _onlineLoading = false;
  String? _onlineError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadAll();
  }

  // ─────────────────────────── loaders ──────────────────────────────

  Future<void> _loadAll() async {
    await Future.wait([_loadLocal(), _loadOnline()]);
  }

  Future<void> _loadLocal() async {
    _local = await HighscoreService.load(_bucket);
    if (mounted) setState(() {});
  }

  Future<void> _loadOnline() async {
    setState(() {
      _onlineLoading = true;
      _onlineError   = null;
    });

    final String docId = _bucket == -1 ? 'T' : _bucket.toString();

    try {
      final qs = await FirebaseFirestore.instance
          .collection('highscore')
          .doc(docId)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      _online = qs.docs.map((d) {
        final data = d.data();
        return HighscoreEntry(
          data['name']  as String,
          data['score'] as int,
          (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      _onlineError = 'Błąd pobierania wyników';
    } finally {
      if (mounted) {
        _onlineLoading = false;
        setState(() {});
      }
    }
  }

  // ─────────────────────────── UI ───────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tablica wyników'),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [Tab(text: 'Lokalne'), Tab(text: 'Online')],
          ),
        ),
        body: Column(
          children: [
            _bucketSelector(),
            Expanded(
              child: TabBarView(
                children: [_buildList(_local), _buildOnlineTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drop-down to choose 1 – 10 lives OR “Turniej”
  Widget _bucketSelector() => Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        const Text('Kategoria:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _bucket,
          items: [
            const DropdownMenuItem(value: -1, child: Text('Turniej')),
            ...List.generate(
              10,
                  (i) => DropdownMenuItem(
                value: i + 1,
                child: Text('${i + 1} szans'),
              ),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _bucket = v);
            _loadAll();
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
    if (_onlineLoading)   return const Center(child: CircularProgressIndicator());
    if (_onlineError != null) return Center(child: Text(_onlineError!));
    return _buildList(_online);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}
