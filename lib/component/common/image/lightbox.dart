import 'dart:math' as math;
import 'package:flutter/material.dart';

Future<void> showImageDialog({
  required BuildContext context,
  required double x,
  required double y,
  required double width,
  required double height,
  required String url,
  BoxDecoration? decoration
}) =>
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context)
      .modalBarrierDismissLabel,
    barrierColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
    transitionDuration: Duration(milliseconds:300),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
      child,
    pageBuilder: (context, animation, secondaryAnimation) =>
      _ImageLightBox(
        x:x, y:y, width:width, height:height,
        url: url,
        animation: animation,
        decoration: decoration
      )
  );

class _ImageLightBox extends StatefulWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final String url;
  final Animation<double> animation;
  final BoxDecoration? decoration;
  _ImageLightBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.url,
    required this.animation,
    this.decoration
  });

  @override
  State<StatefulWidget> createState() => _ImageLightBoxState(
    url: this.url
  );
}
class _ImageLightBoxState extends State<_ImageLightBox> {
  Image child;
  ImageInfo? imageInfo;

  _ImageLightBoxState({
    required String url
  }) :
    this.child = Image.network(
      url,
      fit: BoxFit.cover
    );
  
  @override
  void initState() {
    super.initState();
    this.child.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener(
      (ImageInfo info, bool _) =>
        setState(() => this.imageInfo = info)
    ));
  }

  _Dimension enlargeImage(ImageInfo imageInfo) {
    final deviceData = MediaQuery.of(context);
    final deviceWidth = deviceData.size.width;
    final deviceHeight = deviceData.size.height - deviceData.padding.top - deviceData.padding.bottom;
    final maxDimension = math.min(deviceWidth, deviceHeight) - 48;
    final imageAspectRatio = imageInfo.image.height / imageInfo.image.width;
    final width = imageAspectRatio < 1
      ? maxDimension
      : maxDimension / imageAspectRatio;
    final height = imageAspectRatio > 1
      ? maxDimension
      : maxDimension * imageAspectRatio;
    final x = (deviceWidth - width) / 2;
    final y = (deviceHeight - height) / 2 + deviceData.padding.top;
    return _Dimension(
      x:x, y:y,
      width:width, height:height
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimension = this.imageInfo != null
      ? this.enlargeImage(this.imageInfo!)
      : null;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: widget.animation,
          child: Container(
            decoration: widget.decoration,
            child: widget.decoration?.borderRadius is BorderRadius
              ? ClipRRect(
                  borderRadius: widget.decoration!.borderRadius as BorderRadius,
                  child: this.child
                )
              : this.child
          ),
          builder: (context, child) =>
            Positioned(
              top: dimension != null
                ? Tween(begin:widget.y, end:dimension.y).evaluate(widget.animation)
                : widget.y,
              left: dimension != null
                ? Tween(begin:widget.x, end:dimension.x).evaluate(widget.animation)
                : widget.x,
              width: dimension != null
                ? Tween(begin:widget.width, end:dimension.width).evaluate(widget.animation)
                : widget.width,
              height: dimension != null
                ? Tween(begin:widget.height, end:dimension.height).evaluate(widget.animation)
                : widget.height,
              child: child!
            )
        )
      ]
    );
  }
}
class _Dimension {
  double x;
  double y;
  double width;
  double height;
  _Dimension({
    required this.x,
    required this.y,
    required this.width,
    required this.height
  });
}