import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_detail_screen.dart';

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
    Size screenSize = MediaQuery.of(context).size; // Dapatkan ukuran layar

    // Jika tidak ada artikel terbaru, tampilkan placeholder
    if (widget.latestArticles.isEmpty) {
      return Container(
        height: screenSize.height * 0.25, // Tinggi yang lebih masuk akal untuk placeholder
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        ),
        child: Center(
          child: Text(
            'Tidak ada artikel terbaru.',
            style: theme.textTheme.subtitle1?.copyWith(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      decoration: const BoxDecoration(
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
            autoPlayInterval: const Duration(seconds: 5),
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
                    // Menggunakan CachedNetworkImage untuk pemuatan gambar yang lebih baik
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                      child: CachedNetworkImage(
                        imageUrl: i.imageUrl.isNotEmpty && Uri.tryParse(i.imageUrl)?.hasAbsolutePath == true
                            ? i.imageUrl
                            : 'https://placehold.co/400x300/cccccc/333333?text=No+Image', // Placeholder yang lebih besar
                        fit: BoxFit.cover,
                        width: double.infinity, // Pastikan gambar mengisi lebar
                        height: double.infinity, // Pastikan gambar mengisi tinggi
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0)),
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromRGBO(0, 0, 0, 0.0),
                                const Color.fromRGBO(0, 0, 0, 0.1),
                                const Color.fromRGBO(0, 0, 0, 0.3),
                                const Color.fromRGBO(0, 0, 0, 0.4),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.latestArticles[indexArticle].title,
                            style: theme.textTheme.headline5?.copyWith(
                              fontFamily: 'Unna',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Text(widget.latestArticles[indexArticle].penulis,
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontFamily: 'Unna',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Text('●',
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(widget.latestArticles[indexArticle].category,
                                  style: theme.textTheme.bodyText1?.copyWith(
                                    fontFamily: 'Unna',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                          const SizedBox(
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
                    margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 4),
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