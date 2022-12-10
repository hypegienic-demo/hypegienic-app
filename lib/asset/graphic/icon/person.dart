import 'package:flutter/material.dart';

class PersonIcon extends StatelessWidget {
  final Size size;
  final Color color;
  PersonIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PersonIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _PersonIconPainter extends CustomPainter {
  final Color color;
  _PersonIconPainter({required this.color});
  
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
      ..moveTo(12.00, 12.00)
      ..cubicTo(14.21, 12.00, 16.00, 10.21, 16.00, 8.00)
      ..cubicTo(16.00, 5.79, 14.21, 4.00, 12.00, 4.00)
      ..cubicTo(9.79, 4.00, 8.00, 5.79, 8.00, 8.00)
      ..cubicTo(8.00, 10.21, 9.79, 12.00, 12.00, 12.00)
      ..close()
      ..moveTo(12.00, 14.00)
      ..cubicTo(9.33, 14.00, 4.00, 15.34, 4.00, 18.00)
      ..lineTo(4.00, 19.00)
      ..cubicTo(4.00, 19.55, 4.45, 20.00, 5.00, 20.00)
      ..lineTo(19.00, 20.00)
      ..cubicTo(19.55, 20.00, 20.00, 19.55, 20.00, 19.00)
      ..lineTo(20.00, 18.00)
      ..cubicTo(20.00, 15.34, 14.67, 14.00, 12.00, 14.00)
      ..close(),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
