// ===============================
//  file: lib/controllers/game_controller.dart
// ===============================
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jeden_z_dziesieciu/models/game_settings.dart';
import 'package:jeden_z_dziesieciu/models/highscore_entry.dart';
import 'package:jeden_z_dziesieciu/models/player.dart';
import 'package:jeden_z_dziesieciu/repositories/question_repository.dart';
import 'package:jeden_z_dziesieciu/services/highscore_service.dart';

import '../services/audio_service.dart';


/// Logical stages of the game. The UI decides which widget to show for each
/// phase. Mutate through [GameController.setPhase].
enum GamePhase { setupLives, setupPlayers, playing, finished }

class GameController extends ChangeNotifier {
  // ────────────────────────────── core state ──────────────────────────────
  GamePhase _phase = GamePhase.setupLives;
  GamePhase get phase => _phase;

  int lives;
  final List<Player> players = [];
  Player? currentPlayer;
  Question? currentQuestion;
  bool showAnswer = false;
  _LastAction? _lastAction;

  // Services & helpers
  final GameSettings _settings;
  final QuestionRepository _questions;
  final AudioService _audio;

  // Timer
  Timer? _countdown;
  int remainingSeconds = 0;

  // public accessors for UI (loading info, counts)
  bool get questionsLoaded => _questions.isReady;
  int  get availableCount   => _questions.availableCount;
  int  get recentCount      => _questions.recentCount;
  _LastAction? get LastAction => _lastAction;

  GameController(this._settings, this._questions)
      : lives = _settings.defaultLives,
        // _questions = QuestionRepository(_settings),
        _audio = AudioService(_settings);

  // ───────────────────────────── phase helpers ────────────────────────────
  void setPhase(GamePhase p) {
    _phase = p;
    notifyListeners();
  }

  // ──────────────────────────── lives setup (step‑0) ──────────────────────
  void setLives(int v) {
    if (v <= 0) return;
    lives = v;
    notifyListeners();
  }

  // Skip the current question – go back to the player grid.
  void skipQuestion() {
    _countdown?.cancel();
    currentQuestion   = null;
    showAnswer        = false;
    remainingSeconds  = 0;          // reset the timer
    notifyListeners();
  }

  // ────────────────────────── player setup (step‑1) ───────────────────────
  void addEmptyPlayer() {
    players.add(Player('', const AssetImage('assets/default_icon_new.png'), lives));
    notifyListeners();
  }

  void updatePlayer(int idx, {String? name, ImageProvider? avatar}) {
    final p = players[idx];
    players[idx] = Player(name ?? p.name, avatar ?? p.icon, p.lives,
        answeredCount: p.answeredCount, correctAnswers: p.correctAnswers);
    notifyListeners();
  }

  bool get _allPlayersNamed =>
      players.isNotEmpty && players.every((p) => p.name.trim().isNotEmpty);

  void startGame() {
    if (!_allPlayersNamed) return;
    _audio.playStart();
    setPhase(GamePhase.playing);
  }

  /// Bring the entire game back to the very first screen.
  void reset() {
    // stop timers & sounds
    _countdown?.cancel();
    _audio.stop();                       // or _audio.stop() if you add it

    // reset simple state
    lives           = _settings.defaultLives;
    players.clear();
    currentPlayer   = null;
    currentQuestion = null;
    showAnswer      = false;
    _lastAction     = null;
    remainingSeconds = 0;

    // (optional) rebuild question pool in case the user changed filters
    _questions.applyCategorySelection(
      {..._questions.allCategories},
      true,
    );

    // go back to the first phase
    setPhase(GamePhase.setupLives);
  }

  // ───────────────────────────── gameplay (step‑2) ────────────────────────
  Future<void> ask(Player player) async {
    // print('In ask function');
    if (!_questions.isReady) await _questions.load();     // just in case
    if (_questions.availableCount == 0) {
      // should never happen, but prevents a crash
      debugPrint('No questions available!');
      return;
    }
    currentPlayer = player;
    currentQuestion = _questions.next();
    showAnswer = false;

    if (_settings.useTimer) {
      _countdown?.cancel();
      remainingSeconds =
          _settings.timeSeconds + (currentQuestion!.text.length ~/ 10);
      _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
        if (remainingSeconds == 0) {
          t.cancel();
          _autoFail();
        } else {
          remainingSeconds--;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void revealAnswer() {
    showAnswer = !showAnswer;
    notifyListeners();
  }

  /// Register the player's answer outcome and advance state
  void answer(bool correct) {
    _countdown?.cancel();

    if (correct) {
      _audio.playCorrect();
      currentPlayer!.correctAnswers++;
    } else {
      _audio.playWrong();
      currentPlayer!.lives--;
    }
    currentPlayer!.answeredCount++;

    _lastAction = _LastAction(currentPlayer!, correct);
    currentQuestion = null;
    showAnswer = false;

    _checkGameOver();
    notifyListeners();
  }

  void undoLast() {
    if (_lastAction == null) return;
    final act = _lastAction!;
    if (act.wasCorrect) {
      act.player.correctAnswers--; // revert point
      act.player.lives--;          // give a life penalty
    } else {
      act.player.correctAnswers++; // restore point
      act.player.lives++;          // restore life
    }
    _lastAction = null;
    notifyListeners();
  }

  void _autoFail() => answer(false);

  // ─────────────────────────────── finish ────────────────────────────────
  void _checkGameOver() {
    if (players.every((p) => p.lives <= 0)) {
      _audio.playEnd();
      _saveHiScore();
      setPhase(GamePhase.finished);
    }
  }

  Future<void> _saveHiScore() async {
    final best = players.map((p) => p.correctAnswers).reduce(max);
    final now = DateTime.now();
    for (final p in players.where((p) => p.correctAnswers == best)) {
      await HighscoreService.add(
          lives, HighscoreEntry(p.name, p.correctAnswers, now));
      await FirebaseFirestore.instance
          .collection('highscore')
          .doc(lives.toString())
          .collection('scores')
          .add({
        'name': p.name,
        'score': p.correctAnswers,
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  // ───────────────────────────── cleanup ─────────────────────────────────
  @override
  void dispose() {
    _countdown?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

class _LastAction {
  final Player player;
  final bool wasCorrect; // true -> correct, false -> wrong
  _LastAction(this.player, this.wasCorrect);
}