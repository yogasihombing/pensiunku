import 'package:flutter/material.dart';
import 'package:pensiunku/model/usaha_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/usaha_repository.dart';
import 'package:pensiunku/screen/home/dashboard/usaha_list.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/sliver_app_bar_sheet_top.dart';
import 'package:pensiunku/widget/sliver_app_bar_title.dart';

// class UsahaScreenArguments {
//   final UsahaModel usahaModel;

//   UsahaScreenArguments({
//     required this.usahaModel,
//   });
// }

class UsahaScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/usaha';

  const UsahaScreen({
    Key? key,
  }) : super(key: key);

  @override
  _UsahaScreenState createState() => _UsahaScreenState();
}

class _UsahaScreenState extends State<UsahaScreen> {
  ScrollController scrollController = new ScrollController();
  late Future<ResultModel<UsahaModel>> _futureData;

  int _currentArticleIndex = 0;
  // bool _isLoading = false;
  final dataKey = new GlobalKey();

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  _refreshData() {
    return _futureData = UsahaRepository().getAll(_currentArticleIndex).then((value) {
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.3;
    double articleCardSize = screenSize.width * 0.45;
    double articleCarouselHeight = articleCardSize + 70;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: RefreshIndicator(
            onRefresh: () {
            return _refreshData();
          },
          child: Stack(
            children: [
              Container(
                height: sliverAppBarExpandedHeight + 72,
              ),
              Container(
                height: screenSize.height,
                width: screenSize.width,
                decoration:
                    BoxDecoration(color: Color.fromRGBO(247, 247, 247, 1.0)),
              ),
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: sliverAppBarExpandedHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      title: SliverAppBarTitle(
                        child: SizedBox(
                          height: AppBar().preferredSize.height * 0.4,
                          // child: Image.asset('assets/logo_name_white.png'),
                        ),
                      ),
                      titlePadding: const EdgeInsets.only(
                        left: 16.0,
                        bottom: 16.0,
                      ),
                      background: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 31, 157, 159),
                                    Color.fromARGB(255, 255, 221, 123),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      child : Stack(
                                        children: [
                                          Container(
                                            width: screenSize.width,
                                            child: Image.asset('assets/dashboard_screen/bg_usaha.png', fit: BoxFit.fill),
                                          ),
                                          Positioned.fill(
                                            top: 50,
                                            left: 32,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Program \nFranchise',
                                                style: theme.textTheme.headline4
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverAppBarSheetTop(),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Positioned(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xfff2f2f2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 0.0,
                                bottom: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder(
                                    future: _futureData,
                                    builder: (BuildContext context, AsyncSnapshot<ResultModel<UsahaModel>> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data?.data?.categories.isNotEmpty == true) {
                                          UsahaModel data = snapshot.data!.data!;
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 32.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          data.description,
                                                          style: theme.textTheme.subtitle1
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 32.0,
                                                  vertical: 16.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Pilihan Usaha',
                                                        style: theme.textTheme.headline6
                                                            ?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 28.0,
                                                child: ListView(
                                                  scrollDirection: Axis.horizontal,
                                                  children: [
                                                    SizedBox(width: 24.0),
                                                    ...data.categories.asMap().map((index, usahaCategory) {
                                                      return MapEntry(
                                                        index,
                                                        ChipTab(
                                                          text: usahaCategory.nama,
                                                          isActive: _currentArticleIndex == index,
                                                          onTap: () {
                                                            setState(() {
                                                              _currentArticleIndex = index;
                                                            });
                                                          },
                                                        ),
                                                      );
                                                    }).values.toList(),
                                                    SizedBox(width: 24.0),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0),
                                              ...data.categories
                                                  .asMap()
                                                  .map(
                                                      (index, usahaCategory) {
                                                    return MapEntry(
                                                      index,
                                                      _currentArticleIndex ==
                                                          index
                                                          ? UsahaList(
                                                        carouselHeight: articleCarouselHeight,
                                                        usahaModelCategory: usahaCategory,
                                                      )
                                                          : Container(),
                                                    );
                                                  })
                                                  .values
                                                  .toList(),
                                            ],
                                          );
                                        } else {
                                          String errorTitle =
                                              'Tidak dapat menampilkan artikel';
                                          String? errorSubtitle =
                                              snapshot.data?.error;
                                          return Container(
                                            child: ErrorCard(
                                              title: errorTitle,
                                              subtitle: errorSubtitle,
                                              iconData: Icons.warning_rounded,
                                            ),
                                          );
                                        }
                                      } else {
                                        return Container(
                                          height:
                                          articleCarouselHeight + 36 + 16.0,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: 100.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}