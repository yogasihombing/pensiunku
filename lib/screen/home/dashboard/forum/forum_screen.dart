import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/repository/forum_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_detail_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_posting_screen.dart';
import 'package:pensiunku/screen/home/dashboard/forum/photo_view_screen.dart';
import 'package:like_button/like_button.dart';
import 'package:readmore/readmore.dart';
import 'package:pensiunku/config.dart' show apiHost;

import '../../../../model/result_model.dart';
import '../../../../util/shared_preferences_util.dart';
import '../../../../widget/sliver_app_bar_sheet_top.dart';
import '../../../../widget/sliver_app_bar_title.dart';

class ForumScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/forum';
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  Future<ResultModel<List<ForumModel>>>? _futureData;
  int? dataLength;

  //toggle button posting
  final List<Widget> toggleButtonPosting = [
    Text('Terbaru'),
    Text('Postingan Saya')
  ];

  final List<bool> toggleButtonPostingSelected = [true, false];

  bool isReadMore = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
    print('ForumScreen: initState dipanggil.');
  }

  // --- PERBAIKAN UTAMA: Tambahkan metode dispose() ---
  @override
  void dispose() {
    // Pastikan untuk membuang (dispose) setiap controller atau listener
    // yang Anda inisialisasi di initState atau build method dan tidak terikat
    // langsung pada lifecycle widget (misalnya, TextEditingController, StreamController, AnimationController).
    // Dalam kode ini, tidak ada controller eksplisit yang Anda inisialisasi
    // di initState yang perlu di-dispose secara manual oleh Anda.
    // Namun, penting untuk selalu menyertakan dispose() dan memanggil super.dispose().

    // Penting: Jika Anda menambahkan StreamController atau Timer, pastikan dibatalkan di sini.
    // Misalnya: _someStreamSubscription?.cancel();
    //           _someTimer?.cancel();

    print('ForumScreen: dispose() dipanggil.');
    super.dispose();
  }
  // --- AKHIR PERBAIKAN UTAMA ---

  _refreshData() async {
    print('ForumScreen: _refreshData dipanggil.');
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('ForumScreen: Token null, tidak dapat memuat data forum.');
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _futureData = Future.value(
              ResultModel(isSuccess: false, error: 'Token tidak tersedia.'));
          dataLength =
              0; // Atur dataLength agar menampilkan "tidak ada postingan"
        });
      }
      return;
    }

    try {
      int userId = await UserRepository().getOneDb(token).then((value) {
        if (value.data != null) {
          return value.data!.id;
        }
        print('ForumScreen: User ID tidak ditemukan atau null dari DB.');
        throw Exception('User ID tidak tersedia');
      }).catchError((e) {
        print('ForumScreen: Error mengambil user ID dari DB: $e');
        throw e; // Lanjutkan melempar error agar ditangani oleh FutureBuilder
      });

      print('ForumScreen: User ID: $userId');

      Future<ResultModel<List<ForumModel>>> currentFuture;
      if (toggleButtonPostingSelected[0]) {
        print('ForumScreen: Memuat semua postingan forum.');
        currentFuture = ForumRepository().getAllForumPost(token);
      } else {
        print(
            'ForumScreen: Memuat postingan forum berdasarkan user ID: $userId');
        currentFuture = ForumRepository().getForumPostbyUserID(token, userId);
      }

      // Pastikan Future ini ditangani dalam scope _refreshData
      currentFuture.then((value) {
        if (mounted) {
          // Periksa mounted sebelum setState
          setState(() {
            if (value.data != null && value.data!.isNotEmpty) {
              dataLength = value.data!.length;
              print(
                  'ForumScreen: Data forum berhasil dimuat. Jumlah: $dataLength');
            } else {
              dataLength = 0; // Data kosong
              print('ForumScreen: Tidak ada data forum yang dimuat.');
            }
            _futureData = Future.value(
                value); // Perbarui _futureData dengan Future yang selesai
          });
        }
      }).catchError((error) {
        print('ForumScreen: Error memuat data forum: $error');
        if (mounted) {
          // Periksa mounted sebelum setState
          setState(() {
            _futureData = Future.value(
                ResultModel(isSuccess: false, error: error.toString()));
            dataLength =
                0; // Set dataLength agar menampilkan "tidak ada postingan" atau pesan error
          });
        }
      });
      // Penting: Set _futureData di sini agar FutureBuilder langsung mulai menunggu
      _futureData = currentFuture;
    } catch (e) {
      print('ForumScreen: Error umum di _refreshData: $e');
      if (mounted) {
        // Periksa mounted sebelum setState
        setState(() {
          _futureData =
              Future.value(ResultModel(isSuccess: false, error: e.toString()));
          dataLength = 0;
        });
      }
    }
  }

  Future<bool> onLikeButtonTapped(bool isLiked, int id) async {
    print(
        'ForumScreen: Like button ditekan untuk ID: $id. Status isLiked: $isLiked');
    bool success;
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      print('ForumScreen: Token null, tidak bisa melakukan like/unlike.');
      return isLiked; // Kembalikan status asli karena tidak bisa melakukan operasi
    }

    if (isLiked) {
      success = await ForumRepository().removeLike(token, id).then((value) {
        print('ForumScreen: Remove like success: ${value.data}');
        return value.data ?? false; // Pastikan mengembalikan bool
      }).catchError((e) {
        print('ForumScreen: Error remove like: $e');
        return false; // Gagal
      });
    } else {
      success = await ForumRepository().addPostLike(token, id).then((value) {
        print('ForumScreen: Add like success: ${value.data}');
        return value.data ?? false; // Pastikan mengembalikan bool
      }).catchError((e) {
        print('ForumScreen: Error add like: $e');
        return false; // Gagal
      });
    }

    return success ? !isLiked : isLiked;
  }

  //Konversi tanggal dan waktu dalam bentuk menit, jam, hari, dan tanggal
  String _getTime(DateTime time) {
    // menyesuaikan jam dengan zona waktu
    time = time.add(Duration(hours: time.timeZoneOffset.inHours));

    DateTime now = DateTime.now();
    Duration diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} detik';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam';
    } else if (diff.inDays < 5) {
      return '${diff.inDays} hari';
    } else {
      final DateFormat dateFormater = DateFormat('dd MMM yyyy');
      return dateFormater.format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Widget Dimensions
    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.3;

    // font style
    TextStyle blackTextStyle = TextStyle(color: Colors.black);
    TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    TextStyle greenTextTyle =
        TextStyle(color: Color.fromRGBO(1, 169, 159, 1.0));
    TextStyle greyTextStyle = TextStyle(
      color: Color.fromRGBO(149, 149, 149, 1.0),
    );

    // color style
    Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);
    Color greyColor = Color.fromRGBO(149, 149, 149, 1.0);

    Widget header() {
      return SliverAppBar(
        pinned: true,
        expandedHeight: sliverAppBarExpandedHeight,
        leading: IconButton(
          onPressed: () {
            print('ForumScreen: Tombol kembali ditekan.');
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        flexibleSpace: FlexibleSpaceBar(
          title: SliverAppBarTitle(
            child: SizedBox(
              height: AppBar().preferredSize.height * 0.4,
              child: Text('Forum Pensiun Hebat'),
            ),
          ),
          titlePadding: const EdgeInsets.only(
            left: 46.0,
            bottom: 16.0,
          ),
          background: Container(
            child: Stack(
              fit: StackFit.loose,
              children: [
                Container(
                  width: screenSize.width,
                  child: Image.asset('assets/dashboard_screen/bg_kesehatan.png',
                      fit: BoxFit.fitWidth),
                ),
                Positioned.fill(
                  top: 50,
                  left: 32,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pensiunku\nTalk',
                      style: whiteTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverAppBarSheetTop(),
              ],
            ),
          ),
        ),
      );
    }

    Widget posting() {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 48,
                  height: 48,
                  color: Color.fromRGBO(1, 169, 159, 1.0),
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    print('ForumScreen: Tombol "Tulis sesuatu..." ditekan.');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumPostingScreen(),
                      ),
                    ).then((_) {
                      print(
                          'ForumScreen: Kembali dari ForumPostingScreen. Memuat ulang data.');
                      _refreshData();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Tulis sesuatu...',
                        style: blackTextStyle.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget toggleButton() {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.all(16),
          child: ToggleButtons(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            selectedBorderColor: Color.fromRGBO(1, 169, 159, 1.0),
            selectedColor: Colors.white,
            fillColor: Color.fromRGBO(1, 169, 159, 1.0),
            color: Colors.black,
            textStyle: blackTextStyle.copyWith(fontSize: 16),
            constraints: BoxConstraints(
              minHeight: 40.0,
              minWidth: (screenSize.width - 36) / 2,
            ),
            children: toggleButtonPosting,
            isSelected: toggleButtonPostingSelected,
            onPressed: (int index) {
              print('ForumScreen: ToggleButton ditekan. Indeks: $index');
              // ketika di klik akan mengubah status tombel toggle menjadi true dan yang lainya false.
              for (int i = 0; i < toggleButtonPostingSelected.length; i++) {
                toggleButtonPostingSelected[i] = i == index;
              }
              _refreshData();
              if (mounted) {
                // Periksa mounted sebelum setState
                setState(() {});
              }
            },
          ),
        ),
      );
    }

    Widget cardPosting() {
      Widget buildImage(List<ForumFotoModel> foto, int index) {
        if (foto.length <= 3) {
          return Container(
            color: Color.fromRGBO(149, 149, 149, 1.0),
            child: CachedNetworkImage(
              imageUrl: "$apiHost/${foto[index].path!}",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Stack(
            children: [
              Container(
                  color: Color.fromRGBO(149, 149, 149, 1.0),
                  child: CachedNetworkImage(
                    imageUrl: "$apiHost/${foto[index].path!}",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )),
              index == 2
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(0.50),
                      child: Center(
                        child: Text(
                          '+ ${foto.length - 3}',
                          style: whiteTextStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          );
        }
      }

      Widget imageGallery(List<ForumFotoModel> foto) {
        print(
            'ForumScreen: Membangun imageGallery. Jumlah foto: ${foto.length}');
        if (foto.isEmpty) {
          // Tambahkan pengecekan jika foto kosong
          print(
              'ForumScreen: foto list kosong, mengembalikan Container kosong.');
          return Container();
        }

        List<String> fotos =
            foto.map((item) => "$apiHost/${item.path!}").toList();
        return StaggeredGrid.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: foto.asMap().entries.take(3).map((item) {
            if (foto.length == 1) {
              return StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 3,
                child: InkWell(
                  onTap: () {
                    print(
                        'ForumScreen: Image diklik (1 foto). Navigasi ke PhotoViewScreen.');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewScreen(
                            images: fotos,
                          ),
                        ));
                  },
                  child: buildImage(foto, item.key),
                ),
              );
            } else if (foto.length == 2) {
              return StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 2,
                child: InkWell(
                  onTap: () {
                    print(
                        'ForumScreen: Image diklik (2 foto). Navigasi ke PhotoViewScreen.');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewScreen(
                            images: fotos,
                            selectedIndex: item.key == 2
                                ? 2
                                : item.key, // Perlu dicek lagi logika indexnya
                          ),
                        ));
                  },
                  child: buildImage(foto, item.key),
                ),
              );
            } else {
              // foto.length > 2
              return StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: item.key == 0 ? 2 : 1,
                child: InkWell(
                  onTap: () {
                    print(
                        'ForumScreen: Image diklik (>2 foto). Navigasi ke PhotoViewScreen.');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewScreen(
                              images: fotos,
                              selectedIndex: item.key == 2
                                  ? 2
                                  : item
                                      .key), // Perlu dicek lagi logika indexnya
                        ));
                  },
                  child: buildImage(foto, item.key),
                ),
              );
            }
          }).toList(),
        );
      }

      Widget itemPost(ForumModel post) {
        print('ForumScreen: Membangun itemPost untuk ID: ${post.id_forum}.');
        // Pengecekan null-safety tambahan untuk properti yang mungkin null
        final String displayName = post.nama ?? 'Anonim';
        final String displayContent = post.content ?? 'Tidak ada konten.';
        final DateTime displayTime =
            post.created_at ?? DateTime.now(); // Default jika null
        final List<ForumFotoModel> displayFotos = post.foto ?? [];
        final int displayTotalLike = post.total_like ?? 0;
        final int displayTotalComment = post.total_comment ?? 0;

        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 38,
                      height: 38,
                      color: Color.fromRGBO(1, 169, 159, 1.0),
                      child: Icon(
                        Icons.person,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName, // Gunakan displayName
                        style: blackTextStyle.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        _getTime(displayTime), // Gunakan displayTime
                        style: greyTextStyle,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              //BODY
              ReadMoreText(
                displayContent, // Gunakan displayContent
                trimLines: 4,
                moreStyle: greenTextTyle,
                lessStyle: greenTextTyle,
                trimExpandedText: '\nLebih Sedikit',
                trimCollapsedText: 'Selengkapnya',
                style: blackTextStyle.copyWith(height: 1.5),
              ),
              SizedBox(
                height: 12,
              ),
              // IMAGE
              displayFotos.isNotEmpty
                  ? imageGallery(displayFotos)
                  : Container(), // Gunakan displayFotos dan cek isNotEmpty

              //FOOTER
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder<ResultModel<String>>(
                    // PENTING: Pastikan post.id_forum tidak null sebelum dilewatkan
                    future: post.id_forum != null
                        ? ForumRepository().checkStatusLike(post.id_forum!)
                        : Future.value(ResultModel(
                            isSuccess: false, error: 'ID Forum null')),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 24, // Ukuran placeholder
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2), // Loading indicator kecil
                        );
                      }
                      // Log error dari checkStatusLike
                      if (snapshot.hasError) {
                        print(
                            'ForumScreen: Error checkStatusLike for ID ${post.id_forum}: ${snapshot.error}');
                      }
                      if (!snapshot.hasData ||
                          snapshot.data?.data == null ||
                          !snapshot.data!.isSuccess) {
                        print(
                            'ForumScreen: checkStatusLike: No data or error. Defaulting to unliked. IsSuccess: ${snapshot.data?.isSuccess}, Error: ${snapshot.data?.error}');
                        return LikeButton(
                          isLiked: false,
                          likeCount:
                              displayTotalLike, // Gunakan displayTotalLike
                          likeBuilder: (isLiked) =>
                              Icon(Icons.favorite, color: Colors.grey[400]),
                          onTap: (isLiked) =>
                              onLikeButtonTapped(isLiked, post.id_forum!),
                        );
                      }
                      bool isLike = snapshot.data!.data == "1";
                      print(
                          'ForumScreen: checkStatusLike for ID ${post.id_forum}: isLiked: $isLike');
                      return LikeButton(
                        isLiked: isLike,
                        likeCount: displayTotalLike, // Gunakan displayTotalLike
                        likeBuilder: (liked) => Icon(Icons.favorite,
                            color: liked ? Colors.red[500] : Colors.grey[400]),
                        onTap: (liked) =>
                            onLikeButtonTapped(liked, post.id_forum!),
                      );
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          print(
                              'ForumScreen: Tombol komentar ditekan untuk ID: ${post.id_forum}.');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForumDetailScreen(forum: post),
                            ),
                          ).then((_) {
                            print(
                                'ForumScreen: Kembali dari ForumDetailScreen. Memuat ulang data.');
                            _refreshData();
                          });
                        },
                        icon: Icon(
                          Icons.mode_comment_rounded,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(displayTotalComment
                          .toString()) // Gunakan displayTotalComment
                    ],
                  )
                ],
              )
            ],
          ),
        );
      }

      Widget tidakAdaPost() {
        print('ForumScreen: Menampilkan pesan "Belum ada postingan".');
        return Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 16),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(
                Icons.forum,
                size: 64,
                color: greyColor,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'Belum ada postingan',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                'Buat postingan sekarang',
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: () {
                  print(
                      'ForumScreen: Tombol "Tulis sesuatu" (tidak ada postingan) ditekan.');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForumPostingScreen(),
                    ),
                  ).then((_) {
                    print(
                        'ForumScreen: Kembali dari ForumPostingScreen. Memuat ulang data.');
                    _refreshData();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      greenColor, // Ganti primary ke backgroundColor
                ),
                child: Text('Tulis sesuatu'),
              )
            ],
          ),
        );
      }

      return FutureBuilder<ResultModel<List<ForumModel>>>(
        future: _futureData,
        builder: (context, snapshot) {
          print(
              'ForumScreen: FutureBuilder (data forum) - ConnectionState: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return SliverToBoxAdapter(
              child: Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            // --- Penanganan Error dari ResultModel ---
            if (snapshot.hasError || !snapshot.data!.isSuccess) {
              print(
                  'ForumScreen: FutureBuilder (data forum) - Ada error atau isSuccess: false. Error: ${snapshot.error ?? snapshot.data?.error}');
              // Tampilkan pesan error jika Future gagal atau ResultModel mengindikasikan error
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Gagal memuat postingan: ${snapshot.error ?? snapshot.data?.error ?? "Tidak diketahui"}',
                      style: greyTextStyle.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            // --- Akhir Penanganan Error ---

            List<ForumModel>? data = snapshot.data?.data;
            if (data != null && data.isNotEmpty) {
              print(
                  'ForumScreen: FutureBuilder (data forum) - Data berhasil dimuat. Jumlah: ${data.length}');
              data.sort((a, b) => b.created_at!.compareTo(
                  a.created_at!)); // Perlu pastikan created_at tidak null
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return itemPost(data[index]);
                  },
                  childCount: data.length,
                ),
              );
            } else {
              print(
                  'ForumScreen: FutureBuilder (data forum) - Data kosong atau null.');
              return SliverToBoxAdapter(child: tidakAdaPost());
            }
          } else {
            // Ini adalah kondisi fallback jika state bukan waiting/none/done (seharusnya tidak terjadi)
            print(
                'ForumScreen: FutureBuilder (data forum) - ConnectionState tidak terduga: ${snapshot.connectionState}');
            return SliverToBoxAdapter(child: tidakAdaPost());
          }
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) Background gradient
        Container(
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
        ),

        // 2) Scaffold transparan di atasnya
        Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: () async {
              print('ForumScreen: RefreshIndicator dipicu.');
              await _refreshData(); // Tunggu hingga refresh selesai
            },
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                header(),
                posting(),
                toggleButton(),
                cardPosting(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
