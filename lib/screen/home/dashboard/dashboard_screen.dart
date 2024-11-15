import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/article/article_screen.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/ajukanoranglain_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article_list.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/dashboard/icon_menu.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/notification_icon.dart';
import 'ajukan/ajukan_screen.dart';   

class DashboardScreen extends StatefulWidget {
  final void Function(BuildContext) onApplySubmission;
  final void Function(int index) onChangeBottomNavIndex;
  final ScrollController scrollController;
  final int? walkthroughIndex;

  const DashboardScreen({
    Key? key,
    required this.onApplySubmission,
    required this.onChangeBottomNavIndex,
    required this.scrollController,
    this.walkthroughIndex,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0;

  late Future<ResultModel<List<ArticleCategoryModel>>>
      _futureDataArticleCategories;
  late List<ArticleCategoryModel> _articleCategories = [];

  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  bool _isLoading = false;
  UserModel? _userModel;

  final dataKey = new GlobalKey();
  final double articleCarouselHeight = 200.0;

  final List<String> simulationFormTypeTitle = [
    'KREDIT PRA-PENSIUN',
    'KREDIT PENSIUN',
    'KREDIT PLATINUM',
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    UserRepository().getOne(token!);

    _futureDataArticleCategories =
        ArticleRepository().getAllCategories().then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.greenAccent,
                  elevation: 24.0,
                ));
      } else {
        setState(() {
          _articleCategories = value.data!;
        });
      }
      return value;
    });
  }

  final List<String> programList = [
    'Pra-Pensiun',
    'Pensiun',
    'Platinum',
  ];

  final List<String> imageList = [
    'assets/application_screen/SLIDER-01.png',
    'assets/application_screen/SLIDER-02.png',
    'assets/application_screen/SLIDER-03.png',
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;

    double articleCardSize = screenSize.width * 0.45;
    double articleCarouselHeight = articleCardSize + 70;

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height * 0.4,
          child: Image.asset('assets/logo_name_white.png'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(
                NotificationScreen.ROUTE_NAME,
                arguments: NotificationScreenArguments(
                  currentIndex: 0,
                ),
              )
                  .then((newIndex) {
                _refreshData();
                if (newIndex is int) {
                  widget.onChangeBottomNavIndex(newIndex);
                }
              });
            },
            icon: NotificationCounter(),
          ),
          IconButton(
            tooltip: 'Riwayat',
            onPressed: () {
              // Lakukan navigasi ke RiwayatPengajuanPage dengan data yang dibutuhkan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatPengajuanPage(
                    telepon: '085243861919',
                  ),
                ),
              );
            },
            icon: Image.asset(
              'assets/icon/submission_icon.png', // Path ke file gambar
              // width: 24, // Sesuaikan ukuran gambar
              // height: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              // Header image
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  'assets/dashboard_screen/image_1.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Fitur Menu
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(
                        'Fitur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF017964),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 9.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconMenu(
                                image: "assets/icon/icon_event.png",
                                title: "Events",
                                routeNamed: EventScreen.ROUTE_NAME,
                              ),
                              IconMenu(
                                image: "assets/icon/icon_artikel.png",
                                title: "Artikel",
                                routeNamed: ArticleScreen.ROUTE_NAME,
                                arguments: ArticleScreenArguments(
                                    articleCategories: _articleCategories),
                              ),
                              IconMenu(
                                image: "assets/icon/icon_halo_pensiun.png",
                                title: "Halo Pensiun",
                                routeNamed: HalopensiunScreen.ROUTE_NAME,
                              ),
                              IconMenu(
                                image: "assets/icon/icon_forum.png",
                                title: "Forum",
                                routeNamed: ForumScreen.ROUTE_NAME,
                              ),
                              // IconMenu(
                              //   image: "assets/icon/icon_usaha.png",
                              //   title: "Usaha",
                              //   routeNamed: UsahaScreen.ROUTE_NAME,
                              // ),
                              // IconMenu(
                              //   image: "assets/icon/icon_toko.png",
                              //   title: "Toko",
                              //   routeNamed: CategoryScreen.ROUTE_NAME,
                              // ),
                            ],
                          ),
                          SizedBox(height: 19),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => AjukanScreen(),
                                      ));
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        color: Color(0xFFFFAE58),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Ajukan Diri Sendiri',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '', // Tambahkan teks di sinis
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            AjukanOrangLainScreen(),
                                      ));
                                    },
                                    child: Container(
                                      width: 150,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        color: Color(0xFFFFAE58),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Ajukan Orang Lain',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '', // Tambahkan teks di sinis
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Carousel Slider
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: 135,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 1.0,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.6,
                ),
                itemCount: programList.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Container(
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      image: DecorationImage(
                        image: AssetImage(imageList[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        programList[index],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: Image.asset(
                          'assets/dashboard_screen/icon_article.png'),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Artikel',
                        style: theme.textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: _futureDataArticleCategories,
                builder: (BuildContext context,
                    AsyncSnapshot<ResultModel<List<ArticleCategoryModel>>>
                        snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.data?.isNotEmpty == true) {
                      List<ArticleCategoryModel> data = snapshot.data!.data!;
                      return Column(
                        children: [
                          Container(
                            height: 28.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                SizedBox(width: 24.0),
                                ...data
                                    .asMap()
                                    .map((index, articleCategory) {
                                      return MapEntry(
                                        index,
                                        ChipTab(
                                          text: articleCategory.name,
                                          isActive:
                                              _currentArticleIndex == index,
                                          onTap: () {
                                            setState(() {
                                              _currentArticleIndex = index;
                                            });
                                          },
                                        ),
                                      );
                                    })
                                    .values
                                    .toList(),
                                SizedBox(width: 24.0),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          ...data
                              .asMap()
                              .map((index, articleCategory) {
                                return MapEntry(
                                  index,
                                  _currentArticleIndex == index
                                      ? ArticleList(
                                          articleCategory: articleCategory,
                                          carouselHeight: articleCarouselHeight,
                                        )
                                      : Container(),
                                );
                              })
                              .values
                              .toList(),
                        ],
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
                      height: articleCarouselHeight + 36 + 16.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onShowButton(showButton, onPageChanged) {
    if (onPageChanged == Center) {
      showButton == true;
    }
    ;
  }
}
