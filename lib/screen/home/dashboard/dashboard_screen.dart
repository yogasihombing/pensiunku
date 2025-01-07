import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/article/article_screen.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_screen.dart';
import 'package:pensiunku/screen/home/account/account_screen.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_orang_lain_screen.dart';
import 'package:pensiunku/screen/home/dashboard/event/event_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/screen/home/dashboard/halopensiun/halopensiun_screen.dart';
import 'package:pensiunku/screen/home/dashboard/icon_menu.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/notification/notification_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/notification_icon.dart';

// Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
class DashboardScreen extends StatefulWidget {
  // Properti untuk fungsi callback dan parameter lain yang digunakan oleh widget ini
  final void Function(BuildContext)
      onApplySubmission; // Callback saat pengajuan dilakukan
  final void Function(int index)
      onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
  final ScrollController scrollController; // Mengontrol scroll di layar
  final int? walkthroughIndex; // Indeks untuk walkthrough (opsional)

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
  // Variabel untuk menyimpan indeks artikel dan event saat ini
  int _currentArticleIndex = 0;
  int _currenEventIndex = 0;

  // Future untuk mendapatkan data artikel dan event secara asinkron
  late Future<ResultModel<List<ArticleCategoryModel>>>
      _futureDataArticleCategories;
  late List<ArticleCategoryModel> _articleCategories = [];
  Future<ResultModel<List<ForumModel>>>? _futureData;
  late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
  late List<EventModel> _EventModel = [];
  bool _isLoading = false; // Menandai apakah data sedang dimuat
  UserModel? _userModel; // Model pengguna (opsional)
  late Future<ResultModel<UserModel>> _future;

  // Controller untuk input teks
  TextEditingController namaController = TextEditingController();

  final dataKey = new GlobalKey(); // Key global untuk widget tertentu
  final double articleCarouselHeight = 200.0; // Tinggi carousel artikel

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
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token != null) {
      _future = UserRepository().getOne(token);
      _future.then((result) {
        if (result.error == null) {
          setState(() {
            _userModel = result.data;

            // Tambahkan log ini untuk melihat ID di konsol
            print('User ID: ${_userModel?.id}');
          });
        }
      });

      _futureDataArticleCategories =
          ArticleRepository().getAllCategories().then((value) {
        if (value.error != null) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(value.error.toString(),
                        style: const TextStyle(color: Colors.white)),
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
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 138, 217, 165), // Hijau pekat di atas
            Colors.white, // Hijau medium di tengah
            Colors.white, // Putih di bawah
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 1),
                    _buildGreeting(),
                    const SizedBox(height: 6),
                    _buildBalanceCard(),
                    const SizedBox(height: 12),
                    _buildBottomSectionTitle(),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                    const SizedBox(height: 12),
                    _buildHeaderImage(),
                    const SizedBox(height: 2),
                    _buildMenuFeatures(),
                    const SizedBox(height: 6),
                    _buildCarouselSlider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/logo_pensiunku.png',
          height: 80,
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AccountScreen(
                onChangeBottomNavIndex: (int index) {},
              ),
            ),
          )
              .then((_) {
            // Fungsi yang dipanggil saat kembali dari halaman AccountScreen
            _refreshData(); // Perbarui data di halaman utama
          }),
          color: Colors.black54,
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Pagi, ${_userModel?.username ?? 'Pengguna'}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'ID: ${_userModel?.id ?? 'Tidak tersedia'}',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.black),
              const SizedBox(width: 8),
              const Text(
                'Dompet Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Text(
                'Rp 0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(148, 159, 221, 159),
              minimumSize: const Size(double.infinity, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: RichText(
              text: TextSpan(
                text: 'AKTIFKAN ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.green[900],
                ),
                children: [
                  TextSpan(
                    text: 'PENSIUNKU+',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold, // Bold hanya untuk "Pensiunku+"
                    ),
                  ),
                  TextSpan(
                    text: ' SEKARANG',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.normal, // Normal untuk bagian lainnya
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSectionTitle() {
    return Container(
      width: double.infinity, // Menyamakan lebar dengan _buildBalanceCard
      decoration: BoxDecoration(
        color: const Color(0xFF017964), // Latar hijau tua
        borderRadius: BorderRadius.circular(24), // Radius sudut kontainer
      ),
      child: DotteddBorder(
        borderType: BorderType.RRect, // Bentuk border melengkung
        radius: const Radius.circular(24), // Radius sudut yang sama
        dashPattern: [3, 3], // Pola putus-putus (6px garis, 3px jarak)
        color: Colors.white, // Warna putih untuk garis
        strokeWidth: 2, // Ketebalan garis
        padding: const EdgeInsets.all(0), // Padding dalam border
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4, // Padding atas-bawah
            horizontal: 16, // Padding kiri-kanan
          ),
          child: const Center(
            // Menengahkan teks secara horizontal dan vertikal
            child: Text(
              'BUTUH UANG UNTUK MASA PENSIUNMU?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Warna teks putih
              ),
              textAlign: TextAlign.center, // Teks rata tengah horizontal
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'assets/dashboard_screen/pengajuanAnda.png',
            'AJUKAN\nKREDIT\nPENSIUN',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PengajuanAndaScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            context,
            'assets/dashboard_screen/mitra.png',
            'AJUKAN\nMITRA\nPENSIUNKU+',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PengajuanOrangLainScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String iconPath, String text,
      VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF017964), // Warna latar belakang tombol
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Border radius sesuai gambar
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 40, // Sesuaikan ukuran gambar
            height: 40,
          ),
          SizedBox(width: 10), // Spasi antara gambar dan teks
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white, // Warna teks
                fontWeight: FontWeight.bold,
                fontSize: 14, // Ukuran font sesuai kebutuhan
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity, // Menyamakan lebar
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Radius sudut kontainer
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk teks
        children: [
          const Padding(
            padding:
                EdgeInsets.only(left: 8.0, bottom: 8.0), // Jarak teks ke gambar
            child: Text(
              'Ada yang baru nih!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF017964), // Warna teks
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24), // Radius sudut gambar
            child: Image.asset(
              'assets/dashboard_screen/image_1.png',
              fit: BoxFit.cover,
              width: double.infinity, // Mengisi lebar penuh
              height: 200, // Tinggi tetap agar seragam
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 9.0),
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
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk teks
      children: [
        const Padding(
          padding:
              EdgeInsets.only(left: 12.0, bottom: 8.0), // Jarak teks ke slider
          child: Text(
            'Produk kami',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFF017964), // Warna teks
            ),
          ),
        ),
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 135,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 1.0,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.6,
          ),
          itemCount: programList.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return Container(
              margin: const EdgeInsets.all(5.0),
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
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onShowButton(showButton, onPageChanged) {
    if (onPageChanged == Center) {
      showButton == true;
    }
  }
}



// // Body layar dengan RefreshIndicator untuk refresh manual
//       body: RefreshIndicator(
//         onRefresh: _refreshData, // Fungsi refresh data
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => PengajuanAndaScreen(),
//                           ));
//                         },
//                         child: Container(
//                           width: 150,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12.0)),
//                             color: Color(0xFF017964),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Ajukan Diri Sendiri',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         '', // Tambahkan teks di sinis
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => PengajuanOrangLainScreen(),
//                           ));
//                         },
//                         child: Container(
//                           width: 150,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(12.0)),
//                             color: Color(0xFF017964),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Ajukan Orang Lain',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         '', // Tambahkan teks di sinis
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               // Gambar header
//               Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.all(2),
//                 padding: EdgeInsets.all(8),
//                 child: Image.asset(
//                   'assets/dashboard_screen/image_1.png', // Gambar header
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Fitur Menu
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 5.0,
//                         vertical: 9.0,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               IconMenu(
//                                 image: "assets/icon/icon_event.png",
//                                 title: "Events",
//                                 routeNamed: EventScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_artikel.png",
//                                 title: "Artikel",
//                                 routeNamed: ArticleScreen.ROUTE_NAME,
//                                 arguments: ArticleScreenArguments(
//                                     articleCategories: _articleCategories),
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_halo_pensiun.png",
//                                 title: "Halo Pensiun",
//                                 routeNamed: HalopensiunScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_forum.png",
//                                 title: "Forum",
//                                 routeNamed: ForumScreen.ROUTE_NAME,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 19),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment
//                     .start, // Untuk memastikan semua elemen diatur ke kiri
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.zero,
//                     child: Text(
//                       'Produk Kami',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF017964),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // Carousel Slider
//               CarouselSlider.builder(
//                 options: CarouselOptions(
//                   height: 135,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   aspectRatio: 1.0,
//                   autoPlayCurve: Curves.fastOutSlowIn,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: Duration(milliseconds: 800),
//                   viewportFraction: 0.6,
//                 ),
//                 itemCount: programList.length,
//                 itemBuilder: (BuildContext context, int index, int realIndex) {
//                   return Container(
//                     margin: EdgeInsets.all(5.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(13.0),
//                       image: DecorationImage(
//                         image: AssetImage(imageList[index]),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         programList[index],
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),

// // Kelas utama DashboardScreen dengan StatefulWidget agar memiliki state yang dapat berubah
// class DashboardScreen extends StatefulWidget {
//   // Properti untuk fungsi callback dan parameter lain yang digunakan oleh widget ini
//   final void Function(BuildContext)
//       onApplySubmission; // Callback saat pengajuan dilakukan
//   final void Function(int index)
//       onChangeBottomNavIndex; // Callback untuk mengubah indeks navigasi bawah
//   final ScrollController scrollController; // Mengontrol scroll di layar
//   final int? walkthroughIndex; // Indeks untuk walkthrough (opsional)

// // Constructor dengan parameter yang diperlukan
//   const DashboardScreen({
//     Key? key,
//     required this.onApplySubmission,
//     required this.onChangeBottomNavIndex,
//     required this.scrollController,
//     this.walkthroughIndex,
//   }) : super(key: key); // Memanggil constructor parent

//   // Membuat state untuk DashboardScreen
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// // State dari DashboardScreen
// class _DashboardScreenState extends State<DashboardScreen> {
//   // Variabel untuk menyimpan indeks artikel dan event saat ini
//   int _currentArticleIndex = 0;
//   int _currenEventIndex = 0;

//   // Future untuk mendapatkan data artikel dan event secara asinkron
//   late Future<ResultModel<List<ArticleCategoryModel>>>
//       _futureDataArticleCategories;
//   late List<ArticleCategoryModel> _articleCategories = [];

//   late Future<ResultModel<List<EventModel>>> _futureDataEventModel;
//   late List<EventModel> _EventModel = [];
//   bool _isLoading = false; // Menandai apakah data sedang dimuat
//   UserModel? _userModel; // Model pengguna (opsional)

//   final dataKey = new GlobalKey(); // Key global untuk widget tertentu
//   final double articleCarouselHeight = 200.0; // Tinggi carousel artikel

//   // Daftar tipe simulasi kredit
//   final List<String> simulationFormTypeTitle = [
//     'KREDIT PRA-PENSIUN',
//     'KREDIT PENSIUN',
//     'KREDIT PLATINUM',
//   ];

//   // Fungsi initState untuk inisialisasi data saat widget pertama kali dibangun
//   @override
//   void initState() {
//     super.initState();
//     _refreshData(); // Memuat data awal
//   }

//   // Fungsi untuk memuat ulang data
//   Future<void> _refreshData() async {
//     String? token = SharedPreferencesUtil().sharedPreferences.getString(
//         SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

//     UserRepository().getOne(token!);

// // Memuat kategori artikel dan menangani error
//     _futureDataArticleCategories =
//         ArticleRepository().getAllCategories().then((value) {
//       if (value.error != null) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(value.error.toString(),
//                       style: TextStyle(
//                           color: Colors.white)), // Menampilkan pesan error
//                   backgroundColor: Colors.greenAccent,
//                   elevation: 24.0,
//                 ));
//       } else {
//         setState(() {
//           _articleCategories = value.data!; // Memperbarui kategori artikel
//           print(value);
//         });
//       }
//       return value;
//     });
//   }

// // Daftar nama program dan gambar untuk carousel
//   final List<String> programList = [
//     'Pra-Pensiun',
//     'Pensiun',
//     'Platinum',
//   ];

//   final List<String> imageList = [
//     'assets/application_screen/SLIDER-01.png',
//     'assets/application_screen/SLIDER-02.png',
//     'assets/application_screen/SLIDER-03.png',
//   ];

// // Fungsi build untuk menggambar UI
//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context); // Tema aplikasi

//     // Widget Dimensions
//     Size screenSize = MediaQuery.of(context).size;

//     double articleCardSize = screenSize.width * 0.45; // Ukuran kartu artikel
//     double articleCarouselHeight =
//         articleCardSize + 70; // Tinggi carousel artikel

//     // Scaffold sebagai struktur dasar layar
//     return Scaffold(
//       appBar: AppBar(
//         // Bar atas dengan logo dan tombol notifikasi
//         title: SizedBox(
//           height: AppBar().preferredSize.height * 0.4,
//           child: Image.asset('assets/logo_name_white.png'),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Notifikasi', // Tooltip untuk notifikasi
//             onPressed: () {
//               Navigator.of(context)
//                   .pushNamed(
//                 NotificationScreen.ROUTE_NAME,
//                 arguments: NotificationScreenArguments(
//                   currentIndex: 0,
//                 ),
//               )
//                   .then((newIndex) {
//                 _refreshData(); // Refresh data saat kembali dari notifikasi
//                 if (newIndex is int) {
//                   widget.onChangeBottomNavIndex(
//                       newIndex); // Update navigasi bawah
//                 }
//               });
//             },
//             icon: NotificationCounter(), // Ikon notifikasi dengan penghitung
//           ),
//         ],
//       ),
//       // Body layar dengan RefreshIndicator untuk refresh manual
//       body: RefreshIndicator(
//         onRefresh: _refreshData, // Fungsi refresh data
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 5),
//               // Gambar header
//               Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.all(2),
//                 padding: EdgeInsets.all(8),
//                 child: Image.asset(
//                   'assets/dashboard_screen/image_1.png', // Gambar header
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Fitur Menu
//               Container(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 18.0),
//                       child: Text(
//                         'Fitur',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF017964),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 5.0,
//                         vertical: 9.0,
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               IconMenu(
//                                 image: "assets/icon/icon_event.png",
//                                 title: "Events",
//                                 routeNamed: EventScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_artikel.png",
//                                 title: "Artikel",
//                                 routeNamed: ArticleScreen.ROUTE_NAME,
//                                 arguments: ArticleScreenArguments(
//                                     articleCategories: _articleCategories),
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_halo_pensiun.png",
//                                 title: "Halo Pensiun",
//                                 routeNamed: HalopensiunScreen.ROUTE_NAME,
//                               ),
//                               IconMenu(
//                                 image: "assets/icon/icon_forum.png",
//                                 title: "Forum",
//                                 routeNamed: ForumScreen.ROUTE_NAME,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 19),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (context) =>
//                                             PengajuanAndaScreen(),
//                                       ));
//                                     },
//                                     child: Container(
//                                       width: 150,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(12.0)),
//                                         color: Color(0xFFFFAE58),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Ajukan Diri Sendiri',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     '', // Tambahkan teks di sinis
//                                   ),
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (context) =>
//                                             PengajuanOrangLainScreen(),
//                                       ));
//                                     },
//                                     child: Container(
//                                       width: 150,
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(12.0)),
//                                         color: Color(0xFFFFAE58),
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           'Ajukan Orang Lain',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     '', // Tambahkan teks di sinis
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Carousel Slider
//               CarouselSlider.builder(
//                 options: CarouselOptions(
//                   height: 135,
//                   autoPlay: true,
//                   enlargeCenterPage: true,
//                   aspectRatio: 1.0,
//                   autoPlayCurve: Curves.fastOutSlowIn,
//                   enableInfiniteScroll: true,
//                   autoPlayAnimationDuration: Duration(milliseconds: 800),
//                   viewportFraction: 0.6,
//                 ),
//                 itemCount: programList.length,
//                 itemBuilder: (BuildContext context, int index, int realIndex) {
//                   return Container(
//                     margin: EdgeInsets.all(5.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(13.0),
//                       image: DecorationImage(
//                         image: AssetImage(imageList[index]),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         programList[index],
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32.0,
//                   vertical: 16.0,
//                 ),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       height: 28,
//                       width: 28,
//                       child: Image.asset(
//                           'assets/dashboard_screen/icon_article.png'),
//                     ),
//                     SizedBox(width: 12.0),
//                     Expanded(
//                       child: Text(
//                         'Artikel',
//                         style: theme.textTheme.subtitle1?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               FutureBuilder(
//                 future: _futureDataArticleCategories,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<ResultModel<List<ArticleCategoryModel>>>
//                         snapshot) {
//                   if (snapshot.hasData) {
//                     if (snapshot.data?.data?.isNotEmpty == true) {
//                       List<ArticleCategoryModel> data = snapshot.data!.data!;
//                       return Column(
//                         children: [
//                           Container(
//                             height: 28.0,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               children: [
//                                 SizedBox(width: 24.0),
//                                 ...data
//                                     .asMap()
//                                     .map((index, articleCategory) {
//                                       return MapEntry(
//                                         index,
//                                         ChipTab(
//                                           text: articleCategory.name,
//                                           isActive:
//                                               _currentArticleIndex == index,
//                                           onTap: () {
//                                             setState(() {
//                                               _currentArticleIndex = index;
//                                             });
//                                           },
//                                         ),
//                                       );
//                                     })
//                                     .values
//                                     .toList(),
//                                 SizedBox(width: 24.0),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 16.0),
//                           ...data
//                               .asMap()
//                               .map((index, articleCategory) {
//                                 return MapEntry(
//                                   index,
//                                   _currentArticleIndex == index
//                                       ? ArticleList(
//                                           articleCategory: articleCategory,
//                                           carouselHeight: articleCarouselHeight,
//                                         )
//                                       : Container(),
//                                 );
//                               })
//                               .values
//                               .toList(),
//                         ],
//                       );
//                     } else {
//                       String errorTitle = 'Tidak dapat menampilkan artikel';
//                       String? errorSubtitle = snapshot.data?.error;
//                       return Container(
//                         child: ErrorCard(
//                           title: errorTitle,
//                           subtitle: errorSubtitle,
//                           iconData: Icons.warning_rounded,
//                         ),
//                       );
//                     }
//                   } else {
//                     return Container(
//                       height: articleCarouselHeight + 36 + 16.0,
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: theme.primaryColor,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Fungsi untuk mengatur visibilitas tombol
//   void _onShowButton(showButton, onPageChanged) {
//     if (onPageChanged == Center) {
//       showButton == true;
//     }
//     ;
//   }
// }
