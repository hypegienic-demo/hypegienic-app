import 'package:flutter/widgets.dart';

class FailIllustration extends StatelessWidget {
  final Size size;
  final Color color;
  FailIllustration({
    this.size = const Size.square(128.0),
    this.color = const Color.fromRGBO(0, 0, 0, 1)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FailIllustrationPainter(
        color: color
      ),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _FailIllustrationPainter extends CustomPainter {
  final Color color;
  _FailIllustrationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 64.0), (size.height / 64.0));
    [
      Path()
        ..moveTo(26.4270949, 23.3499747)
        ..lineTo(32.0489747, 29.1709747)
        ..lineTo(37.8713918, 23.5497357)
        ..lineTo(40.6500253, 26.4270949)
        ..lineTo(34.8279747, 32.0489747)
        ..lineTo(40.4502643, 37.8713918)
        ..lineTo(37.5729051, 40.6500253)
        ..lineTo(31.9499747, 34.8279747)
        ..lineTo(26.1286082, 40.4502643)
        ..lineTo(23.3499747, 37.5729051)
        ..lineTo(29.1709747, 31.9499747)
        ..lineTo(23.5497357, 26.1286082),
      Path()
        ..moveTo(32.0, 11.5)
        ..cubicTo(20.678163, 11.5, 11.5, 20.678163, 11.5, 32.0)
        ..cubicTo(11.5, 43.321837, 20.678163, 52.5, 32.0, 52.5)
        ..cubicTo(43.321837, 52.5, 52.5, 43.321837, 52.5, 32.0)
        ..cubicTo(52.5, 20.678163, 43.321837, 11.5, 32.0, 11.5)
        ..close()
        ..moveTo(32.0, 14.5)
        ..cubicTo(41.664983, 14.5, 49.5, 22.335017, 49.5, 32.0)
        ..cubicTo(49.5, 41.664983, 41.664983, 49.5, 32.0, 49.5)
        ..cubicTo(22.335017, 49.5, 14.5, 41.664983, 14.5, 32.0)
        ..cubicTo(14.5, 22.335017, 22.335017, 14.5, 32.0, 14.5)
        ..close(),
    ].forEach((path) {
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.fill
        ..color = this.color
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
