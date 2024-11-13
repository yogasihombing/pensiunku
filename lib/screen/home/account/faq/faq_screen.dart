import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/repository/faq_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';
import 'package:pensiunku/widget/item_faq_category_new.dart';

class FaqScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/faq';

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _isBottomNavBarVisible = false;
  late Future<ResultModel<List<FaqCategoryModel>>> _futureData;

  @override
  void initState() {
    super.initState();

    _refreshData();
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
          RefreshIndicator(
            onRefresh: () {
              return _refreshData();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height,
                  ),
                  FutureBuilder(
                    future: _futureData,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<List<FaqCategoryModel>>>
                            snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data?.isNotEmpty == true) {
                          List<FaqCategoryModel> data = snapshot.data!.data!;
                          return _buildBody(theme, data);
                        } else {
                          String errorTitle = 'Tidak dapat menampilkan FAQ';
                          String? errorSubtitle = snapshot.data?.error;
                          return Column(
                            children: [
                              SizedBox(height: 16),
                              ErrorCard(
                                title: errorTitle,
                                subtitle: errorSubtitle,
                                iconData: Icons.warning_rounded,
                              ),
                            ],
                          );
                        }
                      } else {
                        return Column(
                          children: [
                            SizedBox(height: 16),
                            Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
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

  _refreshData() {
    return _futureData = FaqRepository().getAll().then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
        // WidgetUtil.showSnackbar(
        //   context,
        //   value.error.toString(),
        // );
      }
      setState(() {});
      return value;
    });
  }

  Widget _buildBody(ThemeData theme, List<FaqCategoryModel> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
        SizedBox(height: 8.0),
        ...data.map(
          (faqCategory) => ItemFaqCategoryNew(
            model: faqCategory,
            onChangeBottomNavIndex: (newIndex) {
              Navigator.of(context).pop(newIndex);
            },
          ),
        ),
        SizedBox(height: 80.0), // BottomNavBar
      ],
    );
  }
}
