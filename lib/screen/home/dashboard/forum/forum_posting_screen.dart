import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';

import '../../../../repository/forum_repository.dart';
import '../../../../repository/user_repository.dart';
import '../../../../util/shared_preferences_util.dart';

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

  getUser() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    user = await UserRepository().getOneDb(token!).then((value) {
      return value.data!;
    });
    setState(() {});
  }

  openImages() async {
    try {
      var pickedfiles = await imgpicker.pickMultiImage();
      if (pickedfiles != null) {
        imagefiles = pickedfiles;
        setState(() {});
      } else {
        print("tidak ada gambar yang dipilih.");
      }
    } catch (e) {
      print("error saat memilih gambar.");
    }
  }

  Future<bool> _addPosting(String content, List<File> foto) async {
    setState(() {
      isLoading = true;
    });

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    List<MultipartFile> uploadFile = [];
    for (var img in foto) {
      var pic = MultipartFile.fromFileSync(img.path);
      uploadFile.add(pic);
    }

    var data = FormData.fromMap({'content': content, 'photos[]': uploadFile});

    bool success =
        await ForumRepository().addForumPost(token!, data).then((value) {
      return value.data!;
    });

    return success;
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
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
              "${user?.username}",
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
                onPressed: () {
                  openImages();
                },
              ),
            ],
          ));
    }

    Widget showImage() {
      Widget buildImage(XFile image, int idx) {
        // print(image.path);
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
                  onPressed: () {
                    imagefiles!.removeAt(idx);
                    setState(() {});
                  },
                  icon: Icon(Icons.cancel),
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: imagefiles != null
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
          onPressed: () {
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
              onPressed: () async {
                if (!isLoading) {
                  if (_postController.text.isNotEmpty) {
                    List<File> fileUpload = [];
                    if (imagefiles != null) {
                      for (var foto in imagefiles!) {
                        fileUpload.add(File(foto.path));
                      }
                    }

                    if (await _addPosting(_postController.text, fileUpload)) {
                      // Navigator.popAndPushNamed(
                      //     context, ForumScreen.ROUTE_NAME);
                      Navigator.pop(context);
                    }
                  }
                }
              },
              child: Text(
                'Post',
                style: greenTextTyle,
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: bottomBar(),
      ),
      resizeToAvoidBottomInset: false,
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
          isLoading
              ? Container(
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
                )
              : SizedBox()
        ],
      ),
    );
  }
}
