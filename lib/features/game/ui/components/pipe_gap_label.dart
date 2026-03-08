import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/game_constants.dart';

class PipeGapLabel extends TextComponent {
  final String article;
  final bool isCorrectAnswer;
  final double gapCenterY;

  bool flashing = false;
  double flashTimer = 0;
  final double flashDuration = 0.4;

  late TextPaint originalStyle;

  PipeGapLabel({
    required this.article,
    required this.isCorrectAnswer,
    required this.gapCenterY,
  }) : super(
         text: article,
         textRenderer: TextPaint(
           style: TextStyle(
             color: AppColors.primary,
             fontSize: 20,
             fontWeight: FontWeight.bold,
           ),
         ),
       );

  @override
  FutureOr<void> onLoad() async {
    anchor = Anchor.center;
    position = Vector2(pipeWidth / 2, gapCenterY);
    originalStyle = textRenderer as TextPaint;
  }

  @override
  void update(double dt) {
    if (flashing) {
      flashTimer += dt;

      if (flashTimer >= flashDuration) {
        flashing = false;
        flashTimer = 0;
        textRenderer = originalStyle;
      } else {
        // animate flash
        final progress = flashTimer / flashDuration;
        final intensity = 1 - progress;

        textRenderer = TextPaint(
          style: TextStyle(
            color: Color.lerp(Colors.lightGreenAccent, Colors.white, progress)!,
            fontSize: 24 + (8 * intensity),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.green.withOpacity(intensity * 0.8),
                offset: Offset.zero,
                blurRadius: 15 * intensity,
              ),
              const Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        );
      }
    }
  }

  void triggerFlash() {
    if (isCorrectAnswer) {
      flashing = true;
      flashTimer = 0;
    }
  }
}
