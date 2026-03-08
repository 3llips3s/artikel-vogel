import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/german_noun.dart';
import 'animated_article.dart';
import 'glassmorphic_components.dart';

Future<void> showGameOverDialog({
  required BuildContext context,
  required int score,
  required int highScore,
  required bool isNewRecord,
  required GermanNoun? currentNoun,
  required String? correctArticle,
  required VoidCallback onRestart,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => GameOverDialog(
          score: score,
          highScore: highScore,
          isNewRecord: isNewRecord,
          currentNoun: currentNoun,
          correctArticle: correctArticle,
          onRestart: onRestart,
        ),
  );
}

class GameOverDialog extends StatefulWidget {
  final int score;
  final int highScore;
  final bool isNewRecord;
  final GermanNoun? currentNoun;
  final String? correctArticle;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highScore,
    required this.isNewRecord,
    required this.currentNoun,
    required this.correctArticle,
    required this.onRestart,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  bool _canInteract = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _canInteract = true;
        });
      }
    });
  }

  void _handleRestart() {
    Navigator.of(context).pop();
    widget.onRestart();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicDialog(
      width: 300,
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: AnimatedOpacity(
            opacity: _canInteract ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeIn,
            child: GlassButton(
              onPressed: _canInteract ? _handleRestart : () {},
              color: AppColors.primary,
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _buildTitle(),
          const SizedBox(height: 32),
          _buildScoreSection(),
          if (widget.currentNoun != null) ...[
            const SizedBox(height: 36),
            _buildNounSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.isNewRecord ? 'Neuer Rekord :)' : 'Spiel vorbei :(',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: widget.isNewRecord ? AppColors.success : AppColors.textDark,
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.scoreCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blurBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isNewRecord
                    ? Icons.emoji_events_rounded
                    : Icons.star_rounded,
                color:
                    widget.isNewRecord ? AppColors.success : AppColors.primary,
                size: 30,
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.score == 1 ? 'Punkt' : 'Punkte',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!widget.isNewRecord && widget.highScore > 0) ...[
            const SizedBox(height: 20),
            _buildHighScoreBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildHighScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.highScoreCard,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 6),
          const Text(
            'Rekord: ',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.highScore}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNounSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, fadeValue, child) {
        return Opacity(opacity: fadeValue, child: child);
      },
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // animated correct article
                AnimatedArticle(
                  article: widget.correctArticle!,
                  delay: const Duration(milliseconds: 300),
                ),
                const SizedBox(width: 8),
                // noun
                Text(
                  widget.currentNoun!.noun,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // translation
          Text(
            '- ${widget.currentNoun!.english}',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.textTranslation,
            ),
          ),
        ],
      ),
    );
  }
}
