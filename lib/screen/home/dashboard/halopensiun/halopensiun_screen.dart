import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/halopensiun_model.dart';
import 'package:pensiunku/repository/halopensiun_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/screen/welcome/welcome_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/chip_tab.dart';
import 'package:pensiunku/widget/sliver_app_bar_sheet_top.dart';
import 'package:pensiunku/widget/sliver_app_bar_title.dart';

class HalopensiunScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/halopensiun';

  const HalopensiunScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HalopensiunScreenState createState() => _HalopensiunScreenState();
}

class _HalopensiunScreenState extends State<HalopensiunScreen> {
  ScrollController scrollController = ScrollController();
  late Future<ResultModel<HalopensiunModel>> _futureData;
  late String _searchText;
  final TextEditingController editingController = TextEditingController();
  late List<Categories> _categories = [];
  late List<ListHalopensiun> _listHalopensiun = [];
  late int _selectedCategoryId;

  final dataKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = 1;
    _searchText = '';
    // --- PERUBAHAN: Inisialisasi _futureData dengan data kosong yang sukses, bukan error dummy ---
    _futureData = Future.value(ResultModel(
        isSuccess: true, data: HalopensiunModel(categories: [], list: [])));
    // --- AKHIR PERUBAHAN ---
    _refreshData();
  }

  Future<void> _refreshData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              'Token otentikasi tidak ditemukan. Silakan coba masuk kembali.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.red,
            elevation: 24.0,
          ),
        ).then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            WelcomeScreen.ROUTE_NAME,
            (Route<dynamic> route) => false,
          );
        });
      }
      // --- PERUBAHAN: Set _futureData ke error jika token tidak ada ---
      setState(() {
        _futureData = Future.error('Token otentikasi tidak ditemukan.');
      });
      return;
      // --- AKHIR PERUBAHAN ---
    }

    try {
      final value = await HalopensiunRepository().getAllHalopensiuns(token);
      if (mounted) {
        setState(() {
          _futureData = Future.value(value); // Selesaikan Future
          if (value.error != null) {
            if (value.error!.contains('Sesi Anda telah berakhir') ||
                value.error!.contains('Unauthorized')) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(
                    'Sesi Anda telah berakhir. Mohon login kembali.',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ),
              ).then((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomeScreen.ROUTE_NAME,
                  (Route<dynamic> route) => false,
                );
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.error.toString(),
                      style: const TextStyle(color: Colors.black)),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else if (value.data != null) {
            _categories = [];
            _listHalopensiun = [];

            value.data!.categories.asMap().forEach((key, categoryValue) {
              _categories.add(categoryValue);
            });

            value.data!.list.asMap().forEach((key, halopensiunItem) {
              if (halopensiunItem.idKategori == _selectedCategoryId &&
                  halopensiunItem.judul
                      .toLowerCase()
                      .contains(_searchText.toLowerCase())) {
                _listHalopensiun.add(halopensiunItem);
              }
            });
          }
        });
      }
    } catch (e) {
      print('Error during _refreshData: $e');
      if (mounted) {
        setState(() {
          _futureData = Future.error(e); // Selesaikan Future dengan error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}',
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Size screenSize = MediaQuery.of(context).size;
    double sliverAppBarExpandedHeight = screenSize.height * 0.24;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
                Colors.white,
                Color(0xFFDCE293),
              ],
              stops: [0.25, 0.5, 0.75, 1.0],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: () =>
                _refreshData(), // onRefresh akan await Future<void>
            child: CustomScrollView(
              controller: scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Memastikan selalu bisa di-scroll
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: sliverAppBarExpandedHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: SliverAppBarTitle(
                      child: SizedBox(
                        height: AppBar().preferredSize.height * 0.4,
                        child: Text('Halo Pensiun'),
                      ),
                    ),
                    titlePadding: const EdgeInsets.only(
                      left: 46.0,
                      bottom: 16.0,
                    ),
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(110, 184, 179, 1),
                                  Color.fromRGBO(119, 189, 185, 1),
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: InkWell(
                                    child: Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        Image.asset(
                                          'assets/halopensiun/banner.png',
                                          fit: BoxFit.cover,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              9 /
                                              16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // --- PERUBAHAN: Membungkus SliverAppBarSheetTop dengan SliverToBoxAdapter ---
                SliverToBoxAdapter(
                  child: SliverAppBarSheetTop(),
                ),
                // --- AKHIR PERUBAHAN ---
                SliverToBoxAdapter(
                  child: FutureBuilder<ResultModel<HalopensiunModel>>(
                    future: _futureData,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<HalopensiunModel>> snapshot) {
                      // --- PERUBAHAN: Logika loading dan error yang lebih cerdas ---
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Tampilkan loading hanya jika belum ada data yang dimuat sebelumnya
                        if (_categories.isEmpty && _listHalopensiun.isEmpty) {
                          return _buildLoadingIndicator(screenSize, theme);
                        } else {
                          // Jika sudah ada data, sembunyikan indikator loading di sini
                          // (animasi refresh indicator di atas sudah cukup)
                          return const SizedBox.shrink();
                        }
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.isSuccess) {
                        // Tampilkan error hanya jika tidak ada data sama sekali untuk ditampilkan
                        if (_categories.isEmpty && _listHalopensiun.isEmpty) {
                          return _buildErrorWidget(snapshot.error?.toString() ??
                              snapshot.data?.error ??
                              'Terjadi kesalahan tidak dikenal.');
                        } else {
                          // Jika ada data lama, jangan tampilkan error card, cukup pesan toast (sudah di _refreshData)
                          return const SizedBox.shrink();
                        }
                      }
                      // --- AKHIR PERUBAHAN ---

                      // Data berhasil dimuat dan sudah diproses di _refreshData
                      // Sekarang, cukup tampilkan UI menggunakan _categories dan _listHalopensiun
                      if (_categories.isNotEmpty) {
                        // Pastikan kategori tidak kosong
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 12.0,
                                top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 36.0,
                                  child: TextField(
                                    onSubmitted: (value) {
                                      setState(() {
                                        _searchText = value;
                                      });
                                      _refreshData();
                                    },
                                    controller: editingController,
                                    decoration: InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(228, 228, 228, 1.0),
                                        suffixIcon: Icon(Icons.search),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(36.0)))),
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Container(
                                  height: 28.0,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      ..._categories
                                          .asMap()
                                          .map((index, halopensiunCategory) {
                                            return MapEntry(
                                              index,
                                              ChipTab(
                                                text: halopensiunCategory.nama,
                                                isActive: _selectedCategoryId ==
                                                    index + 1,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCategoryId =
                                                        index + 1;
                                                  });
                                                  _refreshData();
                                                },
                                                backgroundColor:
                                                    const Color(0xFFFEC842),
                                              ),
                                            );
                                          })
                                          .values
                                          .toList(),
                                      SizedBox(width: 24.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return noData(); // Tampilkan noData jika kategori kosong
                      }
                    },
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final item = _listHalopensiun[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: ExpansionTile(
                              title: Text(item.judul),
                              children: [
                                if (item.infografis != null &&
                                    item.infografis!.isNotEmpty &&
                                    Uri.tryParse(item.infografis!)
                                            ?.hasAbsolutePath ==
                                        true)
                                  CachedNetworkImage(
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    imageUrl: item.infografis!,
                                    fit: BoxFit.fitWidth,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/placeholder_image.png',
                                      fit: BoxFit.fitWidth,
                                    ),
                                  )
                                else
                                  Image.asset(
                                    'assets/placeholder_image.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _listHalopensiun.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(Size screenSize, ThemeData theme) {
    return Container(
      height: (screenSize.height) * 0.5 + 36 + 16.0,
      child: Center(
        child: CircularProgressIndicator(
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          'Error: $message',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }

  Widget noData() {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 90.0,
        horizontal: 60.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 160,
            child: Image.asset('assets/notification_screen/empty.png'),
          ),
          SizedBox(height: 24.0),
          Text(
            'Tidak ada info Halo Pensiun',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Jika ada info Halo Pensiun, maka informasinya akan muncul disini',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.caption?.color,
            ),
          ),
        ],
      ),
    );
  }
}
