import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_detail_screen.dart';

class ArticleItemScreen extends StatelessWidget {
  final MobileArticleModel article;
  final int status;

  const ArticleItemScreen({
    Key? key,
    required this.article,
    required this.status,
  }) : super(key: key);

  // Fungsi helper untuk parsing tanggal yang lebih robust
  DateTime _parseDateSafely(String dateString) {
    try {
      return DateFormat('dd MMM yyyy', 'en_US').parse(dateString);
    } catch (e) {
      // Menghapus print statement yang berlebihan
      // print('Warning: Gagal parsing tanggal "$dateString" dengan format "dd MMM yyyy": $e');
      try {
        return DateTime.parse(dateString);
      } catch (e2) {
        // Menghapus print statement yang berlebihan
        // print('Warning: Gagal parsing tanggal "$dateString" dengan format ISO 8601: $e2');
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Size screenSize = MediaQuery.of(context).size; // Tidak digunakan, bisa dihapus

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ArticleDetailScreen.ROUTE_NAME,
          arguments: ArticleDetailScreenArguments(articleId: article.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 0.05),
                offset: const Offset(0.0, 7.0),
                blurRadius: 5.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Card(
            shadowColor: Colors.transparent,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8.0)),
                        // Menggunakan CachedNetworkImage untuk pemuatan gambar yang lebih baik
                        child: CachedNetworkImage(
                          imageUrl: (article.imageUrl.isNotEmpty &&
                                  Uri.tryParse(article.imageUrl)
                                          ?.hasAbsolutePath ==
                                      true)
                              ? article.imageUrl
                              : 'https://placehold.co/100x100/cccccc/333333?text=No+Image',
                          fit: BoxFit.cover,
                          width:
                              double.infinity, // Pastikan gambar mengisi lebar
                          height:
                              double.infinity, // Pastikan gambar mengisi tinggi
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF017964)),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            // Menghapus print statement yang berlebihan
                            // print('Error loading article item image: ${article.imageUrl} - $error');
                            return Container(
                              color: const Color.fromRGBO(1, 169, 159, 1.0),
                              width: double.infinity,
                              height: double.infinity,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.category.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          article.title.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat("dd MMMM yyyy").format(
                            _parseDateSafely(article.tanggal),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: status == 0
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: Color.fromRGBO(232, 232, 232, 1.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat("dd").format(
                                    _parseDateSafely(article.tanggal),
                                  ),
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: const Color.fromRGBO(
                                        112, 112, 112, 1.0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat("MMM").format(
                                    _parseDateSafely(article.tanggal),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color.fromRGBO(
                                        112, 112, 112, 1.0),
                                    fontSize: 11.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
