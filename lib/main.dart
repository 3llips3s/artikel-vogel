import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'core/constants/colors.dart';
import 'features/game/logic/artikel_vogel.dart';
import 'features/nouns/data/csv_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  await CsvLoader.loadNouns();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _WebGameWrapper();
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.transparent,
      body: GameWidget(game: ArtikelVogel()),
    );
  }
}

class _WebGameWrapper extends StatelessWidget {
  const _WebGameWrapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          // On mobile web in landscape: show rotate overlay
          if (isLandscape && constraints.maxWidth < 900) {
            return const _RotateOverlay();
          }

          // On desktop (wide screens): center a portrait-ratio column
          // On mobile web portrait: fill screen
          const double maxGameWidth = 420.0;
          final double gameWidth = constraints.maxWidth.clamp(0, maxGameWidth);

          return Center(
            child: SizedBox(
              width: gameWidth,
              height: constraints.maxHeight,
              child: GameWidget(game: ArtikelVogel()),
            ),
          );
        },
      ),
    );
  }
}

class _RotateOverlay extends StatelessWidget {
  const _RotateOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation_rounded,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bitte drehe dein Gerät',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please rotate your device\nto portrait mode',
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
