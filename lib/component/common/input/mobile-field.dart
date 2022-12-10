import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './field.dart';
import './mask.dart';

final _digit10 = ['11', '15'];

class MobileInputField extends InputField {
  MobileInputField({
    Key? key,
    String? value,
    required void Function(String) onChanged,
    void Function(String)? onSubmitted,
    String? placeholder,
    bool? autofocus,
    TextStyle? style,
    EdgeInsets? scrollPadding
  }) :
    super(
      key: key,
      value: value,
      onChanged: (value) {
        final digits = value.replaceAll(RegExp(r'\D'), '');
        bool conformed = RegExp(_digit10.any(value.startsWith)? r'^\d{10}$' : r'^\d{9}$').hasMatch(digits);
        onChanged(conformed? '+60' + digits : '');
      },
      onSubmitted: onSubmitted,
      formatters: [
        MobileInputFormatter()
      ],
      keyboardType: TextInputType.phone,
      placeholder: placeholder,
      adornment: '+60',
      autofocus: autofocus,
      style: style,
      scrollPadding: scrollPadding
    );
}

String getConformedMobileNumber(String value) {
  final mask = _digit10.any(value.startsWith)
    ? ['/\\d/', '/\\d/', '-', '/\\d/', '/\\d/', '/\\d/', '/\\d/', ' ', '/\\d/', '/\\d/', '/\\d/', '/\\d/']
    : ['/\\d/', '/\\d/', '-', '/\\d/', '/\\d/', '/\\d/', ' ', '/\\d/', '/\\d/', '/\\d/', '/\\d/'];
  return conformToMask(value, mask);
}
class MobileInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldTextValue = oldValue.text;
    final newTextValue = newValue.text;
    if(oldTextValue == newTextValue) {
      return oldValue;
    } else if(newTextValue.length > 0) {
      final mask = _digit10.any(newTextValue.startsWith)
        ? ['/\\d/', '/\\d/', '-', '/\\d/', '/\\d/', '/\\d/', '/\\d/', ' ', '/\\d/', '/\\d/', '/\\d/', '/\\d/']
        : ['/\\d/', '/\\d/', '-', '/\\d/', '/\\d/', '/\\d/', ' ', '/\\d/', '/\\d/', '/\\d/', '/\\d/'];
      String conformed = conformToMask(newTextValue, mask);
      final modifiedValue = mask[conformed.length - 1];
      if(!modifiedValue.startsWith('/') || !modifiedValue.endsWith('/')) {
        conformed = conformed.substring(0, conformed.length - 1);
      }

      final addedMask = conformed.length - newValue.text.length;
      return TextEditingValue(
        text: conformed,
        selection: addedMask != 0
          ? newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset + addedMask,
            extentOffset: newValue.selection.extentOffset + addedMask
          )
          : newValue.selection
      );
    } else {
      return newValue;
    }
  }
}