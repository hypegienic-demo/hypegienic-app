import 'package:flutter/material.dart';

class MobileIcon extends StatelessWidget {
  final Size size;
  final Color color;
  MobileIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MobileIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _MobileIconPainter extends CustomPainter {
  final Color color;
  _MobileIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 24.00), (size.height / 24.00));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()
      ..moveTo(13.263, 18.902)
      ..lineTo(15.686, 16.336)
      ..cubicTo(15.909, 16.122, 16.217, 16.058, 16.495, 16.145)
      ..cubicTo(17.375, 16.439, 18.32, 16.589, 19.295, 16.589)
      ..cubicTo(19.724, 16.589, 20.081, 16.947, 20.081, 17.375)
      ..lineTo(20.152, 19.208)
      ..cubicTo(20.152, 19.636, 19.961, 20.152, 19.367, 20.152)
      ..cubicTo(10.794, 20.152, 3.848, 13.206, 3.848, 4.633)
      ..cubicTo(3.848, 4.039, 4.364, 3.848, 4.792, 3.848)
      ..lineTo(6.624, 3.919)
      ..cubicTo(7.053, 3.919, 7.41, 4.276, 7.41, 4.704)
      ..cubicTo(7.41, 5.68, 7.561, 6.624, 7.855, 7.505)
      ..cubicTo(7.942, 7.782, 7.878, 8.091, 7.664, 8.314)
      ..lineTo(5.097, 10.737),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
