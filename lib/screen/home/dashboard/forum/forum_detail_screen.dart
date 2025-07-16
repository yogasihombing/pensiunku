import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/config.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:like_button/like_button.dart';
import 'package:pensiunku/config.dart' show apiHost;
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/forum_repository.dart';
import 'package:pensiunku/screen/common/galery_fullscreen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class ForumDetailScreen extends StatefulWidget {
  final ForumModel forum;
  const ForumDetailScreen({Key? key, required this.forum}) : super(key: key);

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  late Future<ResultModel<List<ForumDetailModel>>> _futureData;
  late FocusNode myFocusNode;

  final TextEditingController _komentarController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // font style (Dipindahkan ke sini agar dapat diakses oleh semua metode widget)
  late TextStyle blackTextStyle;
  late TextStyle whiteTextStyle;
  late TextStyle greenTextTyle;
  late TextStyle greyTextStyle;

  // color style (Dipindahkan ke sini agar dapat diakses oleh semua metode widget)
  late Color greenColor;
  late Color greyColor;

  //Konversi tanggal dan waktu dalam bentuk menit, jam, hari, dan tanggal
  String _getTime(DateTime time) {
    // menyesuaikan jam dengan zona waktu
    // time = time.add(Duration(hours: time.timeZoneOffset.inHours)); // Hapus ini jika createdAt sudah UTC atau lokal
    DateTime now = DateTime.now();
    Duration diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} detik yang lalu';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 5) {
      return '${diff.inDays} hari yang lalu';
    } else {
      final DateFormat dateFormater = DateFormat('dd MMM yyyy');
      return dateFormater.format(time);
    }
  }

  @override
  void initState() {
    super.initState();
    print('ForumDetailScreen: initState dipanggil.');
    myFocusNode = FocusNode();
    // Inisialisasi style dan color di initState
    blackTextStyle = TextStyle(color: Colors.black);
    whiteTextStyle = TextStyle(color: Colors.white);
    greenTextTyle = TextStyle(color: Color.fromRGBO(1, 169, 159, 1.0));
    greyTextStyle = TextStyle(color: Color.fromRGBO(149, 149, 149, 1.0));

    greenColor = Color.fromRGBO(1, 169, 159, 1.0);
    greyColor = Color.fromRGBO(149, 149, 149, 1.0);

    _refreshData();
  }

  @override
  void dispose() {
    print('ForumDetailScreen: dispose() dipanggil.');
    myFocusNode.dispose();
    _komentarController.dispose();
    super.dispose();
  }

  _refreshData() async {
    // Ubah menjadi async
    print('ForumDetailScreen: _refreshData dipanggil.');
    final prefs = await SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    print(
        'ForumDetailScreen: Token diambil: ${token != null && token.isNotEmpty ? "Ada" : "Tidak Ada"}');

    if (token == null || token.isEmpty) {
      print(
          'ForumDetailScreen: Token null atau kosong, tidak dapat memuat detail forum.');
      if (mounted) {
        setState(() {
          _futureData = Future.value(
              ResultModel(isSuccess: false, error: 'Token tidak tersedia.'));
        });
      }
      return Future.value(ResultModel(
          isSuccess: false, error: 'Token tidak tersedia.')); // Return a Future
    }

    if (widget.forum.idForum == null) {
      // Menggunakan idForum
      print(
          'ForumDetailScreen: ID Forum null, tidak dapat memuat detail forum.');
      if (mounted) {
        setState(() {
          _futureData = Future.value(
              ResultModel(isSuccess: false, error: 'ID Forum tidak tersedia.'));
        });
      }
      return Future.value(ResultModel(
          isSuccess: false,
          error: 'ID Forum tidak tersedia.')); // Return a Future
    }

    try {
      print(
          'ForumDetailScreen: Memulai panggilan ForumRepository().getForumPostbyPostID...');
      final result = await ForumRepository().getForumPostbyPostID(
          token, widget.forum.idForum!); // Menggunakan idForum
      print(
          'ForumDetailScreen: Panggilan ForumRepository().getForumPostbyPostID selesai. isSuccess: ${result.isSuccess}, error: ${result.error}');

      if (mounted) {
        setState(() {
          _futureData = Future.value(result);
        });
      }
      return result;
    } catch (e) {
      print('ForumDetailScreen: Error di _refreshData (catch block): $e');
      if (mounted) {
        setState(() {
          _futureData =
              Future.value(ResultModel(isSuccess: false, error: e.toString()));
        });
      }
      return Future.value(ResultModel(isSuccess: false, error: e.toString()));
    }
  }

  Future<bool> _addKomentar(dynamic data) async {
    print('ForumDetailScreen: _addKomentar dipanggil.');
    setState(() {
      isLoading = true;
    });
    // Future.delayed(Duration(seconds: 2)); // Ini tidak memblokir, hapus saja jika tidak ada tujuan lain
    final prefs = await SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      print(
          'ForumDetailScreen: Token null atau kosong, tidak bisa menambahkan komentar.');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Token tidak tersedia, silakan login ulang.'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    }

    if (widget.forum.idForum == null) {
      // Menggunakan idForum
      print(
          'ForumDetailScreen: ID Forum null, tidak bisa menambahkan komentar.');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ID Forum tidak tersedia.'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    }

    bool success = false;
    try {
      print(
          'ForumDetailScreen: Memulai panggilan ForumRepository().addForumComment...');
      final value = await ForumRepository().addForumComment(token, data);
      success = value.data ?? false; // Pastikan mengembalikan bool
      print(
          'ForumDetailScreen: addForumComment success: $success. Error: ${value.error}');
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(value.error ?? 'Gagal menambahkan komentar.'),
                backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Komentar berhasil ditambahkan!'),
                backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print('ForumDetailScreen: Error saat menambahkan komentar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
      success = false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _refreshData(); // Refresh data setelah komentar ditambahkan
    }
    return success;
  }

  Future<bool> onLikeButtonTapped(bool isLiked, int id) async {
    print(
        'ForumDetailScreen: Like button ditekan untuk ID: $id. Status isLiked: $isLiked');
    bool success;
    final prefs = await SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      print(
          'ForumDetailScreen: Token null atau kosong, tidak bisa melakukan like/unlike.');
      return isLiked;
    }

    try {
      if (isLiked) {
        print('ForumDetailScreen: Memanggil ForumRepository().removeLike...');
        final value = await ForumRepository().removeLike(token, id);
        success = value.data ?? false;
        print(
            'ForumDetailScreen: Remove like success: $success. Error: ${value.error}');
      } else {
        print('ForumDetailScreen: Memanggil ForumRepository().addPostLike...');
        final value = await ForumRepository().addPostLike(token, id);
        success = value.data ?? false;
        print(
            'ForumDetailScreen: Add like success: $success. Error: ${value.error}');
      }
    } catch (e) {
      print('ForumDetailScreen: Error saat melakukan like/unlike: $e');
      success = false;
    }

    if (success) {
      _refreshData(); // Refresh data untuk update total_like dan total_comment
    }

    return success ? !isLiked : isLiked;
  }

  // Pindahkan deklarasi widget di sini agar dapat diakses
  Widget _buildImage(List<ForumFotoModel> foto, int index) {
    // Pengecekan null-safety untuk path gambar
    final imageUrl =
        foto[index].path != null ? "$apiHost/${foto[index].path!}" : null;

    if (foto.length <= 3) {
      return Container(
        color: Color.fromRGBO(149, 149, 149, 1.0),
        child:
            imageUrl != null && Uri.tryParse(imageUrl)?.hasAbsolutePath == true
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/placeholder_image.png', // Fallback image
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/placeholder_image.png', // Fallback if URL is invalid or null
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
            child: imageUrl != null &&
                    Uri.tryParse(imageUrl)?.hasAbsolutePath == true
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/placeholder_image.png', // Fallback image
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/placeholder_image.png', // Fallback if URL is invalid or null
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
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

  Widget _imageGallery(List<ForumFotoModel> foto) {
    print(
        'ForumDetailScreen: Membangun imageGallery. Jumlah foto: ${foto.length}');
    if (foto.isEmpty) {
      print(
          'ForumDetailScreen: foto list kosong, mengembalikan Container kosong.');
      return Container();
    }
    List<String> fotos = foto
        .map((item) => "$apiHost/${item.path!}")
        .toList(); // Pastikan path tidak null
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
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        GalleryFullScreen(images: fotos, indexPage: item.key)),
              ),
              child: _buildImage(foto, item.key), // Gunakan _buildImage
            ),
          );
        } else if (foto.length == 2) {
          return StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 2,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        GalleryFullScreen(images: fotos, indexPage: item.key)),
              ),
              child: _buildImage(foto, item.key), // Gunakan _buildImage
            ),
          );
        } else {
          return StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: item.key == 0 ? 2 : 1,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        GalleryFullScreen(images: fotos, indexPage: item.key)),
              ),
              child: _buildImage(foto, item.key), // Gunakan _buildImage
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _itemPost(ForumDetailModel post) {
    // Ubah nama fungsi dari 'post' menjadi '_itemPost'
    print(
        'ForumDetailScreen: Membangun itemPost untuk ID: ${post.idForum}.'); // Menggunakan idForum
    // Pengecekan null-safety tambahan untuk properti yang mungkin null
    final String displayName = post.nama ?? 'Anonim';
    final String displayContent = post.content ?? 'Tidak ada konten.';
    final DateTime displayTime =
        post.createdAt ?? DateTime.now(); // Menggunakan createdAt
    final List<ForumFotoModel> displayFotos = post.foto ?? [];
    final int displayTotalLike = post.totalLike ?? 0; // Menggunakan totalLike
    final int displayTotalComment =
        post.totalComment ?? 0; // Menggunakan totalComment

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    displayName,
                    style: blackTextStyle.copyWith(fontSize: 16),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    _getTime(displayTime),
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
          Text(
            displayContent,
            style: blackTextStyle.copyWith(height: 1.5),
          ),
          SizedBox(
            height: 12,
          ),
          // IMAGE
          displayFotos.isNotEmpty
              ? _imageGallery(displayFotos)
              : Container(), // Gunakan _imageGallery

          //FOOTER
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FutureBuilder<ResultModel<String>>(
                future: post.idForum != null // Menggunakan idForum
                    ? ForumRepository()
                        .checkStatusLike(post.idForum!) // Menggunakan idForum
                    : Future.value(
                        ResultModel(isSuccess: false, error: 'ID Forum null')),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (snapshot.hasError) {
                    print(
                        'ForumDetailScreen: Error checkStatusLike for ID ${post.idForum}: ${snapshot.error}'); // Menggunakan idForum
                  }
                  if (!snapshot.hasData ||
                      snapshot.data?.data == null ||
                      !snapshot.data!.isSuccess) {
                    print(
                        'ForumDetailScreen: checkStatusLike: No data or error. Defaulting to unliked. IsSuccess: ${snapshot.data?.isSuccess}, Error: ${snapshot.data?.error}');
                    return LikeButton(
                      isLiked: false,
                      likeCount: displayTotalLike,
                      likeBuilder: (isLiked) =>
                          Icon(Icons.favorite, color: Colors.grey[400]),
                      onTap: (isLiked) => onLikeButtonTapped(
                          isLiked, post.idForum!), // Menggunakan idForum
                    );
                  }
                  bool isLike = snapshot.data!.data == "1";
                  print(
                      'ForumDetailScreen: checkStatusLike for ID ${post.idForum}: isLiked: $isLike'); // Menggunakan idForum
                  return LikeButton(
                    isLiked: isLike,
                    likeCount: displayTotalLike,
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red[500] : Colors.grey[400],
                      );
                    },
                    countBuilder: (likeCount, isLiked, text) {
                      return Text(
                        text,
                        style: blackTextStyle,
                      );
                    },
                    onTap: (isLiked) {
                      return onLikeButtonTapped(
                          isLiked, post.idForum!); // Menggunakan idForum
                    },
                  );
                },
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      print(
                          'ForumDetailScreen: Tombol komentar ditekan, meminta fokus input komentar.');
                      myFocusNode.requestFocus();
                    },
                    icon: Icon(
                      Icons.mode_comment_rounded,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(displayTotalComment.toString())
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _komentar(List<ForumkomentarModel> komentarList) {
    // Ubah nama fungsi dari 'komentar' menjadi '_komentar'
    print(
        'ForumDetailScreen: Membangun daftar komentar. Jumlah komentar: ${komentarList.length}');
    if (komentarList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Belum ada komentar.',
            style: greyTextStyle,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: komentarList
            .map((komentar) => _buildKomentar(komentar))
            .toList(), // Gunakan _buildKomentar
      ),
    );
  }

  Widget _buildKomentar(ForumkomentarModel komentar) {
    // Ubah nama fungsi dari 'buildKomentar' menjadi '_buildKomentar'
    // Pengecekan null-safety tambahan
    final String displayNamaKomentator = komentar.nama ?? 'Anonim';
    final String displayContentKomentar =
        komentar.content ?? 'Tidak ada komentar.';
    final DateTime displayTimeKomentar =
        komentar.createdAt ?? DateTime.now(); // Menggunakan createdAt

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 38,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayNamaKomentator,
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getTime(displayTimeKomentar),
                      style: greyTextStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            margin: EdgeInsets.only(left: 56, right: 32),
            child: Text(
              displayContentKomentar,
              style: blackTextStyle.copyWith(height: 1.5),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                print(
                    'ForumDetailScreen: Tombol "Reply" ditekan, meminta fokus input komentar.');
                myFocusNode.requestFocus();
              },
              child: Text(
                'Reply',
                style: greyTextStyle,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _komentarInput() {
    // Ubah nama fungsi dari 'komentarInput' menjadi '_komentarInput'
    print('ForumDetailScreen: Membangun komentarInput.');
    // font style
    // TextStyle blackTextStyle = TextStyle(color: Colors.black); // Dihapus karena sudah properti kelas
    // TextStyle whiteTextStyle = TextStyle(color: Colors.white); // Dihapus karena sudah properti kelas
    // TextStyle greyTextStyle = TextStyle( // Dihapus karena sudah properti kelas
    //   color: Color.fromRGBO(149, 149, 149, 1.0),
    // );

    // color style
    // Color greenColor = Color.fromRGBO(1, 169, 159, 1.0); // Dihapus karena sudah properti kelas

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      focusNode: myFocusNode,
                      controller: _komentarController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Tulis komentar...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Komentar tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 14,
            ),
            InkWell(
              onTap: isLoading
                  ? null
                  : () async {
                      // Disable onTap when loading
                      print(
                          'ForumDetailScreen: Tombol kirim komentar ditekan.');
                      myFocusNode.unfocus();
                      if (_formKey.currentState!.validate()) {
                        var data = {
                          'content': _komentarController.text,
                          'id': widget.forum.idForum, // Menggunakan idForum
                        };
                        print('ForumDetailScreen: Data komentar: $data');
                        _komentarController.clear(); // Clear input immediately

                        bool success = await _addKomentar(data);
                        print(
                            'ForumDetailScreen: Komentar berhasil ditambahkan: $success');
                        if (success) {
                          // Optionally, show a success message or refresh the list
                        }
                      } else {
                        print('ForumDetailScreen: Validasi komentar gagal.');
                      }
                    },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // font style (Dihapus dari sini karena sudah properti kelas)
    // TextStyle blackTextStyle = TextStyle(color: Colors.black);
    // TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    // TextStyle greyTextStyle = TextStyle(
    //   color: Color.fromRGBO(149, 149, 149, 1.0),
    // );

    // color style (Dihapus dari sini karena sudah properti kelas)
    // Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: greenColor,
        leading: IconButton(
          onPressed: () {
            print('ForumDetailScreen: Tombol kembali di AppBar ditekan.');
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text(
          "Forum Pensiun Hebat",
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: _komentarInput(), // Gunakan _komentarInput
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => myFocusNode.unfocus(),
        child: RefreshIndicator(
          onRefresh: () async {
            print('ForumDetailScreen: RefreshIndicator dipicu.');
            await _refreshData(); // Tunggu hingga refresh selesai
          },
          child: FutureBuilder<ResultModel<List<ForumDetailModel>>>(
            future: _futureData,
            builder: (context, snapshot) {
              print(
                  'ForumDetailScreen: FutureBuilder (detail forum) - ConnectionState: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError ||
                    (snapshot.hasData && !snapshot.data!.isSuccess)) {
                  print(
                      'ForumDetailScreen: FutureBuilder (detail forum) - Ada error atau isSuccess: false. Error: ${snapshot.error ?? snapshot.data?.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Gagal memuat detail postingan: ${snapshot.error ?? snapshot.data?.error ?? "Tidak diketahui"}',
                        style: greyTextStyle.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                List<ForumDetailModel>? data = snapshot.data?.data;
                if (data != null && data.isNotEmpty) {
                  print(
                      'ForumDetailScreen: FutureBuilder (detail forum) - Data berhasil dimuat. Jumlah: ${data.length}');
                  // Menampilkan post berdasarkan waktu paling baru (jika ada beberapa, ambil yang pertama)
                  // Pastikan createdAt tidak null sebelum sorting
                  data.sort((a, b) {
                    if (a.createdAt == null && b.createdAt == null) return 0;
                    if (a.createdAt == null) return 1; // Nulls last
                    if (b.createdAt == null) return -1; // Nulls last
                    return b.createdAt!.compareTo(a.createdAt!);
                  });
                  return ListView(
                    children: [
                      _itemPost(data[0]), // Gunakan _itemPost
                      _komentar(data[0].comment ?? []), // Gunakan _komentar
                    ],
                  );
                } else {
                  print(
                      'ForumDetailScreen: FutureBuilder (detail forum) - Data kosong atau null.');
                  return Center(
                    child: Text('Tidak ada detail postingan ditemukan.',
                        style: greyTextStyle),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                print(
                    'ForumDetailScreen: FutureBuilder (detail forum) - ConnectionState.waiting, menampilkan loading.');
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                    ),
                  ),
                );
              } else {
                print(
                    'ForumDetailScreen: FutureBuilder (detail forum) - ConnectionState tidak terduga: ${snapshot.connectionState}');
                return Center(
                  child: Text('Terjadi kesalahan saat memuat data.',
                      style: greyTextStyle),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
