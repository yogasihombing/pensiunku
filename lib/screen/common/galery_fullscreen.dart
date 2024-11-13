import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryFullScreenArguments {
  final List<String> images;
  final int indexPage;

  GalleryFullScreenArguments({
    required this.images,
    required this.indexPage,
  });
}

class GalleryFullScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/gallery-fullscreen';
  final List<String> images;
  final int indexPage;

  const GalleryFullScreen(
      {Key? key, required this.images, required this.indexPage})
      : super(key: key);

  @override
  State<GalleryFullScreen> createState() => _GalleryFullScreenState();
}

class _GalleryFullScreenState extends State<GalleryFullScreen> {
  // int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // ThemeData theme = Theme.of(context);
    PageController _pageController =
        PageController(initialPage: widget.indexPage);

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          Container(
              height: screenSize.height,
              width: screenSize.width,
              child: PhotoViewGallery.builder(
                itemCount: widget.images.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(widget.images[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.images[index]),
                  );
                },
                scrollPhysics: BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(
                    // borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color.fromARGB(255, 0, 0, 0)),
                enableRotation: true,
                loadingBuilder: (context, event) => Center(
                  child: Container(
                    width: 30.0,
                    height: 30.0,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightGreen,
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!,
                    ),
                  ),
                ),
                pageController: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    // _currentIndex = index;
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
        ],
      ),
    );
  }
}
