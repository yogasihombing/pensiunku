import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/screen/article/article_detail_screen.dart';

class ItemArticle extends StatelessWidget {
  final ArticleModel article;

  const ItemArticle({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double cardWidth = screenSize.width * 0.37;

    return ClipRect(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: cardWidth,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ArticleDetailScreen.ROUTE_NAME,
              arguments: ArticleDetailScreenArguments(articleId: article.id),
            );
          },
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar dengan AspectRatio 1:1
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image(
                    image: CachedNetworkImageProvider(article.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Teks berada di bawah gambar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.textTheme.bodyText1?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Baca Selengkapnya',
                      style: theme.textTheme.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// class ItemArticle extends StatelessWidget {
//   final ArticleModel article;

//   const ItemArticle({
//     Key? key,
//     required this.article,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     Size screenSize = MediaQuery.of(context).size;
//     double cardWidth = screenSize.width * 0.37;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8.0),
//       width: cardWidth,
//       height: cardWidth + 10, // Tambahkan tinggi agar tidak terlalu sempit
//       child: InkWell(
//         onTap: () {
//           Navigator.of(context).pushNamed(
//             ArticleDetailScreen.ROUTE_NAME,
//             arguments: ArticleDetailScreenArguments(articleId: article.id),
//           );
//         },
//         borderRadius: BorderRadius.circular(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize:
//               MainAxisSize.min, // Mencegah Column mengambil ruang berlebih
//           children: [
//             // Bagian gambar
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: AspectRatio(
//                 aspectRatio: 1, // Rasio 1:1 untuk gambar
//                 child: Image(
//                   image: CachedNetworkImageProvider(article.imageUrl),
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               ),
//             ),

//             // Bagian teks dengan Flexible agar tidak overflow
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     article.title,
//                     style: theme.textTheme.bodyText1?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                     maxLines: 1, // Batas 2 baris agar tidak terlalu panjang
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 8.0),
//                   Text(
//                     'Baca Selengkapnya',
//                     style: theme.textTheme.caption,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// class ItemArticle extends StatelessWidget {
//   final ArticleModel article;

//   const ItemArticle({
//     Key? key,
//     required this.article,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     Size screenSize = MediaQuery.of(context).size;
//     double cardWidth = screenSize.width * 0.37;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           // Navigator.of(
//           //   context,
//           //   rootNavigator: true,
//           // ).pushNamed(
//           //   WebViewScreen.ROUTE_NAME,
//           //   arguments: WebViewScreenArguments(
//           //     initialUrl: article.url,
//           //   ),
//           // );
//           Navigator.of(context).pushNamed(ArticleDetailScreen.ROUTE_NAME,
//               arguments: ArticleDetailScreenArguments(articleId: article.id));
//         },
//         borderRadius: BorderRadius.circular(8.0),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 4.0),
//           width: cardWidth,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: cardWidth,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                       color: theme.primaryColor.withOpacity(0.5),
//                       image: DecorationImage(
//                         image: CachedNetworkImageProvider(article.imageUrl),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(
//                   top: 8.0,
//                   right: 8.0,
//                   left: 8.0,
//                   bottom: 16.0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       article.title,
//                       style: theme.textTheme.bodyText1?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 8.0),
//                     Text(
//                       'Baca Selengkapnya',
//                       style: theme.textTheme.caption,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
