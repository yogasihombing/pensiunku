import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/widget/item_faq.dart';

class FaqDetailScreenArguments {
  final FaqCategoryModel faqCategoryModel;

  FaqDetailScreenArguments({
    required this.faqCategoryModel,
  });
}

class FaqDetailScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/faq/detail';
  final FaqCategoryModel faqCategoryModel;

  const FaqDetailScreen({
    Key? key,
    required this.faqCategoryModel,
  }) : super(key: key);

  @override
  _FaqDetailScreenState createState() => _FaqDetailScreenState();
}

class _FaqDetailScreenState extends State<FaqDetailScreen> {
  bool _isBottomNavBarVisible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(context, 'FAQ', 2, (newIndex) {
        Navigator.of(context).pop(newIndex);
      }, () {
        Navigator.of(context).pop();
      }, useNotificationIcon: false),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 40.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Frequently Asked Questions (FAQ)',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headline5?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 60.0),
                            Text(
                              'Pertanyaan Seputar Pensiunku',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ...widget.faqCategoryModel.faqs.map(
                        (faq) => ItemFaq(
                          model: faq,
                        ),
                      ),
                      SizedBox(height: 80.0), // BottomNavBar
                    ],
                  ),
                ),
              ],
            ),
          ),
          // FloatingBottomNavigationBar(
          //   isVisible: _isBottomNavBarVisible,
          //   currentIndex: 2,
          //   onTapItem: (newIndex) {
          //     Navigator.of(context).pop(newIndex);
          //   },
          // ),
        ],
      ),
    );
  }
}
