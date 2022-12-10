import 'package:flutter/material.dart';

class ServiceIcon extends StatelessWidget {
  final Size size;
  final Color color;
  ServiceIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ServiceIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _ServiceIconPainter extends CustomPainter {
  final Color color;
  _ServiceIconPainter({required this.color});
  
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
      ..moveTo(14.027027, 6.783784)
      ..lineTo(9.972973, 6.783784)
      ..cubicTo(8.853477, 6.783784, 7.945946, 7.691315, 7.945946, 8.810811)
      ..lineTo(7.945946, 18.972973)
      ..cubicTo(7.945946, 20.092469, 8.853477, 21.0, 9.972973, 21.0)
      ..lineTo(14.027027, 21.0)
      ..cubicTo(15.146523, 21.0, 16.054054, 20.092469, 16.054054, 18.972973)
      ..lineTo(16.054054, 8.810811)
      ..cubicTo(16.054054, 7.691315, 15.146523, 6.783784, 14.027027, 6.783784)
      ..close()
      ..moveTo(10.108108, 6.783784)
      ..lineTo(10.108108, 4.081081)
      ..cubicTo(10.108108, 3.513870, 10.447861, 3.048684, 10.879987, 3.003584)
      ..lineTo(10.948949, 3.0)
      ..lineTo(13.051051, 3.0)
      ..cubicTo(13.492215, 3.0, 13.854026, 3.436825, 13.889105, 3.992416)
      ..lineTo(13.891892, 4.081081)
      ..lineTo(13.891892, 6.783784),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
