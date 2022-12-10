import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../asset/graphic/icon/error.dart';

class InlineError extends StatefulWidget {
  final String? error;
  InlineError(this.error);

  @override
  State<StatefulWidget> createState() => _InlineErrorState();
}
class _InlineErrorState extends State<InlineError> with TickerProviderStateMixin {
  late AnimationController appearController;
  late AnimationController shakeController;
  String? error;

  @override
  void initState() {
    super.initState();
    appearController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: widget.error != null? 1:0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
    shakeController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: -10.0,
      upperBound: 10.0
    );
  }
  @override
  void didUpdateWidget(InlineError self) {
    super.didUpdateWidget(self);
    if(widget.error != self.error) {
      if(widget.error != null) {
        setState(() => this.error = widget.error);
        this.shake();
      }
      appearController.animateTo(widget.error != null? 1:0).then((_) {
        if(widget.error == null) setState(() => this.error = null);
      });
    }
  }
  @override
  void dispose() {
    appearController.dispose();
    shakeController.dispose();
    super.dispose();
  }

  shake() async {
    shakeController.reset();
    final duration = Duration(milliseconds:80);
    for(var i = 0; i < 3; i++) {
      await shakeController.animateTo(-10, duration:duration);
      await shakeController.animateTo(i == 2? 0:10, duration:duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;

    return Container(
      width: [width, 360.0].reduce(math.min),
      padding: EdgeInsets.symmetric(horizontal:48, vertical:16),
      child: AnimatedBuilder(
      animation: Listenable.merge([this.appearController, this.shakeController]),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              borderRadius: BorderRadius.circular(16)
            ),
            padding: EdgeInsets.symmetric(horizontal:8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(right:8),
                  child: ErrorIcon(
                    size: Size.square(16),
                    color: Theme.of(context).colorScheme.onError
                  )
                ),
                Flexible(
                  child: Text(
                    this.error?? '',
                    style: Theme.of(context).textTheme.caption
                  )
                )
              ]
            )
          )
        ),
        builder: (context, child) => Opacity(
          opacity: Tween(begin:0.0, end:1.0).evaluate(this.appearController),
          child: Transform.translate(
            offset: Offset(this.shakeController.value, 0),
            child: child
          )
        )
      )
    );
  }
}