import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewScreen extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  const PhotoViewScreen(
      {Key? key, required this.images, this.selectedIndex = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController _pageController = PageController(initialPage: selectedIndex);

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: _pageController,
      ),
    );
  }
}
