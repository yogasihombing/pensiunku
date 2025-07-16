import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/forum_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class ForumPostingScreen extends StatefulWidget {
  const ForumPostingScreen({Key? key}) : super(key: key);

  @override
  State<ForumPostingScreen> createState() => _ForumPostingScreenState();
}

class _ForumPostingScreenState extends State<ForumPostingScreen> {
  final ImagePicker imgpicker = ImagePicker();
  List<XFile>? imagefiles;
  UserModel? user;

  final TextEditingController _postController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print('ForumPostingScreen: initState dipanggil.');
    getUser();
  }

  @override
  void dispose() {
    print('ForumPostingScreen: dispose() dipanggil.');
    _postController.dispose();
    super.dispose();
  }

  getUser() async {
    print('ForumPostingScreen: getUser dipanggil.');
    try {
      final prefs = await SharedPreferencesUtil().sharedPreferences;
      String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);
      print('ForumPostingScreen: Token diambil: ${token != null && token.isNotEmpty ? "Ada" : "Tidak Ada"}');

      if (token == null || token.isEmpty) {
        print('ForumPostingScreen: Token null atau kosong, tidak dapat mengambil data user.');
        // Handle case where token is not available, e.g., navigate to login
        return;
      }

      final userResult = await UserRepository().getOneDb(token);
      if (mounted) {
        setState(() {
          user = userResult.data;
          print('ForumPostingScreen: Data user berhasil diambil: ${user?.username}');
        });
      }
      if (userResult.data == null) {
        print('ForumPostingScreen: Gagal mendapatkan data user: ${userResult.error}');
        // Optionally show an error message to the user
      }
    } catch (e) {
      print('ForumPostingScreen: Error saat mengambil data user: $e');
      // Optionally show an error message to the user
    }
  }

  openImages() async {
    print('ForumPostingScreen: openImages dipanggil.');
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      if (pickedfiles != null && mounted) {
        setState(() {
          imagefiles = pickedfiles;
          print('ForumPostingScreen: ${imagefiles!.length} gambar dipilih.');
        });
      } else {
        print("ForumPostingScreen: Tidak ada gambar yang dipilih.");
      }
    } catch (e) {
      print("ForumPostingScreen: Error saat memilih gambar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat memilih gambar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Mengubah parameter `data` menjadi `content` dan `foto` (List<File>)
  Future<bool> _addPosting(String content, List<File> foto) async {
    print('ForumPostingScreen: _addPosting dipanggil. Konten: $content, Jumlah foto: ${foto.length}');
    if (content.isEmpty && foto.isEmpty) {
      print('ForumPostingScreen: Konten dan foto kosong, postingan tidak dapat dibuat.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Postingan tidak boleh kosong!'), backgroundColor: Colors.orange),
        );
      }
      return false;
    }

    setState(() {
      isLoading = true;
    });
    print('ForumPostingScreen: isLoading = true.');

    final prefs = await SharedPreferencesUtil().sharedPreferences;
    String? token = prefs.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      print('ForumPostingScreen: Token null atau kosong, tidak bisa menambah postingan.');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token tidak tersedia, silakan login ulang.'), backgroundColor: Colors.red),
        );
      }
      return false;
    }

    bool success = false;
    try {
      print('ForumPostingScreen: Memulai panggilan ForumRepository().addForumPost...');
      // Meneruskan content dan foto secara terpisah
      final value = await ForumRepository().addForumPost(token, content, foto);
      success = value.data ?? false; // Pastikan mengembalikan bool
      print('ForumPostingScreen: addForumPost success: $success. Error: ${value.error}');
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value.error ?? 'Gagal membuat postingan.'), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Postingan berhasil dibuat!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print('ForumPostingScreen: Error saat menambahkan postingan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      success = false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // font style
    TextStyle blackTextStyle = TextStyle(color: Colors.black);
    TextStyle greenTextTyle =
        TextStyle(color: Color.fromRGBO(1, 169, 159, 1.0));

    //Color Style
    Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);

    Widget header() {
      return Container(
        margin: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              width: 20,
            ),
            Text(
              "${user?.username ?? 'Memuat...'}", // Tampilkan username atau 'Memuat...'
              style: blackTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    Widget post() {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: TextFormField(
          controller: _postController,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          minLines: 10,
          maxLines: null,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: 'Buat postingan...',
            hintStyle: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      );
    }

    Widget bottomBar() {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.image,
                  size: 32,
                  color: greenColor,
                ),
                onPressed: isLoading ? null : () { // Disable when loading
                  print('ForumPostingScreen: Tombol pilih gambar ditekan.');
                  openImages();
                },
              ),
            ],
          ));
    }

    Widget showImage() {
      Widget buildImage(XFile image, int idx) {
        return Container(
          width: 200,
          height: 200,
          margin: EdgeInsets.only(
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(image.path),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: isLoading ? null : () { // Disable when loading
                    print('ForumPostingScreen: Tombol hapus gambar ditekan untuk indeks: $idx.');
                    if (imagefiles != null && mounted) {
                      setState(() {
                        imagefiles!.removeAt(idx);
                      });
                    }
                  },
                  icon: Icon(Icons.cancel, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: imagefiles != null && imagefiles!.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: imagefiles!
                    .asMap()
                    .entries
                    .map(
                      (item) => Container(
                        margin: EdgeInsets.only(left: item.key == 0 ? 16 : 0),
                        child: buildImage(item.value, item.key),
                      ),
                    )
                    .toList(),
              )
            : Container(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: greenColor,
        leading: IconButton(
          onPressed: isLoading ? null : () { // Disable when loading
            print('ForumPostingScreen: Tombol kembali di AppBar ditekan.');
            Navigator.of(context).pop(true);
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: isLoading ? null : () async { // Disable when loading
                print('ForumPostingScreen: Tombol Post ditekan.');
                if (_postController.text.isEmpty && (imagefiles == null || imagefiles!.isEmpty)) {
                  print('ForumPostingScreen: Postingan kosong (konten dan gambar).');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Postingan tidak boleh kosong!'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                List<File> fileUpload = [];
                if (imagefiles != null) {
                  for (var foto in imagefiles!) {
                    fileUpload.add(File(foto.path));
                  }
                }

                bool success = await _addPosting(_postController.text, fileUpload);
                print('ForumPostingScreen: Postingan berhasil: $success');
                if (success && mounted) {
                  Navigator.pop(context); // Kembali ke ForumScreen
                }
              },
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: greenTextTyle.color,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Post',
                      style: greenTextTyle,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: bottomBar(),
      ),
      resizeToAvoidBottomInset: false, // Set false agar tidak resize saat keyboard muncul
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      header(),
                      post(),
                    ],
                  ),
                  showImage(),
                ],
              ),
            ),
          ),
          if (isLoading) // Tampilkan overlay loading jika isLoading true
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              child: Center(
                child: Container(
                  width: 65,
                  height: 65,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}