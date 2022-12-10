import 'package:flutter/material.dart';

class EmailIcon extends StatelessWidget {
  final Size size;
  final Color color;
  EmailIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EmailIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _EmailIconPainter extends CustomPainter {
  final Color color;
  _EmailIconPainter({required this.color});
  
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
      ..moveTo(18.67, 5.33)
      ..lineTo(5.33, 5.33)
      ..cubicTo(4.42, 5.33, 3.67, 6.08, 3.67, 7.00)
      ..lineTo(3.67, 17.00)
      ..cubicTo(3.67, 17.92, 4.42, 18.67, 5.33, 18.67)
      ..lineTo(18.67, 18.67)
      ..cubicTo(19.58, 18.67, 20.33, 17.92, 20.33, 17.00)
      ..lineTo(20.33, 7.00)
      ..cubicTo(20.33, 6.08, 19.58, 5.33, 18.67, 5.33)
      ..close()
      ..moveTo(6.04227903, 8.26171544)
      ..lineTo(12, 12)
      ..lineTo(17.957721, 8.26171544),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
