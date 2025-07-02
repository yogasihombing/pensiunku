import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pensiunku/model/toko/toko_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) onTap; // Callback saat kartu produk diklik

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardPadding = screenSize.width * 0.015;
    final double imagePadding = screenSize.width * 0.01;
    final double textSize = screenSize.width * 0.03;
    final double ratingSize = screenSize.width * 0.025;

    // Perbaikan: Pengecekan null safety untuk properti gambar
    String imageUrl = '';
    if (product.gallery != null && product.gallery.isNotEmpty) {
      imageUrl = product.gallery[0].path; // Gunakan path jika tidak null, atau string kosong
    }

    return GestureDetector(
      onTap: () => onTap(product), // Memanggil callback onTap dengan objek produk
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                padding: EdgeInsets.all(imagePadding),
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    print('ProductCard: CachedNetworkImage ERROR: $error for URL: $url');
                    return Icon(Icons.error);
                  },
                  imageUrl: imageUrl, // Gunakan imageUrl yang sudah dipastikan aman
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      product.getTotalPriceFormatted(),
                      style: TextStyle(
                        fontSize: textSize,
                        color: Color.fromRGBO(149, 149, 149, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    if (product.averageRating != null) // Pastikan averageRating tidak null
                      RatingBar.builder(
                        initialRating: product.averageRating!,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: ratingSize,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        unratedColor: Colors.grey.withAlpha(50),
                        onRatingUpdate: (rating) {
                          print('ProductCard: Rating updated: $rating');
                        },
                      ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
