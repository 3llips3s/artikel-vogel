import 'dart:developer' as developer;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class AudioManager {
  static bool _isInitialized = false;
  static bool _isMuted = false;
  static bool _isMusicPlaying = false;

  static const double musicVolume = 0.4;
  static const double flapVolume = 0.30;
  static const double correctVolume = 0.7;
  static const double incorrectVolume = 0.5;

  static AudioPool? _flapPool;
  static AudioPool? _correctPool;
  static AudioPool? _incorrectPool;

  static const int maxFlapInstances = 3;
  static const int maxCorrectInstances = 2;
  static const int maxIncorrectInstances = 2;

  static bool _webAudioUnlocked = false;

  // preload sounds
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await FlameAudio.audioCache.loadAll([
        'background.mp3',
        'flap.mp3',
        'correct.mp3',
        'incorrect.mp3',
      ]);

      _flapPool = await FlameAudio.createPool(
        'flap.mp3',
        maxPlayers: maxFlapInstances,
      );

      _correctPool = await FlameAudio.createPool(
        'correct.mp3',
        maxPlayers: maxCorrectInstances,
      );
      _incorrectPool = await FlameAudio.createPool(
        'incorrect.mp3',
        maxPlayers: maxIncorrectInstances,
      );

      _isInitialized = true;

      _setupWebAudioUnlock();
    } catch (e) {
      developer.log('Audio initialization error: $e');
    }
  }

  static void _setupWebAudioUnlock() {
    if (!kIsWeb || _webAudioUnlocked) return;

    void unlock(JSAny event) {
      if (_webAudioUnlocked) return;
      _webAudioUnlocked = true;

      // start background music directly in DOM event
      if (!_isMusicPlaying && !_isMuted && _isInitialized) {
        startBackgroundMusic();
      }

      // play and pause pools to force decoding and unsuspend
      _flapPool?.start(volume: 0.0);
      _correctPool?.start(volume: 0.0);
      _incorrectPool?.start(volume: 0.0);
    }

    web.window.addEventListener('pointerdown', unlock.toJS);
    web.window.addEventListener('touchstart', unlock.toJS);
    web.window.addEventListener('click', unlock.toJS);

    // Resume context on every interaction to prevent it from going stale
    web.window.addEventListener(
      'pointerdown',
      ((web.Event e) {
        if (_isInitialized) resumeAudioContext();
      }).toJS,
    );

    // Listen for fullscreen changes to resume audio if it was suspended
    web.document.addEventListener(
      'fullscreenchange',
      ((web.Event e) {
        if (_isInitialized) resumeAudioContext();
      }).toJS,
    );
  }

  static void resumeAudioContext() {
    if (_isMusicPlaying && !_isMuted) {
      // Try to resume first
      FlameAudio.bgm.resume();

      // If resume isn't enough (e.g. context was suspended and needs a "poke"),
      // we can try playing again. audiocache handles the already-playing state
      // but on web, re-calling play can sometimes fix a stalled context.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isMusicPlaying && !_isMuted) {
          FlameAudio.bgm.play('background.mp3', volume: musicVolume);
        }
      });
    }
  }

  static Future<void> startBackgroundMusic() async {
    if (!_isInitialized || _isMuted || _isMusicPlaying) return;

    try {
      await FlameAudio.bgm.play('background.mp3', volume: musicVolume);
      _isMusicPlaying = true;
    } catch (e) {
      developer.log('music start error: $e');
    }
  }

  static void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
    _isMusicPlaying = false;
  }

  static void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  static void resumeBackgroundMusic() {
    if (!_isMuted && _isMusicPlaying) {
      FlameAudio.bgm.resume();
    }
  }

  static void playFlap() {
    if (!_isInitialized || _isMuted || _flapPool == null) return;

    _flapPool!.start(volume: flapVolume);
  }

  static void playCorrect() {
    if (!_isInitialized || _isMuted || _correctPool == null) return;

    _correctPool!.start(volume: correctVolume);
  }

  static void playIncorrect() {
    if (!_isInitialized || _isMuted || _incorrectPool == null) return;

    _incorrectPool!.start(volume: incorrectVolume);
  }

  static void toggleMute() {
    _isMuted = !_isMuted;

    if (_isMuted) {
      pauseBackgroundMusic();
    } else {
      resumeBackgroundMusic();
    }
  }

  static bool get isMuted => _isMuted;
  static bool get isMusicPlaying => _isMusicPlaying;

  static void dispose() {
    FlameAudio.bgm.dispose();

    _flapPool = null;
    _correctPool = null;
    _incorrectPool = null;

    _isInitialized = false;
    _isMusicPlaying = false;

    developer.log('Audio disposed');
  }
}
