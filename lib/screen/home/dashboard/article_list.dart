import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/item_article.dart';

class ArticleList extends StatefulWidget {
  final ArticleCategoryModel articleCategory;
  final double carouselHeight;

  const ArticleList({
    Key? key,
    required this.articleCategory,
    required this.carouselHeight,
  }) : super(key: key);
  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  late Future<ResultModel<List<ArticleModel>>> _futureDataArticles;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  _refreshData() {
    return _futureDataArticles =
        ArticleRepository().getAll(widget.articleCategory).then((value) {
      // if (value.error != null) {
      //   WidgetUtil.showSnackbar(
      //     context,
      //     value.error.toString(),
      //   );
      // }
      setState(() {});
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    BackgroundFetchFetch:
    backgroundColor:
    Color(0xFF017964);
    ThemeData theme = Theme.of(context);

    return FutureBuilder(
      future: _futureDataArticles,
      builder: (BuildContext context,
          AsyncSnapshot<ResultModel<List<ArticleModel>>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.data?.isNotEmpty == true) {
            List<ArticleModel> data = snapshot.data!.data!;
            return Container(
              height: widget.carouselHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 24.0),
                  ...data.map((article) {
                    return Builder(
                      builder: (BuildContext context) {
                        return ItemArticle(
                          article: article,
                        );
                      },
                    );
                  }).toList(),
                  SizedBox(width: 24.0),
                ],
              ),
            );
          } else {
            String errorTitle = 'Tidak dapat menampilkan artikel';
            String? errorSubtitle = snapshot.data?.error;
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
            height: widget.carouselHeight,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            ),
          );
        }
      },
    );
  }
}
