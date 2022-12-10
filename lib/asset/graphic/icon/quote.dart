import 'package:flutter/material.dart';

class QuoteIcon extends StatelessWidget {
  final Size size;
  final Color color;
  QuoteIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QuoteIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _QuoteIconPainter extends CustomPainter {
  final Color color;
  _QuoteIconPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 24.00), (size.height / 24.00));
    final paint = Paint()
      ..color = color;
    canvas.drawPath(Path()
      ..moveTo(15.654, 12.096)
      ..cubicTo(16.018, 12.096, 16.214, 11.900, 16.214, 11.536)
      ..lineTo(16.214, 8.960)
      ..cubicTo(16.214, 8.596, 16.018, 8.400, 15.654, 8.400)
      ..lineTo(14.954, 8.400)
      ..lineTo(16.074, 5.936)
      ..cubicTo(16.158, 5.740, 16.074, 5.600, 15.850, 5.600)
      ..lineTo(14.590, 5.600)
      ..cubicTo(14.422, 5.600, 14.338, 5.656, 14.254, 5.796)
      ..lineTo(12.742, 8.092)
      ..cubicTo(12.602, 8.316, 12.546, 8.512, 12.546, 8.792)
      ..lineTo(12.546, 11.536)
      ..cubicTo(12.546, 11.900, 12.742, 12.096, 13.106, 12.096)
      ..lineTo(15.654, 12.096)
      ..close()
      ..moveTo(10.894, 12.096)
      ..cubicTo(11.258, 12.096, 11.454, 11.900, 11.454, 11.536)
      ..lineTo(11.454, 8.960)
      ..cubicTo(11.454, 8.596, 11.258, 8.400, 10.894, 8.400)
      ..lineTo(10.194, 8.400)
      ..lineTo(11.314, 5.936)
      ..cubicTo(11.398, 5.740, 11.314, 5.600, 11.090, 5.600)
      ..lineTo(9.830, 5.600)
      ..cubicTo(9.662, 5.600, 9.578, 5.656, 9.494, 5.796)
      ..lineTo(7.982, 8.092)
      ..cubicTo(7.842, 8.316, 7.786, 8.512, 7.786, 8.792)
      ..lineTo(7.786, 11.536)
      ..cubicTo(7.786, 11.900, 7.982, 12.096, 8.346, 12.096)
      ..lineTo(10.894, 12.096)
      ..close(),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
