import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/widget/button_text_field.dart';
import 'package:pensiunku/widget/grey_button.dart';
import 'package:pensiunku/widget/grey_select_button.dart';

class CustomDateField extends StatefulWidget {
  final String labelText;
  final void Function(DateTime?) onChanged;
  final DateTime? currentValue;
  final bool enabled;
  final String buttonType;
  final bool useLabel;
  final Color fillColor;
  final String? errorText;
  final String hintText;
  final double borderRadius;
  final DateTime lastDate;

  const CustomDateField({
    Key? key,
    required this.labelText,
    required this.onChanged,
    required this.lastDate,
    this.currentValue,
    this.errorText,
    this.enabled = true,
    this.useLabel = true,
    this.buttonType = 'grey_button',
    this.fillColor = const Color.fromARGB(255, 226, 226, 226),
    this.hintText = 'yyyy-mm-dd',
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  _CustomDateFieldState createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String title = widget.currentValue != null
        ? DateFormat('yyyy-MM-dd').format(widget.currentValue!)
        : widget.hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.useLabel)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.labelText,
                style: theme.textTheme.bodyText1?.copyWith(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4.0),
            ],
          ),
        if (widget.buttonType == 'grey_button')
          GreyButton(
            title: title,
            onTap: widget.enabled ? _onTap : null,
            borderRadius: widget.borderRadius,
            color: widget.fillColor,
          ),
        if (widget.buttonType == 'grey_select_button')
          GreySelectButton(
            title: title,
            onTap: widget.enabled ? _onTap : null,
            borderRadius: widget.borderRadius,
            showIcon: false,
            color: widget.fillColor,
          ),
        if (widget.buttonType == 'button_text_field')
          ButtonTextField(
            title: title,
            onTap: widget.enabled ? _onTap : null,
            borderRadius: widget.borderRadius,
            color: widget.fillColor,
            labelText: widget.labelText,
            isFilled: widget.currentValue != null,
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 16.0,
            ),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.caption?.copyWith(
                color: theme.errorColor,
              ),
            ),
          ),
      ],
    );
  }

  void _onTap() {
    FocusScope.of(context).unfocus();
    showDatePicker(
      context: context,
      currentDate: widget.currentValue,
      initialDate: widget.currentValue ?? DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: widget.lastDate,
    ).then((value) {
      if (value != null) {
        widget.onChanged(value);
      }
    });
  }
}
