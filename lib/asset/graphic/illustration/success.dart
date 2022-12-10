import 'package:flutter/widgets.dart';

class SuccessIllustration extends StatelessWidget {
  final Size size;
  final Color color;
  SuccessIllustration({
    this.size = const Size.square(128.0),
    this.color = const Color.fromRGBO(0, 0, 0, 1)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SuccessIllustrationPainter(
        color: color
      ),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _SuccessIllustrationPainter extends CustomPainter {
  final Color color;
  _SuccessIllustrationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 64.0), (size.height / 64.0));
    [
      Path()
        ..moveTo(40.3213865, 24.0802786)
        ..lineTo(42.7281013, 26.4639889)
        ..lineTo(28.22777, 42.2127392)
        ..lineTo(20.8418465, 33.6728901)
        ..lineTo(22.7964064, 31.6683395)
        ..lineTo(28.22777, 36.2432787)
        ..close(),
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
