import 'package:flutter/material.dart';

class FixLocationIcon extends StatelessWidget {
  final Size size;
  final Color color;
  FixLocationIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FixLocationIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _FixLocationIconPainter extends CustomPainter {
  final Color color;
  _FixLocationIconPainter({required this.color});
  
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
      ..moveTo(12.00, 10.00)
      ..cubicTo(10.890909, 10.00, 10.00, 10.890909, 10.00, 12.00)
      ..cubicTo(10.00, 13.109091, 10.890909, 14.00, 12.00, 14.00)
      ..cubicTo(13.109091, 14.00, 14.00, 13.109091, 14.00, 12.00)
      ..cubicTo(14.00, 10.890909, 13.109091, 10.00, 12.00, 10.00)
      ..close()
      ..moveTo(12.00, 5.50)
      ..cubicTo(8.412, 5.50, 5.50, 8.412, 5.50, 12.00)
      ..cubicTo(5.50, 15.588, 8.412, 18.50, 12.00, 18.50)
      ..cubicTo(15.588, 18.50, 18.50, 15.588, 18.50, 12.00)
      ..cubicTo(18.50, 8.412, 15.588, 5.50, 12.00, 5.50)
      ..close()
      ..moveTo(12.00, 5.00)
      ..lineTo(12.00, 3.00)
      ..moveTo(12.00, 19.00)
      ..lineTo(12.00, 21.00)
      ..moveTo(5.00, 12.00)
      ..lineTo(3.00, 12.00)
      ..moveTo(19.00, 12.00)
      ..lineTo(21.00, 12.00),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
