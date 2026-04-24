import 'package:flutter/material.dart';

class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final double delay;

  const FadeSlideAnimation({
    Key? key,
    required this.child,
    this.delay = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // We simulate a delay by keeping value at 0 until a certain threshold if we wanted, 
        // but simpler is just staggering via a mathematical curve mapping.
        // For a more robust delay, usually you'd use a StatefulWidget, but TweenAnimationBuilder works great.
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
