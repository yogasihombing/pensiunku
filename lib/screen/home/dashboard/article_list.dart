import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/item_article.dart';

class ArticleList extends StatefulWidget {
  final ArticleCategoryModel articleCategory;
  final double carouselHeight;

  const ArticleList({
    Key? key,
    required this.articleCategory,
    required this.carouselHeight,
  }) : super(key: key);

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  late Future<ResultModel<List<ArticleModel>>> _futureDataArticles;

  @override
  void initState() {
    super.initState();
    print(
        'ArticleList: initState dipanggil untuk kategori: ${widget.articleCategory.name}');
    _refreshData();
  }

  // Override didUpdateWidget untuk memuat ulang artikel ketika kategori berubah
  @override
  void didUpdateWidget(covariant ArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.articleCategory != oldWidget.articleCategory) {
      print(
          'ArticleList: Kategori artikel berubah dari ${oldWidget.articleCategory.name} ke ${widget.articleCategory.name}. Memuat ulang data...');
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    print(
        'ArticleList: _refreshData dipanggil. Memulai pengambilan artikel untuk kategori: ${widget.articleCategory.name}');
    setState(() {
      _futureDataArticles = ArticleRepository().getAll(widget.articleCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return FutureBuilder<ResultModel<List<ArticleModel>>>(
      future: _futureDataArticles,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(
              'ArticleList: FutureBuilder - ConnectionState.waiting untuk kategori: ${widget.articleCategory.name}');
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
            ),
          );
        }

        // --- Logging untuk Kondisi Error ---
        if (snapshot.hasError) {
          print(
              'ArticleList: FutureBuilder - snapshot.hasError: ${snapshot.error}');
          return ErrorCard(
            title: 'Tidak dapat menampilkan artikel',
            subtitle:
                snapshot.error.toString(), // Gunakan snapshot.error secara langsung
            iconData: Icons.warning_rounded,
          );
        }
        if (snapshot.hasData && snapshot.data?.error != null) {
          print(
              'ArticleList: FutureBuilder - snapshot.hasData tapi ada error di ResultModel: ${snapshot.data?.error}');
          return ErrorCard(
            title: 'Tidak dapat menampilkan artikel',
            subtitle: snapshot.data?.error ?? 'Terjadi kesalahan pada data',
            iconData: Icons.warning_rounded,
          );
        }
        // --- Akhir Logging untuk Kondisi Error ---

        // Handle empty state
        if (snapshot.hasData &&
            (snapshot.data?.data == null || snapshot.data!.data!.isEmpty)) {
          print(
              'ArticleList: FutureBuilder - Tidak ada data artikel atau data kosong untuk kategori: ${widget.articleCategory.name}');
          return Center(
            child: Text(
              'Tidak ada artikel tersedia',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        // Handle successful data state
        final List<ArticleModel> articles = snapshot.data!.data!;
        print(
            'ArticleList: FutureBuilder - Data artikel berhasil dimuat. Jumlah artikel: ${articles.length} untuk kategori: ${widget.articleCategory.name}');

        return SizedBox(
          height: widget.carouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: widget.carouselHeight *
                    0.7, // Sesuaikan lebar item dengan rasio 0.7
                child: ItemArticle(article: articles[index]),
              );
            },
          ),
        );
      },
    );
  }
}


// class ArticleList extends StatefulWidget {
//   final ArticleCategoryModel articleCategory;
//   final double carouselHeight;

//   const ArticleList({
//     Key? key,
//     required this.articleCategory,
//     required this.carouselHeight,
//   }) : super(key: key);
//   @override
//   State<ArticleList> createState() => _ArticleListState();
// }

// class _ArticleListState extends State<ArticleList> {
//   late Future<ResultModel<List<ArticleModel>>> _futureDataArticles;

//   @override
//   void initState() {
//     super.initState();
//     _refreshData();
//   }

//   _refreshData() {
//     return _futureDataArticles =
//         ArticleRepository().getAll(widget.articleCategory).then((value) {
//       // if (value.error != null) {
//       //   WidgetUtil.showSnackbar(
//       //     context,
//       //     value.error.toString(),
//       //   );
//       // }
//       setState(() {});
//       return value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     BackgroundFetchFetch:
//     backgroundColor:
//     Color(0xFF017964);
//     ThemeData theme = Theme.of(context);

//     return FutureBuilder(
//       future: _futureDataArticles,
//       builder: (BuildContext context,
//           AsyncSnapshot<ResultModel<List<ArticleModel>>> snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data?.data?.isNotEmpty == true) {
//             List<ArticleModel> data = snapshot.data!.data!;
//             return Container(
//               height: widget.carouselHeight,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   SizedBox(width: 24.0),
//                   ...data.map((article) {
//                     return Builder(
//                       builder: (BuildContext context) {
//                         return ItemArticle(
//                           article: article,
//                         );
//                       },
//                     );
//                   }).toList(),
//                   SizedBox(width: 24.0),
//                 ],
//               ),
//             );
//           } else {
//             String errorTitle = 'Tidak dapat menampilkan artikel';
//             String? errorSubtitle = snapshot.data?.error;
//             return Container(
//               child: ErrorCard(
//                 title: errorTitle,
//                 subtitle: errorSubtitle,
//                 iconData: Icons.warning_rounded,
//               ),
//             );
//           }
//         } else {
//           return Container(
//             height: widget.carouselHeight,
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: theme.primaryColor,
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
