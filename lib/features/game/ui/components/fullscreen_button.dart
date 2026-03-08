import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/audio/audio_manager.dart';
import '../../logic/artikel_vogel.dart';

class FullscreenButton extends TextComponent
    with TapCallbacks, HasGameReference<ArtikelVogel>, HasPaint {
  FullscreenButton() : super(anchor: Anchor.center);

  static final _fullscreenOnIcon = TextPaint(
    style: const TextStyle(
      color: AppColors.fullscreenOn,
      fontSize: 26,
      fontFamily: 'MaterialIcons',
    ),
  );

  static final _fullscreenOffIcon = TextPaint(
    style: const TextStyle(
      color: AppColors.fullscreenOff,
      fontSize: 26,
      fontFamily: 'MaterialIcons',
    ),
  );

  bool _isFullscreen = false;

  @override
  FutureOr<void> onLoad() async {
    _updateIcon();

    add(
      CircleHitbox()
        ..size = Vector2(24, 24)
        ..anchor = Anchor.center,
    );

    if (kIsWeb) {
      _isFullscreen = web.document.fullscreenElement != null;
      web.document.addEventListener(
        'fullscreenchange',
        ((JSAny event) {
          _isFullscreen = web.document.fullscreenElement != null;
          _updateIcon();
        }).toJS,
      );
    }
  }

  void _updateIcon() {
    final iconData =
        _isFullscreen
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded;
    text = String.fromCharCode(iconData.codePoint);
    textRenderer = _isFullscreen ? _fullscreenOffIcon : _fullscreenOnIcon;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Positioned at the actual bottom left, within the ground
    position = Vector2(36, game.size.y - 36);
  }

  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
    _toggleFullscreen();
    scale = Vector2.all(0.8);
    add(OpacityEffect.to(0.5, EffectController(duration: 0.3)));
  }

  void _toggleFullscreen() {
    if (!kIsWeb) return;

    // Explicitly poke the audio engine during the user gesture
    AudioManager.resumeAudioContext();

    if (_isFullscreen) {
      web.document.exitFullscreen();
    } else {
      final options = web.FullscreenOptions(navigationUI: 'hide');
      web.document.documentElement?.requestFullscreen(options);
    }

    // Secondary poke after the transition starts
    Future.delayed(const Duration(milliseconds: 300), () {
      AudioManager.resumeAudioContext();
    });
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
    add(OpacityEffect.to(1.0, EffectController(duration: 0.3)));
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
    add(OpacityEffect.to(1.0, EffectController(duration: 0.3)));
  }

  @override
  void render(Canvas canvas) {
    if (!game.gameStarted && kIsWeb) {
      super.render(canvas);
    }
  }
}
