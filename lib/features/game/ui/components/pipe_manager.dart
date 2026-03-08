import 'dart:math';

import 'package:flame/components.dart';

import '../../../../core/constants/game_constants.dart';
import '../../logic/artikel_vogel.dart';
import 'pipe_pair.dart';

class PipeManager extends Component with HasGameReference<ArtikelVogel> {
  double pipeSpawnTimer = 0;
  bool firstPipe = true;
  double firstPipeDelay = 1.5;

  @override
  void update(double dt) {
    if (!game.gameStarted) {
      pipeSpawnTimer = 0;
      firstPipe = true;
      return;
    }

    pipeSpawnTimer += dt;

    final spawnDelay = firstPipe ? firstPipeDelay : pipeInterval;

    if (pipeSpawnTimer > spawnDelay) {
      pipeSpawnTimer = 0;
      spawnPipe();
      firstPipe = false;
    }
  }

  void spawnPipe() {
    final double screenHeight = game.size.y;
    final double availableHeight = screenHeight - groundHeight;
    final double totalGapSpace = pipeGapSize * 2;
    final double maxPipeSpace = availableHeight - totalGapSpace;
    final double minRequiredSpace =
        minTopPipeHeight + minMiddlePipeHeight + minBottomPipeHeight;

    if (maxPipeSpace < minRequiredSpace) return;

    final double extraSpace = maxPipeSpace - minRequiredSpace;

    // distribute space left evenly and randomly
    final random = Random();

    double r1 = random.nextDouble();
    double r2 = random.nextDouble();
    double r3 = random.nextDouble();

    // normalize distribution: always sum up to 1.0
    final double total = r1 + r2 + r3;
    r1 /= total;
    r2 /= total;
    r3 /= total;

    final double topExtra = extraSpace * r1;
    final double middleExtra = extraSpace * r2;

    final double topPipeHeight = minTopPipeHeight + topExtra;
    final double middlePipeHeight = minMiddlePipeHeight + middleExtra;

    final double bottomPipeStartY =
        topPipeHeight + middlePipeHeight + totalGapSpace;

    final currentNoun = game.gameState.currentNoun;
    if (currentNoun == null) return;

    final pipePair = PipePair(
      topPipeHeight: topPipeHeight,
      middlePipeHeight: middlePipeHeight,
      bottomPipeStartY: bottomPipeStartY,
      correctArticle: game.gameState.correctArticle ?? 'der',
      incorrectArticle: game.gameState.incorrectArticle ?? 'die',
      noun: currentNoun,
    );

    pipePair.position = Vector2(game.size.x, 0);
    game.add(pipePair);
  }
}
