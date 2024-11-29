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

// Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
class DashboardScreen extends StatefulWidget {
  // Properti untuk fungsi callback dan parameter lain yang digunakan oleh widget ini
  final void Function(BuildContext)
      onApplySubmission; // Callback saat pengajuan dilakukan
  final void Function(int index)
      onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
  final ScrollController scrollController; // Mengontrol scroll di layar
  final int? walkthroughIndex; // Indeks untuk walkthrough (opsional)

// Constructor dengan parameter yang diperlukan
  const DashboardScreen({
    Key? key,
    required this.onApplySubmission,
    required this.onChangeBottomNavIndex,
    required this.scrollController,
    this.walkthroughIndex,
  }) : super(key: key); // Memanggil constructor parent

  // Membuat state untuk DashboardScreen
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

// State dari DashboardScreen
class _DashboardScreenState extends State<DashboardScreen> {
  // Variabel untuk menyimpan indeks artikel dan event saat ini
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0;

  // Future untuk mendapatkan data artikel dan event secara asinkron
  late Future<ResultModel<List<ArticleCategoryModel>>>
      _futureDataArticleCategories;
  late List<ArticleCategoryModel> _articleCategories = [];

  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  bool _isLoading = false; // Menandai apakah data sedang dimuat
  UserModel? _userModel; // Model pengguna (opsional)

  final dataKey = new GlobalKey(); // Key global untuk widget tertentu
  final double articleCarouselHeight = 200.0; // Tinggi carousel artikel

  // Daftar tipe simulasi kredit
  final List<String> simulationFormTypeTitle = [
    'KREDIT PRA-PENSIUN',
    'KREDIT PENSIUN',
    'KREDIT PLATINUM',
  ];

  // Fungsi initState untuk inisialisasi data saat widget pertama kali dibangun
  @override
  void initState() {
    super.initState();
    _refreshData(); // Memuat data awal
  }

  // Fungsi untuk memuat ulang data
  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil().sharedPreferences.getString(
        SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

    UserRepository().getOne(token!);

// Memuat kategori artikel dan menangani error
    _futureDataArticleCategories =
        ArticleRepository().getAllCategories().then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(
                          color: Colors.white)), // Menampilkan pesan error
                  backgroundColor: Colors.greenAccent,
                  elevation: 24.0,
                ));
      } else {
        setState(() {
          _articleCategories = value.data!; // Memperbarui kategori artikel
          print(value);
        });
      }
      return value;
    });
  }

// Daftar nama program dan gambar untuk carousel
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

// Fungsi build untuk menggambar UI
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context); // Tema aplikasi

    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;

    double articleCardSize = screenSize.width * 0.45; // Ukuran kartu artikel
    double articleCarouselHeight =
        articleCardSize + 70; // Tinggi carousel artikel

    // Scaffold sebagai struktur dasar layar
    return Scaffold(
      appBar: AppBar(
        // Bar atas dengan logo dan tombol notifikasi
        title: SizedBox(
          height: AppBar().preferredSize.height * 0.4,
          child: Image.asset('assets/logo_name_white.png'),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi', // Tooltip untuk notifikasi
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(
                NotificationScreen.ROUTE_NAME,
                arguments: NotificationScreenArguments(
                  currentIndex: 0,
                ),
              )
                  .then((newIndex) {
                _refreshData(); // Refresh data saat kembali dari notifikasi
                if (newIndex is int) {
                  widget.onChangeBottomNavIndex(
                      newIndex); // Update navigasi bawah
                }
              });
            },
            icon: NotificationCounter(), // Ikon notifikasi dengan penghitung
          ),
          IconButton(
            tooltip: 'Riwayat', // Tooltip untuk riwayat
            onPressed: () {
              // Lakukan navigasi ke RiwayatPengajuanPage dengan data yang dibutuhkan
            },
            icon: Image.asset(
              'assets/icon/submission_icon.png', // Path ke file gambar
              // width: 24, // Sesuaikan ukuran gambar
              // height: 24,
            ),
          ),
        ],
      ),
      // Body layar dengan RefreshIndicator untuk refresh manual
      body: RefreshIndicator(
        onRefresh: _refreshData, // Fungsi refresh data
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              // Gambar header
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(8),
                child: Image.asset(
                  'assets/dashboard_screen/image_1.png', // Gambar header
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

  // Fungsi untuk mengatur visibilitas tombol
  void _onShowButton(showButton, onPageChanged) {
    if (onPageChanged == Center) {
      showButton == true;
    }
    ;
  }
}
