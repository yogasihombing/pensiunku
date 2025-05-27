import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_detail_screen.dart';

class ArticleItemScreen extends StatelessWidget {
  final MobileArticleModel article;
  final int status;

  const ArticleItemScreen({
    Key? key,
    required this.article,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ArticleDetailScreen.ROUTE_NAME,
            arguments: ArticleDetailScreenArguments(articleId: article.id));
      },
      child: Container(
        width: screenSize.width - 16.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: new BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: const Offset(
                  0.0,
                  7.0,
                ),
                blurRadius: 5.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Card(
            shadowColor: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color.fromRGBO(1, 169, 159, 1.0),
                          image: DecorationImage(
                              image: NetworkImage(article.imageUrl.toString()),
                              fit: BoxFit.fitHeight)),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.category.toString(),
                          style: theme.textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w700, color: Colors.grey),
                        ),
                        Text(
                          article.title.toString(),
                          style: theme.textTheme.subtitle1
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          article.tanggal,
                          style: theme.textTheme.subtitle1
                              ?.copyWith(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
