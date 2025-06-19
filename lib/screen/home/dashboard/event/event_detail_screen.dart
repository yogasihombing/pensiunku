import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/event_model.dart';
import 'package:pensiunku/repository/event_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/common/galery_fullscreen.dart';
import 'package:pensiunku/screen/common/gallery_youtube_fullscreen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/url_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EventDetailScreenArguments {
  final int eventId;

  EventDetailScreenArguments({
    required this.eventId,
  });
}

class EventDetailScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/event-detail';
  final int eventId;

  const EventDetailScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<ResultModel<EventDetailModel>> _futureData;
  late List<String> fotos = [];
  late List<String> videos = [];

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData =
        EventRepository().getEventDetail(token!, widget.eventId).then((value) {
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
      setState(() {});
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double cardWidth = screenSize.width * 0.37;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              icon: Icon(Icons.arrow_back),
              color: Colors.black,
            ),
            title: Text(
              "Event",
              style: theme.textTheme.headline6?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )),
        body: RefreshIndicator(
          onRefresh: () {
            return _refreshData();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Stack(children: [
              Container(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height * 1.2,
              ),
              Column(children: [
                FutureBuilder(
                    future: _futureData,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<EventDetailModel>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data != null) {
                          EventDetailModel data = snapshot.data!.data!;
                          fotos = [];
                          videos = [];
                          data.foto.asMap().forEach((key, value) {
                            if (value.type == 0) {
                              fotos.add(value.path);
                            } else {
                              videos.add(value.path);
                              log("video:" + videos.length.toString());
                            }
                          });
                          return Column(
                            children: [
                              Container(
                                height: screenSize.height * 0.5,
                                width: screenSize.width,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            data.eflyer.toString()),
                                        fit: BoxFit.fitHeight)),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Container(
                                width: screenSize.width,
                                child: Column(
                                  children: [
                                    Container(
                                      width: screenSize.width * 0.9,
                                      child: Text(
                                        data.nama,
                                        style: theme.textTheme.subtitle1
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Container(
                                      width: screenSize.width * 0.9,
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat("dd MMMM yyyy").format(
                                                DateTime.parse(
                                                    data.tanggal.toString())),
                                            style: theme.textTheme.subtitle1
                                                ?.copyWith(
                                              color: Color.fromRGBO(
                                                  131, 131, 131, 1.0),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6.0,
                                          ),
                                          Text(
                                            "|",
                                            style: theme.textTheme.subtitle1
                                                ?.copyWith(
                                              color: Color.fromRGBO(
                                                  131, 131, 131, 1.0),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6.0,
                                          ),
                                          Text(
                                            data.waktu + " WIB",
                                            style: theme.textTheme.subtitle1
                                                ?.copyWith(
                                              color: Color.fromRGBO(
                                                  131, 131, 131, 1.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    data.status == 0
                                        ? Container(
                                            width: screenSize.width * 0.9,
                                            child: Text(
                                              data.description,
                                              style: theme.textTheme.bodyText1,
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    data.status == 0
                                        ? Center(
                                            child: Container(
                                              height: 50.0,
                                              width: screenSize.width * 0.4,
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color.fromRGBO(
                                                      77, 195, 171, 1.0),
                                                ).copyWith(
                                                    elevation: ButtonStyleButton
                                                        .allOrNull(0.0)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "D A F T A R",
                                                      style: theme
                                                          .textTheme.headline2
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  UrlUtil.launchURL(data.link!);
                                                },
                                              ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                                fotos.length > 0
                                                    ? Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Column(
                                                          // mainAxisAlignment:
                                                          //     MainAxisAlignment
                                                          //         .start,
                                                          // crossAxisAlignment:
                                                          //     CrossAxisAlignment
                                                          //         .start,
                                                          children: [
                                                            Container(
                                                              width: screenSize
                                                                      .width *
                                                                  0.9,
                                                              child: Text(
                                                                  "Foto",
                                                                  style: theme
                                                                      .textTheme
                                                                      .subtitle1
                                                                      ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                            ),
                                                            Container(
                                                              height: cardWidth,
                                                              child: ListView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 24.0,
                                                                  ),
                                                                  ...fotos.map(
                                                                      (foto) {
                                                                    int indexFoto =
                                                                        fotos.indexOf(
                                                                            foto);
                                                                    log("index foto:" +
                                                                        indexFoto
                                                                            .toString());
                                                                    return Builder(builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return Material(
                                                                        color: Colors
                                                                            .transparent,
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pushNamed(
                                                                              GalleryFullScreen.ROUTE_NAME,
                                                                              arguments: GalleryFullScreenArguments(images: fotos, indexPage: indexFoto),
                                                                            );
                                                                          },
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                EdgeInsets.symmetric(horizontal: 4.0),
                                                                            width:
                                                                                cardWidth,
                                                                            child:
                                                                                Container(
                                                                              height: cardWidth,
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                child: Container(
                                                                                  width: screenSize.width,
                                                                                  child: Image.network(
                                                                                    foto,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                                  })
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                videos.length > 0
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            width: screenSize
                                                                    .width *
                                                                0.9,
                                                            child: Text("Video",
                                                                style: theme
                                                                    .textTheme
                                                                    .subtitle1
                                                                    ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                          ),
                                                          Container(
                                                            height: cardWidth,
                                                            child: ListView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              children: [
                                                                SizedBox(
                                                                  width: 24.0,
                                                                ),
                                                                ...videos.map(
                                                                    (video) {
                                                                  int indexVideo =
                                                                      videos.indexOf(
                                                                          video);
                                                                  log("index video:" +
                                                                      indexVideo
                                                                          .toString());
                                                                  return Builder(builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          log("video tapped");
                                                                          Navigator.of(context)
                                                                              .pushNamed(
                                                                            GalleryYoutubeFullscreen.ROUTE_NAME,
                                                                            arguments:
                                                                                GalleryYoutubeFullscreenArguments(videos: videos, indexPage: indexVideo),
                                                                          );
                                                                        },
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        child:
                                                                            Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(horizontal: 4.0),
                                                                          width:
                                                                              cardWidth * 1.5,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                cardWidth,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              child: Container(
                                                                                width: screenSize.width,
                                                                                child: Image.network(
                                                                                  'https://img.youtube.com/vi/' + YoutubePlayer.convertUrlToId(video).toString() + '/0.jpg',
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                                })
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : Container(),
                                              ]),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          String errorTitle =
                              'Tidak dapat menemukan event yang dicari';
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
                            SizedBox(height: 16),
                            Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        );
                      }
                    }),
              ])
            ]),
          ),
        ));
  }
}
