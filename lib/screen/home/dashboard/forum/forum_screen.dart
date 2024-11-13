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

import '../../../../repository/result_model.dart';
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
  }

  _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    int userId = await UserRepository().getOneDb(token!).then((value) {
      return value.data!.id;
    });

    if (toggleButtonPostingSelected[0]) {
      print(userId);
      return _futureData =
          ForumRepository().getAllForumPost(token).then((value) {
        if (value.data!.isEmpty) {
          dataLength = 1;
        } else {
          dataLength = value.data!.length;
        }
        setState(() {});
        return value;
      });
    } else {
      return _futureData =
          ForumRepository().getForumPostbyUserID(token, userId).then((value) {
        if (value.data!.isEmpty) {
          dataLength = 1;
        } else {
          dataLength = value.data!.length;
        }
        setState(() {});
        return value;
      });
    }
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
          onPressed: () => Navigator.pop(context),
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
                      'Forum\nPensiun Hebat',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumPostingScreen(),
                      ),
                    ).then((_) => _refreshData());
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
              // ketika di klik akan mengubah status tombel toggle menjadi true dan yang lainya false.
              for (int i = 0; i < toggleButtonPostingSelected.length; i++) {
                toggleButtonPostingSelected[i] = i == index;
              }
              _refreshData();
              setState(() {});
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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                          images: fotos,
                        ),
                      )),
                  child: buildImage(foto, item.key),
                ),
              );
            } else if (foto.length == 2) {
              return StaggeredGridTile.count(
                crossAxisCellCount: 4,
                mainAxisCellCount: 2,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                          images: fotos,
                          selectedIndex: item.key == 2 ? 2 : item.key,
                        ),
                      )),
                  child: buildImage(foto, item.key),
                ),
              );
            } else {
              return StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: item.key == 0 ? 2 : 1,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(
                            images: fotos,
                            selectedIndex: item.key == 2 ? 2 : item.key),
                      )),
                  child: buildImage(foto, item.key),
                ),
              );
            }
          }).toList(),
        );
      }

      Widget itemPost(ForumModel post) {
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
              ReadMoreText(
                post.content!,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForumDetailScreen(forum: post),
                            ),
                          ).then((_) => _refreshData());
                        },
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

      Widget tidakAdaPost() {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForumPostingScreen(),
                    ),
                  ).then((_) => _refreshData());
                },
                style: ElevatedButton.styleFrom(
                  primary: greenColor,
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
          print(snapshot.connectionState);
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
            List<ForumModel>? data = snapshot.data?.data;
            if (data!.isNotEmpty) {
              data.sort((a, b) => b.created_at!.compareTo(a.created_at!));
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return itemPost(data[index]);
                  },
                  childCount: data.length,
                ),
              );
            } else {
              return SliverToBoxAdapter(child: tidakAdaPost());
            }
          } else {
            return SliverToBoxAdapter(child: tidakAdaPost());
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1.0),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
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
    );
  }
}
