import 'package:flutter/material.dart';

class Player {
  final String name;
  final ImageProvider icon;
  int lives;
  int correctAnswers = 0;

  Player(this.name, this.icon, this.lives);
}
