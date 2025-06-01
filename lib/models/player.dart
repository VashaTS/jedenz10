class Player {
  final String name;
  int lives;
  final int maxLives;

  Player({required this.name, required this.lives}) : maxLives = lives;

  bool get isAlive => lives > 0;
}
