import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/config.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/screen/home/dashboard/forum/forum_screen.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:like_button/like_button.dart';
import 'package:pensiunku/config.dart' show apiHost;

import '../../../../repository/forum_repository.dart';
import '../../../../repository/result_model.dart';
import '../../../../util/shared_preferences_util.dart';
import '../../../common/galery_fullscreen.dart';

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

  //Konversi tanggal dan waktu dalam bentuk menit, jam, hari, dan tanggal
  String _getTime(DateTime time) {
    // menyesuaikan jam dengan zona waktu
    time = time.add(Duration(hours: time.timeZoneOffset.inHours));
    DateTime now = DateTime.now();
    Duration diff = now.difference(time);
    if (diff.inMinutes < 60) {
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
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    _refreshData();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _komentarController.dispose();
    super.dispose();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = ForumRepository()
        .getForumPostbyPostID(token!, widget.forum.id_forum!)
        .then((value) {
      setState(() {});
      return value;
    });
  }

  Future<bool> _addKomentar(dynamic data) async {
    isLoading = true;
    Future.delayed(Duration(seconds: 2));
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    bool success =
        await ForumRepository().addForumComment(token!, data).then((value) {
      isLoading = false;
      return value.data!;
    });
    _refreshData();
    return success;
  }

  Future<bool> onLikeButtonTapped(bool isLiked, int id) async {
    bool success;
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (isLiked) {
      success = await ForumRepository()
          .removeLike(token!, id)
          .then((value) => value.data!);
    } else {
      success = await ForumRepository()
          .addPostLike(token!, id)
          .then((value) => value.data!);
    }

    return success ? !isLiked : isLiked;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // font style
    TextStyle blackTextStyle = TextStyle(color: Colors.black);
    TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    TextStyle greyTextStyle = TextStyle(
      color: Color.fromRGBO(149, 149, 149, 1.0),
    );

    // color style
    Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);

    Widget post(ForumDetailModel forum) {
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
                  )
                  // ),
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

      Widget imageGallery(List<ForumFotoModel> foto) {
        List<String> fotos =
            foto.map((item) => "$apiHost/${item.path}").toList();
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
                  onTap: () => Navigator.of(context).pushNamed(
                    GalleryFullScreen.ROUTE_NAME,
                    arguments: GalleryFullScreenArguments(
                        images: fotos, indexPage: item.key),
                  ),
                  child: buildImage(foto, item.key),
                ),
              );
            } else if (foto.length == 2) {
              return StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 2,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(
                    GalleryFullScreen.ROUTE_NAME,
                    arguments: GalleryFullScreenArguments(
                        images: fotos, indexPage: item.key),
                  ),
                  child: buildImage(foto, item.key),
                ),
              );
            } else {
              return StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: item.key == 0 ? 2 : 1,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed(
                    GalleryFullScreen.ROUTE_NAME,
                    arguments: GalleryFullScreenArguments(
                        images: fotos, indexPage: item.key),
                  ),
                  child: buildImage(foto, item.key),
                ),
              );
            }
          }).toList(),
        );
      }

      Widget itemPost(ForumDetailModel post) {
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
                        post.nama!,
                        style: blackTextStyle.copyWith(fontSize: 16),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        _getTime(post.created_at!),
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
                post.content!,
                style: blackTextStyle.copyWith(height: 1.5),
              ),
              SizedBox(
                height: 12,
              ),
              // IMAGE
              post.foto!.length > 0 ? imageGallery(post.foto!) : Container(),

              //FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder<ResultModel<String>>(
                    future: ForumRepository().checkStatusLike(post.id_forum!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        bool isLike = snapshot.data!.data! == "1";
                        return LikeButton(
                          isLiked: isLike,
                          likeCount: post.total_like,
                          likeBuilder: (bool isLiked) {
                            // print(isLiked);
                            return Icon(
                              Icons.favorite,
                              color:
                                  isLiked ? Colors.red[500] : Colors.grey[400],
                            );
                          },
                          countBuilder: (likeCount, isLiked, text) {
                            return Text(
                              text,
                              style: blackTextStyle,
                            );
                          },
                          onTap: (isLiked) {
                            return onLikeButtonTapped(isLiked, post.id_forum!);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => myFocusNode.requestFocus(),
                        icon: Icon(
                          Icons.mode_comment_rounded,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(post.total_comment.toString())
                    ],
                  )
                ],
              )
            ],
          ),
        );
      }

      return FutureBuilder<ResultModel<List<ForumDetailModel>>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<ForumDetailModel> data = snapshot.data!.data!;
              if (data.length > 0) {
                // Menampilkan post berdasrkan waktu paling baru
                data.sort((a, b) => b.created_at!.compareTo(a.created_at!));

                return itemPost(data[0]);
              } else {
                return Container();
              }
            } else {
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                ),
              );
            }
          });
    }

    Widget komentar(List<ForumkomentarModel> komentar) {
      Widget buildKomentar(ForumkomentarModel komentar) {
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
                    child: Text(
                      komentar.nama!,
                      style: blackTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                  komentar.content!,
                  style: blackTextStyle.copyWith(height: 1.5),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => myFocusNode.requestFocus(),
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

      return SingleChildScrollView(
        child: Column(
          children:
              komentar.map((komentar) => buildKomentar(komentar)).toList(),
        ),
      );
    }

    Widget komentarInput() {
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
                        validator: (value) => null,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 14,
              ),
              InkWell(
                onTap: () {
                  myFocusNode.unfocus();
                  if (_formKey.currentState!.validate()) {
                    var data = {
                      'content': _komentarController.text,
                      'id': widget.forum.id_forum,
                    };
                    _komentarController.clear();

                    _addKomentar(data);
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

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: greenColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
        child: komentarInput(),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => myFocusNode.unfocus(),
        child: RefreshIndicator(
          onRefresh: () => _refreshData(),
          child: FutureBuilder<ResultModel<List<ForumDetailModel>>>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<ForumDetailModel> data = snapshot.data!.data!;
                if (data.isNotEmpty) {
                  return ListView(
                    children: [
                      post(data[0]),
                      komentar(data[0].comment!),
                    ],
                  );
                } else {
                  return Container();
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
