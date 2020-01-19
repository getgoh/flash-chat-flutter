import 'package:flutter/material.dart';

import '../constants.dart';

class InputTextField extends StatelessWidget {
  final Function onTextChanged;
  final TextInputType inputType;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;

  const InputTextField({
    this.onTextChanged,
    this.inputType,
    this.hintText,
    this.prefixIcon,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            obscureText: obscureText ?? false,
            onChanged: onTextChanged,
            keyboardType: inputType ?? TextInputType.text,
            textAlign: TextAlign.center,
            style: kTextFieldTextStyle,
            decoration: kTextFieldDecoration.copyWith(
              hintText: hintText,
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
