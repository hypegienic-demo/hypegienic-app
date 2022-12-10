import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final Key? key;
  final String? value;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final String? placeholder;
  final String? adornment;
  final bool? autofocus;
  final TextStyle? style;
  final EdgeInsets? scrollPadding;
  InputField({
    this.key,
    this.value,
    required this.onChanged,
    this.onSubmitted,
    this.formatters,
    this.keyboardType,
    this.textCapitalization,
    this.placeholder,
    this.adornment,
    this.autofocus,
    this.style,
    this.scrollPadding
  });

  @override
  State<StatefulWidget> createState() => _InputFieldState(
    value: this.value
  );
}
class _InputFieldState extends State<InputField> with SingleTickerProviderStateMixin {
  GlobalKey _editableText;
  TextEditingController _textFieldController;
  late AnimationController _focusController;
  FocusNode _focusNode;

  double _focus;
  bool _empty;

  _InputFieldState({
    required String? value
  }) :
    this._editableText = GlobalKey(),
    this._textFieldController = TextEditingController(text:value),
    this._focusNode = FocusNode(),
    this._focus = 1,
    this._empty = true;

  @override
  void initState() {
    super.initState();
    this._textFieldController.addListener(() {
      final empty = this._textFieldController.value.text == '';
      if(this._empty != empty) {
      setState(() => this._empty = empty);
      }
    });
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
  void didUpdateWidget(InputField self) {
    super.didUpdateWidget(self);
    if(widget.value != self.value) {
      this._textFieldController.value = this._textFieldController.value.copyWith(
        text: widget.value
      );
    }
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
    Widget editable = EditableText(
      key: this._editableText,
      controller: this._textFieldController,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      inputFormatters: (widget.formatters?.length?? 0) > 0
        ? widget.formatters
        : null,
      focusNode: this._focusNode,
      autofocus: widget.autofocus?? false,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization?? TextCapitalization.none,
      style: widget.style?? Theme.of(context).textTheme.bodyText1!,
      cursorColor: Color.fromRGBO(79, 139, 108, 1),
      backgroundCursorColor: Color.fromRGBO(79, 139, 108, 1),
      selectionColor: Color.fromRGBO(79, 139, 108, 0.2),
      cursorOpacityAnimates: true,
      scrollPadding: widget.scrollPadding?? EdgeInsets.zero,
    );
    if(widget.placeholder != null && this._empty) {
      editable = Stack(
        children: [
          editable,
          Opacity(
            opacity: 0.5,
            child: Text(
              widget.placeholder!,
              style: widget.style?? Theme.of(context).textTheme.bodyText1,
            )
          )
        ]
      );
    }
    if(widget.adornment != null) {
      editable = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.adornment!,
            style: widget.style?? Theme.of(context).textTheme.bodyText1
          ),
          Expanded(
            child: editable
          )
        ]
      );
    } else {
      editable = Center(
        child: editable
      );
    }
    return GestureDetector(
      onTap: () => this._focusNode.requestFocus(),
      child: CustomPaint(
        painter: _InputFieldBorderPainter(
          color: Theme.of(context).colorScheme.onSurface,
          progress: this._focus
        ),
        child: Container(
          padding: EdgeInsets.all(12),
          child: editable
        )
      )
    );
  }
}

class _InputFieldBorderPainter extends CustomPainter {
  final Color? color;
  final double progress;
  final double? radius;
  _InputFieldBorderPainter({
    this.color,
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
  bool shouldRepaint(_InputFieldBorderPainter self) {
    return self.progress != progress || self.color.toString() != color.toString();
  }
}