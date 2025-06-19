import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_item_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/latest_articles_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/no_article_screen.dart';
import 'package:pensiunku/widget/chip_tab.dart';

class ArticleScreenArguments {
  final List<ArticleCategoryModel> articleCategories;

  ArticleScreenArguments({
    required this.articleCategories,
  });
}

class ArticleScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/article';
  final List<ArticleCategoryModel> articleCategories;

  const ArticleScreen({Key? key, required this.articleCategories})
      : super(key: key);

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<ResultModel<List<MobileArticleModel>>> _futureData;
  late Future<ResultModel<List<MobileArticleModel>>>
      _futureDataWithoutSearchString;
  late List<ArticleCategoryModel> _articleCategories = widget.articleCategories;
  // late List<MobileArticleModel> _articlesWithSearch = [];
  // int _currentCarouselIndex = 0;
  int _filterIndex = 0;
  String _searchText = '';
  final TextEditingController editingController = TextEditingController();
  List<String> images = [];
  List<MobileArticleModel> latestArticles = [];

  @override
  void initState() {
    super.initState();

    // _currentCarouselIndex = 0;
    _filterIndex = 0;
    _searchText = '';
    // _articlesWithSearch = [];
    _refreshData();
  }

  _refreshData() {
    return _futureData = ArticleRepository()
        .getMobileAll(_articleCategories[_filterIndex])
        .then((value) {
      if (value.error != null) {
        // showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //           content: Text(value.error.toString(),
        //               style: TextStyle(color: Colors.white)),
        //           backgroundColor: Colors.red,
        //           elevation: 24.0,
        //         ));
        // } else {
        //   _articlesWithSearch = [];
        //   value.data!.asMap().forEach((key, value) {
        //     if(value.title.toLowerCase().contains(_searchText!)){
        //       _articlesWithSearch.add(value);
        //     }
        //    });
      }
      _futureDataWithoutSearchString =
          ArticleRepository().getMobileAll(_articleCategories[_filterIndex]);
      setState(() {});
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: Icon(Icons.arrow_back),
          color: Color(0xFF017964),
        ),
        title: Text(
          "Artikel",
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: Color(0xFF017964),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 220, 226, 147),
            ],
            stops: [0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () {
            return _refreshData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height * 1.2,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 36.0,
                        child: TextField(
                          onSubmitted: (value) {
                            _searchText = value;
                            _refreshData();
                          },
                          controller: editingController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromRGBO(228, 228, 228, 1.0),
                              suffixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0)))),
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: _futureData,
                        builder: (BuildContext context,
                            AsyncSnapshot<ResultModel<List<MobileArticleModel>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.data != null) {
                              List<MobileArticleModel> data =
                                  snapshot.data!.data!;
                              if (data.isEmpty) {
                                return NoArticle();
                              } else {
                                latestArticles = [];
                                data.asMap().forEach((index, value) {
                                  if (index < 3) {
                                    latestArticles.add(value);
                                  }
                                });
                                return Column(
                                  children: [
                                    LatestArticles(
                                        latestArticles: latestArticles),
                                    SizedBox(
                                      height: 12.0,
                                    ),
                                    Container(
                                      height: 28.0,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          SizedBox(width: 12.0),
                                          ..._articleCategories
                                              .asMap()
                                              .map((index, articleCategory) {
                                                return MapEntry(
                                                  index,
                                                  ChipTab(
                                                    text: articleCategory.name,
                                                    isActive:
                                                        _filterIndex == index,
                                                    onTap: () {
                                                      setState(() {
                                                        _filterIndex = index;
                                                      });
                                                      _refreshData();
                                                    },
                                                    custom: true,
                                                  ),
                                                );
                                              })
                                              .values
                                              .toList(),
                                          SizedBox(width: 24.0),
                                        ],
                                      ),
                                    ),
                                    ...data
                                        .where((element) => element.title
                                            .toLowerCase()
                                            .contains(_searchText))
                                        .map((article) {
                                      return ArticleItemScreen(
                                        article: article,
                                        status: _filterIndex,
                                      );
                                    })
                                  ],
                                );
                              }
                            } else {
                              //check without search
                              return FutureBuilder(
                                  future: _futureDataWithoutSearchString,
                                  builder: ((context,
                                      AsyncSnapshot<
                                              ResultModel<
                                                  List<MobileArticleModel>>>
                                          snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data?.data != null) {
                                        List<MobileArticleModel> data =
                                            snapshot.data!.data!;
                                        if (data.isEmpty) {
                                          return NoArticle();
                                        } else {
                                          latestArticles = [];
                                          data.asMap().forEach((index, value) {
                                            if (index < 3) {
                                              latestArticles.add(value);
                                            }
                                          });
                                          return Column(
                                            children: [
                                              LatestArticles(
                                                  latestArticles:
                                                      latestArticles),
                                              filter(context),
                                              Container(
                                                width: screenSize.width - 16.0,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                child: Card(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            'Hasil pencarian : 0 artikel'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      } else {
                                        return NoArticle();
                                      }
                                    } else {
                                      return Container(
                                        height: (screenSize.height) * 0.5 +
                                            36 +
                                            16.0,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      );
                                    }
                                  }));
                            }
                          } else {
                            return Column(
                              children: [
                                SizedBox(height: screenSize.height * 0.4),
                                Center(
                                  child: CircularProgressIndicator(
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filter(BuildContext context) {
    return Container(
        height: 36.0,
        margin: EdgeInsets.symmetric(horizontal: 45.0, vertical: 18.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(195, 195, 195, 1.0)),
          // color: Color.fromRGBO(195, 195, 195, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(36)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filterIndex = 0;
                    _refreshData();
                  });
                },
                child: Container(
                    alignment: Alignment.center,
                    height: 36.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          bottomLeft: Radius.circular(36)),
                      color:
                          _filterIndex == 0 ? Color(0xFF017964) : Colors.white,
                    ),
                    child: Text(
                      "Akan Berlangsung",
                      style: TextStyle(
                        color: _filterIndex == 0
                            ? Colors.white
                            : Color.fromRGBO(149, 149, 149, 1.0),
                      ),
                    )),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = 1;
                  _refreshData();
                });
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 36.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(36),
                        bottomRight: Radius.circular(36)),
                    color: _filterIndex == 1
                        ? Color.fromRGBO(1, 169, 159, 1.0)
                        : Colors.white,
                  ),
                  child: Text(
                    "Telah Berlangsung",
                    style: TextStyle(
                        color: _filterIndex == 0
                            ? Color.fromRGBO(149, 149, 149, 1.0)
                            : Colors.white),
                  )),
            ))
          ],
        ));
  }
}
