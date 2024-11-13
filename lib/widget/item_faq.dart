import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_model.dart';

class ItemFaq extends StatefulWidget {
  final FaqModel model;

  const ItemFaq({
    Key? key,
    required this.model,
  }) : super(key: key);
  @override
  _ItemFaqState createState() => _ItemFaqState();
}

class _ItemFaqState extends State<ItemFaq> with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isOpen = !_isOpen;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  !_isOpen ? Icons.expand_more : Icons.expand_less,
                  color: Colors.green,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    widget.model.question,
                    style: theme.textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 100),
          child: _isOpen
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 42.0,
                    bottom: 16.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    child: Text(widget.model.answer),
                  ),
                )
              : Container(
                  width: double.infinity,
                ),
        )
      ],
    );
  }
}
