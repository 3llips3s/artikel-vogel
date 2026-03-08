import '../../../core/models/german_noun.dart';

class GameState {
  int score = 0;
  bool isGameOver = false;
  GermanNoun? currentNoun;
  String? correctArticle;
  String? incorrectArticle;

  void reset() {
    score = 0;
    isGameOver = false;
    currentNoun = null;
    correctArticle = null;
    incorrectArticle = null;
  }

  void setCurrentNoun({
    required GermanNoun noun,
    required String correctArticle,
    required String incorrectArticle,
  }) {
    currentNoun = noun;
    this.correctArticle = correctArticle;
    this.incorrectArticle = incorrectArticle;
  }

  void incrementScore() {
    score++;
  }

  void gameOver() {
    isGameOver = true;
  }
}
