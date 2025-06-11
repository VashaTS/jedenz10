// ===============================
//  file: lib/models/player.dart
// ===============================
import 'package:flutter/material.dart';

class Player {
  final String name;
  final ImageProvider icon;
  int lives;
  int answeredCount;
  int correctAnswers;
  int points;

  Player(
      this.name,
      this.icon,
      this.lives, {
        this.answeredCount = 0,
        this.correctAnswers = 0,
        this.points = 0
      });
}