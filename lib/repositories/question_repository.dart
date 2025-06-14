// ===============================
//  file: lib/repositories/question_repository.dart
// ===============================
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:jeden_z_dziesieciu/models/game_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/question.dart';

/// Holds the entire question bank, provides random non‑repeating questions
/// respecting category filters and a recency window.

/// A factory that returns a freshly-built Question.
typedef QuestionGenerator = Question Function();
typedef QuestionItem = Object;
class QuestionRepository extends ChangeNotifier {
  final GameSettings _settings;
  QuestionRepository(this._settings);

  // raw data
  final List<Object> _all = [];
  final Queue<Object> _recent = Queue<QuestionItem>();
  final List<Object> _pool = [];

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

  // final _generators = <String, QuestionGenerator>{
  //   '{romanAmount}': _buildRomanAmount,
  //   // add more tokens → generator here
  // };
  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
  // Public API ------------------------------------------------------------
  Future<void> _tryRestoreSelection() async {
    final prefs   = await SharedPreferences.getInstance();
    final listKey = 'cat_list';
    final hashKey = 'cat_checksum';

    final stored  = prefs.getStringList(listKey);
    final storedHash = prefs.getInt(hashKey);

    if (stored != null &&
        storedHash != null &&
        _checksum(stored) == storedHash) {
      // categories didn’t change → accept
      selectedCategories = stored.toSet();
    } else {
      // categories list changed (or first launch) → keep default (all selected)
      selectedCategories = {...allCategories};
    }
  }

  Future<void> load() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/pytania_clean.csv');
    final lines = LineSplitter.split(raw);
    final lineRe = RegExp(r'^"([^"]*)";"([^"]*)"(;"([^"]*)")?$');
    _all.clear();
    final cats = <String>{};
    final counts = <String, int>{};
    for (final l in lines) {
      final m = lineRe.firstMatch(l);
      if (m == null) continue;                // pomiń wadliwy wiersz
      final q = m.group(1)!;                  // pytanie   (zawsze)
      final a = m.group(2)!;                  // odpowiedź (zawsze)
      final c = m.group(4);                   // kategoria (może być null)

      /// Parses "{token(x-y)}" pattern and returns (token, x, y) or null.
      ({String token, int Function() rand})? parseRangeToken(String s) {
        final pattern = RegExp(r'^\{([a-zA-Z_]+)\((\d+)-(\d+)\)\}$');
        final match = pattern.firstMatch(s);
        if (match == null) return null;
        final from = int.parse(match.group(2)!);
        final to   = int.parse(match.group(3)!);
        return (
        token: match.group(1)!,
        rand: () => Random().nextInt(to - from + 1) + from,
        );
      }
      final questionArrayPattern = RegExp(r"^\{questionArray\('(.*?)',\[(.*?)\],'(.*?)',\[(.*?)\]\)\}$");
      final match = questionArrayPattern.firstMatch(q);
      if (match != null) {
        final prefix = match.group(1)!; // 'Jak nazywa się dźwięk '
        final questionsRaw = match.group(2)!; // 'C','D','E'
        final suffix = match.group(3)!; // ' obniżony o pół tonu'
        final answersRaw = match.group(4)!; // 'ces','des','es'

        final questions = questionsRaw.split(',').map((s) => s.trim().replaceAll("'", '')).toList();
        final answers   = answersRaw.split(',').map((s) => s.trim().replaceAll("'", '')).toList();

        if (questions.length != answers.length) throw FormatException('questionArray: mismatched lengths');

        _all.add(() {
          final i = Random().nextInt(questions.length);
          final qPart = questions[i];
          final aPart = answers[i];
          return Question(
            '$prefix$qPart$suffix',
            aPart,
            c!,
          );
        });

        if (c!.isNotEmpty) {
          cats.add(c);
          counts[c] = (counts[c] ?? 0) + 1;
        }

        continue;
      }

      final parsed = parseRangeToken(q);
      if (parsed != null) {
        switch (parsed.token) {
          case 'generateRoman_Amount':
            _all.add(() {
              final n = parsed.rand();
              final roman = _toRoman(n);
              return Question(
                'Ilu cyfr rzymskich użyjemy do zapisania liczby $n?',
                '${roman.length} ($roman)',
                c!,
              );
            });
            break;
          case 'generateYear_Century':
            _all.add(() {
              final year = parsed.rand();
              final century = ((year - 1) ~/ 100) + 1;
              return Question(
                'Rok $year – który to wiek?',
                '${_toRoman(century)} ($century)',
                c!,
              );
            });
            break;
          case 'generateFactorial':
          _all.add(() {
            final n = parsed.rand();
            final f = List.generate(n, (i) => i + 1).fold(1, (a, b) => a * b);
            return Question(
              'Ile wynosi $n silnia?',
              '$f',
              c!,
            );
          });
          break;
          case 'biggestNatural':
            _all.add(() {
              final digitCount = parsed.rand();
              final max = int.parse('9' * digitCount);
              return Question(
                'Największa naturalna liczba $digitCount-cyfrowa to…',
                '$max',
                c!,
              );
            });
            break;
          case 'multiplyFractionsSame':
            _all.add(() {
              final d = parsed.rand();
              final result = 1 ~/ _gcd(d * d, 1); // always 1 numerator
              final simp = d * d;
              return Question(
                'Ile to jest 1/$d × 1/$d?',
                '1/$simp',
                c!,
              );
            });
            break;
          case 'power':
            _all.add(() {
              final a = parsed.rand(); // base
              final b = parsed.rand(); // exponent
              final result = pow(a, b)!.toInt();

              return Question(
                'Ile wynosi $a do potęgi $b?',
                '$result',
                c!,
              );
            });
            break;
        }

        if (c!.isNotEmpty) {
          cats.add(c);
          counts[c] = (counts[c] ?? 0) + 1;
        }

        continue;
      }
      _all.add(Question(q, a, c ?? ''));
    }

    // init categories


    for (final q in _all) {
      if (q is! Question) continue;
      if (q.category.trim().isEmpty) continue;
      cats.add(q.category);
      counts[q.category] = (counts[q.category] ?? 0) + 1;
    }
    allCategories      = cats.toList()..sort();
    _tryRestoreSelection();
    selectedCategories = {...allCategories};
    categoryCounts     = counts;
    _rebuildPool();
    _ready = true;
    notifyListeners();
  }

  // Deterministic checksum for a list of category names.
  /// (If the list contents OR their order change, the hash changes.)
  int _checksum(List<String> cats) {
    final sorted = [...cats]..sort();            // do NOT mutate the original
    return sorted.join('|').hashCode;            // ⇒ int
  }

  Question next() {
    if (_pool.isEmpty) _recycle();
    _pool.shuffle();
    final item = _pool.removeLast();
    late Question q;
    if (item is Question) {
      // normal, pre-made question
      q = item;
    } else if (item is QuestionGenerator) {
      // generate on-the-fly (need the cast so we can call it)
      q = (item as QuestionGenerator)();
    } else if (item is Function) {
      // in case the generator is a plain top-level/anon function
      q = (item as Question Function())();
    } else {
      throw StateError('Unknown item type in pool: $item');
    }

    _recent.addLast(item);
    if (_recent.length > _settings.recencyWindow) {
      _recent.removeFirst();
    }
    return q;
  }

  /// Quick converter good up to 3999
  static String _toRoman(int num) {
    const nums  = [1000,900,500,400,100,90,50,40,10,9,5,4,1];
    const romans= ['M','CM','D','CD','C','XC','L','XL','X','IX','V','IV','I'];
    var n = num;
    final sb = StringBuffer();
    for (var i=0;i<nums.length;i++){
      while(n>=nums[i]){
        sb.write(romans[i]);
        n-=nums[i];
      }
    }
    return sb.toString();
  }

  Future<void> applyCategorySelection(
      Set<String> cats,
      bool includeAIQuestions,
      ) async {
    selectedCategories = cats;
    includeAI          = includeAIQuestions;
    _rebuildPool();
    notifyListeners();

    // ── persist the new selection ───────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final listKey = 'cat_list';
    final hashKey = 'cat_checksum';

    // store the *ordered* list for later restore
    final ordered = [...cats]..sort();
    await prefs.setStringList(listKey, ordered);

    // store the checksum
    await prefs.setInt(hashKey, _checksum(ordered));
  }

  // ---------------------------------------------------------------------
  void _rebuildPool() {
    _pool
      ..clear()
      ..addAll(
        _all.where((item) {
          // keep every generator; for real questions apply category filter
          if (item is Question) return _isAllowed(item);
          return true;                     // generator closure → keep
        }),
      );

    // drop only *real* questions from _recent that are no longer allowed
    _recent.removeWhere(
          (item) => item is Question && !_isAllowed(item),
    );
  }

  bool _isAllowed(Object o) {
    // ignore anything that isn’t a plain Question
    if (o is! Question) return false;

    final q = o;                 // promoted to Question
    if (!includeAI && q.isAI) return false;
    return selectedCategories.contains(q.category);
  }

  void _recycle() {
    _pool.addAll(_recent.where(_isAllowed));
    _recent.clear();
  }
}