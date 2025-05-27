import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/widget/item_faq.dart';

class FaqDetailScreenArguments {
  final FaqCategoryModel faqCategoryModel;

  FaqDetailScreenArguments({required this.faqCategoryModel});
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
    Future.delayed(Duration.zero, () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Stack(
      children: [
        // Background gradasi
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFDCE293), // gradasi hijau kekuningan
              ],
              stops: [0.6, 1.0],
            ),
          ),
        ),

        // Scaffold dengan AppBar transparan dan body konten
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'FAQ',
              style: TextStyle(
                color: Color(0xFF017964),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40.0),
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
                            const SizedBox(height: 60.0),
                            Text(
                              'Pertanyaan Seputar Pensiunku',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ...widget.faqCategoryModel.faqs.map(
                        (faq) => ItemFaq(model: faq),
                      ),
                      const SizedBox(height: 80.0), // Untuk space BottomNavBar
                    ],
                  ),
                ),
              ),

              // FloatingBottomNavigationBar jika diperlukan
              // FloatingBottomNavigationBar(
              //   isVisible: _isBottomNavBarVisible,
              //   currentIndex: 2,
              //   onTapItem: (newIndex) {
              //     Navigator.of(context).pop(newIndex);
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }
}