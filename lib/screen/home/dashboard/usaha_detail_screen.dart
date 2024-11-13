import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/usaha_detail_model.dart';
import 'package:pensiunku/screen/common/galery_fullscreen.dart';
import 'package:pensiunku/util/url_util.dart';

class UsahaDetailScreenArguments {
  final DetailUsaha usahaDetailModel;

  UsahaDetailScreenArguments({
    required this.usahaDetailModel,
  });
}

class UsahaDetailScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/usaha/detail';
  final DetailUsaha usahaDetailModel;

  const UsahaDetailScreen({
    Key? key,
    required this.usahaDetailModel,
  }) : super(key: key);

  @override
  _UsahaDetailScreenState createState() => _UsahaDetailScreenState();
}

class _UsahaDetailScreenState extends State<UsahaDetailScreen> {
  ScrollController scrollController = new ScrollController();
  DetailUsaha get usahaDetailModel => widget.usahaDetailModel;

  final dataKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.21;
    double articleCardSize = screenSize.width * 0.45;
    double articleCarouselHeight = articleCardSize;
    double cardWidthLogo = screenSize.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          children: [
            Container(
              height: sliverAppBarExpandedHeight + 72,
            ),
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: sliverAppBarExpandedHeight,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 255, 255),
                                  Color.fromARGB(255, 255, 255, 255),
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
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: screenSize.width,
                                          child: Image.network(
                                              usahaDetailModel.banner,
                                              fit: BoxFit.fill),
                                        ),
                                      ],
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                    vertical: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            usahaDetailModel.nama,
                                            style: theme.textTheme.headline4
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
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
                                            usahaDetailModel.description,
                                            style: theme.textTheme.subtitle1),
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
                                          'Galeri',
                                          style: theme.textTheme.headline6
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: articleCarouselHeight,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          ...usahaDetailModel.photo_gallery
                                              .map((franchise) {
                                            int indexFoto = usahaDetailModel.photo_gallery.indexOf(franchise);
                                            List<String> fotos = usahaDetailModel.photo_gallery.map((photo){
                                              return photo.path.toString();
                                            }).toList();
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        GalleryFullScreen
                                                            .ROUTE_NAME,
                                                        arguments:
                                                            GalleryFullScreenArguments(
                                                                images: fotos,
                                                                indexPage:
                                                                    indexFoto),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4.0),
                                                      width: cardWidthLogo,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height:
                                                                cardWidthLogo,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: theme
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.5),
                                                                  image:
                                                                      DecorationImage(
                                                                    image: CachedNetworkImageProvider(
                                                                        franchise
                                                                            .path),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  splashColor: Colors.black12,
                                  onTap: () {
                                    {
                                      UrlUtil.launchURL(
                                          'https://wa.me/+6281181106000?text=Hallo%20Kreditpensiun.com%0ASaya%20adalah%20Pensiun%20Hebat%20yang%20tetap%20ingin%20produktif%20di%20masa%20pensiun%0ASaya%20ingin%20konsultasi%20mengenai%20Franchise%20${usahaDetailModel.nama}');
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 100.0,
                                      right: 100.0,
                                    ),
                                    child: Image.asset(
                                        'assets/dashboard_screen/button_wa.png'),
                                  ),
                                ),
                                SizedBox(height: 150.0)
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
    );
  }
}
