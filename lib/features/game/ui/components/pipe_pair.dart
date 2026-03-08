import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/models/german_noun.dart';
import '../../logic/artikel_vogel.dart';
import 'gap_sparkle.dart';
import 'noun_label.dart';
import 'pipe_gap_label.dart';
import 'pipe_segment.dart';

class PipePair extends PositionComponent with HasGameReference<ArtikelVogel> {
  final double topPipeHeight;
  final double middlePipeHeight;
  final double bottomPipeStartY;
  final String correctArticle;
  final String incorrectArticle;
  final GermanNoun noun;

  bool scored = false;
  bool isTopGapCorrect = false;

  late PipeSegment topPipe;
  late PipeSegment middlePipe;
  late PipeSegment bottomPipe;
  late PipeGapLabel topGapLabel;
  late PipeGapLabel bottomGapLabel;
  late NounLabel nounLabel;

  // gap boundaries
  late double topGapStartY;
  late double topGapEndY;
  late double bottomGapStartY;
  late double bottomGapEndY;

  PipePair({
    required this.topPipeHeight,
    required this.middlePipeHeight,
    required this.bottomPipeStartY,
    required this.correctArticle,
    required this.incorrectArticle,
    required this.noun,
  });

  @override
  FutureOr<void> onLoad() async {
    // gap boundaries
    topGapStartY = topPipeHeight;
    topGapEndY = topGapStartY + pipeGapSize;

    final double middlePipeStartY = topGapEndY;
    final double middlePipeEndY = middlePipeStartY + middlePipeHeight;

    bottomGapStartY = middlePipeEndY;
    bottomGapEndY = bottomGapStartY + pipeGapSize;

    topPipe = PipeSegment(
      position: Vector2(0, 0),
      size: Vector2(pipeWidth, topPipeHeight),
      spriteAsset: 'top_pipe.png',
    );
    add(topPipe);

    final bool useTopPipeForMiddle = Random().nextBool();

    middlePipe = PipeSegment(
      position: Vector2(0, middlePipeStartY),
      size: Vector2(pipeWidth, middlePipeHeight),
      spriteAsset: useTopPipeForMiddle ? 'top_pipe.png' : 'bottom_pipe.png',
    );
    add(middlePipe);

    final bottomPipeHeight = game.size.y - groundHeight - bottomPipeStartY;

    bottomPipe = PipeSegment(
      position: Vector2(0, bottomPipeStartY),
      size: Vector2(pipeWidth, bottomPipeHeight),
      spriteAsset: 'bottom_pipe.png',
    );
    add(bottomPipe);

    isTopGapCorrect = Random().nextBool();

    topGapLabel = PipeGapLabel(
      article: isTopGapCorrect ? correctArticle : incorrectArticle,
      isCorrectAnswer: isTopGapCorrect,
      gapCenterY: (topGapStartY + topGapEndY) / 2,
    );
    add(topGapLabel);

    bottomGapLabel = PipeGapLabel(
      article: !isTopGapCorrect ? correctArticle : incorrectArticle,
      isCorrectAnswer: !isTopGapCorrect,
      gapCenterY: (bottomGapStartY + bottomGapEndY) / 2,
    );
    add(bottomGapLabel);

    final nounDistance = nounVisibilityTime * groundScrollingSpeed * 0.5;

    nounLabel = NounLabel(noun: noun);
    final middlePipeCenterY = middlePipeStartY + (middlePipeHeight / 2) - 24;
    nounLabel.position = Vector2(-nounDistance, middlePipeCenterY);
    add(nounLabel);
  }

  @override
  void update(double dt) {
    if (!game.gameStarted) return;

    position.x -= groundScrollingSpeed * dt;

    if (!scored) {
      final birdCenterX = game.bird.position.x + (birdWidth / 2);
      final pipeCenterX = position.x + (pipeWidth / 2);

      if (birdCenterX >= pipeCenterX && birdCenterX < pipeCenterX + 5) {
        scored = true;

        final birdCenterY = game.bird.position.y + (birdHeight / 2);
        final correctGapStart =
            isTopGapCorrect ? topGapStartY : bottomGapStartY;
        final correctGapEnd = isTopGapCorrect ? topGapEndY : bottomGapEndY;

        if (birdCenterY >= correctGapStart + 10 &&
            birdCenterY <= correctGapEnd - 10) {
          if (isTopGapCorrect) {
            topGapLabel.triggerFlash();
          } else {
            bottomGapLabel.triggerFlash();
          }

          // sparkles
          final sparklePosition = Vector2(
            position.x + pipeWidth / 2,
            isTopGapCorrect
                ? (topGapStartY + topGapEndY) / 2
                : (bottomGapStartY + bottomGapEndY) / 2,
          );
          game.add(GapSparkle(gapCenter: sparklePosition));

          game.onCorrectGap();
        } else {
          game.gameOver();
        }
      }
    }

    if (position.x + pipeWidth <= 0) {
      removeFromParent();
    }
  }
}
