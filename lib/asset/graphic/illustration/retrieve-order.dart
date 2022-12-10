import 'package:flutter/widgets.dart';

class RetrieveOrderIllustration extends StatelessWidget {
  final Size size;
  final Color color;
  RetrieveOrderIllustration({
    this.size = const Size.square(128.0),
    this.color = const Color.fromRGBO(0, 0, 0, 1)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RetrieveOrderIllustrationPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _RetrieveOrderIllustrationPainter extends CustomPainter {
  final Color color;
  _RetrieveOrderIllustrationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 64.0), (size.height / 64.0));
    [
      Path()
        ..moveTo(39.000743, 26.0)
        ..lineTo(48.021177, 26.0)
        ..cubicTo(49.125747, 26.0, 50.021177, 26.895430, 50.021177, 28.0)
        ..lineTo(50.021177, 51.0)
        ..cubicTo(50.021177, 52.104569, 49.125747, 53.0, 48.021177, 53.0)
        ..lineTo(15.978308, 53.0)
        ..cubicTo(14.873739, 53.0, 13.978308, 52.104569, 13.978308, 51.0)
        ..lineTo(13.978308, 28.0)
        ..cubicTo(13.978308, 26.895430, 14.873739, 26.0, 15.978308, 26.0)
        ..lineTo(25.008139, 26.0)
        ..lineTo(25.008139, 26.0),
      Path()
        ..moveTo(23.75, 33.7)
        ..cubicTo(26.235281, 33.7, 28.25, 35.714719, 28.25, 38.2)
        ..cubicTo(28.25, 39.896102, 27.311645, 41.373039, 25.925753, 42.139994)
        ..lineTo(25.925, 45.7)
        ..lineTo(21.425, 45.7)
        ..lineTo(21.425180, 42.053728)
        ..cubicTo(20.121495, 41.265572, 19.25, 39.834560, 19.25, 38.2)
        ..cubicTo(19.25, 35.714719, 21.264719, 33.7, 23.75, 33.7)
        ..close(),
      Path()
        ..moveTo(24.7, 19.5)
        ..lineTo(32.0, 12.0711006)
        ..lineTo(39.3, 19.5)
        ..moveTo(32.0, 31.75)
        ..lineTo(32.0, 12.6708731),
      Path()
    ].forEach((path) {
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..color = color
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
