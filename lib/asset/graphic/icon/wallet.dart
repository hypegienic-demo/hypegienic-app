import 'package:flutter/material.dart';

class WalletIcon extends StatelessWidget {
  final Size size;
  final Color color;
  WalletIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WalletIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _WalletIconPainter extends CustomPainter {
  final Color color;
  _WalletIconPainter({required this.color});
  
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
      ..moveTo(18.5, 16.7)
      ..cubicTo(18.5, 16.868896, 18.5, 17.135563, 18.5, 17.5)
      ..cubicTo(18.5, 18.604570, 17.604570, 19.5, 16.5, 19.5)
      ..lineTo(6.5, 19.5)
      ..cubicTo(5.395430, 19.5, 4.5, 18.604570, 4.5, 17.5)
      ..lineTo(4.5, 6.5)
      ..cubicTo(4.5, 5.395430, 5.395430, 4.5, 6.5, 4.5)
      ..lineTo(16.5, 4.5)
      ..cubicTo(17.604570, 4.5, 18.5, 5.395430, 18.5, 6.5)
      ..cubicTo(18.5, 6.853688, 18.5, 7.120354, 18.5, 7.3)
      ..moveTo(13.0, 8.0)
      ..lineTo(19.0, 8.0)
      ..cubicTo(19.552285, 8.0, 20.0, 8.447715, 20.0, 9.0)
      ..lineTo(20.0, 15.0)
      ..cubicTo(20.0, 15.552285, 19.552285, 16.0, 19.0, 16.0)
      ..lineTo(13.0, 16.0)
      ..cubicTo(12.447715, 16.0, 12.0, 15.552285, 12.0, 15.0)
      ..lineTo(12.0, 9.0)
      ..cubicTo(12.0, 8.447715, 12.447715, 8.0, 13.0, 8.0)
      ..close(),
      paint
    );
    paint.style = PaintingStyle.fill;
    canvas.drawPath(Path()
      ..moveTo(16.0, 10.5)
      ..cubicTo(15.168182, 10.5, 14.5, 11.168182, 14.5, 12.0)
      ..cubicTo(14.5, 12.831818, 15.168182, 13.5, 16.0, 13.5)
      ..cubicTo(16.831818, 13.5, 17.5, 12.831818, 17.5, 12.0)
      ..cubicTo(17.5, 11.168182, 16.831818, 10.5, 16.0, 10.5)
      ..close(),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
