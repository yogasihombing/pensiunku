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
    // print('ArticleDetailScreen: initState dipanggil.'); // Hapus print ini

    // Inisialisasi _futureData segera dengan panggilan pertama ke _refreshData()
    // Ini memastikan _futureData memiliki nilai Future sebelum build dipanggil.
    _futureData = _refreshData();

    _switchController.addListener(() {
      // print('ArticleDetailScreen: _switchController listener dipicu. Value: ${_switchController.value}'); // Hapus print ini
      setState(() {
        if (_switchController.value) {
          _darkMode = false;
          // print('ArticleDetailScreen: Mode terang diaktifkan.'); // Hapus print ini
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "false");
          ThemeRepository().update(theme).then((value) {
            // print("ArticleDetailScreen: updateTheme (light mode): " + value.toString()); // Hapus print ini
          });
        } else {
          _darkMode = true;
          // print('ArticleDetailScreen: Mode gelap diaktifkan.'); // Hapus print ini
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "true");
          ThemeRepository().update(theme).then((value) {
            // print("ArticleDetailScreen: updateTheme (dark mode): " + value.toString()); // Hapus print ini
          });
        }
      });
    });
  }

  // Mengubah tipe return menjadi Future<ResultModel<MobileArticleDetailModel>>
  Future<ResultModel<MobileArticleDetailModel>> _refreshData() async {
    // print('ArticleDetailScreen: _refreshData dipanggil.'); // Hapus print ini

    // Get theme setting first
    // print('ArticleDetailScreen: Mengambil pengaturan tema...'); // Hapus print ini
    try {
      final themeValue = await ThemeRepository().get();
      if (mounted) {
        if (themeValue.error == null && themeValue.data != null) {
          ThemeModel theme = themeValue.data!;
          if (theme.value == 'false') {
            _darkMode = false;
            _switchController.value = true;
            // print('ArticleDetailScreen: Tema diatur ke terang.'); // Hapus print ini
          } else {
            _darkMode = true;
            _switchController.value = false;
            // print('ArticleDetailScreen: Tema diatur ke gelap.'); // Hapus print ini
          }
        } else {
          // print('ArticleDetailScreen: Gagal mengambil tema: ${themeValue.error}. Menggunakan default.'); // Hapus print ini
        }
      }
    } catch (e) {
      // print('ArticleDetailScreen: Error mengambil tema: $e. Menggunakan default.'); // Hapus print ini
    }

    // Then get article data
    // print('ArticleDetailScreen: Memulai panggilan ArticleRepository().getMobileArticle...'); // Hapus print ini
    try {
      final articleResult =
          await ArticleRepository().getMobileArticle(widget.articleId);
      if (mounted) {
        setState(() {
          // Hanya update articleTitle di sini, _futureData sudah diinisialisasi
          if (articleResult.data != null) {
            articleTitle = articleResult.data!.title;
            // print('ArticleDetailScreen: Data artikel berhasil dimuat. Judul: $articleTitle'); // Hapus print ini
          } else {
            // print('ArticleDetailScreen: Data artikel null.'); // Hapus print ini
          }
        });
      }
      return articleResult; // Mengembalikan hasil dari API
    } catch (e) {
      // print('ArticleDetailScreen: Error saat mengambil artikel: $e'); // Hapus print ini
      if (mounted) {
        // Gunakan SnackBar atau custom dialog yang tidak memblokir UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat memuat artikel: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              // print('ArticleDetailScreen: Tombol kembali ditekan.'); // Hapus print ini
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.arrow_back),
            color: _darkMode ? Colors.black : Colors.white,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: AdvancedSwitch(
                activeChild: const Icon(
                  Icons.dark_mode_outlined,
                  color: Colors.black,
                ),
                inactiveChild: const Icon(Icons.light_mode),
                activeColor: const Color.fromRGBO(255, 255, 255, 0.65),
                inactiveColor: const Color.fromRGBO(177, 177, 177, 0.65),
                height: 28,
                width: 60,
                controller: _switchController,
              ),
            ),
            const SizedBox(
              width: 15.0,
            )
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                // Pastikan onRefresh adalah async
                // print('ArticleDetailScreen: RefreshIndicator dipicu.'); // Hapus print ini
                // Update _futureData dengan Future baru dari _refreshData
                setState(() {
                  _futureData = _refreshData();
                });
                // Tunggu hingga Future selesai agar indikator refresh hilang
                await _futureData;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        color: _darkMode
                            ? Colors.white
                            : const Color.fromRGBO(38, 38, 38, 1.0)),
                  ),
                  Column(children: [
                    FutureBuilder<ResultModel<MobileArticleDetailModel>>(
                        // Tambahkan tipe eksplisit
                        future: _futureData,
                        builder: (BuildContext context,
                            AsyncSnapshot<ResultModel<MobileArticleDetailModel>>
                                snapshot) {
                          // print('ArticleDetailScreen: FutureBuilder ConnectionState: ${snapshot.connectionState}'); // Hapus print ini
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
                            // print('ArticleDetailScreen: FutureBuilder Error: ${snapshot.error ?? snapshot.data?.error}'); // Hapus print ini
                            String errorTitle = 'Gagal memuat artikel';
                            String? errorSubtitle =
                                snapshot.error?.toString() ??
                                    snapshot.data?.error;
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                ErrorCard(
                                  title: errorTitle,
                                  subtitle: errorSubtitle,
                                  iconData: Icons.warning_rounded,
                                ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.data != null) {
                            // print('ArticleDetailScreen: FutureBuilder Data tersedia.'); // Hapus print ini
                            MobileArticleDetailModel data =
                                snapshot.data!.data!;
                            // Panggil splitTextByImageTag
                            // print('ArticleDetailScreen: Memulai splitTextByImageTag...'); // Hapus print ini
                            List<String> paragraf =
                                splitTextByImageTag(data.content, []);
                            // print('ArticleDetailScreen: splitTextByImageTag selesai. Panjang list paragraf: ${paragraf.length}'); // Hapus print ini

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
                                                  const Color.fromRGBO(
                                                      0, 0, 0, 0.0),
                                                  const Color.fromRGBO(
                                                      0, 0, 0, 0.1),
                                                  const Color.fromRGBO(
                                                      0, 0, 0, 0.3),
                                                  const Color.fromRGBO(
                                                      0, 0, 0, 0.4),
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
                                const SizedBox(
                                  height: 12.0,
                                ),
                                Container(
                                  color: _darkMode
                                      ? Colors.white
                                      : const Color.fromRGBO(38, 38, 38, 1.0),
                                  width: screenSize.width,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      SizedBox(
                                        width: screenSize.width * 0.9,
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      149, 149, 149, 1.0),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30))),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  left: 3,
                                                  right: 15,
                                                  top: 3,
                                                  bottom: 3),
                                              margin: const EdgeInsets.only(
                                                  bottom: 5),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    child: Container(
                                                      width: 26,
                                                      color: Colors.white,
                                                      child: const Icon(
                                                        Icons.person,
                                                        size: 25,
                                                        color: Color.fromRGBO(
                                                            76, 168, 155, 1.0),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    data.penulis.toString(),
                                                    style: theme
                                                        .textTheme.subtitle2
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12.0,
                                            ),
                                            Text(
                                              data.tanggal,
                                              style: theme.textTheme.subtitle2
                                                  ?.copyWith(
                                                color: _darkMode
                                                    ? const Color.fromRGBO(
                                                        131, 131, 131, 1.0)
                                                    : Colors.white,
                                              ),
                                            ),
                                            const Spacer()
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      ...paragraf.map((kalimat) {
                                        if (kalimat.indexOf('[img') != -1) {
                                          String imgUrl = kalimat.substring(
                                              5, kalimat.length - 1);
                                          // print('ArticleDetailScreen: imgUrl dari tag: $imgUrl'); // Hapus print ini
                                          return Container(
                                            width: screenSize.width * 0.9,
                                            child: CachedNetworkImage(
                                              // Gunakan CachedNetworkImage untuk gambar konten
                                              imageUrl: imgUrl.trim(),
                                              fit: BoxFit.fitWidth,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
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
                                                      ? const Color.fromRGBO(
                                                          61, 61, 61, 1.0)
                                                      : Colors.white),
                                            ),
                                          );
                                        }
                                      }).toList(),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          } else {
                            // Ini akan menangani kasus di mana snapshot.data null atau data di dalamnya null
                            // print('ArticleDetailScreen: FutureBuilder Data null atau tidak ada.'); // Hapus print ini
                            String errorTitle =
                                'Tidak dapat menemukan artikel yang dicari';
                            String? errorSubtitle = snapshot.data?.error ??
                                'Data artikel tidak tersedia.';
                            return Column(
                              children: [
                                const SizedBox(height: 16),
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
  }

  List<String> splitTextByImageTag(
      String kalimat, List<String> splittedKalimat) {
    // print('ArticleDetailScreen: splitTextByImageTag dipanggil dengan kalimat awal: ${kalimat.length > 50 ? kalimat.substring(0, 50) + '...' : kalimat}'); // Hapus print ini
    late String firstPart;
    late String nextPart;
    late String lastPart;
    late String imgUrl;
    late int startIndex;
    late int endIndex;

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
        // print('ArticleDetailScreen: Ditemukan tag gambar. FirstPart: ${firstPart.length}, ImgUrl: ${imgUrl.length}, LastPart: ${lastPart.length}'); // Hapus print ini
      } else {
        // Handle case where [img= tag is opened but not closed
        // print('ArticleDetailScreen: Peringatan: Tag [img= tidak ditutup dengan ]. Menambahkan sisa kalimat sebagai teks.'); // Hapus print ini
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
      // print('ArticleDetailScreen: Tidak ada tag gambar lagi. Mengembalikan list. Total paragraf: ${splittedKalimat.length}'); // Hapus print ini
      return splittedKalimat;
    }
  }
}
