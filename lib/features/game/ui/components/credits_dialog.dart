import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';

Future<void> showCreditsDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const CreditsDialog(),
  );
}

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 120 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dialog(
        backgroundColor: AppColors.transparent,
        child: Container(
          width: 320,
          height: 520,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              // blur effect
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.blurBorder,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.glassTop, AppColors.glassBottom],
                      ),
                    ),
                  ),
                ),
              ),

              // scrollable content
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 64),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title
                      Center(
                        child: Text(
                          'Danksagungen',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // technologies
                      _buildHeading(context, 'Technologie'),
                      _buildCreditLink(
                        context,
                        'Entwickelt mit ',
                        'Flutter Flame',
                        'https://docs.flame-engine.org/latest/',
                      ),
                      const SizedBox(height: 20),

                      // nouns
                      _buildHeading(context, 'Wortschatz'),
                      _buildCreditLink(
                        context,
                        'Wörter von ',
                        'Frequency Lists by Neri',
                        'https://frequencylists.blogspot.com/2016/01/the-2980-most-frequently-used-german.html',
                      ),
                      const SizedBox(height: 20),

                      // assets
                      _buildHeading(context, 'Grafiken'),
                      _buildCreditLink(
                        context,
                        'Vogel von ',
                        'Bevouliin',
                        'https://bevouliin.com/flappy-box-bird-free-2d-game-sprites/',
                      ),
                      _buildCreditLink(
                        context,
                        'Rohr von ',
                        'Bevouliin',
                        'https://bevouliin.com/flappy-box-bird-free-2d-game-sprites/',
                      ),
                      _buildCreditLink(
                        context,
                        'Wald von ',
                        'Kenney',
                        'https://kenney.nl/assets/background-elements-redux',
                      ),
                      _buildCreditLink(
                        context,
                        'Boden von ',
                        'LaxAttack1226 - OpenGameArt',
                        'https://opengameart.org/content/basic-platform-game-ground-0',
                      ),
                      const SizedBox(height: 20),

                      // sounds
                      _buildHeading(context, 'Sounds'),
                      _buildCreditLink(
                        context,
                        'Whoosh von ',
                        'Dragon-Studio - Pixabay',
                        'https://pixabay.com/sound-effects/simple-whoosh-382724/',
                      ),
                      _buildCreditLink(
                        context,
                        'Ding von ',
                        'Dragon-Studio - Pixabay',
                        'https://pixabay.com/sound-effects/ding-402325/',
                      ),
                      _buildCreditLink(
                        context,
                        'Thud von ',
                        'Universfield - Pixabay',
                        'https://pixabay.com/sound-effects/thud-291047/',
                      ),
                      _buildCreditLink(
                        context,
                        'Atmospheric Soundscape von ',
                        'Universfield - Pixabay',
                        'https://pixabay.com/sound-effects/atmospheric-soundscape-152493/',
                      ),
                    ],
                  ),
                ),
              ),

              // close button
              Positioned(
                right: 30,
                bottom: 30,
                child: _FloatingCloseButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCreditLink(
    BuildContext context,
    String prefix,
    String linkText,
    String url,
  ) {
    final textStyle = TextStyle(fontSize: 15, color: AppColors.textLight);

    final linkStyle = TextStyle(
      fontSize: 15,
      color: Colors.blue.shade800,
      decoration: TextDecoration.underline,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•   ',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: prefix, style: textStyle),
                  TextSpan(
                    text: linkText,
                    style: linkStyle,
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () => _launchURL(context, url),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        _showErrorSnackBar(context, 'Link konnte nicht geöffnet werden.');
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, 'Linkfehler.');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.only(
          bottom: kToolbarHeight,
          left: 40,
          right: 40,
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// close button
class _FloatingCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FloatingCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
        ),
        // border: Border.all(color: AppColors.bottomRightGradient, width: 1),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(Icons.close, color: AppColors.white, size: 24),
        ),
      ),
    );
  }
}
