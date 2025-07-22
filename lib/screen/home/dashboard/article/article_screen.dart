import 'package:flutter/material.dart';
import 'package:pensiunku/model/article_model.dart';
import 'package:pensiunku/repository/article_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/home/dashboard/article/article_item_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/latest_articles_screen.dart';
import 'package:pensiunku/screen/home/dashboard/article/no_article_screen.dart';
import 'package:pensiunku/widget/chip_tab.dart';

class ArticleScreenArguments {
  final List<ArticleCategoryModel> articleCategories;

  ArticleScreenArguments({
    required this.articleCategories,
  });
}

class ArticleScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/article';
  final List<ArticleCategoryModel> articleCategories;

  const ArticleScreen({Key? key, required this.articleCategories})
      : super(key: key);

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  // Deklarasi Future untuk data artikel. Akan diinisialisasi di initState dan di-update saat filter berubah.
  late Future<ResultModel<List<MobileArticleModel>>> _futureData;

  // _futureDataWithoutSearchString tidak lagi diperlukan karena redundan.
  // late Future<ResultModel<List<MobileArticleModel>>> _futureDataWithoutSearchString;

  late List<ArticleCategoryModel> _articleCategories = widget.articleCategories;
  int _filterIndex = 0; // Indeks kategori yang sedang aktif
  String _searchText = ''; // Teks pencarian
  final TextEditingController editingController = TextEditingController();

  // latestArticles akan diisi dari hasil FutureBuilder
  List<MobileArticleModel> latestArticles = [];

  @override
  void initState() {
    super.initState();
    print('ArticleScreen: initState dipanggil.');
    // Inisialisasi _futureData dengan kategori pertama saat initState
    _futureData =
        ArticleRepository().getMobileAll(_articleCategories[_filterIndex]);
  }

  // Metode untuk me-refresh data artikel berdasarkan filter dan teks pencarian saat ini
  // Metode ini akan mengembalikan Future<void> agar RefreshIndicator dapat menunggu
  Future<void> _refreshData() async {
    print(
        'ArticleScreen: _refreshData dipanggil. Filter Index: $_filterIndex, Search Text: $_searchText');
    setState(() {
      // Re-assign _futureData untuk memicu FutureBuilder agar mengambil data baru
      _futureData = ArticleRepository().getMobileAll(
        _articleCategories[_filterIndex],
        // Jika API Anda mendukung pencarian, Anda bisa meneruskan _searchText di sini
        // Contoh: searchString: _searchText,
      );
    });
    // Tunggu hingga future selesai untuk memastikan RefreshIndicator berhenti
    await _futureData;
    print('ArticleScreen: _refreshData selesai.');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF017964),
        ),
        title: Text(
          "Artikel",
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF017964),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              Color.fromARGB(255, 220, 226, 147),
            ],
            stops: [0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData, // Panggil _refreshData saat pull-to-refresh
          child: Column(
            // Gunakan Column untuk menyusun widget secara vertikal
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  // Gunakan SizedBox untuk mengontrol tinggi TextField
                  height: 36.0,
                  child: TextField(
                    onSubmitted: (value) {
                      _searchText = value;
                      _refreshData(); // Panggil _refreshData saat pencarian disubmit
                    },
                    controller: editingController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromRGBO(228, 228, 228, 1.0),
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      ),
                    ),
                  ),
                ),
              ),
              // Bagian Chip Kategori - ini selalu terlihat dan tidak akan loading ulang
              SizedBox(
                height: 28.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 12.0),
                    ..._articleCategories
                        .asMap()
                        .map((index, articleCategory) {
                          return MapEntry(
                            index,
                            ChipTab(
                              text: articleCategory.name,
                              isActive: _filterIndex == index,
                              onTap: () {
                                setState(() {
                                  _filterIndex = index; // Update indeks filter
                                });
                                _refreshData(); // Panggil _refreshData untuk kategori baru
                              },
                              custom: true,
                            ),
                          );
                        })
                        .values
                        .toList(),
                    const SizedBox(width: 24.0),
                  ],
                ),
              ),
              const SizedBox(
                  height: 12.0), // Spasi antara chip dan daftar artikel

              // FutureBuilder untuk menampilkan daftar artikel
              // Hanya bagian ini yang akan menunjukkan loading
              Expanded(
                // Gunakan Expanded agar daftar artikel mengambil sisa ruang yang tersedia
                child: FutureBuilder<ResultModel<List<MobileArticleModel>>>(
                  future: _futureData, // Future yang akan dipantau
                  builder: (BuildContext context,
                      AsyncSnapshot<ResultModel<List<MobileArticleModel>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print(
                          'ArticleScreen: FutureBuilder (articles) - ConnectionState.waiting');
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      print(
                          'ArticleScreen: FutureBuilder (articles) - snapshot.hasError: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'Error memuat artikel: ${snapshot.error}',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: screenSize.width * 0.04),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.hasData &&
                        snapshot.data?.data != null) {
                      List<MobileArticleModel> data = snapshot.data!.data!;

                      // Terapkan filter pencarian di sini (client-side)
                      if (_searchText.isNotEmpty) {
                        data = data
                            .where((element) => element.title
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()))
                            .toList();
                      }

                      if (data.isEmpty) {
                        print(
                            'ArticleScreen: FutureBuilder (articles) - Data artikel kosong setelah filter.');
                        return NoArticle();
                      } else {
                        print(
                            'ArticleScreen: FutureBuilder (articles) - Data artikel berhasil dimuat. Jumlah: ${data.length}');
                        // Ambil 3 artikel terbaru untuk LatestArticles
                        latestArticles = data.take(3).toList();

                        return SingleChildScrollView(
                          // Memungkinkan konten artikel untuk discroll
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Penting untuk RefreshIndicator
                          child: Column(
                            children: [
                              LatestArticles(latestArticles: latestArticles),
                              // Tampilkan semua artikel yang sudah difilter
                              ...data.map((article) {
                                return ArticleItemScreen(
                                  article: article,
                                  status:
                                      _filterIndex, // Status ini mungkin perlu disesuaikan jika ada logika khusus
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }
                    } else {
                      print(
                          'ArticleScreen: FutureBuilder (articles) - Tidak ada data artikel atau null.');
                      return NoArticle(); // Tampilkan widget jika tidak ada data
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filter(BuildContext context) {
    return Container(
        height: 36.0,
        margin: EdgeInsets.symmetric(horizontal: 45.0, vertical: 18.0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(195, 195, 195, 1.0)),
          // color: Color.fromRGBO(195, 195, 195, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(36)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filterIndex = 0;
                    _refreshData();
                  });
                },
                child: Container(
                    alignment: Alignment.center,
                    height: 36.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          bottomLeft: Radius.circular(36)),
                      color:
                          _filterIndex == 0 ? Color(0xFF017964) : Colors.white,
                    ),
                    child: Text(
                      "Akan Berlangsung",
                      style: TextStyle(
                        color: _filterIndex == 0
                            ? Colors.white
                            : Color.fromRGBO(149, 149, 149, 1.0),
                      ),
                    )),
              ),
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = 1;
                  _refreshData();
                });
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 36.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(36),
                        bottomRight: Radius.circular(36)),
                    color: _filterIndex == 1
                        ? Color.fromRGBO(1, 169, 159, 1.0)
                        : Colors.white,
                  ),
                  child: Text(
                    "Telah Berlangsung",
                    style: TextStyle(
                        color: _filterIndex == 0
                            ? Color.fromRGBO(149, 149, 149, 1.0)
                            : Colors.white),
                  )),
            ))
          ],
        ));
  }
}
