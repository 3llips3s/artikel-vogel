import 'dart:math';

import '../../../core/models/german_noun.dart';

class NounSelector {
  final List<GermanNoun> allNouns;
  late List<int> availableIndices;
  late Random _random;

  NounSelector(this.allNouns) {
    availableIndices = List.generate(allNouns.length, (index) => index);
    _random = Random();
  }

  ({GermanNoun noun, String correctArticle, String incorrectArticle})
  selectNoun() {
    if (availableIndices.isEmpty) {
      availableIndices = List.generate(allNouns.length, (index) => index);
    }

    final randomPosition = _random.nextInt(availableIndices.length);
    final nounIndex = availableIndices[randomPosition];

    availableIndices.removeAt(randomPosition);

    final noun = allNouns[nounIndex];
    final correctArticle = noun.article;

    final articles = ['der', 'die', 'das'];
    final otherArticles =
        articles.where((article) => article != correctArticle).toList();
    final incorrectArticle =
        otherArticles[_random.nextInt(otherArticles.length)];

    return (
      noun: noun,
      correctArticle: correctArticle,
      incorrectArticle: incorrectArticle,
    );
  }

  void reset() {
    availableIndices = List.generate(allNouns.length, (index) => index);
  }
}
