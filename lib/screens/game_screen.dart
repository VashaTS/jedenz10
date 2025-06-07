import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/game_settings.dart';
import '../models/player.dart';
import '../widgets/player_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int numberOfLives = 3;
  List<Player> players = [];
  Player? currentPlayer;
  List<List<String>> questions = [];
  List<String>? currentQuestion;
  bool showAnswer = false;
  int timer = 0;
  Timer? countdownTimer;
  String statusMessage = "";
  /// Questions that may be drawn right now
  late List<List<String>> availableQuestions;
  /// FIFO buffer of the last N questions that are on “cool-down”
  final Queue<List<String>> recentQuestions = Queue<List<String>>();
  /// How many recent questions to hold back
  // static const int recencyWindow = 10;
  final TextEditingController _livesController = TextEditingController();
  final List<TextEditingController> playerControllers = [];
  final List<ImageProvider> playerIcons = [];
  int step = 0; // 0: wybór szans, 1: dodawanie graczy, 2: gra, 3: koniec gry
  late final AudioPlayer _player;
  // int _turnIndex = 0;

  void _resetToSetup() {
    final gs = context.read<GameSettings>();
    numberOfLives = gs.defaultLives;
    _livesController.text = numberOfLives.toString();
    setState(() {
      step = 0;
      players.clear();
      currentPlayer = null;
      currentQuestion = null;
      countdownTimer?.cancel();
      timer = 0;
      for (final c in playerControllers) c.dispose();
      playerControllers.clear();
      playerIcons.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    final gs = context.read<GameSettings>();
    numberOfLives = gs.defaultLives;
    loadCSV();
    _livesController.text = numberOfLives.toString();
    _player = AudioPlayer();
  }

  Future<void> loadCSV() async {
    final raw = await rootBundle.loadString('assets/pytania_clean.csv');
    final lines = LineSplitter().convert(raw);

    final all = lines
        .map((l) {
      // "Pytanie";"Odpowiedź"
      if (!l.startsWith('"') || !l.endsWith('"')) return null;
      final parts = l.split('";"');
      if (parts.length != 2) return null;
      final q = parts[0].substring(1);                   // drop opening "
      final a = parts[1].substring(0, parts[1].length-1); // drop closing "
      return [q, a];
    })
        .whereType<List<String>>()
        .toList();

    setState(() {
      questions = all;              // keep original for reference (optional)
      availableQuestions = [...all]; // working pool
    });
  }



  void startQuestion(Player player) {
    final gs = context.read<GameSettings>();
    if (availableQuestions.isEmpty && recentQuestions.isEmpty) return;

    // If the working pool is empty, recycle the cold ones
    if (availableQuestions.isEmpty) {
      availableQuestions = recentQuestions.toList();
      recentQuestions.clear();
    }

    // Pull a random question that is *not* in the cooldown buffer
    availableQuestions.shuffle();
    final nextQ = availableQuestions.removeLast();

    // Add it to the cooldown queue
    recentQuestions.addLast(nextQ);
    if (recentQuestions.length > gs.recencyWindow) {
      // release the oldest question back into circulation
      availableQuestions.add(recentQuestions.removeFirst());
    }

    // Standard bookkeeping
    setState(() {
      currentPlayer = player;
      currentQuestion = nextQ;
      showAnswer = false;
      // timer = 10 + (currentQuestion![0].length ~/ 10);
      statusMessage = "";
    });

    // start / reset countdown
    if (gs.useTimer) {
      timer = gs.timeSeconds+(currentQuestion![0].length ~/ 10);
      // start / reset countdown
      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (timer > 0) {
            timer--;
          } else {
            countdownTimer?.cancel();
            statusMessage = "Czas minął!";
          }
        });
      });
    } else {
      // timer disabled
      countdownTimer?.cancel();
      timer = 0;
    }
  }


  void checkGameOver() {
    if (players.every((p) => p.lives <= 0)) {
      setState(() {
        step = 3;
      });
    }
  }
  // void _advanceTurn() {
  //   if (players.where((p) => p.lives > 0).isEmpty) return;
  //
  //   do {
  //     _turnIndex = (_turnIndex + 1) % players.length;
  //   } while (players[_turnIndex].lives == 0);
  //
  //   startQuestion(players[_turnIndex]);
  // }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        playerIcons[index] = FileImage(File(pickedFile.path));
      });
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    for (var c in playerControllers) c.dispose();
    _livesController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int maxCorrect = players.isNotEmpty
        ? players.map((p) => p.correctAnswers).reduce(max)
        : 0;

    final Set<Player> winners =
    players.where((p) => p.correctAnswers == maxCorrect).toSet();
    final alive = players.where((p) => p.lives > 0).toList();
    final distinctCounts = alive.map((p) => p.answeredCount).toSet().toList()
      ..sort();                        // rosnąco
    final Color end = const Color(0xFF32CD32);  // limegreen
    final Color start   = Colors.blue;  // blue600

    const int steps = 5;
    final palette = List<Color>.generate(
      steps,
          (i) => Color.lerp(start, end, i / (steps - 1))!,
    );

    final Map<int, Color> countColor = {};
    for (var i = 0; i < distinctCounts.length; i++) {
      countColor[distinctCounts[i]] = palette[i % palette.length];
    }
    final gs = context.read<GameSettings>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Jeden z dziesięciu V3"),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: step == 0
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (questions.isEmpty)
              const Text("Ładowanie pytań…")
            else
              Text("Załadowano ${questions.length} pytań",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            const Text("Wybierz liczbę szans:"),
            TextField(
              controller: _livesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "np. 3",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) {
                final v = int.tryParse(value);
                if (v != null && v > 0) {
                  setState(() => numberOfLives = v);
                }
              },
            ),
            const SizedBox(height: 8),

            // szybkie przyciski 2-6
            Wrap(
              spacing: 10,
              children: List.generate(
                5,
                    (i) => ElevatedButton(
                  onPressed: () {
                    final v = i + 2;
                    setState(() {
                      numberOfLives = v;
                      _livesController.text = v.toString(); // nadpisz pole
                      // od razu przejdź dalej — tak jak wcześniej
                      step = 1;
                      playerControllers.add(TextEditingController());
                      playerIcons.add(
                        const AssetImage('assets/default_icon_new.png'),
                      );
                    });
                  },
                  child: Text("${i + 2}"),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // ręczne potwierdzenie dla wartości wpisanej z klawiatury
            ElevatedButton(
              onPressed: () {
                final v = int.tryParse(_livesController.text) ?? 0;
                if (v <= 0) return; // opcjonalnie pokaż snackbar/alert
                setState(() {
                  numberOfLives = v;
                  step = 1;
                  playerControllers.add(TextEditingController());
                  playerIcons.add(
                    const AssetImage('assets/default_icon_new.png'),
                  );
                });
              },
              child: const Text("Dalej"),
            ),
          ],
        )
            : step == 1
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Wprowadź imiona graczy i wybierz piktogramy:"),
            Expanded(
              child: ListView.builder(
                itemCount: playerControllers.length,
                itemBuilder: (context, index) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: playerControllers[index],
                        decoration: InputDecoration(
                          labelText: "Gracz ${index + 1}",
                          errorText: playerControllers[index].text.trim().isEmpty ? 'Imię wymagane' : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: CircleAvatar(backgroundImage: playerIcons[index], radius: 20),
                      onPressed: () => pickImage(index),
                    )
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(                        // ⬅ nowy przycisk
                  onPressed: _resetToSetup,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text("Wróć"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      playerControllers.add(TextEditingController());
                      playerIcons.add(const AssetImage('assets/default_icon_new.png'));
                    });
                  },
                  child: const Text("Dodaj gracza"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: playerControllers.any((c) => c.text.trim().isEmpty)
                      ? null
                      : () {
                    players = List.generate(
                      playerControllers.length,
                          (i) => Player(
                        playerControllers[i].text.trim(),
                        playerIcons[i],
                        numberOfLives,
                      ),
                    );
                    // _turnIndex = 0;
                    // startQuestion(players[0]);
                    _player.play(AssetSource('start.mp3'));
                    setState(() => step = 2);
                  },
                  child: const Text("Start gry"),
                ),
              ],
            )

          ],
        )
            : step == 3
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gra zakończona!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...players.map(
                  (p) => Row(
                children: [
                  if (winners.contains(p))
                    const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    "${p.name}: ${p.correctAnswers} poprawnych odpowiedzi",
                    style: TextStyle(
                      fontWeight:
                      winners.contains(p) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GameScreen()),
              ),
              child: Text("Zagraj ponownie"),
            )
          ],
        )
            : currentQuestion != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: currentPlayer?.icon, radius: 24),
                SizedBox(width: 10),
                Text("Pytanie dla: ${currentPlayer?.name}", style: TextStyle(fontSize: 20)),
              ],
            ),
            SizedBox(height: 10),
            Text(currentQuestion![0], style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (gs.useTimer)
              Text("Czas: $timer s",
                  style: TextStyle(
                    fontSize: 18,
                    color: timer <= 3 ? Colors.red : Colors.black,
                  )),
            // Text("Czas: $timer s", style: TextStyle(fontSize: 18, color: timer <= 3 ? Colors.red : Colors.black)),
            if (statusMessage.isNotEmpty)
              Text(statusMessage, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => setState(() => showAnswer = !showAnswer),
              child: Text("Pokaż odpowiedź"),
            ),
            if (showAnswer)
              Text("Odpowiedź: ${currentQuestion![1]}", style: TextStyle(color: Colors.green, fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if(gs.soundEnabled){
                      await _player.play(AssetSource('correct.mp3'));
                    }

                    setState(() {
                      currentPlayer?.answeredCount++;
                      currentPlayer?.correctAnswers++;
                      currentQuestion = null;
                    });
                    // _advanceTurn();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Dobra odpowiedź"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    if(gs.soundEnabled){
                      await _player.play(AssetSource('wrong.mp3'));
                    }
                    setState(() {
                      currentPlayer?.answeredCount++;
                      currentPlayer?.lives = (currentPlayer?.lives ?? 1) - 1;
                      currentQuestion = null;
                      checkGameOver();
                    });
                    // _advanceTurn();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Zła odpowiedź"),
                ),
              ],
            ),
          ],
        )
            : Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _resetToSetup,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Nowa gra"),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: players.map((p) => PlayerCard(
                  player: p,
                  onTap: () {
                    if (step == 2 && p.lives > 0) startQuestion(p);
                  },
                  bgColor: p.lives == 0
                      ? Colors.grey.shade700                   // martwi gracze = szare
                      : countColor[p.answeredCount] ?? Colors.blue,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
