import 'package:flutter/material.dart';
import 'question_screen.dart';
import '../models/player.dart';

class PlayerSelectionScreen extends StatefulWidget {
  final int startingLives;

  PlayerSelectionScreen({required this.startingLives});

  @override
  _PlayerSelectionScreenState createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    10,
        (index) => TextEditingController(),
  );
  int _playerCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj graczy'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButton<int>(
              value: _playerCount,
              items: List.generate(10, (index) {
                int count = index + 1;
                return DropdownMenuItem(
                  value: count,
                  child: Text('$count graczy'),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _playerCount = value!;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCount,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: _controllers[index],
                    decoration: InputDecoration(labelText: 'Gracz ${index + 1}'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wprowadź imię';
                      }
                      return null;
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  List<Player> players = _controllers
                      .take(_playerCount)
                      .map((controller) => Player(
                    name: controller.text,
                    lives: widget.startingLives,
                  ))
                      .toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionScreen(players: players),
                    ),
                  );
                }
              },
              child: Text('Rozpocznij grę'),
            ),
          ],
        ),
      ),
    );
  }
}
