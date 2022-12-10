import 'package:flutter/material.dart';

class MapIcon extends StatelessWidget {
  final Size size;
  final Color color;
  MapIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _MapIconPainter extends CustomPainter {
  final Color color;
  _MapIconPainter({required this.color});
  
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
      ..moveTo(12.00, 3.581402)
      ..cubicTo(7.352934, 3.581402, 3.581402, 7.352934, 3.581402, 12.00)
      ..cubicTo(3.581402, 16.647066, 7.352934, 20.418598, 12.00, 20.418598)
      ..cubicTo(16.647066, 20.418598, 20.418598, 16.647066, 20.418598, 12.00)
      ..cubicTo(20.418598, 7.352934, 16.647066, 3.581402, 12.00, 3.581402)
      ..close()
      ..moveTo(13.606907, 13.606907)
      ..lineTo(7.59751515, 16.4024848)
      ..lineTo(10.393093, 10.393093)
      ..lineTo(16.4024848, 7.59751515)
      ..close(),
      paint
    );
    paint.style = PaintingStyle.fill;
    canvas.drawPath(Path()
      ..moveTo(12.00, 11.25)
      ..cubicTo(11.584091, 11.25, 11.25, 11.584091, 11.25, 12.00)
      ..cubicTo(11.25, 12.415909, 11.584091, 12.75, 12.00, 12.75)
      ..cubicTo(12.415909, 12.75, 12.75, 12.415909, 12.75, 12.00)
      ..cubicTo(12.75, 11.584091, 12.415909, 11.25, 12.00, 11.25)
      ..close(),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
