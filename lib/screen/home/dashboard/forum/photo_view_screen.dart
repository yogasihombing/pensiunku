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
    print('PhotoViewScreen: Membangun PhotoViewScreen. Jumlah gambar: ${images.length}, Selected Index: $selectedIndex');
    PageController _pageController = PageController(initialPage: selectedIndex);

    return Scaffold( // Tambahkan Scaffold agar memiliki AppBar dan back button
      appBar: AppBar(
        backgroundColor: Colors.black, // Warna AppBar untuk tampilan gambar
        iconTheme: IconThemeData(color: Colors.white), // Warna ikon kembali
        title: Text(
          'Gambar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.black, // Background hitam untuk galeri foto
        child: PhotoViewGallery.builder(
          itemCount: images.length,
          builder: (context, index) {
            print('PhotoViewScreen: Memuat gambar: ${images[index]}');
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(images[index]),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: images[index]), // Tambahkan hero tag untuk animasi
            );
          },
          pageController: _pageController,
          onPageChanged: (index) {
            print('PhotoViewScreen: Halaman gambar berubah ke indeks: $index');
          },
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
