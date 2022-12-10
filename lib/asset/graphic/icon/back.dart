import 'package:flutter/material.dart';

class BackIcon extends StatelessWidget {
  final Size size;
  final Color color;
  BackIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _BackIconPainter extends CustomPainter {
  final Color color;
  _BackIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 24.00), (size.height / 24.00));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(Path()
      ..moveTo(12.0, 4.7)
      ..lineTo(4.7, 12.0)
      ..lineTo(12.0, 19.3)
      ..moveTo(19.3, 4.7)
      ..lineTo(12.0, 12.0)
      ..lineTo(19.3, 19.3),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
