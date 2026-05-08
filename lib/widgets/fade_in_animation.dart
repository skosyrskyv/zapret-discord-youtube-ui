import 'package:flutter/material.dart';

class FadeInAnimation extends StatefulWidget {
  final Duration delay;
  final Duration animationDuration;
  final bool playWhenRebuilds;
  final Widget child;
  const FadeInAnimation({
    super.key,
    this.delay = Duration.zero,
    this.animationDuration = const Duration(milliseconds: 500),
    this.playWhenRebuilds = true,
    required this.child,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  final Tween<double> opacityTween = Tween(begin: 0.0, end: 1);

  Future<void> _delayedStart() async {
    await Future.delayed(widget.delay);
    if (mounted) {
      controller.forward();
    }
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    opacityTween.animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    _delayedStart();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FadeInAnimation oldWidget) {
    if (!widget.playWhenRebuilds) {
      return;
    }
    if (oldWidget.child != widget.child) {
      controller.reset();
      _delayedStart();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: controller.value,
      child: widget.child,
    );
  }
}
