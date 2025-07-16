import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/model/theme_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/theme_repository.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pensiunku/config.dart' show apiHost;

class ArticleDetailScreenArguments {
  final int articleId;

  ArticleDetailScreenArguments({
    required this.articleId,
  });
}

class ArticleDetailScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/article-detail';
  final int articleId;

  const ArticleDetailScreen({Key? key, required this.articleId})
      : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Future<ResultModel<MobileArticleDetailModel>> _futureData;
  final _switchController = ValueNotifier<bool>(false);
  bool _darkMode = true;
  String articleTitle = ''; // Inisialisasi dengan string kosong

  @override
  void initState() {
    super.initState();
    print('ArticleDetailScreen: initState dipanggil.');

    // Inisialisasi _futureData segera dengan panggilan pertama ke _refreshData()
    // Ini memastikan _futureData memiliki nilai Future sebelum build dipanggil.
    _futureData = _refreshData();

    _switchController.addListener(() {
      print(
          'ArticleDetailScreen: _switchController listener dipicu. Value: ${_switchController.value}');
      setState(() {
        if (_switchController.value) {
          _darkMode = false;
          print('ArticleDetailScreen: Mode terang diaktifkan.');
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "false");
          ThemeRepository().update(theme).then((value) {
            print("ArticleDetailScreen: updateTheme (light mode): " +
                value.toString()); // Menggunakan print
          });
        } else {
          _darkMode = true;
          print('ArticleDetailScreen: Mode gelap diaktifkan.');
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "true");
          ThemeRepository().update(theme).then((value) {
            print("ArticleDetailScreen: updateTheme (dark mode): " +
                value.toString()); // Menggunakan print
          });
        }
      });
    });

    // _initializeData(); // Tidak perlu memanggil ini lagi karena _refreshData sudah dipanggil di atas
  }

  // Fungsi ini sekarang tidak lagi diperlukan karena _refreshData dipanggil langsung di initState
  // Future<void> _initializeData() async {
  //   print('ArticleDetailScreen: _initializeData dipanggil.');
  //   await _refreshData();
  // }

  // Mengubah tipe return menjadi Future<ResultModel<MobileArticleDetailModel>>
  Future<ResultModel<MobileArticleDetailModel>> _refreshData() async {
    print('ArticleDetailScreen: _refreshData dipanggil.');

    // Get theme setting first
    print('ArticleDetailScreen: Mengambil pengaturan tema...');
    try {
      final themeValue = await ThemeRepository().get();
      if (mounted) {
        if (themeValue.error == null && themeValue.data != null) {
          ThemeModel theme = themeValue.data!;
          if (theme.value == 'false') {
            _darkMode = false;
            _switchController.value = true;
            print('ArticleDetailScreen: Tema diatur ke terang.');
          } else {
            _darkMode = true;
            _switchController.value = false;
            print('ArticleDetailScreen: Tema diatur ke gelap.');
          }
        } else {
          print(
              'ArticleDetailScreen: Gagal mengambil tema: ${themeValue.error}. Menggunakan default.');
        }
      }
    } catch (e) {
      print(
          'ArticleDetailScreen: Error mengambil tema: $e. Menggunakan default.');
    }

    // Then get article data
    print(
        'ArticleDetailScreen: Memulai panggilan ArticleRepository().getMobileArticle...');
    try {
      final articleResult =
          await ArticleRepository().getMobileArticle(widget.articleId);
      if (mounted) {
        setState(() {
          // Hanya update articleTitle di sini, _futureData sudah diinisialisasi
          if (articleResult.data != null) {
            articleTitle = articleResult.data!.title;
            print(
                'ArticleDetailScreen: Data artikel berhasil dimuat. Judul: $articleTitle');
          } else {
            print('ArticleDetailScreen: Data artikel null.');
          }
        });
      }
      return articleResult; // Mengembalikan hasil dari API
    } catch (e) {
      print('ArticleDetailScreen: Error saat mengambil artikel: $e');
      if (mounted) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                      'Terjadi kesalahan saat memuat artikel: ${e.toString()}',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      }
      return ResultModel(
          isSuccess: false,
          error: e.toString()); // Mengembalikan ResultModel dengan error
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    // double cardWidth = screenSize.width * 0.37;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              print('ArticleDetailScreen: Tombol kembali ditekan.');
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
            color: _darkMode ? Colors.black : Colors.white,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: AdvancedSwitch(
                activeChild: Icon(
                  Icons.dark_mode_outlined,
                  color: Colors.black,
                ),
                inactiveChild: Icon(Icons.light_mode),
                activeColor: Color.fromRGBO(255, 255, 255, 0.65),
                inactiveColor: Color.fromRGBO(177, 177, 177, 0.65),
                height: 28,
                width: 60,
                controller: _switchController,
              ),
            ),
            SizedBox(
              width: 15.0,
            )
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // Pastikan onRefresh adalah async
                print('ArticleDetailScreen: RefreshIndicator dipicu.');
                // Update _futureData dengan Future baru dari _refreshData
                setState(() {
                  _futureData = _refreshData();
                });
                // Tunggu hingga Future selesai agar indikator refresh hilang
                await _futureData;
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        color: _darkMode
                            ? Colors.white
                            : Color.fromRGBO(38, 38, 38, 1.0)),
                  ),
                  Column(children: [
                    FutureBuilder<ResultModel<MobileArticleDetailModel>>(
                        // Tambahkan tipe eksplisit
                        future: _futureData,
                        builder: (BuildContext context,
                            AsyncSnapshot<ResultModel<MobileArticleDetailModel>>
                                snapshot) {
                          print(
                              'ArticleDetailScreen: FutureBuilder ConnectionState: ${snapshot.connectionState}');
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                SizedBox(height: screenSize.height * 0.5),
                                Center(
                                  child: CircularProgressIndicator(
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.hasError ||
                              (snapshot.hasData && !snapshot.data!.isSuccess)) {
                            print(
                                'ArticleDetailScreen: FutureBuilder Error: ${snapshot.error ?? snapshot.data?.error}');
                            String errorTitle = 'Gagal memuat artikel';
                            String? errorSubtitle =
                                snapshot.error?.toString() ??
                                    snapshot.data?.error;
                            return Column(
                              children: [
                                SizedBox(height: 16),
                                ErrorCard(
                                  title: errorTitle,
                                  subtitle: errorSubtitle,
                                  iconData: Icons.warning_rounded,
                                ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.data != null) {
                            print(
                                'ArticleDetailScreen: FutureBuilder Data tersedia.');
                            MobileArticleDetailModel data =
                                snapshot.data!.data!;
                            // Panggil splitTextByImageTag
                            print(
                                'ArticleDetailScreen: Memulai splitTextByImageTag...');
                            List<String> paragraf =
                                splitTextByImageTag(data.content, []);
                            print(
                                'ArticleDetailScreen: splitTextByImageTag selesai. Panjang list paragraf: ${paragraf.length}');

                            return Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: screenSize.height * 0.5,
                                      width: screenSize.width,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            data.imageUrl.toString(),
                                          ),
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: screenSize.height * 0.5,
                                      width: screenSize.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 200,
                                            decoration: BoxDecoration(
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Container(
                                        height: screenSize.height * 0.5,
                                        width: screenSize.width * 0.9,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          149, 149, 149, 1.0),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  30))),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 3),
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      Text(
                                                        data.category
                                                            .toString(),
                                                        style: theme
                                                            .textTheme.subtitle2
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer()
                                              ],
                                            ),
                                            Text(
                                              data.title,
                                              style: theme.textTheme.headline5
                                                  ?.copyWith(
                                                      fontFamily: 'Unna',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      shadows: [
                                                    // Shadow(
                                                    //   blurRadius: 10.0,
                                                    //   color: Colors.black,
                                                    //   offset:
                                                    //       Offset(1.0, 1.0))
                                                  ]),
                                            ),
                                            SizedBox(
                                              height: 30,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Container(
                                  color: _darkMode
                                      ? Colors.white
                                      : Color.fromRGBO(38, 38, 38, 1.0),
                                  width: screenSize.width,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Container(
                                        width: screenSize.width * 0.9,
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      149, 149, 149, 1.0),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30))),
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(
                                                  left: 3,
                                                  right: 15,
                                                  top: 3,
                                                  bottom: 3),
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: Container(
                                                      width: 26,
                                                      color: Colors.white,
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 25,
                                                        color: Color.fromRGBO(
                                                            76, 168, 155, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    data.penulis.toString(),
                                                    style: theme
                                                        .textTheme.subtitle2
                                                        ?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12.0,
                                            ),
                                            Text(
                                              data.tanggal,
                                              style: theme.textTheme.subtitle2
                                                  ?.copyWith(
                                                color: _darkMode
                                                    ? Color.fromRGBO(
                                                        131, 131, 131, 1.0)
                                                    : Colors.white,
                                              ),
                                            ),
                                            Spacer()
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      ...paragraf.map((kalimat) {
                                        if (kalimat.indexOf('[img') != -1) {
                                          String imgUrl = kalimat.substring(
                                              5, kalimat.length - 1);
                                          print(
                                              'ArticleDetailScreen: imgUrl dari tag: $imgUrl'); // Menggunakan print
                                          return Container(
                                            width: screenSize.width * 0.9,
                                            child: CachedNetworkImage(
                                              // Gunakan CachedNetworkImage untuk gambar konten
                                              imageUrl: imgUrl.trim(),
                                              fit: BoxFit.fitWidth,
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            width: screenSize.width * 0.9,
                                            child: Text(
                                              kalimat,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  fontFamily: 'Athelas',
                                                  fontWeight: FontWeight.normal,
                                                  color: _darkMode
                                                      ? Color.fromRGBO(
                                                          61, 61, 61, 1.0)
                                                      : Colors.white),
                                            ),
                                          );
                                        }
                                      }),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            // Ini akan menangani kasus di mana snapshot.data null atau data di dalamnya null
                            print(
                                'ArticleDetailScreen: FutureBuilder Data null atau tidak ada.'); // Menggunakan print
                            String errorTitle =
                                'Tidak dapat menemukan artikel yang dicari';
                            String? errorSubtitle = snapshot.data?.error ??
                                'Data artikel tidak tersedia.';
                            return Column(
                              children: [
                                SizedBox(height: 16),
                                ErrorCard(
                                  title: errorTitle,
                                  subtitle: errorSubtitle,
                                  iconData: Icons.warning_rounded,
                                ),
                              ],
                            );
                          }
                        }),
                  ]),
                ]),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  sharePressed();
                },
                child: CircleAvatar(
                  backgroundColor: _darkMode ? Colors.teal[700] : Colors.white,
                  radius: 20,
                  child: Icon(
                    Icons.share,
                    size: 30,
                    color: _darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void sharePressed() {
    String url = '$apiHost/article/';
    String id = widget.articleId.toString();
    String message = '$articleTitle $url$id';
    Share.share(message);

    // / optional subject that will be used when sharing to email
    // Share.share(message, subject: 'Become An Elite Flutter Developer');

    // / share a file
    // Share.shareFiles(['${directory.path}/image.jpg'], text: 'Great picture');
    // / share multiple files
    // Share.shareFiles(['${directory.path}/image1.jpg', '${directory.path}/image2.jpg']);
  }

  List<String> splitTextByImageTag(
      String kalimat, List<String> splittedKalimat) {
    print(
        'ArticleDetailScreen: splitTextByImageTag dipanggil dengan kalimat awal: ${kalimat.length > 50 ? kalimat.substring(0, 50) + '...' : kalimat}'); // Menggunakan print
    late String firstPart;
    late String nextPart;
    late String lastPart;
    late String imgUrl;
    late int startIndex;
    late int endIndex;

    // if (kalimat != null && kalimat.length > 0) { // Pengecekan null ini tidak diperlukan karena parameter String tidak nullable
    startIndex = kalimat.indexOf('[img=');
    if (startIndex != -1) {
      // there are image in this paragraph
      firstPart = kalimat.substring(0, startIndex);
      nextPart = kalimat.substring(startIndex);

      //find the endIndex from nextPart
      endIndex = nextPart.indexOf(']');
      if (endIndex != -1) {
        imgUrl = nextPart.substring(0, endIndex + 1);
        lastPart = nextPart.substring(endIndex + 1);
        splittedKalimat.add(firstPart);
        splittedKalimat.add(imgUrl);
        print(
            'ArticleDetailScreen: Ditemukan tag gambar. FirstPart: ${firstPart.length}, ImgUrl: ${imgUrl.length}, LastPart: ${lastPart.length}'); // Menggunakan print
      } else {
        // Handle case where [img= tag is opened but not closed
        print(
            'ArticleDetailScreen: Peringatan: Tag [img= tidak ditutup dengan ]. Menambahkan sisa kalimat sebagai teks.'); // Menggunakan print
        splittedKalimat.add(kalimat);
        return splittedKalimat;
      }

      return splitTextByImageTag(lastPart, splittedKalimat);
    } else {
      //tidak ada image lagi dalam paragraf
      if (kalimat.isNotEmpty) {
        // Hanya tambahkan jika tidak kosong
        splittedKalimat.add(kalimat);
      }
      print(
          'ArticleDetailScreen: Tidak ada tag gambar lagi. Mengembalikan list. Total paragraf: ${splittedKalimat.length}'); // Menggunakan print
      return splittedKalimat;
    }
    // } // Tutup komentar ini
  }
}
