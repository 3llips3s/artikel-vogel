import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../../../core/constants/game_constants.dart';
import '../../logic/artikel_vogel.dart';

class Ground extends SpriteComponent
    with HasGameReference<ArtikelVogel>, CollisionCallbacks {
  Ground() : super();

  @override
  FutureOr<void> onLoad() async {
    size = Vector2(2 * game.size.x, groundHeight);
    position = Vector2(0, game.size.y - groundHeight);

    // load image
    sprite = await Sprite.load('ground.png');

    // collision box
    add(RectangleHitbox());
  }

  // move ground to the left
  @override
  void update(double dt) {
    if (!game.gameStarted) return;

    position.x -= groundScrollingSpeed * dt;

    // infinite scroll - reset ground if half has been passed
    if (position.x + size.x / 2 <= 0) {
      position.x = 0;
    }
  }
}
