import 'package:flutter/material.dart';

class ExpandIcon extends StatelessWidget {
  final Size size;
  final Color color;
  ExpandIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ExpandIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _ExpandIconPainter extends CustomPainter {
  final Color color;
  _ExpandIconPainter({required this.color});
  
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
      ..moveTo(9.4, 6.8)
      ..lineTo(14.6, 12.0)
      ..lineTo(9.4, 17.2),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
