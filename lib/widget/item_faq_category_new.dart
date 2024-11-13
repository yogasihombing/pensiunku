import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/screen/home/account/faq/faq_detail_screen.dart';
import 'package:pensiunku/widget/grey_button.dart';

class ItemFaqCategoryNew extends StatelessWidget {
  final FaqCategoryModel model;
  final void Function(int index) onChangeBottomNavIndex;

  const ItemFaqCategoryNew({
    Key? key,
    required this.model,
    required this.onChangeBottomNavIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GreyButton(
        title: model.name,
        color: Color(0xfff7f7f7),
        borderRadius: 36.0,
        onTap: () {
          Navigator.of(context)
              .pushNamed(
            FaqDetailScreen.ROUTE_NAME,
            arguments: FaqDetailScreenArguments(
              faqCategoryModel: model,
            ),
          )
              .then(
            (newIndex) {
              if (newIndex is int) {
                onChangeBottomNavIndex(newIndex);
              }
            },
          );
        },
      ),
    );
  }
}
