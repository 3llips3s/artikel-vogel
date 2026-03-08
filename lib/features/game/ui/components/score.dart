import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../logic/artikel_vogel.dart';

class Score extends TextComponent with HasGameReference<ArtikelVogel> {
  int lastScore = 0;
  double scaleTimer = 0;
  bool isAnimating = false;
  final double animationDuration = 0.3;

  Score()
    : super(
        text: '0',
        textRenderer: TextPaint(
          style: TextStyle(
            color: AppColors.score,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  FutureOr<void> onLoad() {
    anchor = Anchor.center;
    position = Vector2(
      game.size.x / 2, // center horizontally
      game.size.y - 100, // near bottom
    );
  }

  @override
  void update(double dt) {
    final newScore = game.gameState.score;

    if (newScore != lastScore) {
      lastScore = newScore;
      text = newScore.toString();

      isAnimating = true;
      scaleTimer = 0;

      if (isAnimating) {
        scaleTimer += dt;

        if (scaleTimer >= animationDuration) {
          isAnimating = false;
          scale = Vector2.all(1.0);
        } else {
          // scale up quickly then settle
          final progress = scaleTimer / animationDuration;
          double scaleValue;

          if (progress < 0.5) {
            // grow to 1.3x first
            scaleValue = 1.0 + (progress * 2) * 0.3;
          } else {
            // then shrink back to 1.0 with small overshoot
            final backProgress = (progress - 0.5) * 2;
            scaleValue = 1.3 - (backProgress * 0.3);
          }

          scale = Vector2.all(scaleValue);
        }
      }
    }

    final newScoreText = game.gameState.score.toString();
    if (text != newScoreText) {
      text = newScoreText;
    }
  }
}
