import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/german_noun.dart';

class NounLabel extends TextComponent {
  final GermanNoun noun;
  late TextComponent nounText;
  late TextComponent translationText;

  NounLabel({required this.noun});

  @override
  FutureOr<void> onLoad() async {
    nounText = TextComponent(
      text: noun.noun,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(0, 0),
    );
    add(nounText);

    translationText = TextComponent(
      text: '- ${noun.english}',
      textRenderer: TextPaint(
        style: TextStyle(
          color: AppColors.textTranslation,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(0, 40),
    );
    add(translationText);
  }
}
