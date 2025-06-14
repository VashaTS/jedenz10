// ─── models/question.dart ───────────────────────────────
class Question {
  final String text;
  final String answer;
  final String category;
  final bool isAI;
  int points = 0;                 // nothing changes here

  Question(this.text, this.answer, this.category)
      : isAI = text.contains('🤖');
}

/// Anything that creates a fully-formed Question on demand
typedef QuestionGenerator = Question Function();