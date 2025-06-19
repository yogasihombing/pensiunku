import 'package:flutter/material.dart';
import 'package:pensiunku/model/faq_category_model.dart';
import 'package:pensiunku/repository/faq_repository.dart';
import 'package:pensiunku/model/result_model.dart';
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

    return Stack(
      children: [
        // Background Gradient
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

        // Konten utama dengan Scaffold transparan
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Color(0xFF017964), // Warna tombol back
            ),
            title: Text(
              'FAQ',
              style: TextStyle(
                color: Color(0xFF017964), // Warna title
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(); // atau pop(newIndex) jika perlu
              },
            ),
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => _refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height,
                      ),
                      FutureBuilder<ResultModel<List<FaqCategoryModel>>>(
                        future: _futureData,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.data?.isNotEmpty == true) {
                              List<FaqCategoryModel> data =
                                  snapshot.data!.data!;
                              return _buildBody(theme, data);
                            } else {
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  ErrorCard(
                                    title: 'Tidak dapat menampilkan FAQ',
                                    subtitle: snapshot.data?.error,
                                    iconData: Icons.warning_rounded,
                                  ),
                                ],
                              );
                            }
                          } else {
                            return Column(
                              children: [
                                const SizedBox(height: 16),
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

              // Bottom Navigation Bar jika digunakan
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

  Future<ResultModel<List<FaqCategoryModel>>> _refreshData() {
    return _futureData = FaqRepository().getAll().then((value) {
      if (value.error != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              value.error.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            elevation: 24.0,
          ),
        );
      }
      setState(() {});
      return value;
    });
  }

  Widget _buildBody(ThemeData theme, List<FaqCategoryModel> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        ...data.map(
          (faqCategory) => ItemFaqCategoryNew(
            model: faqCategory,
            onChangeBottomNavIndex: (newIndex) {
              Navigator.of(context).pop(newIndex);
            },
          ),
        ),
        const SizedBox(height: 80.0), // Space for BottomNavBar
      ],
    );
  }
}
