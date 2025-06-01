import 'package:flutter/material.dart';
import 'player_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedLives = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('1 z 10 - Ustawienia'),
      ),
      body: Column(
        children: [
          Text('Wybierz liczbę szans:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              int lives = index + 1;
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedLives = lives;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: _selectedLives == lives ? Colors.green : Colors.blue,
                ),
                child: Text('$lives'),
              );
            }),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerSelectionScreen(
                    startingLives: _selectedLives,
                  ),
                ),
              );
            },
            child: Text('Dalej'),
          ),
        ],
      ),
    );
  }
}
