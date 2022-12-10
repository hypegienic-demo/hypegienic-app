import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './field.dart';

class EmailInputField extends InputField {
  EmailInputField({
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
        bool conformed = RegExp(
          r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'
        ).hasMatch(value);
        onChanged(conformed? value : '');
      },
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      placeholder: placeholder,
      autofocus: autofocus,
      style: style,
      scrollPadding: scrollPadding
    );
}
