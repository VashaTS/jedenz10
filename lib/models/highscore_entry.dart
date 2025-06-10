class HighscoreEntry {
  final String name;
  final int score;           // correctAnswers
  final DateTime date;

  HighscoreEntry(this.name, this.score, this.date);

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'date': date.toIso8601String(),
  };

  factory HighscoreEntry.fromJson(Map<String, dynamic> j) =>
      HighscoreEntry(j['name'], j['score'], DateTime.parse(j['date']));
}
