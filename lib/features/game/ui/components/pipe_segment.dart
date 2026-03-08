import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class PipeSegment extends SpriteComponent with CollisionCallbacks {
  final String spriteAsset;
  final bool flipVertical;

  PipeSegment({
    required Vector2 position,
    required Vector2 size,
    required this.spriteAsset,
    this.flipVertical = false,
  }) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(spriteAsset);

    if (flipVertical) {
      flipVertically();
    }

    add(RectangleHitbox());
  }
}
