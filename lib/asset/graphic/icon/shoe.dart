import 'package:flutter/material.dart';

class ShoeIcon extends StatelessWidget {
  final Size size;
  final Color color;
  ShoeIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShoeIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _ShoeIconPainter extends CustomPainter {
  final Color color;
  _ShoeIconPainter({required this.color});
  
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
      ..moveTo(4.463769, 17.566839)
      ..cubicTo(2.738956, 17.566839, 1.340719, 16.168602, 1.340719, 14.443789)
      ..cubicTo(1.340719, 13.106520, 2.181214, 11.965558, 3.362757, 11.520350)
      ..lineTo(15.094574, 6.748291)
      ..cubicTo(15.530090, 6.576111, 16.156549, 6.433161, 16.498440, 6.433161)
      ..lineTo(20.659281, 6.433161)
      ..cubicTo(21.763850, 6.433161, 22.659281, 7.328592, 22.659281, 8.433161)
      ..lineTo(22.659281, 15.566839)
      ..cubicTo(22.659281, 16.671408, 21.763850, 17.566839, 20.659281, 17.566839)
      ..lineTo(4.463769, 17.566839)
      ..close()
      ..moveTo(12.33, 7.99)
      ..lineTo(13.64, 10.72)
      ..moveTo(9.89, 8.99)
      ..lineTo(11.20, 11.72),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
