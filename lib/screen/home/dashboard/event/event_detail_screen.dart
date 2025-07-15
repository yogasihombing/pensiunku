import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/event_model.dart'; // Pastikan EventDetailModel ada di sini
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
  // --- PERUBAHAN: Inisialisasi list di sini, dan akan diisi di _refreshData ---
  List<String> fotos = [];
  List<String> videos = [];
  // --- AKHIR PERUBAHAN ---

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    // Mengubah return type menjadi Future<void>
    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // --- PERUBAHAN: Penanganan token null lebih awal ---
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir. Mohon login kembali.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
        // Opsional: Redirect ke halaman login
        // Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.ROUTE_NAME, (route) => false);
      }
      // Menginisialisasi _futureData dengan Future.error agar FutureBuilder bisa menangani error
      setState(() {
        _futureData = Future.error('Token tidak tersedia.');
      });
      return;
    }
    // --- AKHIR PERUBAHAN ---

    // --- PERUBAHAN: Inisialisasi _futureData dan mengisi fotos/videos di sini ---
    setState(() {
      _futureData =
          EventRepository().getEventDetail(token, widget.eventId).then((value) {
        if (value.error != null) {
          if (mounted) {
            // Pastikan widget masih mounted sebelum showDialog
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Text(
                  value.error.toString(),
                  // --- PERUBAHAN: Warna teks untuk kontras yang lebih baik ---
                  style: const TextStyle(color: Colors.black),
                  // --- AKHIR PERUBAHAN ---
                ),
                backgroundColor: Colors.red,
                elevation: 24.0,
              ),
            );
          }
        } else if (value.data != null) {
          // Hanya isi fotos dan videos jika data berhasil diambil dan tidak ada error
          fotos = []; // Reset sebelum mengisi
          videos = []; // Reset sebelum mengisi
          value.data!.foto.asMap().forEach((key, mediaItem) {
            if (mediaItem.type == 0) {
              // Asumsi 0 adalah foto
              fotos.add(mediaItem.path);
            } else if (mediaItem.type == 1) {
              // Asumsi 1 adalah video
              videos.add(mediaItem.path);
              log("video:" + videos.length.toString());
            }
          });
        }
        return value; // Mengembalikan value agar FutureBuilder tetap dapat mengaksesnya
      });
    });
    // --- AKHIR PERUBAHAN ---
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double cardWidth = screenSize.width * 0.37;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: const Color(0xFF017964)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Event',
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF017964),
            ),
          ),
        ),
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // --- PERUBAHAN: Menangani error dan data null/kosong ---
                      if (snapshot.hasError || snapshot.data?.data == null) {
                        String errorTitle = 'Tidak dapat memuat detail event';
                        String? errorSubtitle =
                            snapshot.error?.toString() ?? snapshot.data?.error;
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
                      // --- AKHIR PERUBAHAN ---

                      EventDetailModel data = snapshot.data!.data!;
                      // fotos dan videos sudah diisi di _refreshData()
                      return Column(
                        children: [
                          Container(
                            height: screenSize.height * 0.5,
                            width: screenSize.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(data.eflyer.toString()),
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
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                        style:
                                            theme.textTheme.subtitle1?.copyWith(
                                          color: Color.fromRGBO(
                                              131, 131, 131, 1.0),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      Text(
                                        "|",
                                        style:
                                            theme.textTheme.subtitle1?.copyWith(
                                          color: Color.fromRGBO(
                                              131, 131, 131, 1.0),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      Text(
                                        data.waktu + " WIB",
                                        style:
                                            theme.textTheme.subtitle1?.copyWith(
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
                                // --- PERUBAHAN: Menggunakan data.status (String) ---
                                data.status ==
                                        "0" // Bandingkan dengan String "0"
                                    // --- AKHIR PERUBAHAN ---
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
                                // --- PERUBAHAN: Menggunakan data.status (String) ---
                                data.status ==
                                        "0" // Bandingkan dengan String "0"
                                    // --- AKHIR PERUBAHAN ---
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
                                                elevation:
                                                    ButtonStyleButton.allOrNull(
                                                        0.0)),
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
                                                              FontWeight.bold,
                                                          color: Colors.white),
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
                                          fotos.isNotEmpty // Menggunakan isNotEmpty
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width:
                                                            screenSize.width *
                                                                0.9,
                                                        child: Text("Foto",
                                                            style: theme
                                                                .textTheme
                                                                .subtitle1
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
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
                                                            ...fotos
                                                                .map((foto) {
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
                                                                    onTap: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pushNamed(
                                                                        GalleryFullScreen
                                                                            .ROUTE_NAME,
                                                                        arguments: GalleryFullScreenArguments(
                                                                            images:
                                                                                fotos,
                                                                            indexPage:
                                                                                indexFoto),
                                                                      );
                                                                    },
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      width:
                                                                          cardWidth,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            cardWidth,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                screenSize.width,
                                                                            child:
                                                                                Image.network(
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
                                                            }).toList()
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
                                          videos.isNotEmpty // Menggunakan isNotEmpty
                                              ? Column(
                                                  children: [
                                                    Container(
                                                      width: screenSize.width *
                                                          0.9,
                                                      child: Text("Video",
                                                          style: theme.textTheme
                                                              .subtitle1
                                                              ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
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
                                                          ...videos
                                                              .map((video) {
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
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    log("video tapped");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pushNamed(
                                                                      GalleryYoutubeFullscreen
                                                                          .ROUTE_NAME,
                                                                      arguments: GalleryYoutubeFullscreenArguments(
                                                                          videos:
                                                                              videos,
                                                                          indexPage:
                                                                              indexVideo),
                                                                    );
                                                                  },
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                    width:
                                                                        cardWidth *
                                                                            1.5,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          cardWidth,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              screenSize.width,
                                                                          child:
                                                                              Image.network(
                                                                            'https://img.youtube.com/vi/' +
                                                                                YoutubePlayer.convertUrlToId(video).toString() +
                                                                                '/0.jpg',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          }).toList()
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          )
                        ],
                      );
                    }),
              ])
            ]),
          ),
        ));
  }
}
// 