import 'package:flutter/material.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/widget/custom_text_field.dart';

class CustomSelectFieldBottomSheet extends StatefulWidget {
  final String searchLabelText;
  final List<OptionModel> options;
  final OptionModel? currentOption;
  final bool enableSearch;

  const CustomSelectFieldBottomSheet({
    Key? key,
    required this.searchLabelText,
    required this.options,
    this.currentOption,
    this.enableSearch = true,
  }) : super(key: key);

  @override
  _CustomSelectFieldBottomSheetState createState() =>
      _CustomSelectFieldBottomSheetState();
}

class _CustomSelectFieldBottomSheetState
    extends State<CustomSelectFieldBottomSheet> {
  String _searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    var finalOptions = widget.options.where(
      (option) => option.text.toLowerCase().contains(
            _searchKeyword.toLowerCase(),
          ),
    );

    return Wrap(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.enableSearch
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomTextField(
                        labelText: widget.searchLabelText,
                        onChanged: (newValue) {
                          setState(() {
                            _searchKeyword = newValue;
                          });
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.searchLabelText,
                        style: theme.textTheme.bodyText1?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ),
              Container(
                height: 400,
                child: ListView(
                  children: [
                    ...finalOptions.map(
                      (option) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: widget.currentOption?.id == option.id
                                      ? theme.textTheme.bodyText1
                                      : theme.textTheme.bodyText2,
                                ),
                              ),
                              if (widget.currentOption?.id == option.id)
                                Icon(Icons.check),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60.0),
                  ],
                ),
              ),
              // SizedBox(height: 60.0),
            ],
          ),
        ),
      ],
    );
  }
}
