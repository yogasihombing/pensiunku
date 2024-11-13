import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class GalleryYoutubeFullscreenArguments {
  final List<String> videos;
  final int indexPage;

  GalleryYoutubeFullscreenArguments({
    required this.videos,
    required this.indexPage,
  });
}

class GalleryYoutubeFullscreen extends StatefulWidget {
  static const String ROUTE_NAME = '/gallery-youtube-fullscreen';
  final List<String> videos;
  final int indexPage;

  const GalleryYoutubeFullscreen(
      {Key? key, required this.videos, required this.indexPage})
      : super(key: key);

  @override
  State<GalleryYoutubeFullscreen> createState() =>
      _GalleryYoutubeFullscreenState();
}

class _GalleryYoutubeFullscreenState extends State<GalleryYoutubeFullscreen> {
  late List<YoutubePlayerController> _youtubeController;
  CarouselController _carouselController = CarouselController();
  // int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();

    _youtubeController = widget.videos
        .map<YoutubePlayerController>(
          (videoId) => YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(videoId)!,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              disableDragSeek: true,
            ),
          ),
        )
        .toList();

    // _currentCarouselIndex = widget.indexPage;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.canvasColor.withOpacity(0.9),
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
        ),
        CarouselSlider(
            items: widget.videos.map((video) {
              int videoIndex = widget.videos.indexOf(video);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                    height: screenSize.width * 9 / 16,
                    width: screenSize.width,
                    child: YoutubePlayer(
                      controller: _youtubeController[videoIndex],
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.blue,
                      progressColors: ProgressBarColors(
                          playedColor: Colors.blue,
                          handleColor: Colors.blueAccent),
                    ),
                  ),
                  Spacer()
                ],
              );
            }).toList(),
            carouselController: _carouselController,
            options: CarouselOptions(
              height: screenSize.height,
              viewportFraction: 1,
              autoPlay: false,
              initialPage: widget.indexPage,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  // _currentCarouselIndex = index;
                });
              },
            )),
        Positioned(
          top: 50,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.cancel,
            ),
          ),
        ),
      ]),
    );
  }
}
