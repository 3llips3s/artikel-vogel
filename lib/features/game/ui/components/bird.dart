import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../../core/constants/game_constants.dart';
import '../../logic/artikel_vogel.dart';
import 'ground.dart';
import 'pipe_segment.dart';

class Bird extends SpriteComponent
    with CollisionCallbacks, HasGameReference<ArtikelVogel> {
  // initial bird position + size
  Bird()
    : super(position: Vector2.zero(), size: Vector2(birdWidth, birdHeight));

  double velocity = 0;

  // animation properties
  double targetX = 0;
  double startX = 0;
  bool isMovingToStartPosition = false;
  double moveTimer = 0;
  final double moveDuration = 1;

  // hover properties
  double hoverTimer = 0;
  final double hoverAmplitude = 8;
  final double hoverSpeed = 0.5;
  double baseY = 0;

  // load bird
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('bird.png');

    add(
      CircleHitbox(radius: 8, position: Vector2(birdWidth / 2, birdHeight / 2)),
    );

    startX = game.size.x / 2.35;
    targetX = game.size.x / 4;

    baseY = (game.size.y - groundHeight) / 3;

    position = Vector2(startX, baseY);
  }

  // jump
  void flap() {
    velocity = jumpStrength;

    if (!game.gameStarted) {
      game.startGame();

      isMovingToStartPosition = true;
      moveTimer = 0;
    }
  }

  // update per sec.
  @override
  void update(double dt) {
    if (!game.gameStarted && !isMovingToStartPosition) {
      hoverTimer += dt;
      final offset = sin(hoverTimer * hoverSpeed * 2 * pi) * hoverAmplitude;
      position.y = baseY + offset;
      return;
    }

    if (isMovingToStartPosition) {
      moveTimer += dt;

      double progress = (moveTimer / moveDuration).clamp(0.0, 1.0);
      double easedProgress =
          1 - (1 - progress) * (1 - progress) * (1 - progress);

      position.x = startX + (targetX - startX) * easedProgress;

      if (moveTimer >= moveDuration) {
        isMovingToStartPosition = false;
        position.x = targetX;
      }
    }

    // apply physics after game starts
    if (!game.gameStarted) return;

    // apply gravity
    velocity += gravity * dt;

    // update position based on velocity
    position.y += velocity * dt;

    if (position.y < 0) {
      position.y = 0;
      velocity = 0;
    }
  }

  // collision
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Ground || other is PipeSegment) {
      (parent as ArtikelVogel).gameOver();
    }
  }

  void resetPosition() {
    startX = game.size.x / 2.25;
    position.x = startX;
    position.y = baseY;
    velocity = 0;
    isMovingToStartPosition = false;
    moveTimer = 0;
    moveTimer = 0;
    hoverTimer = 0;
  }
}
