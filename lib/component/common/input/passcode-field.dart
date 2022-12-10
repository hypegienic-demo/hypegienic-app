import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasscodeField extends StatefulWidget {
  final Key? key;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final int digit;
  final String? placeholder;
  final bool? autofocus;
  final TextStyle? style;
  final EdgeInsets? scrollPadding;
  PasscodeField({
    this.key,
    required this.onChanged,
    this.onSubmitted,
    required this.digit,
    this.placeholder,
    this.autofocus,
    this.style,
    this.scrollPadding
  });

  @override
  State<StatefulWidget> createState() => _PasscodeFieldState();
}
class _PasscodeFieldState extends State<PasscodeField> with SingleTickerProviderStateMixin {
  TextEditingController _textFieldController;
  late AnimationController _focusController;
  FocusNode _focusNode;

  double _focus;
  String _value = '';

  _PasscodeFieldState() :
    this._textFieldController = TextEditingController(),
    this._focusNode = FocusNode(),
    this._focus = 1;

  @override
  void initState() {
    super.initState();
    this._textFieldController.addListener(() =>
      setState(() => this._value = this._textFieldController.value.text)
    );
    this._focusController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds:300),
      value: 1.0,
      lowerBound: 0,
      upperBound: 1
    );
    this._focusController.addListener(() =>
      setState(() => this._focus = this._focusController.value)
    );
    this._focusNode.addListener(() =>
      this._focusController.animateTo(this._focusNode.hasFocus? 0.0:1.0)
    );
  }
  @override
  void dispose() {
    this._textFieldController.dispose();
    this._focusController.dispose();
    this._focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this._focusNode.requestFocus(),
      child: CustomPaint(
        painter: _PasscodeFieldBorderPainter(
          digit: widget.digit,
          color: Theme.of(context).colorScheme.onSurface,
          progress: this._focus
        ),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(widget.digit, (index) {
                  final placeholder = widget.placeholder != null && this._value == '';
                  Widget text = Container(
                    width: 38,
                    child: Text(
                      placeholder && widget.placeholder!.length > index
                        ? widget.placeholder![index]
                        : this._value.length > index
                        ? this._value[index]
                        : '',
                      textAlign: TextAlign.left,
                      style: widget.style?? Theme.of(context).textTheme.bodyText1
                    )
                  );
                  if(placeholder) {
                    text = Opacity(
                      opacity: 0.5,
                      child: text
                    );
                  }
                  return text;
                }).toList(),
              ),
              Positioned(
                width: 38.0 * widget.digit,
                child: EditableText(
                  controller: this._textFieldController,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  focusNode: this._focusNode,
                  autofocus: widget.autofocus?? false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.digit)
                  ],
                  style: (widget.style?? Theme.of(context).textTheme.bodyText1!).copyWith(
                    color: Colors.transparent
                  ),
                  showCursor: false,
                  cursorColor: Colors.transparent,
                  backgroundCursorColor: Colors.transparent,
                  scrollPadding: widget.scrollPadding?? EdgeInsets.zero,
                )
              )
            ]
          )
        )
      )
    );
  }
}

class _PasscodeFieldBorderPainter extends CustomPainter {
  final Color? color;
  final int? digit;
  final double progress;
  final double? radius;
  _PasscodeFieldBorderPainter({
    this.color,
    this.digit,
    required this.progress,
    this.radius
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0.0, 0.0);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = this.color ?? Colors.transparent;

    final progress = this.progress * 0.95 + 0.05;
    final leftPathLength = size.width / 2 + size.height;
    final left = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, size.height);
    if(progress > 0) {
      final remaining = math.min(progress * leftPathLength, size.height);
      left..relativeLineTo(0, -remaining);
    }
    if(progress > size.height / leftPathLength) {
      final remaining = progress * leftPathLength - size.height;
      left..relativeLineTo(remaining, 0.0);
    }
    final bevel = 12.0;
    final bevelWidth = math.sqrt(math.pow(12, 2) * 2);
    final rightPathLength = size.width / 2 + size.height +
      bevelWidth / 2 - bevel;
    final right = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width - bevel, size.height)
      ..lineTo(size.width - bevel / 2, size.height - bevel / 2);
    if(progress > 0) {
      final remaining = math.min(
        progress * rightPathLength,
        bevelWidth / 2
      ) / bevelWidth * bevel;
      right..relativeLineTo(remaining, -remaining);
    }
    if(progress > bevelWidth / 2 / rightPathLength) {
      final remaining = math.max(
        math.min(
          progress * rightPathLength - bevelWidth / 2,
          size.height + bevelWidth / 2 - bevel
        ) - bevelWidth / 2,
        0.0
      );
      right..relativeLineTo(0, -remaining);
    }
    if(
      progress >
      (size.height + bevelWidth / 2 - bevel) / rightPathLength
    ) {
      final remaining = progress * rightPathLength - (
        size.height + bevelWidth / 2 - bevel
      );
      right..relativeLineTo(-remaining, 0);
    }

    if(this.digit != null && this.digit! > 1) {
      final lines = List.generate(this.digit!, (index) => (index + 1) * 38.0).toList();
      final progress = (1 - this.progress) * 0.85;
      lines.forEach((line) {
        canvas.drawLine(
          Offset(line, 0 + progress * size.height),
          Offset(line, size.height),
          borderPaint
        );
      });
    }

    canvas.drawPath(
      left,
      borderPaint
    );
    canvas.drawPath(
      right,
      borderPaint
    );
  }

  @override
  bool shouldRepaint(_PasscodeFieldBorderPainter self) {
    return self.progress != progress || self.color.toString() != color.toString();
  }
}