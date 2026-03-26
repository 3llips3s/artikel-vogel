import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/models/german_noun.dart';
import '../../nouns/data/csv_loader.dart';
import '../../nouns/logic/incorrect_nouns_tracker.dart';
import '../../nouns/logic/noun_selector.dart';
import '../data/high_score_manager.dart';
import '../ui/components/audio_button.dart';
import '../ui/components/background.dart';
import '../ui/components/bird.dart';
import '../ui/components/credits_button.dart';

import '../ui/components/game_over_dialog.dart';
import '../ui/components/ground.dart';
import '../ui/components/pipe_manager.dart';
import '../ui/components/pipe_pair.dart';
import '../ui/components/score.dart';
import '../ui/components/tap_to_start.dart';
import 'game_state.dart';

class ArtikelVogel extends FlameGame
    with TapCallbacks, HasCollisionDetection, KeyboardEvents {
  late Bird bird;
  late Background background;
  late Ground ground;
  late PipeManager pipeManager;
  late Score scoreText;
  late AudioButton audioButton;
  late CreditsButton creditsButton;

  late NounSelector nounSelector;
  late GameState gameState;
  late List<GermanNoun> allNouns;

  bool gameStarted = false;

  @override
  FutureOr<void> onLoad() async {
    await AudioManager.initialize();

    allNouns = await CsvLoader.loadNouns();
    nounSelector = NounSelector(allNouns);
    gameState = GameState();

    background = Background(size);
    add(background);

    bird = Bird();
    add(bird);

    ground = Ground();
    add(ground);

    pipeManager = PipeManager();
    add(pipeManager);

    scoreText = Score();
    add(scoreText);

    final tapToStartText = TapToStart();
    add(tapToStartText);

    audioButton = AudioButton();
    add(audioButton);

    creditsButton = CreditsButton();
    add(creditsButton);

    if (!kIsWeb) {
      AudioManager.startBackgroundMusic();
    }

    _selectNextNoun();
  }

  @override
  Color backgroundColor() => AppColors.skyBlue;

  @override
  void update(double dt) {
    super.update(dt);

    if (gameStarted && !gameState.isGameOver) {
      // center bird on screen + offsetting camera
      final screenCenter = size.y / 2;
      final birdY = bird.position.y;

      // bird offset from center
      final offset = birdY - screenCenter;

      final currentCameraY = camera.viewport.position.y;
      // negative offset since camera moves opposite
      final targetCameraY = -offset;

      camera.viewport.position.y =
          currentCameraY +
          (targetCameraY - currentCameraY) * cameraFollowSpeed * dt;
    } else {
      camera.viewport.position.y = 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tappedAudio = audioButton.containsPoint(event.localPosition);
    final tappedCredits = creditsButton.containsPoint(event.localPosition);

    final tappedUI = tappedAudio || tappedCredits;

    // Start BGM and decode all audio pools instantly into memory.
    // This safely absorbs the web audio decoding stutter into the first tap.
    AudioManager.warmup();

    if (tappedUI) return;

    AudioManager.playFlap();
    bird.flap();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!gameState.isGameOver) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        // Prevent continuous flapping on key hold
        if (event is KeyDownEvent) {
          AudioManager.warmup();
          AudioManager.playFlap();
          bird.flap();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void startGame() {
    gameStarted = true;
  }

  void _selectNextNoun() {
    final selection = nounSelector.selectNoun();
    gameState.setCurrentNoun(
      noun: selection.noun,
      correctArticle: selection.correctArticle,
      incorrectArticle: selection.incorrectArticle,
    );
  }

  void onCorrectGap() {
    AudioManager.playCorrect();
    gameState.incrementScore();
    _selectNextNoun();
  }

  /// Called when the player loses. [noun] and [correctArticle] can be
  /// supplied by the collision source (e.g. a PipePair) to avoid showing
  /// the wrong noun when gameState has already advanced to the next one.
  void gameOver({GermanNoun? noun, String? correctArticle}) async {
    if (gameState.isGameOver) return;

    // Use the caller-provided noun if available, else fall back to gameState
    final displayNoun = noun ?? gameState.currentNoun;
    final displayArticle = correctArticle ?? gameState.correctArticle;

    AudioManager.playIncorrect();
    gameState.gameOver();
    AudioManager.pauseBackgroundMusic();

    if (displayNoun != null) {
      await IncorrectNounsTracker.addIncorrectNoun(displayNoun);
    }

    final isNewRecord = await HighScoreManager.updateHighScore(gameState.score);
    final highScore = await HighScoreManager.getHighScore();

    pauseEngine();

    showGameOverDialog(
      context: buildContext!,
      score: gameState.score,
      highScore: highScore,
      isNewRecord: isNewRecord,
      currentNoun: displayNoun,
      correctArticle: displayArticle,
      onRestart: resetGame,
    );
  }

  void resetGame() {
    bird.resetPosition();
    gameState.reset();
    nounSelector.reset();
    children.whereType<PipePair>().forEach((pipe) => pipe.removeFromParent());
    _selectNextNoun();
    gameStarted = false;
    camera.viewport.position.y = 0;

    if (!AudioManager.isMuted) {
      AudioManager.resumeBackgroundMusic();
    }

    resumeEngine();
  }

  @override
  void onRemove() {
    AudioManager.dispose();
    super.onRemove();
  }
}
