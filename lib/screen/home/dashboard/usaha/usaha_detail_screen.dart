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
  ScrollController scrollController = ScrollController();
  DetailUsaha get usahaDetailModel => widget.usahaDetailModel;

  final dataKey = GlobalKey();

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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color(0xFFDCE293),
            ],
            stops: [0.25, 0.5, 0.75, 1.0],
          ),
        ),
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
                          child: Container(color: Colors.transparent),
                        ),
                        // CHANGED: pakai CachedNetworkImage dengan placeholder & errorWidget
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: usahaDetailModel.banner,
                            width: screenSize.width,
                            height: sliverAppBarExpandedHeight,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image,
                                  size: 60, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Usaha
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
                                      style:
                                          theme.textTheme.headline4?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Deskripsi
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
                                    style: theme.textTheme.subtitle1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Judul Galeri
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
                                    style: theme.textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Carousel Foto
                          SizedBox(
                            height: articleCarouselHeight,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: usahaDetailModel.photo_gallery
                                  .map((franchise) {
                                int indexFoto = usahaDetailModel.photo_gallery
                                    .indexOf(franchise);
                                List<String> fotos = usahaDetailModel
                                    .photo_gallery
                                    .map((photo) => photo.path.toString())
                                    .toList();
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        GalleryFullScreen.ROUTE_NAME,
                                        arguments: GalleryFullScreenArguments(
                                          images: fotos,
                                          indexPage: indexFoto,
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      width: cardWidthLogo,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        // CHANGED: juga gunakan CachedNetworkImage di carousel
                                        child: CachedNetworkImage(
                                          imageUrl: franchise.path,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: Icon(Icons.broken_image,
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Tombol WA
                          Center(
                            child: InkWell(
                              splashColor: Colors.black12,
                              onTap: () {
                                UrlUtil.launchURL(
                                  'https://wa.me/+6281220357098?text=Hallo%20Pensiunku%0ASaya%20adalah%20Pensiun%20Hebat%20yang%20tetap%20ingin%20produktif%20di%20masa%20pensiun%0ASaya%20ingin%20konsultasi%20mengenai%20Franchise%20${usahaDetailModel.nama}',
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Image.asset(
                                  'assets/dashboard_screen/button_wa.png',
                                  width: 200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 150.0),
                        ],
                      ),
                    ),
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
