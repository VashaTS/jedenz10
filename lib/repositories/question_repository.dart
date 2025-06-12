// ===============================
//  file: lib/repositories/question_repository.dart
// ===============================
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:jeden_z_dziesieciu/models/game_settings.dart';
import 'package:flutter/material.dart';

class Question {
  final String text;
  final String answer;
  final String category;
  final bool isAI;

  Question(this.text, this.answer, this.category) : isAI = text.contains('🤖');
}

/// Holds the entire question bank, provides random non‑repeating questions
/// respecting category filters and a recency window.
class QuestionRepository extends ChangeNotifier {
  final GameSettings _settings;
  QuestionRepository(this._settings);

  // raw data
  final List<Question> _all = [];
  final Queue<Question> _recent = Queue<Question>();
  final List<Question> _pool = [];

  bool _ready = false;
  bool get isReady => _ready;

  // filters
  late List<String> allCategories;
  late Map<String, int> categoryCounts;
  late Set<String> selectedCategories;
  bool includeAI = true;

  // counts for UI
  int get availableCount => _pool.length;
  int get recentCount    => _recent.length;

  // Public API ------------------------------------------------------------
  Future<void> load() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/pytania_clean.csv');
    final lines = LineSplitter.split(raw);
    final lineRe = RegExp(r'^"([^"]*)";"([^"]*)"(;"([^"]*)")?$');
    _all.clear();
    for (final l in lines) {
      final m = lineRe.firstMatch(l);
      if (m == null) continue;                // pomiń wadliwy wiersz
      final q = m.group(1)!;                  // pytanie   (zawsze)
      final a = m.group(2)!;                  // odpowiedź (zawsze)
      final c = m.group(4);                   // kategoria (może być null)

      _all.add(Question(q, a, c ?? ''));
    }
    // init categories
    final cats = <String>{};
    final counts = <String, int>{};
    for (final q in _all) {
      if (q.category.trim().isEmpty) continue;
      cats.add(q.category);
      counts[q.category] = (counts[q.category] ?? 0) + 1;
    }
    allCategories      = cats.toList()..sort();
    selectedCategories = {...allCategories};
    categoryCounts     = counts;
    _rebuildPool();
    _ready = true;
    notifyListeners();

    // just for sanity-check while debugging
    // debugPrint('Loaded ${_all.length} questions, '
    //     'pool size: ${_pool.length}, cats: ${allCategories.length}');
  }

  Question next() {
    if (_pool.isEmpty) _recycle();
    _pool.shuffle();
    final q = _pool.removeLast();

    _recent.addLast(q);
    if (_recent.length > _settings.recencyWindow) {
      _recent.removeFirst();
    }
    return q;
  }

  void applyCategorySelection(Set<String> cats, bool includeAIQuestions) {
    selectedCategories = cats;
    includeAI = includeAIQuestions;
    _rebuildPool();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  void _rebuildPool() {
    _pool
      ..clear()
      ..addAll(_all.where(_isAllowed));
    // also drop recent questions that are no longer allowed
    _recent.removeWhere((q) => !_isAllowed(q));
  }

  bool _isAllowed(Question q) {
    if (!includeAI && q.isAI) return false;
    return selectedCategories.contains(q.category);
  }

  void _recycle() {
    _pool.addAll(_recent.where(_isAllowed));
    _recent.clear();
  }
}