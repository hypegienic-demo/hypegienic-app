import 'package:flutter/material.dart';

class Touchable extends StatefulWidget {
  final Key? key;
  final void Function()? onTap;
  final Widget child;
  final EdgeInsets? padding;
  final bool disabled;
  Touchable({this.key, this.onTap, required this.child, this.padding, bool? disabled}) :
    this.disabled = disabled?? false;

  @override
  State<StatefulWidget> createState() => _TouchableState();
}
class _TouchableState extends State<Touchable> with SingleTickerProviderStateMixin {
  late AnimationController tapController;

  @override
  void initState() {
    super.initState();
    tapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:100),
      value: widget.disabled? 0.5:1.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
  }
  @override
  void didUpdateWidget(Touchable self) {
    super.didUpdateWidget(self);
    if(widget.disabled != self.disabled) {
      tapController.animateTo(widget.disabled? 0.5:1.0);
    }
  }
  @override
  void dispose() {
    tapController.dispose();
    super.dispose();
  }

  bool _tapped = false;
  void onTap(_Direction direction) {
    if(!widget.disabled) {
      if(direction == _Direction.Down) {
        final complete = this.tapController.animateTo(0.0);
        this._tapped = true;
        complete.then((_) {
          if(!this._tapped) this.tapController.animateTo(1.0);
          else this._tapped = false;
        });
      } else {
        if(this._tapped) this._tapped = false;
        else this.tapController.animateTo(1.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    if(widget.padding != null)
      child = Padding(padding:widget.padding!, child:widget.child);
    return GestureDetector(
      key: widget.key,
      onTapDown: (event) => this.onTap(_Direction.Down),
      onTapUp: (event) => this.onTap(_Direction.Up),
      onTapCancel: () => this.onTap(_Direction.Up),
      onTap: !widget.disabled? widget.onTap : null,
      child: AnimatedBuilder(
        animation: tapController,
        child: child,
        builder: (context, child) => Opacity(
          opacity: Tween(begin:0.2, end:1.0).evaluate(this.tapController),
          child: child
        )
      )
    );
  }
}
enum _Direction {
  Up,
  Down
}