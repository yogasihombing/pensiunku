import 'package:flutter/material.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/widget/button_text_field.dart';
import 'package:pensiunku/widget/custom_select_field_bottom_sheet.dart';
import 'package:pensiunku/widget/grey_button.dart';
import 'package:pensiunku/widget/grey_select_button.dart';

class CustomSelectField extends StatefulWidget {
  final String labelText;
  final bool enableSearch;
  final String searchLabelText;
  final List<OptionModel> options;
  final void Function(OptionModel) onChanged;
  final OptionModel? currentOption;
  final bool enabled;
  final String buttonType;
  final IconData? iconData;
  final TextAlign? textAlign;
  final String hintText;
  final double borderRadius;
  final bool useLabel;
  final Color fillColor;
  final String? errorText;
  final TextStyle? textStyle;

  const CustomSelectField({
    Key? key,
    required this.labelText,
    required this.searchLabelText,
    required this.options,
    required this.onChanged,
    this.enableSearch = true,
    this.currentOption,
    this.enabled = true,
    this.buttonType = 'grey_button',
    this.iconData = Icons.chevron_right,
    this.textAlign = TextAlign.start,
    this.hintText = 'Belum pilih',
    this.useLabel = true,
    this.borderRadius = 8.0,
    this.fillColor = const Color.fromARGB(255, 226, 226, 226),
    this.errorText,
    this.textStyle,
  }) : super(key: key);

  @override
  _CustomSelectFieldState createState() => _CustomSelectFieldState();
}

class _CustomSelectFieldState extends State<CustomSelectField> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String title =
        widget.currentOption != null && widget.currentOption?.text != ''
            ? widget.currentOption!.text
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
            textStyle: widget.textStyle ??
                TextStyle(fontSize: 12.0), // Atur default ukuran font
          ),
        if (widget.buttonType == 'grey_select_button')
          GreySelectButton(
            title: title,
            onTap: widget.enabled ? _onTap : null,
            borderRadius: widget.borderRadius,
            iconData: widget.iconData,
            textAlign: widget.textAlign,
            color: widget.fillColor,
            textStyle: widget.textStyle ??
                TextStyle(fontSize: 12.0), // Atur default ukuran font
          ),
        if (widget.buttonType == 'button_text_field')
          ButtonTextField(
            title: title,
            onTap: widget.enabled ? _onTap : null,
            borderRadius: widget.borderRadius,
            color: widget.fillColor,
            labelText: widget.labelText,
            isFilled: widget.currentOption != null &&
                widget.currentOption?.text != '',
            useIcon: true,
            textStyle: widget.textStyle ??
                TextStyle(fontSize: 12.0), // Atur default ukuran font
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
    showModalBottomSheet<OptionModel>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CustomSelectFieldBottomSheet(
          enableSearch: widget.enableSearch,
          searchLabelText: widget.searchLabelText,
          options: widget.options,
          currentOption: widget.currentOption,
        );
      },
    ).then((value) {
      if (value != null) {
        widget.onChanged(value);
      }
    });
  }
}
