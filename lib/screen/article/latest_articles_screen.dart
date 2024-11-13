import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/screen/article/article_detail_screen.dart';

class LatestArticles extends StatefulWidget {
  final List<MobileArticleModel> latestArticles;

  const LatestArticles({Key? key, required this.latestArticles})
      : super(key: key);

  @override
  State<LatestArticles> createState() => _LatestArticlesState();
}

class _LatestArticlesState extends State<LatestArticles> {
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentCarouselIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      // padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          color: Color.fromRGBO(228, 228, 228, 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(18.0),
          )),
      child: Stack(children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.5,
            aspectRatio: 1,
            enlargeCenterPage: true,
            viewportFraction: 1,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: widget.latestArticles.map<Widget>((i) {
            int indexArticle = widget.latestArticles.indexOf(i);
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        ArticleDetailScreen.ROUTE_NAME,
                        arguments: ArticleDetailScreenArguments(
                            articleId: widget.latestArticles[indexArticle].id));
                  },
                  child: Stack(children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: NetworkImage(i.imageUrl)))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0)),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.0),
                                Color.fromRGBO(0, 0, 0, 0.1),
                                Color.fromRGBO(0, 0, 0, 0.3),
                                Color.fromRGBO(0, 0, 0, 0.4),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.latestArticles[indexArticle].title,
                            style: theme.textTheme.headline5?.copyWith(
                              fontFamily: 'Unna',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              // shadows: [Shadow(
                              //         blurRadius: 10.0,
                              //         color: Colors.black,
                              //         offset: Offset(1.0,1.0)
                              //       )]
                            ),
                          ),
                          Row(
                            children: [
                              Text(widget.latestArticles[indexArticle].penulis,
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontFamily: 'Unna',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    // shadows: [Shadow(
                                    //   blurRadius: 10.0,
                                    //   color: Colors.black,
                                    //   offset: Offset(2.0,2.0)
                                    // )]
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Text('●',
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    // shadows: [Shadow(
                                    //   blurRadius: 10.0,
                                    //   color: Colors.black,
                                    //   offset: Offset(2.0,2.0)
                                    // )]
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Text(widget.latestArticles[indexArticle].category,
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontFamily: 'Unna',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    // shadows: [Shadow(
                                    //   blurRadius: 10.0,
                                    //   color: Colors.black,
                                    //   offset: Offset(2.0,2.0)
                                    // )]
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    )
                  ]),
                );
              },
            );
          }).toList(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.latestArticles.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: 25.0,
                    height: 8.0,
                    margin: EdgeInsets.only(bottom: 16.0, left: 8.0, right: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (Colors.white).withOpacity(
                            _currentCarouselIndex == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ]),
    );
  }
}
