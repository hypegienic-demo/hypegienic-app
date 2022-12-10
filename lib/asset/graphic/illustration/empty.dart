import 'package:flutter/widgets.dart';

class EmptyIllustration extends StatelessWidget {
  final Size size;
  final Color color;
  EmptyIllustration({
    this.size = const Size.square(128.0),
    this.color = const Color.fromRGBO(0, 0, 0, 1)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EmptyIllustrationPainter(color:color),
      child: Container(
        height: size.height,
        width: size.width
      )
    );
  }
}
class _EmptyIllustrationPainter extends CustomPainter {
  final Color color;
  _EmptyIllustrationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    canvas.scale((size.width / 64.0), (size.height / 64.0));
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    [
      Path()
        ..moveTo(29.504, 40.784768)
        ..lineTo(29.504, 45.712768)
        ..lineTo(34.528, 45.712768)
        ..lineTo(34.528, 40.784768)
        ..close(),
      Path()
        ..moveTo(34.368, 29.008768)
        ..lineTo(34.368, 22.864768)
        ..lineTo(29.632, 22.864768)
        ..lineTo(29.632, 29.008768)
        ..lineTo(30.848, 38.864768)
        ..lineTo(33.12, 38.864768)
        ..close(),
      Path()
        ..moveTo(34.454314, 13.594033)
        ..cubicTo(35.230124, 14.035442, 35.872558, 14.677876, 36.313967, 15.453686)
        ..lineTo(52.349691, 43.637686)
        ..cubicTo(53.705408, 46.020462, 52.872813, 49.051108, 50.490038, 50.406825)
        ..cubicTo(49.741935, 50.832470, 48.896011, 51.056276, 48.035295, 51.056276)
        ..lineTo(15.963847, 51.056276)
        ..cubicTo(13.222390, 51.056276, 11.0, 48.833886, 11.0, 46.092429)
        ..cubicTo(11.0, 45.231714, 11.223806, 44.385789, 11.649451, 43.637686)
        ..lineTo(27.685175, 15.453686)
        ..cubicTo(29.040892, 13.070911, 32.071539, 12.238316, 34.454314, 13.594033)
        ..close()
        ..moveTo(32.981468, 16.182671)
        ..cubicTo(32.073744, 15.666207, 30.930965, 15.943689, 30.355739, 16.794619)
        ..lineTo(30.273813, 16.926532)
        ..lineTo(14.238088, 45.110532)
        ..cubicTo(14.067830, 45.409773, 13.978308, 45.748143, 13.978308, 46.092429)
        ..cubicTo(13.978308, 47.139167, 14.788287, 47.996725, 15.815664, 48.072522)
        ..lineTo(15.963847, 48.077968)
        ..lineTo(48.035295, 48.077968)
        ..cubicTo(48.379581, 48.077968, 48.717951, 47.988445, 49.017192, 47.818188)
        ..cubicTo(49.924916, 47.301724, 50.270216, 46.177576, 49.832596, 45.248353)
        ..lineTo(49.761054, 45.110532)
        ..lineTo(33.725330, 16.926532)
        ..cubicTo(33.578193, 16.667928, 33.375216, 16.446374, 33.132059, 16.277528)
        ..lineTo(32.981468, 16.182671)
        ..close()
    ].forEach((path) {
      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter self) {
    return false;
  }
}
