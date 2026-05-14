import 'package:flutter/material.dart';
import 'package:zapret_ui/app/runner.dart';
import 'package:zapret_ui/core/utils/custom_icons.dart';
import 'package:zapret_ui/core/widgets/fade_in_animation.dart';
import 'package:zapret_ui/features/process/presentation/controllers/process_controller.dart';

class ProcessSwitchButton extends StatefulWidget {
  const ProcessSwitchButton({
    super.key,
  });

  @override
  State<ProcessSwitchButton> createState() => _ProcessSwitchButtonState();
}

class _ProcessSwitchButtonState extends State<ProcessSwitchButton> {
  late final ProcessController _state;
  final Size _size = Size(200, 200);

  @override
  void initState() {
    _state = getIt.get<ProcessController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final powerOnColor = colorScheme.primary;
    final powerOffColor = colorScheme.primary.withAlpha(20);
    final borderRadius = BorderRadius.circular(_size.height / 2);

    return FadeAnimation(
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => SizedBox.fromSize(
          size: _size,
          child: Material(
            color: colorScheme.surface,
            borderRadius: borderRadius,
            child: Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  borderRadius: borderRadius,
                  onTap: _state.switchZapret,
                ),
                _InnerCircle(
                  isRunning: _state.isRunning && !_state.isLoading,
                  powerOnColor: powerOnColor,
                  powerOffColor: powerOffColor,
                ),
                _PowerIcon(
                  isRunning: _state.isRunning,
                  powerOnColor: powerOnColor,
                  powerOffColor: powerOffColor,
                ),
                _LoadingCircle(
                  isLoading: _state.isLoading,
                  powerOnColor: powerOnColor,
                  powerOffColor: powerOffColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// INNER CIRCLE
//
class _InnerCircle extends StatelessWidget {
  final bool isRunning;
  final Color powerOnColor;
  final Color powerOffColor;
  const _InnerCircle({
    required this.isRunning,
    required this.powerOnColor,
    required this.powerOffColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        margin: EdgeInsets.all(8),
        duration: Duration(milliseconds: 1000),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 6,
            color: isRunning ? powerOnColor : powerOffColor,
          ),
        ),
      ),
    );
  }
}

//
// POWER ICON
//
class _PowerIcon extends StatefulWidget {
  final bool isRunning;
  final Color powerOnColor;
  final Color powerOffColor;

  const _PowerIcon({
    required this.isRunning,
    required this.powerOnColor,
    required this.powerOffColor,
  });

  @override
  State<_PowerIcon> createState() => __PowerIconState();
}

class __PowerIconState extends State<_PowerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _colorAnimation = ColorTween(
      begin: widget.powerOffColor,
      end: widget.powerOnColor,
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PowerIcon oldWidget) {
    if (oldWidget.isRunning != widget.isRunning) {
      if (widget.isRunning) {
        _turnOn();
      } else {
        _turnOff();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _colorAnimation,
      builder: (_, _) => IgnorePointer(
        child: Icon(
          CustomIcons.power,
          color: _colorAnimation.value,
          size: 30,
        ),
      ),
    );
  }

  Future<void> _turnOn() async {
    await Future.delayed(Duration(milliseconds: 800));
    _controller.forward();
  }

  Future<void> _turnOff() async {
    await Future.delayed(Duration(milliseconds: 500));
    _controller.reverse();
  }
}

//
// LOADING CIRCLE
//
class _LoadingCircle extends StatelessWidget {
  final bool isLoading;
  final Color powerOnColor;
  final Color powerOffColor;

  const _LoadingCircle({
    required this.isLoading,
    required this.powerOnColor,
    required this.powerOffColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        constraints: BoxConstraints.expand(),
        padding: const EdgeInsets.all(11.0),
        child: FadeAnimation(
          show: isLoading,
          fadeInDuration: Duration(milliseconds: 500),
          fadeOutDuration: Duration(milliseconds: 500),
          child: CircularProgressIndicator(
            color: powerOnColor,
            strokeWidth: 6,
          ),
        ),
      ),
    );
  }
}
