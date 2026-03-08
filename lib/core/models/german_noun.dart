class GermanNoun {
  final String article;
  final String noun;
  final String plural;
  final String english;

  GermanNoun({
    required this.article,
    required this.noun,
    required this.plural,
    required this.english,
  });

  factory GermanNoun.fromJson(Map<String, dynamic> json) {
    return GermanNoun(
      article: json['article'] as String,
      noun: json['noun'] as String,
      plural: json['plural'] as String,
      english: json['english'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article,
      'noun': noun,
      'plural': plural,
      'english': english,
    };
  }
}
