import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class Checkbox extends StatefulWidget {
  final bool checked;
  final void Function() onCheck;
  final String label;
  final String? description;
  Checkbox({
    required this.checked,
    required this.onCheck,
    required this.label,
    this.description
  });

  @override
  State<StatefulWidget> createState() => _CheckboxState(
    checked: this.checked
  );
}
class _CheckboxState extends State<Checkbox> with TickerProviderStateMixin {
  late AnimationController _checkController;
  String _checkBoxAnimation;
  bool _snapToEnd;

  _CheckboxState({
    required bool checked
  }) :
    _checkBoxAnimation = checked? 'check':'uncheck',
    _snapToEnd = true;

  @override
  void initState() {
    super.initState();
    this._checkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: widget.checked? 1.0:0.0,
      lowerBound: 0.0,
      upperBound: 1.0
    );
  }
  @override
  void didUpdateWidget(Checkbox self) {
    super.didUpdateWidget(self);
    if(widget.checked != self.checked) {
      _checkController.animateTo(widget.checked? 1.0:0.0);
      setState(() {
        _checkBoxAnimation = widget.checked? 'check':'uncheck';
        _snapToEnd = false;
      });
    }
  }
  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._checkController,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: Tween(begin:1.0, end:2.0).evaluate(this._checkController),
            color: ColorTween(
              begin: Theme.of(context).colorScheme.onBackground,
              end: Theme.of(context).colorScheme.onSurface
            ).evaluate(this._checkController)!
          )
        ),
        child: GestureDetector(
          onTap: widget.onCheck,
          child: Container(
            padding: EdgeInsets.all(
              Tween(begin:12.0, end:11.0).evaluate(this._checkController)
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24.0,
                  width: 32.0,
                  padding: EdgeInsets.only(right:8),
                  child: ClipRect(
                    child: Transform.scale(
                      scale: 6.4,
                      child: FlareActor(
                        'lib/asset/animation/checkbox.flr',
                        fit: BoxFit.contain,
                        animation: this._checkBoxAnimation,
                        snapToEnd: this._snapToEnd
                      )
                    )
                  )
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.headline5?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(
                            Tween(begin:0.5, end:1.0).evaluate(this._checkController)
                          )
                        )
                      ),
                      widget.description != null
                        ? Text(
                            widget.description!,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(
                                Tween(begin:0.5, end:1.0).evaluate(this._checkController)
                              )
                            )
                          )
                        : null
                    ].whereType<Widget>().toList()
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}