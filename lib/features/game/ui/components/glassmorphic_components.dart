import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class GlassmorphicDialog extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final List<Widget>? actions;
  final double blur;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const GlassmorphicDialog({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.actions,
    this.blur = 10,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 120 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dialog(
        backgroundColor: AppColors.transparent,
        child: IntrinsicHeight(
          child: Container(
            height: height,
            width: width ?? 320,
            decoration: BoxDecoration(borderRadius: borderRadius),
            child: Stack(
              children: [
                // blur effect — fills to match content size
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.blurBorder,
                            width: 1.5,
                          ),
                          borderRadius: borderRadius,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.glassTop, AppColors.glassBottom],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // content — determines the dialog size
                Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      child,
                      if (actions != null && actions!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: actions!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (color ?? AppColors.white).withOpacity(0.3),
            (color ?? AppColors.white).withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            child: child,
          ),
        ),
      ),
    );
  }
}
