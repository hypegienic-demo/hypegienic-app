import 'dart:math' as math;
import 'package:flutter/material.dart';

class Alert extends StatefulWidget {
  final bool update;
  Alert({
    required this.update
  });

  @override
  State<StatefulWidget> createState() => _AlertState();
}
class _AlertState extends State<Alert> with SingleTickerProviderStateMixin {
  late AnimationController _alertController;

  @override
  void initState() {
    super.initState();
    this._alertController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:1800),
      value: 0.0,
      lowerBound: 0,
      upperBound: 1
    );
    if(widget.update) {
      this.alert();
    }
  }
  @override
  void didUpdateWidget(Alert self) {
    super.didUpdateWidget(self);
    if(widget.update && !self.update) {
      this.alert();
    }
  }
  @override
  void dispose() {
    this._alertController.dispose();
    super.dispose();
  }

  alert() async {
    await this._alertController.animateTo(1);
    this._alertController.reset();
    if(widget.update) {
      this.alert();
    } 
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._alertController,
      builder: (context, child) {
        final animation = CurveTween(curve:Curves.slowMiddle).evaluate(this._alertController);
        return Transform(
          transform: Matrix4.identity()
            ..translate(6.0, 6.0)
            ..translate(
              (animation - 0.5) * 18.0,
              0.0
            )
            ..rotateZ(
              animation * 4 * math.pi
            )
            ..scale(
              math.min(animation, 0.5) * 2 +
              (math.max(animation, 0.5) - 0.5) * -2
            )
            ..translate(-6.0, -6.0),
          child: Container(
            height: 12,
            width: 12,
            color: Theme.of(context).colorScheme.error
          )
        );
      }
    );
  }
}