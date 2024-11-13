import 'package:flutter/material.dart';
import 'package:pensiunku/widget/button_text_field.dart';

class DummyCustomSelectField extends StatefulWidget {
  final String labelText;
  final String placeholderText;
  final void Function() onTap;
  final bool enabled;

  const DummyCustomSelectField({
    Key? key,
    required this.labelText,
    required this.placeholderText,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  _DummyCustomSelectFieldState createState() => _DummyCustomSelectFieldState();
}

class _DummyCustomSelectFieldState extends State<DummyCustomSelectField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ButtonTextField(
          title: widget.placeholderText,
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: 36.0,
          isFilled: false,
          labelText: '',
          color: Color(0xfff7f7f7),
        ),
      ],
    );
  }
}
