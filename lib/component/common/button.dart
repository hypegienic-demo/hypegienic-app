import 'dart:math' as math;
import 'package:flutter/material.dart';

import './stripe.dart';

enum ButtonSideBorder {
  beveled,
  bordered,
  extruded
}
class ButtonSideBorders {
  final ButtonSideBorder left;
  final ButtonSideBorder right;
  ButtonSideBorders({
    this.left = ButtonSideBorder.beveled,
    this.right = ButtonSideBorder.beveled
  });
}
class AnimationSumClamp extends CompoundAnimation<double> {
  double? clamp;
  AnimationSumClamp(Animation<double> first, Animation<double> next, {
    this.clamp
  }) :
    super(first:first, next:next);

  @override
  double get value => this.clamp != null
    ? math.min(first.value + next.value, this.clamp!)
    : first.value + next.value;
}
class Button extends StatefulWidget {
  final Key? key;
  final void Function()? onTap;
  final String label;
  final Color? color;
  final Color? highlightColor;
  final bool loading;
  final ButtonSideBorders sideBorders;
  Button({
    this.key,
    this.onTap,
    required this.label,
    this.color,
    this.highlightColor,
    bool? loading,
    ButtonSideBorders? sideBorders
  }) :
    this.loading = loading?? false,
    this.sideBorders = sideBorders?? ButtonSideBorders();

  @override
  State<StatefulWidget> createState() => _ButtonState();
}
class _ButtonState extends State<Button> with TickerProviderStateMixin {
  late AnimationController tapController;
  late AnimationController loadingController;

  late List<int> positions;

  @override
  void initState() {
    super.initState();
    this.positions = List.generate(
      widget.label.split(' ').length,
      (index) => math.Random().nextInt(3) - 1
    );
    this.tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    this.loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    Listenable.merge([
      this.tapController,
      this.loadingController
    ]).addListener(() =>
      setState(() {})
    );
  }
  @override
  void didUpdateWidget(Button self) {
    super.didUpdateWidget(self);
    if(widget.loading != self.loading) {
      this.loadingController.animateTo(widget.loading? 1.0:0.0);
    }
  }
  @override
  void dispose() {
    this.tapController.dispose();
    this.loadingController.dispose();
    super.dispose();
  }

  bool _tapped = false;
  void onTap(Direction direction) {
    if(direction == Direction.Down) {
      final complete = this.tapController.animateTo(1);
      this._tapped = true;
      complete.then((_) {
        if(!this._tapped) this.tapController.animateTo(0);
        else this._tapped = false;
      });
    } else {
      if(this._tapped) this._tapped = false;
      else this.tapController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.highlightColor?? Theme.of(context).colorScheme.primaryVariant;
    final loading = AnimationSumClamp(
      this.tapController,
      this.loadingController,
      clamp: 1.0
    );
    return GestureDetector(
      key: widget.key,
      onTapDown: (event) => this.onTap(Direction.Down),
      onTapUp: (event) => this.onTap(Direction.Up),
      onTapCancel: () => this.onTap(Direction.Up),
      onTap: () {
        if(!widget.loading && widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            Tween(begin:1.0, end:0.98).evaluate(this.tapController)
          ),
        child: Material(
          clipBehavior: Clip.none,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: widget.sideBorders.left == ButtonSideBorder.beveled
                ? Radius.circular(12)
                : Radius.zero,
              bottomRight: widget.sideBorders.right == ButtonSideBorder.beveled
                ? Radius.circular(12)
                : Radius.zero
            ),
          ),
          child: CustomPaint(
            painter: _ButtonBorder(
              borderColor: background,
              backgroundColor: Theme.of(context).colorScheme.background,
              borders: widget.sideBorders
            ),
            child: Container(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    height: 44,
                    padding: EdgeInsets.symmetric(vertical:6, horizontal:24),
                    child: Opacity(
                      opacity: loading.value,
                      child: Center(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button?.copyWith(
                            color: background
                          )
                        )
                      )
                    )
                  ),
                  Positioned(
                    top:6, bottom:6, left:6, right:6,
                    child: Opacity(
                      opacity: loading.value,
                      child: ClipPath(
                        clipper: ShapeBorderClipper(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: widget.sideBorders.left == ButtonSideBorder.beveled
                                ? Radius.circular(8)
                                : Radius.zero,
                              bottomRight: widget.sideBorders.right == ButtonSideBorder.beveled
                                ? Radius.circular(8)
                                : Radius.zero
                            )
                          )
                        ),
                        child: StripeBackground(
                          label: widget.label,
                          color: background
                        )
                      )
                    )
                  ),
                  Positioned(
                    top:6, bottom:6, left:10, right:10,
                    child: Opacity(
                      opacity: 1.0 - loading.value,
                      child: Center(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button?.copyWith(
                            color: background
                          )
                        )
                      )
                    )
                  )
                  // ...List.generate(
                  //   widget.label.split(' ').length,
                  //   (index) {
                  //     final position = positions[index];
                  //     final text = Center(
                  //       child: Padding(
                  //         padding: EdgeInsets.symmetric(horizontal:10),
                  //         child: RichText(
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis,
                  //           textAlign: TextAlign.center,
                  //           text: TextSpan(
                  //             text: '',
                  //             style: Theme.of(context).textTheme.button?.copyWith(
                  //               color: Colors.transparent
                  //             ),
                  //             children: widget.label.split(' ')
                  //               .asMap().entries
                  //               .map((entry) =>
                  //                 TextSpan(
                  //                   text: entry.value + ' ',
                  //                   style: entry.key == index
                  //                     ? Theme.of(context).textTheme.button
                  //                     : Theme.of(context).textTheme.button?.copyWith(
                  //                         color: Colors.transparent
                  //                       )
                  //                 )
                  //               )
                  //               .toList()
                  //           )
                  //         )
                  //       )
                  //     );
                  //     return [
                  //       Positioned(
                  //         top: Tween(begin:0.0, end:(position == -1? 0:-1) * 8.0).evaluate(this.tapController),
                  //         bottom: Tween(begin:0.0, end:(position == -1? 0:-1) * -8.0).evaluate(this.tapController),
                  //         left:0, right:0,
                  //         child: ClipRect(
                  //           clipper: _CustomClipperRect(
                  //             direction: position == -1
                  //               ? Direction.Down
                  //               : Direction.Up
                  //           ),
                  //           child: Opacity(
                  //             opacity: 0.7,
                  //             child: text
                  //           )
                  //         )
                  //       ),
                  //       Positioned(
                  //         top: Tween(begin:0.0, end:position * 8.0).evaluate(this.tapController),
                  //         bottom: Tween(begin:0.0, end:position * -8.0).evaluate(this.tapController),
                  //         left:0, right:0,
                  //         child: text
                  //       ),
                  //       Positioned(
                  //         top: Tween(begin:0.0, end:(position == 1? 0:1) * 8.0).evaluate(this.tapController),
                  //         bottom: Tween(begin:0.0, end:(position == 1? 0:1) * -8.0).evaluate(this.tapController),
                  //         left:0, right:0,
                  //         child: ClipRect(
                  //           clipper: _CustomClipperRect(
                  //             direction: position == 1
                  //               ? Direction.Up
                  //               : Direction.Down
                  //           ),
                  //           child: Opacity(
                  //             opacity: 0.7,
                  //             child: text
                  //           )
                  //         )
                  //       )
                  //     ];
                  //   }
                  // ).expand((widget) => widget).toList(),
                ]
              )
            )
          )
        )
      )
    );
  }
}
enum Direction {
  Up,
  Down
}

class _ButtonBorder extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;
  final ButtonSideBorders borders;
  _ButtonBorder({
    required this.borderColor,
    required this.backgroundColor,
    required this.borders
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = this.borderColor
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final background = Paint()
      ..color = this.backgroundColor
      ..style = PaintingStyle.fill;
    final path = Path();
    if(borders.left == ButtonSideBorder.beveled) {
      path.moveTo(math.min(12.5, size.width - 0.5), 1);
    } else {
      path.moveTo(1, 1);
    }
    path.lineTo(size.width - 1, 1);
    if(borders.right == ButtonSideBorder.beveled) {
      path.lineTo(size.width - 1, math.max(0.5, size.height - 12.5));
      path.lineTo(math.max(0.5, size.width - 12.5), size.height - 1);
    } else if(borders.right == ButtonSideBorder.bordered) {
      path.lineTo(size.width - 1, size.height - 1);
    } else {
      path.lineTo(size.width + 1, 1);
      path.lineTo(size.width + 1, size.height - 1);
      path.lineTo(size.width - 1, size.height - 1);
    }
    path.lineTo(1, size.height - 1);
    if(borders.left == ButtonSideBorder.beveled) {
      path.lineTo(1, math.min(12.5, size.height - 0.5));
      path.lineTo(math.min(12.5, size.width - 0.5), 1);
    } else if(borders.left == ButtonSideBorder.bordered) {
      path.lineTo(1, 1);
    } else {
      path.lineTo(-1, size.height - 1);
      path.lineTo(-1, 1);
      path.lineTo(1, 1);
    }
    canvas.drawPath(path, background);
    canvas.drawPath(path, border);
  }
  @override
  bool shouldRepaint(_ButtonBorder oldDelagate) =>
    this.borderColor != oldDelagate.borderColor ||
    this.backgroundColor != oldDelagate.backgroundColor ||
    this.borders != oldDelagate.borders;
}

class StripeBackground extends StatefulWidget {
  final String label;
  final Color color;
  StripeBackground({
    this.label = '',
    required this.color
  });

  @override
  State<StatefulWidget> createState() => _StripeBackgroundState();
}
class _StripeBackgroundState extends State<StripeBackground> with TickerProviderStateMixin {
  late AnimationController _translateController;

  @override
  void initState() {
    super.initState();
    this._translateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:3200),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 32.0
    );
    this._translateController.repeat();
  }
  @override
  void dispose() {
    this._translateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._translateController,
      builder: (context, child) => Stack(
        children: [
          Container(height:32),
          Positioned(
            top:0, bottom:0, left:0, right:0,
            child: Stripes(
              color: widget.color,
              translate: this._translateController.value
            )
          ),
          Positioned(
            top:0, bottom:0, left:0, right:0,
            child: ClipPath(
              clipper: _CustomClipperStripe(
                translate: this._translateController.value
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:4),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.button?.copyWith(
                      color: Theme.of(context).colorScheme.background
                    )
                  )
                )
              )
            )
          )
        ]
      )
    );
  }
}
class _CustomClipperStripe extends CustomClipper<Path> {
  final double translate;
  _CustomClipperStripe({
    required this.translate
  });

  @override
  Path getClip(Size size) =>
    getStripePath(size, this.translate, StripeSize(
      lineWidth: 16,
      gapWidth: 16
    ));

  @override
  bool shouldReclip(_CustomClipperStripe oldClipper) =>
    this.translate != oldClipper.translate;
}

class IllustrationButton extends StatefulWidget {
  final Key? key;
  final void Function()? onTap;
  final bool selected;
  final Widget child;
  IllustrationButton({
    this.key,
    this.onTap,
    bool? selected,
    required this.child,
  }) :
    this.selected = selected == true;

  @override
  State<StatefulWidget> createState() => _IllustrationButtonState();
}
class _IllustrationButtonState extends State<IllustrationButton> with TickerProviderStateMixin {
  late AnimationController tapController;
  late AnimationController selectedController;

  @override
  void initState() {
    super.initState();
    this.tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:100),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    this.selectedController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    Listenable.merge([
      this.tapController,
      this.selectedController
    ]).addListener(() =>
      setState(() {})
    );
  }
  @override
  void didUpdateWidget(IllustrationButton self) {
    super.didUpdateWidget(self);
    if(widget.selected != self.selected) {
      this.selectedController.animateTo(widget.selected? 1.0:0.0);
    }
  }
  @override
  void dispose() {
    this.tapController.dispose();
    super.dispose();
  }

  bool _tapped = false;
  void onTap(Direction direction) {
    if(direction == Direction.Down) {
      final complete = this.tapController.animateTo(1);
      this._tapped = true;
      complete.then((_) {
        if(!this._tapped) this.tapController.animateTo(0);
        else this._tapped = false;
      });
    } else {
      if(this._tapped) this._tapped = false;
      else this.tapController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.key,
      onTapDown: (event) => this.onTap(Direction.Down),
      onTapUp: (event) => this.onTap(Direction.Up),
      onTapCancel: () => this.onTap(Direction.Up),
      onTap: widget.onTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            Tween(begin:1.0, end:0.9).evaluate(this.tapController)
          ),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(
              width: Tween(begin:1.0, end:3.0).evaluate(this.selectedController),
              color: ColorTween(
                begin: Theme.of(context).colorScheme.onBackground,
                end: Theme.of(context).colorScheme.onSurface
              ).evaluate(this.selectedController)!
            )
          ),
          padding: EdgeInsets.all(
            Tween(begin:18.0, end:16.0).evaluate(this.selectedController)
          ),
          child: Opacity(
            opacity: Tween(begin:0.5, end:0.9).evaluate(this.selectedController),
            child: widget.child
          )
        )
      )
    );
  }
}