import 'package:flutter/material.dart';

class ErrorIcon extends StatelessWidget {
  final Size size;
  final Color color;
  ErrorIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ErrorIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _ErrorIconPainter extends CustomPainter {
  final Color color;
  _ErrorIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 24.00), (size.height / 24.00));
    final paint = Paint()
      ..color = color;
    canvas.drawPath(Path()
      ..moveTo(4.47, 21.00)
      ..lineTo(19.53, 21.00)
      ..cubicTo(21.07, 21.00, 22.03, 19.33, 21.26, 18.00)
      ..lineTo(13.73, 4.99)
      ..cubicTo(12.96, 3.66, 11.04, 3.66, 10.27, 4.99)
      ..lineTo(2.74, 18.00)
      ..cubicTo(1.97, 19.33, 2.93, 21.00, 4.47, 21.00)
      ..close()
      ..moveTo(12.00, 14.00)
      ..cubicTo(11.45, 14.00, 11.00, 13.55, 11.00, 13.00)
      ..lineTo(11.00, 11.00)
      ..cubicTo(11.00, 10.45, 11.45, 10.00, 12.00, 10.00)
      ..cubicTo(12.55, 10.00, 13.00, 10.45, 13.00, 11.00)
      ..lineTo(13.00, 13.00)
      ..cubicTo(13.00, 13.55, 12.55, 14.00, 12.00, 14.00)
      ..close()
      ..moveTo(13.00, 18.00)
      ..lineTo(11.00, 18.00)
      ..lineTo(11.00, 16.00)
      ..lineTo(13.00, 16.00)
      ..lineTo(13.00, 18.00)
      ..close(),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
