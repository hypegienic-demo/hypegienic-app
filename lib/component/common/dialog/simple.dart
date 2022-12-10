import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<T?> showSimpleDialog<T extends Object?>({
  Key? key,
  required BuildContext context,
  required Widget child
}) =>
  showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context)
      .modalBarrierDismissLabel,
    barrierColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
    transitionDuration: Duration(milliseconds:300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final deviceData = MediaQuery.of(context);
      final height = deviceData.size.height;
      return Transform(
        transform: Matrix4.translationValues(
          0.0,
          (1 - animation.value) * height,
          0.0
        ),
        child: child
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) =>
      _SimpleModal(
        key: key,
        child: child
      )
  );

class _SimpleModal extends StatelessWidget {
  final Key? key;
  final Widget child;
  _SimpleModal({
    this.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    final deviceData = MediaQuery.of(context);
    final width = deviceData.size.width;
    final height = deviceData.size.height;
    final top = deviceData.padding.top;
    final bottom = deviceData.padding.bottom;
    final insetTop = deviceData.viewInsets.top;
    final insetBottom = deviceData.viewInsets.bottom;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: height - top - bottom - insetTop - insetBottom - 32
        ),
        child: Container(
          key: this.key,
          width: math.min(480, width - 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface
          ),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: this.child
          )
        )
      )
    );
  }
}