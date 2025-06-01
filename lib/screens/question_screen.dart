import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../utils/csv_loader.dart';

class QuestionScreen extends StatefulWidget {
  final List<Player> players;

  QuestionScreen({required this.players});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  List<List<String>> _questions = [];
  Player? _currentPlayer;
  String _currentQuestion = '';
  String _currentAnswer = '';
  Timer? _timer;
  int _timeLeft = 0;
  bool _timeExceeded = false;

  @override
  void initState() {
    super.initState();
    loadQuestions().then((questions) {
      setState(() {
        _questions = questions;
      });
    });
  }

  void _startQuestion(Player player) {
    if (_questions.isEmpty) return;
    final question = (_questions..shuffle()).removeLast();
    setState(() {
      _currentPlayer = player;
      _currentQuestion = question[0];
      _currentAnswer = question[1];
      _timeLeft = 5 + (_currentQuestion.length ~/ 10);
      _timeExceeded = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        setState(() {
          _timeExceeded = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _handleAnswer(bool isCorrect) {
    if (!isCorrect) {
      setState(() {
        _currentPlayer!.lives--;
      });
    }
    _timer?.cancel();
    setState(() {
      _currentPlayer = null;
      _currentQuestion = '';
      _currentAnswer = '';
      _timeLeft = 0;
      _timeExceeded = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlayer == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Wybierz gracza'),
        ),
        body: ListView(
          children: widget.players
              .where((player) => player.isAlive)
              .map((player) => ListTile(
            title: Text(player.name),
            subtitle: Text('Szanse: ${player.lives}'),
            onTap: () => _startQuestion(player),
          ))
              .toList(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Pytanie dla ${_currentPlayer!.name}'),
          ),
          body: Padding(
          padding: const EdgeInsets.all(16.0),
    child: Column(
    children: [
    Text(
    _currentQuestion,
    style: TextStyle(fontSize: 18),
    ),
    SizedBox(height: 20),
    Text(
    'Czas: $_timeLeft s',

        ::contentReference[oaicite:75]{index=75}

