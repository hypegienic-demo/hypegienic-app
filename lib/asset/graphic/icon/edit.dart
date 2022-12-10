import 'package:flutter/material.dart';

class EditIcon extends StatelessWidget {
  final Size size;
  final Color color;
  EditIcon({this.size = const Size.square(48), this.color = const Color.fromRGBO(88, 89, 91, 1)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EditIconPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _EditIconPainter extends CustomPainter {
  final Color color;
  _EditIconPainter({required this.color});
  
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
      ..moveTo(18.113170, 8.274926)
      ..lineTo(8.313847, 18.074248)
      ..lineTo(5.681508, 18.074248)
      ..lineTo(5.681508, 15.441909)
      ..lineTo(15.480830, 5.642587)
      ..cubicTo(15.614202, 5.509215, 15.789691, 5.439019, 15.972200, 5.439019)
      ..cubicTo(16.124291, 5.439019, 16.271507, 5.482892, 16.397599, 5.578761)
      ..lineTo(16.470590, 5.642587)
      ..lineTo(18.113170, 7.285167)
      ..cubicTo(18.362045, 7.534042, 18.384670, 7.922149, 18.181045, 8.196340)
      ..lineTo(18.113170, 8.274926)
      ..close()
      ..moveTo(16.3514582, 10.1283459)
      ..lineTo(13.7191188, 7.49600651),
      paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
