import 'dart:math' as math;
import 'package:flutter/material.dart';

Path getStripePath(Size size, double translate, StripeSize stripeSize) {
  final path = Path();
  final stripeWidth = stripeSize.lineWidth + stripeSize.gapWidth;
  final theta = 45 * math.pi / 180;
  final opposite = math.tan(theta) * size.height;
  final startX = (translate - stripeSize.lineWidth) / stripeWidth;
  for(var i = startX; i < (size.width + opposite) / stripeWidth; i++) {
    final x = i * stripeWidth;
    path.moveTo(x, 0);
    path.lineTo(x + stripeSize.lineWidth, 0);
    path.lineTo(x + stripeSize.lineWidth - opposite, size.height);
    path.lineTo(x - opposite, size.height);
    path.lineTo(x, 0);
  }
  path.close();
  return path;
}
class StripeSize {
  double lineWidth;
  double gapWidth;
  StripeSize({
    required this.lineWidth,
    required this.gapWidth
  });
}
class MovingStripes extends StatefulWidget {
  final Color color;
  final StripeSize stripeSize;
  MovingStripes({
    required this.color,
    StripeSize? stripeSize
  }) :
    this.stripeSize = stripeSize?? StripeSize(
      lineWidth: 16,
      gapWidth: 16
    );

  @override
  State<StatefulWidget> createState() => MovingStripesState();
}
class MovingStripesState extends State<MovingStripes> with TickerProviderStateMixin {
  late AnimationController _translateController;

  @override
  void initState() {
    super.initState();
    this._translateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:3200),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 32.0
    );
    this._translateController.repeat();
  }
  @override
  void dispose() {
    this._translateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._translateController,
      builder: (context, child) => ClipRect(
        child: CustomPaint(
          painter: _Stripes(
            color: widget.color,
            translate: this._translateController.value,
            stripeSize: widget.stripeSize
          )
        )
      )
    );
  }
}
class Stripes extends StatelessWidget {
  final double translate;
  final Color color;
  final StripeSize stripeSize;
  Stripes({
    this.translate = 0.0,
    required this.color,
    StripeSize? stripeSize
  }) :
    this.stripeSize = stripeSize?? StripeSize(
      lineWidth: 16,
      gapWidth: 16
    );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _Stripes(
          color: this.color,
          translate: this.translate,
          stripeSize: this.stripeSize
        )
      )
    );
  }
}
class _Stripes extends CustomPainter {
  final double translate;
  final Color color;
  final StripeSize stripeSize;
  _Stripes({
    required this.translate,
    required this.color,
    required this.stripeSize
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill;
    final path = getStripePath(size, this.translate, this.stripeSize);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_Stripes oldDelagate) =>
    oldDelagate.translate != this.translate;
}