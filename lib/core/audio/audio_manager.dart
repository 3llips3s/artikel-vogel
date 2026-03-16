import 'dart:developer' as developer;

import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool _isInitialized = false;
  static bool _isMuted = false;
  static bool _isMusicPlaying = false;

  static const double musicVolume = 0.2;
  static const double flapVolume = 0.3;
  static const double correctVolume = 0.7;
  static const double incorrectVolume = 0.5;

  static AudioPool? _flapPool;
  static AudioPool? _correctPool;
  static AudioPool? _incorrectPool;

  static const int maxFlapInstances = 3;
  static const int maxCorrectInstances = 2;
  static const int maxIncorrectInstances = 2;

  // preload sounds
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final assetsToLoad = [
        'background.mp3',
        'flap.mp3',
        'correct.mp3',
        'incorrect.mp3',
      ];

      await FlameAudio.audioCache.loadAll(assetsToLoad);

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
    } catch (e) {
      developer.log('Audio initialization error: $e');
    }
  }

  static bool _isWarmedUp = false;

  static void warmup() {
    if (_isWarmedUp || !_isInitialized) return;
    _isWarmedUp = true;

    // Decodes and primes the Web Audio contexts for all sounds synchronously.
    // This will cause a tiny unnoticeable stutter on the Welcome screen tap,
    // protecting the active gameplay from decoding lag.
    _flapPool?.start(volume: 0.0);
    _correctPool?.start(volume: 0.0);
    _incorrectPool?.start(volume: 0.0);

    startBackgroundMusic();
  }

  static final AudioPlayer _bgmPlayer =
      AudioPlayer()..setReleaseMode(ReleaseMode.loop);

  static Future<void> startBackgroundMusic() async {
    if (!_isInitialized || _isMuted || _isMusicPlaying) return;

    try {
      await _bgmPlayer.play(
        AssetSource('audio/background.mp3'),
        volume: musicVolume,
      );
      _isMusicPlaying = true;
    } catch (e) {
      developer.log('music start error: $e');
    }
  }

  static void stopBackgroundMusic() {
    _bgmPlayer.stop();
    _isMusicPlaying = false;
  }

  static void pauseBackgroundMusic() {
    _bgmPlayer.pause();
  }

  static void resumeBackgroundMusic() {
    if (!_isMuted && _isMusicPlaying) {
      _bgmPlayer.resume();
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
    _bgmPlayer.dispose();

    _flapPool = null;
    _correctPool = null;
    _incorrectPool = null;

    _isInitialized = false;
    _isMusicPlaying = false;

    developer.log('Audio disposed');
  }
}
