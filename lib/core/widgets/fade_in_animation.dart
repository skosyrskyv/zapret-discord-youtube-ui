import 'package:flutter/material.dart';

/// Виджет для плавного появления и исчезновения дочернего виджета с анимацией прозрачности.
///
/// Управляется свойством [show] — при значении `true` запускается анимация появления (Fade In),
/// при `false` — анимация исчезновения (Fade Out).
///
/// Если изначально указать `show: false`, виджет не отображается, но при последующем изменении
/// `show` на `true` он плавно появится. Аналогично работает скрытие.
///
/// Поддерживаются задержки перед началом анимации, разная длительность для появления и исчезновения,
/// а также опциональный повтор анимации при перестройке родительского виджета.
class FadeAnimation extends StatefulWidget {
  /// Управляет видимостью дочернего виджета.
  ///
  /// - `true` — запустить анимацию появления (Fade In).
  /// - `false` — запустить анимацию исчезновения (Fade Out).
  ///
  /// По умолчанию `true`.
  final bool show;

  /// Запускать ли анимацию при каждом перестроении родительского виджета
  /// или изменении конфигурации (например, при смене [child]).
  ///
  /// Если `true`, то при изменении [child] или при вызове `didUpdateWidget`
  /// анимация будет воспроизведена заново в соответствии с текущим значением [show].
  ///
  /// По умолчанию `false`.
  final bool playWhenRebuilds;

  /// Задержка перед началом анимации появления (Fade In).
  ///
  /// По умолчанию [Duration.zero].
  final Duration fadeInDelay;

  /// Задержка перед началом анимации исчезновения (Fade Out).
  ///
  /// По умолчанию [Duration.zero].
  final Duration fadeOutDelay;

  /// Длительность анимации появления (Fade In).
  ///
  /// За это время виджет полностью становится видимым.
  /// По умолчанию 500 мс.
  final Duration fadeInDuration;

  /// Длительность анимации исчезновения (Fade Out).
  ///
  /// За это время виджет полностью становится невидимым.
  /// По умолчанию 500 мс.
  final Duration fadeOutDuration;

  /// Дочерний виджет, к которому применяется анимация прозрачности.
  final Widget child;

  const FadeAnimation({
    super.key,
    this.show = true,
    this.playWhenRebuilds = false,
    this.fadeInDelay = Duration.zero,
    this.fadeOutDelay = Duration.zero,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeOutDuration = const Duration(milliseconds: 500),
    required this.child,
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Tween<double> _opacityTween = Tween(begin: 0.0, end: 1.0);

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
      reverseDuration: widget.fadeOutDuration,
    );
    _opacityTween.animate(_controller);
    if (widget.show) {
      _playFadeInAnimation();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FadeAnimation oldWidget) {
    // Реакция на изменение show
    if (oldWidget.show != widget.show) {
      widget.show ? _playFadeInAnimation() : _playFadeOutAnimation();
    }
    // Если требуется воспроизводить анимацию при перестройке
    if (!widget.playWhenRebuilds) {
      return;
    }
    // При смене дочернего виджета сбрасываем анимацию и запускаем заново
    if (oldWidget.child != widget.child) {
      _controller.reset();
      widget.show ? _playFadeInAnimation() : _playFadeOutAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, Widget? child) => Opacity(
        opacity: _controller.value,
        child: child,
      ),
      child: widget.child,
    );
  }

  /// Запускает анимацию появления с учётом [fadeInDelay].
  void _playFadeInAnimation() async {
    await Future.delayed(widget.fadeInDelay);
    if (mounted) {
      _controller.forward();
    }
  }

  /// Запускает анимацию исчезновения с учётом [fadeOutDelay].
  void _playFadeOutAnimation() async {
    await Future.delayed(widget.fadeOutDelay);
    if (mounted) {
      _controller.reverse();
    }
  }
}
