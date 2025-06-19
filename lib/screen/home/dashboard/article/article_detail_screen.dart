import 'dart:developer';

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
  // late Future<ResultModel<ThemeModel>> _futureTheme;
  final _switchController = ValueNotifier<bool>(false);
  bool _darkMode = true;
  late String articleTitle;

  @override
  void initState() {
    super.initState();
    _switchController.addListener(() {
      setState(() {
        if (_switchController.value) {
          _darkMode = false;
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "false");
          ThemeRepository().update(theme).then((value) {
            log("updateTheme" + value.toString());
          });
        } else {
          _darkMode = true;
          //update db
          ThemeModel theme = ThemeModel(parameter: "darkMode", value: "true");
          ThemeRepository().update(theme).then((value) {
            log("updateTheme" + value.toString());
          });
        }
      });
    });

    _refreshData();
  }

  _refreshData() {
    //get theme setting
    ThemeRepository().get().then((value) {
      if (value.error == null) {
        ThemeModel theme = value.data!;
        if (theme.value == 'false') {
          _darkMode = false;
          _switchController.value = true;
        } else {
          _darkMode = true;
          _switchController.value = false;
        }
      }
    });

    return _futureData =
        ArticleRepository().getMobileArticle(widget.articleId).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      }
      setState(() {
        articleTitle = value.data!.title;
      });
      return value;
    });
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
              onRefresh: () {
                return _refreshData();
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
                    FutureBuilder(
                        future: _futureData,
                        builder: (BuildContext context,
                            AsyncSnapshot<ResultModel<MobileArticleDetailModel>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.data != null) {
                              MobileArticleDetailModel data =
                                  snapshot.data!.data!;
                              List<String> paragraf =
                                  splitTextByImageTag(data.content, []);
                              log('Panjang list paragraf : ' +
                                  paragraf.length.toString());

                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: screenSize.height * 0.5,
                                        width: screenSize.width,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    data.imageUrl.toString()),
                                                fit: BoxFit.fitHeight)),
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
                                                    Color.fromRGBO(
                                                        0, 0, 0, 0.0),
                                                    Color.fromRGBO(
                                                        0, 0, 0, 0.1),
                                                    Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    Color.fromRGBO(
                                                        0, 0, 0, 0.4),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            )
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
                                                            0, 0, 0, 0.7),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    30))),
                                                    alignment: Alignment.center,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15,
                                                            vertical: 3),
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    child: Text(
                                                      data.category,
                                                      style: theme
                                                          .textTheme.subtitle1
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white),
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
                                                      //     blurRadius: 10.0,
                                                      //     color: Colors.black,
                                                      //     offset:
                                                      //         Offset(1.0, 1.0))
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
                                                            Radius.circular(
                                                                30))),
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
                                                              76,
                                                              168,
                                                              155,
                                                              1.0),
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
                                            log('imgRul : $imgUrl');
                                            return Container(
                                              width: screenSize.width * 0.9,
                                              child: Image.network(
                                                imgUrl.trim(),
                                                fit: BoxFit.fitWidth,
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
                                                    fontWeight:
                                                        FontWeight.normal,
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
                              String errorTitle =
                                  'Tidak dapat menemukan artikel yang dicari';
                              // String? errorSubtitle = snapshot.data?.error;
                              return Column(
                                children: [
                                  SizedBox(height: 16),
                                  ErrorCard(
                                    title: errorTitle,
                                    // subtitle: errorSubtitle,
                                    iconData: Icons.warning_rounded,
                                  ),
                                ],
                              );
                            }
                          } else {
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
    late String firstPart;
    late String nextPart;
    late String lastPart;
    late String imgUrl;
    late int startIndex;
    late int endIndex;

    // if (kalimat != null && kalimat.length > 0) {
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
      }

      return splitTextByImageTag(lastPart, splittedKalimat);
    } else {
      //tidak ada image lagi dalam paragraf
      splittedKalimat.add(kalimat);
      return splittedKalimat;
    }
    // }
  }
}
