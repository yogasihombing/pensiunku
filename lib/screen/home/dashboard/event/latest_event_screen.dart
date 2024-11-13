import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_detail_screen.dart';

class LatestEvent extends StatefulWidget {
  final List<String> images;
  final List<int> idArticles;

  const LatestEvent({Key? key, required this.images, required this.idArticles})
      : super(key: key);

  @override
  State<LatestEvent> createState() => _LatestEventState();
}

class _LatestEventState extends State<LatestEvent> {
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentCarouselIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      // padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          color: Color.fromRGBO(228, 228, 228, 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
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
          items: widget.images.map<Widget>((i) {
            int indexArticle = widget.images.indexOf(i);
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        EventDetailScreen.ROUTE_NAME,
                        arguments: EventDetailScreenArguments(
                            eventId: widget.idArticles[indexArticle]));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          image: DecorationImage(
                              fit: BoxFit.fitHeight, image: NetworkImage(i)))),
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
              children: widget.images.asMap().entries.map((entry) {
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
