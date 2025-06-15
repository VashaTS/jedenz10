// ─── models/question.dart ───────────────────────────────
class Question {
  final String text;
  final String answer;
  final String category;
  final bool isAI;
  final String? musicAsset;

  Question(this.text, this.answer, this.category, {this.musicAsset})
      : isAI = text.contains('🤖');
}

/// Anything that creates a fully-formed Question on demand
typedef QuestionGenerator = Question Function();