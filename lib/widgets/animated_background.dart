import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:zapret_ui/widgets/fade_in_animation.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.verticalSpeed = 1,
    this.horizontalSpeed = 2,
    this.strokeWidth = 1,
    this.colors = const [Colors.greenAccent],
    this.child,
    this.isInBackground = true,
    this.alignment = Alignment.center,
    this.waveAmplitude = 1,
    this.numberOfLines = 100,
  }) : assert(colors.length >= 1, "The  colors list cannot be empty");

  /// Speed in the vertical direction per frame
  final double verticalSpeed;

  /// Speed in the horizontal direction per frame
  final double horizontalSpeed;

  /// the width of each line
  final double strokeWidth;

  /// Color of each
  final List<Color> colors;

  /// Whether should be painted behind or in front of the child widget
  final bool isInBackground;

  /// The child widget alignment
  final AlignmentGeometry? alignment;

  /// Number of lines
  final int numberOfLines;

  /// strength of the movement
  final double waveAmplitude;

  /// The child widget to display
  final Widget? child;

  @override
  State<StatefulWidget> createState() => PerlinNoiseState();
}

class PerlinNoiseState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  final ValueNotifier notifier = ValueNotifier(false);
  late PerlinNoisePainter perlinNoisePainter;
  late final Ticker ticker;

  PerlinNoisePainter _createPainter() {
    return PerlinNoisePainter(
      verticalSpeed: widget.verticalSpeed,
      horizontalSpeed: widget.horizontalSpeed,
      waveAmplitude: widget.waveAmplitude,
      numberOfLines: widget.numberOfLines,
      strokeWidth: widget.strokeWidth,
      colors: widget.colors,
      notifier: notifier,
    );
  }

  @override
  void initState() {
    super.initState();
    perlinNoisePainter = _createPainter();
    ticker = createTicker((_) {
      notifier.value = !notifier.value;
    });
    ticker.start();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    perlinNoisePainter = _createPainter();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    ticker.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      child: ClipRect(
        child: CustomPaint(
          painter: (widget.isInBackground) ? perlinNoisePainter : null,
          foregroundPainter: (widget.isInBackground)
              ? null
              : perlinNoisePainter,
          child: Container(
            alignment: widget.alignment,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class PerlinNoisePainter extends CustomPainter {
  final Paint paintObject = Paint();
  final double verticalSpeed;
  final double horizontalSpeed;
  final double strokeWidth;
  final List<Color> colors;
  final int numberOfLines;
  final double waveAmplitude;
  late final ValueNotifier notifier;
  late double _pointSpacing;
  late double _linesSpacing;
  late int _pointsPerLine;
  PerlinNoiseAlgorithm? _perlinNoise;
  double _time = 0;
  final List<Path> _pathPool = [];
  final List<List<Offset>> _pointsPool = [];
  int _pathPoolIndex = 0;
  int _pointsPoolIndex = 0;
  int _pointIndex = 0;
  late double _yStart;
  late double _yEnd;
  late double _noiseCoeff1X;
  late double _noiseCoeff1Y;
  late double _noiseCoeff2X;
  late double _noiseCoeff2Y;
  late double _timeMultiplier1;
  late double _timeMultiplier2;
  late double _amplitudeScale1;
  late double _amplitudeScale2;
  late List<Color> _lineColors;
  late Path _path;
  late double _xBase;

  PerlinNoisePainter({
    required this.verticalSpeed,
    required this.horizontalSpeed,
    required this.colors,
    required this.strokeWidth,
    required this.notifier,
    required this.numberOfLines,
    required this.waveAmplitude,
  }) : super(repaint: notifier);

  void initialize(Size size) {
    paintObject
      ..color = colors[0]
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _perlinNoise ??= PerlinNoiseAlgorithm();
    _linesSpacing = size.width / numberOfLines;
    _pointSpacing = size.height / 10;
    _pointsPerLine = ((size.height + 100) / _pointSpacing).ceil();

    _yStart = 0;
    _yEnd = size.height + 50;

    _noiseCoeff1X = 0.003 * horizontalSpeed;
    _noiseCoeff1Y = 0.008;
    _noiseCoeff2X = 0.005 * horizontalSpeed;
    _noiseCoeff2Y = 0.01;

    _timeMultiplier1 = 2.0;
    _timeMultiplier2 = 1.5;

    _amplitudeScale1 = 80.0 * waveAmplitude;
    _amplitudeScale2 = 40.0 * waveAmplitude;

    _lineColors = List<Color>.filled(numberOfLines, colors[0]);

    if (colors.length != 1) {
      final colorScale = colors.length.toDouble();
      final lineScale = numberOfLines.toDouble();

      for (int i = 0; i < numberOfLines; i++) {
        final colorIndex = (i / lineScale * colorScale) % colorScale;
        final index1 = colorIndex.floor() % colors.length;
        final index2 = (index1 + 1) % colors.length;
        final t = colorIndex - colorIndex.floor();
        _lineColors[i] = Color.lerp(colors[index1], colors[index2], t)!;
      }
    }

    for (int i = 0; i < numberOfLines; i++) {
      _pathPool.add(Path());
      _pointsPool.add(List<Offset>.filled(_pointsPerLine, Offset.zero));
    }
  }

  @pragma('vm:prefer-inline')
  Path _getPath() => _pathPool[_pathPoolIndex++]..reset();

  @pragma('vm:prefer-inline')
  List<Offset> _getPointsList() => _pointsPool[_pointsPoolIndex++];

  double _getNoiseOffset(double xBase, double y) {
    final time1 = _time * _timeMultiplier1;
    final time2 = _time * _timeMultiplier2;

    final noiseValue1 = _perlinNoise!.noise(
      xBase * _noiseCoeff1X + time1,
      y * _noiseCoeff1Y,
    );

    final noiseValue2 = _perlinNoise!.noise(
      xBase * _noiseCoeff2X + time2,
      y * _noiseCoeff2Y + 100,
    );

    return noiseValue1 * _amplitudeScale1 + noiseValue2 * _amplitudeScale2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    initialize(size);

    _pathPoolIndex = 0;
    _pointsPoolIndex = 0;

    _time += 0.02 * verticalSpeed;

    for (int i = 0; i < numberOfLines; i++) {
      _path = _getPath();
      _xBase = _linesSpacing * i + _linesSpacing / 2;

      if (colors.length != 1) {
        paintObject.color = _lineColors[i];
      }

      _pointIndex = 0;
      final points = _getPointsList();

      for (int j = 0; j < _pointsPerLine; j++) {
        final y = _yStart + j * _pointSpacing;
        if (y >= _yEnd) break;
        points[_pointIndex++] = Offset(_xBase + _getNoiseOffset(_xBase, y), y);
      }

      if (_pointIndex == 0) continue;

      _path.moveTo(points[0].dx, points[0].dy);

      for (int j = 0; j < _pointIndex - 1; j++) {
        final p1 = points[j];
        final p2 = points[j + 1];

        final midX = (p1.dx + p2.dx) * 0.5;
        final midY = (p1.dy + p2.dy) * 0.5;

        _path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
      }

      final lastPoint = points[_pointIndex - 1];
      _path.lineTo(lastPoint.dx, lastPoint.dy);

      canvas.drawPath(_path, paintObject);
    }
  }

  @override
  bool shouldRepaint(PerlinNoisePainter oldDelegate) => true;
}

class PerlinNoiseAlgorithm {
  final List<int> _permutation;
  late final List<int> _p;

  PerlinNoiseAlgorithm([int? seed])
    : _permutation = List<int>.generate(256, (i) => i) {
    final Random random = Random(seed);
    _permutation.shuffle(random);
    _p = List<int>.generate(512, (i) => _permutation[i % 256]);
  }

  double noise(double x, double y) {
    final int X = x.floor() & 255;
    final int Y = y.floor() & 255;
    x -= x.floor();
    y -= y.floor();
    final double u = _fade(x);
    final double v = _fade(y);
    final int A = _p[X] + Y;
    final int B = _p[X + 1] + Y;

    return _lerp(
      v,
      _lerp(u, _grad(_p[A], x, y), _grad(_p[B], x - 1, y)),
      _lerp(u, _grad(_p[A + 1], x, y - 1), _grad(_p[B + 1], x - 1, y - 1)),
    );
  }

  @pragma('vm:prefer-inline')
  double _fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);

  @pragma('vm:prefer-inline')
  double _lerp(double t, double a, double b) => a + t * (b - a);

  @pragma('vm:prefer-inline')
  double _grad(int hash, double x, double y) => switch (hash & 3) {
    0 => x + y,
    1 => -x + y,
    2 => x - y,
    _ => -x - y,
  };
}
