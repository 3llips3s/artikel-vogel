import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class AnimatedArticle extends StatefulWidget {
  final String article;
  final Duration delay;

  const AnimatedArticle({
    super.key,
    required this.article,
    required this.delay,
  });

  @override
  State<AnimatedArticle> createState() => _AnimatedArticleState();
}

class _AnimatedArticleState extends State<AnimatedArticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      // stay at normal size
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1),
      // zoom in
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      // bounce back with overshoot
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      // settle in
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: Text(
        widget.article,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
