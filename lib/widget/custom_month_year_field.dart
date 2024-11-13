import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/widget/button_text_field.dart';
import 'package:pensiunku/widget/grey_button.dart';
import 'package:pensiunku/widget/grey_select_button.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class CustomMonthYearField extends StatefulWidget {
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

  const CustomMonthYearField({
    Key? key,
    required this.labelText,
    required this.onChanged,
    this.currentValue,
    this.errorText,
    this.enabled = true,
    this.useLabel = true,
    this.buttonType = 'grey_button',
    this.fillColor = const Color.fromARGB(255, 226, 226, 226),
    this.hintText = 'Bulan dan Tahun Pensiun',
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  _CustomMonthYearFieldState createState() => _CustomMonthYearFieldState();
}

class _CustomMonthYearFieldState extends State<CustomMonthYearField> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String title = widget.currentValue != null
        ? DateFormat('MMMM yyyy').format(widget.currentValue!)
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
    showMonthPicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateUtils.addMonthsToMonthDate(DateTime.now(), 61),
      initialDate: widget.currentValue ?? DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          widget.onChanged(date);
        });
      }
    });
  }
}
