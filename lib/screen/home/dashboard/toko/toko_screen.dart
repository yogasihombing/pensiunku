import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:pensiunku/model/toko/promo_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko/promo_repository.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/barang_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/history_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/keranjang_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';

import 'package:pensiunku/widget/toko/item_promo.dart';

class TokoScreenArguments {
  final int categoryId;

  TokoScreenArguments({required this.categoryId});
}

class TokoScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/toko';
  final int categoryId;

  const TokoScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> {
  final TextEditingController editingController = TextEditingController();
  late Future<ResultModel<TokoModel>> _futureData;
  late Future<ResultModel<List<PromoModel>>> _futureDataPromos;
  late Future<ResultModel<List<Cart>>> _futureDataCarts;
  int _filterIndex = 0; // #0 terlaris | #1 terbaru
  late int _currentPage;
  late int _lastPage;
  late List<Product> listBarang;
  late int totalCart;
  late String _searchText;

  static const _kAppBarTitleWeight = FontWeight.w600;

  @override
  void initState() {
    super.initState();

    totalCart = 0;
    _searchText = "";

    _refreshData();
  }

  _refreshData() {
    _currentPage = 1;
    listBarang = [];
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    _futureDataPromos = PromoRepository().getAll().then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      }
      setState(() {});
      return value;
    });

    if (_filterIndex == 0) {
      _futureData = TokoRepository()
          .getFeaturedProductByCategory(
              _currentPage, token!, widget.categoryId, _searchText)
          .then((value) {
        log(value.toString());
        if (value.error != null) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(value.error.toString(),
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                    elevation: 24.0,
                  ));
        }
        setState(() {
          listBarang = value.data!.products.data;
          _lastPage = value.data!.products.lastPage;
          print('jumlah barang:' + listBarang.length.toString());
        });
        return value;
      });
    } else {
      _futureData = TokoRepository()
          .getLatestProductByCategory(
              _currentPage, token!, widget.categoryId, _searchText)
          .then((value) {
        log(value.toString());
        if (value.error != null) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(value.error.toString(),
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                    elevation: 24.0,
                  ));
        }
        setState(() {
          listBarang = value.data!.products.data;
          _lastPage = value.data!.products.lastPage;
          print('jumlah barang:' + listBarang.length.toString());
        });
        return value;
      });
    }

    loadCarts();
  }

  loadCarts() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    _futureDataCarts = TokoRepository().getShoppingCart(token!).then((value) {
      log(value.toString());
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(value.error.toString(),
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      } else {
        setState(() {
          totalCart = 0;
          value.data!.forEach((element) {
            totalCart = totalCart + element.jumlahBarang;
          });
        });
      }
      return value;
    });
  }

  loadMore() {
    if (_currentPage < _lastPage) {
      setState(() {
        _currentPage = _currentPage + 1;
        print('current page:' + _currentPage.toString());
      });

      String? token = SharedPreferencesUtil()
          .sharedPreferences
          .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

      if (_filterIndex == 0) {
        TokoRepository()
            .getFeaturedProductByCategory(
                _currentPage, token!, widget.categoryId, _searchText)
            .then((value) {
          log(value.toString());
          if (value.error != null) {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text(value.error.toString(),
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      elevation: 24.0,
                    ));
          } else {
            value.data!.products.data.asMap().forEach((key, barang) {
              setState(() {
                listBarang.add(barang);
              });
            });
            print('jumlah barang:' + listBarang.length.toString());
          }
        });
      } else {
        TokoRepository()
            .getLatestProductByCategory(
                _currentPage, token!, widget.categoryId, _searchText)
            .then((value) {
          log(value.toString());
          if (value.error != null) {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text(value.error.toString(),
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      elevation: 24.0,
                    ));
          } else {
            value.data!.products.data.asMap().forEach((key, barang) {
              setState(() {
                listBarang.add(barang);
              });
            });
            print('jumlah barang:' + listBarang.length.toString());
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Menggunakan MediaQuery untuk ukuran layar yang dinamis
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Ukuran komponen yang dinamis berdasarkan layar
    final double searchBarHeight = screenHeight * 0.06;
    final double cardPadding = screenWidth * 0.02;
    final double filterContainerWidth = screenWidth * 0.8;
    final double bannerHeight = screenHeight * 0.15;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF017964),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Toko',
          style: TextStyle(
            color: const Color(0xFF017964),
            fontWeight: _kAppBarTitleWeight,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: RefreshIndicator(
          onRefresh: () {
            return _refreshData();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Bagian atas yang static (tidak scroll)
              // Search dan Tombol
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Row(
                  children: [
                    // Search Box
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: searchBarHeight,
                        child: TextField(
                          onSubmitted: (value) {
                            _searchText = value;
                            _refreshData();
                          },
                          controller: editingController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromRGBO(228, 228, 228, 1.0),
                              suffixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(36.0)))),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    // Keranjang Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              KeranjangScreen.ROUTE_NAME,
                            )
                            .then((value) => _refreshData());
                      },
                      child: Container(
                        height: searchBarHeight,
                        width: searchBarHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: totalCart == 0
                              ? Image.asset(
                                  'assets/toko/keranjang.png',
                                  height: searchBarHeight * 0.6,
                                )
                              : Badge(
                                  badgeContent: Text(
                                    '$totalCart',
                                    style: theme.textTheme.bodyText1?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  position: BadgePosition.topEnd(
                                    top: -4,
                                    end: -4,
                                  ),
                                  child: Image.asset(
                                    'assets/toko/keranjang.png',
                                    height: searchBarHeight * 0.6,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    // History Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(),
                          ),
                        ).then((value) => _refreshData());
                      },
                      child: Container(
                        height: searchBarHeight,
                        width: searchBarHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/toko/history.png',
                            height: searchBarHeight * 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Banner Image with border radius, horizontal margin, and aspect ratio
              Container(
                // add left-right and top-bottom spacing
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.01,
                ),
                width: screenWidth,
                child: ClipRRect(
                  // set border radius
                  borderRadius: BorderRadius.circular(16.0),
                  child: AspectRatio(
                    // maintain a 16:9 ratio (adjust as needed)
                    aspectRatio: 18 / 9,
                    child: Image.asset(
                      'assets/dashboard_screen/image_2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Filter Terlaris/Terbaru (masih static)
              Container(
                width: filterContainerWidth,
                height: searchBarHeight,
                margin: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(195, 195, 195, 1.0)),
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
                          height: searchBarHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(36),
                              bottomLeft: Radius.circular(36),
                            ),
                            color: _filterIndex == 0
                                ? Color.fromRGBO(1, 169, 159, 1.0)
                                : Colors.white,
                          ),
                          child: Text(
                            "Terlaris",
                            style: TextStyle(
                              color: _filterIndex == 0
                                  ? Colors.white
                                  : Color.fromRGBO(149, 149, 149, 1.0),
                            ),
                          ),
                        ),
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
                          height: searchBarHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(36),
                              bottomRight: Radius.circular(36),
                            ),
                            color: _filterIndex == 1
                                ? Color.fromRGBO(1, 169, 159, 1.0)
                                : Colors.white,
                          ),
                          child: Text(
                            "Terbaru",
                            style: TextStyle(
                              color: _filterIndex == 0
                                  ? Color.fromRGBO(149, 149, 149, 1.0)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Area yang dapat di-scroll (bagian grid produk)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: cardPadding),
                child: FutureBuilder(
                  future: _futureData,
                  builder: (BuildContext context,
                      AsyncSnapshot<ResultModel<TokoModel>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data?.data?.products.data.isNotEmpty ==
                          true) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: cardPadding),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listBarang.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: screenHeight * 0.01,
                              crossAxisSpacing: screenWidth * 0.01,
                              childAspectRatio:
                                  screenWidth / (screenHeight * 0.9),
                            ),
                            itemBuilder: (context, position) {
                              return itemCard(listBarang[position]);
                            },
                          ),
                        );
                      } else {
                        String errorTitle =
                            'Tidak ada barang dalam kategori ini';
                        String? errorSubtitle = snapshot.data?.error;
                        return Container(
                          height: screenHeight * 0.4,
                          child: ErrorCard(
                            title: errorTitle,
                            subtitle: errorSubtitle,
                            iconData: Icons.info_outline_rounded,
                          ),
                        );
                      }
                    } else {
                      return Container(
                        height: screenHeight * 0.4,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        ),
                      );
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

  Widget itemCard(Product barang) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardPadding = screenSize.width * 0.02;
    final double imagePadding = screenSize.width * 0.01;
    final double textSize = screenSize.width * 0.03;
    final double ratingSize = screenSize.width * 0.025;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(BarangScreen.ROUTE_NAME,
                arguments:
                    BarangScreenArguments(barangId: barang.id, barang: barang))
            .then((value) {
          setState(() {
            _refreshData();
          });
        });
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 10,
              child: Container(
                padding: EdgeInsets.all(imagePadding),
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  imageUrl: barang.gallery[0].path,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barang.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      barang.getTotalPriceFormatted(),
                      style: TextStyle(
                        fontSize: textSize,
                        color: Color.fromRGBO(149, 149, 149, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    RatingBar.builder(
                      initialRating: barang.averageRating!,
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
                        print(rating);
                      },
                    ),
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

// class TokoScreenArguments {
//   final int categoryId;

//   TokoScreenArguments({required this.categoryId});
// }

// class TokoScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/toko';
//   final int categoryId;

//   const TokoScreen({Key? key, required this.categoryId}) : super(key: key);

//   @override
//   State<TokoScreen> createState() => _TokoScreenState();
// }

// class _TokoScreenState extends State<TokoScreen> {
//   // ======= CONFIGURABLE =======
//   static const double _kAppBarTitleSize = 20.0;
//   static const FontWeight _kAppBarTitleWeight = FontWeight.w600;
//   static const double _kAppBarIconSize = 28.0;
//   // =============================

//   final TextEditingController editingController = TextEditingController();

//   late Future<ResultModel<TokoModel>> _futureData;
//   late Future<ResultModel<List<PromoModel>>> _futureDataPromos;
//   late Future<ResultModel<List<Cart>>> _futureDataCarts;

//   int _filterIndex = 0; // #0 terlaris | #1 terbaru
//   late int _currentPage;
//   late int _lastPage;
//   late List<Product> listBarang;
//   late int totalCart;
//   late String _searchText;

//   @override
//   void initState() {
//     super.initState();
//     totalCart = 0;
//     _searchText = "";
//     _refreshData();
//   }

//   void _refreshData() {
//     _currentPage = 1;
//     listBarang = [];
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     // Promo
//     _futureDataPromos = PromoRepository().getAll().then((value) {
//       if (value.error != null) {
//         _showError(value.error!);
//       } else {
//         setState(() {});
//       }
//       return value;
//     });

//     // Produk
//     final repo = TokoRepository();
//     Future<ResultModel<TokoModel>> fetch;
//     if (_filterIndex == 0) {
//       fetch = repo.getFeaturedProductByCategory(
//           _currentPage, token!, widget.categoryId, _searchText);
//     } else {
//       fetch = repo.getLatestProductByCategory(
//           _currentPage, token!, widget.categoryId, _searchText);
//     }
//     _futureData = fetch.then((value) {
//       if (value.error != null) {
//         _showError(value.error!);
//       } else {
//         setState(() {
//           listBarang = value.data!.products.data;
//           _lastPage = value.data!.products.lastPage;
//         });
//       }
//       return value;
//     });

//     // Cart
//     _loadCarts();
//   }

//   void _loadCarts() {
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     _futureDataCarts = TokoRepository().getShoppingCart(token!).then((value) {
//       if (value.error != null) {
//         _showError(value.error!);
//       } else {
//         setState(() {
//           totalCart = value.data!.fold(0, (sum, e) => sum + e.jumlahBarang);
//         });
//       }
//       return value;
//     });
//   }

//   void _showError(String msg) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         content: Text(msg, style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//         elevation: 24.0,
//       ),
//     );
//   }

//   void _loadMore() {
//     if (_currentPage < _lastPage) {
//       _currentPage++;
//       String? token = SharedPreferencesUtil()
//           .sharedPreferences
//           .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
//       final repo = TokoRepository();
//       Future<ResultModel<TokoModel>> fetch;
//       if (_filterIndex == 0) {
//         fetch = repo.getFeaturedProductByCategory(
//             _currentPage, token!, widget.categoryId, _searchText);
//       } else {
//         fetch = repo.getLatestProductByCategory(
//             _currentPage, token!, widget.categoryId, _searchText);
//       }
//       fetch.then((value) {
//         if (value.error != null) {
//           _showError(value.error!);
//         } else {
//           setState(() {
//             listBarang.addAll(value.data!.products.data);
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Menggunakan MediaQuery untuk ukuran layar yang dinamis
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final topPadding = MediaQuery.of(context).padding.top;
//     final topBarHeight = topPadding + kToolbarHeight;

//     // Menghitung padding yang responsif
//     final horizontalPadding = screenWidth * 0.04; // 4% dari lebar layar
//     final verticalPadding =
//         screenHeight * 0.01; // 1% dari tinggi layar (dikurangi dari 2%)

//     return Scaffold(
//       extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back,
      //       size: _kAppBarIconSize,
      //       color: const Color(0xFF017964),
      //     ),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Text(
      //     'Toko',
      //     style: TextStyle(
      //       color: const Color(0xFF017964),
      //       fontSize: _kAppBarTitleSize,
      //       fontWeight: _kAppBarTitleWeight,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      // body: Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [
      //         Colors.white,
      //         Colors.white,
      //         Colors.white,
      //         Color(0xFFDCE293),
      //       ],
      //       stops: [0.25, 0.5, 0.75, 1.0],
      //     ),
      //   ),
//         child: Column(
//           children: [
//             // Spacer untuk AppBar transparan
//             SizedBox(height: topBarHeight),

//             // Row: Search, Cart & History
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: verticalPadding * 0.4, // Lebih kecil untuk vertikal
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: screenHeight * 0.05, // 5% dari tinggi layar
//                       child: TextField(
//                         controller: editingController,
//                         onSubmitted: (value) {
//                           _searchText = value;
//                           _refreshData();
//                         },
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: const Color(0xFFE4E4E4),
//                           hintText: 'Cari barang...',
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: horizontalPadding,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(36),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: const Icon(Icons.search),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: screenWidth * 0.02), // 2% dari lebar layar
//                   Stack(
//                     children: [
//                       IconButton(
//                         iconSize: _kAppBarIconSize,
//                         icon: const Icon(Icons.shopping_cart,
//                             color: Color(0xFF017964)),
//                         onPressed: () {
//                           Navigator.of(context)
//                               .pushNamed(KeranjangScreen.ROUTE_NAME)
//                               .then((_) => _refreshData());
//                         },
//                       ),
//                       if (totalCart > 0)
//                         Positioned(
//                           right: 6,
//                           top: 6,
//                           child: Container(
//                             padding: EdgeInsets.all(screenWidth * 0.01),
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).primaryColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Text(
//                               '$totalCart',
//                               style: const TextStyle(
//                                   color: Colors.white, fontSize: 10),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   IconButton(
//                     iconSize: _kAppBarIconSize,
//                     icon: const Icon(Icons.history, color: Color(0xFF017964)),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const HistoryScreen()),
//                       ).then((_) => _refreshData());
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Konten yang bisa discroll
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   _refreshData();
//                 },
//                 child: LazyLoadScrollView(
//                   onEndOfPage: _loadMore,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       children: [
//                         // Banner dengan border radius dan margin yang lebih kecil
//                         Container(
//                           margin: EdgeInsets.symmetric(
//                             horizontal: horizontalPadding,
//                             vertical: verticalPadding *
//                                 0.5, // Mengurangi margin vertikal
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.asset(
//                               'assets/dashboard_screen/image_2.png',
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                               height:
//                                   screenHeight * 0.15, // 15% dari tinggi layar
//                             ),
//                           ),
//                         ),

//                         // Daftar Produk dengan jarak yang lebih kecil
//                         FutureBuilder<ResultModel<TokoModel>>(
//                           future: _futureData,
//                           builder: (context, snap) {
//                             if (snap.hasData) {
//                               final products = snap.data!.data!.products.data;
//                               if (products.isNotEmpty) {
//                                 return Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     // Filter bar dengan padding dan margin yang lebih kecil
//                                     Container(
//                                       height: screenHeight *
//                                           0.045, // 4.5% dari tinggi layar
//                                       margin: EdgeInsets.symmetric(
//                                         horizontal: screenWidth *
//                                             0.12, // 12% dari lebar layar
//                                         vertical: verticalPadding *
//                                             0.8, // Dikurangi dari sebelumnya
//                                       ),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: const Color(0xFFC3C3C3)),
//                                         borderRadius: BorderRadius.circular(36),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           _filterButton(
//                                             "Terlaris",
//                                             0,
//                                             BorderRadius.only(
//                                               topLeft: Radius.circular(36),
//                                               bottomLeft: Radius.circular(36),
//                                             ),
//                                           ),
//                                           _filterButton(
//                                             "Terbaru",
//                                             1,
//                                             BorderRadius.only(
//                                               topRight: Radius.circular(36),
//                                               bottomRight: Radius.circular(36),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Menghilangkan padding luar dan mengurangi jarak
//                                     // antara filter button dengan grid produk
//                                     SizedBox(
//                                         height: verticalPadding *
//                                             0.2), // Sangat kecil

//                                     // Grid produk dengan padding yang lebih kecil
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: horizontalPadding * 0.5,
//                                       ),
//                                       child: GridView.builder(
//                                         shrinkWrap: true,
//                                         physics:
//                                             const NeverScrollableScrollPhysics(),
//                                         itemCount: listBarang.length,
//                                         gridDelegate:
//                                             SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisCount: 2,
//                                           mainAxisSpacing: screenHeight *
//                                               0.01, // 1% dari tinggi layar
//                                           crossAxisSpacing: screenWidth *
//                                               0.02, // 2% dari lebar layar
//                                           childAspectRatio: 0.65,
//                                         ),
//                                         itemBuilder: (ctx, i) => _itemCard(
//                                           listBarang[i],
//                                           screenWidth,
//                                           screenHeight,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               } else {
//                                 return const Padding(
//                                   padding: EdgeInsets.all(24.0),
//                                   child: Center(
//                                     child: Text(
//                                         'Tidak ada barang dalam kategori ini'),
//                                   ),
//                                 );
//                               }
//                             }
//                             return SizedBox(
//                               height:
//                                   screenHeight * 0.25, // 25% dari tinggi layar
//                               child: const Center(
//                                   child: CircularProgressIndicator()),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _filterButton(String label, int idx, BorderRadius radius) {
//     final active = _filterIndex == idx;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _filterIndex = idx;
//             _refreshData();
//           });
//         },
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: active ? const Color(0xFF01A99F) : Colors.white,
//             borderRadius: radius,
//           ),
//           child: Text(
//             label,
//             style: TextStyle(
//               color: active ? Colors.white : const Color(0xFF959595),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _itemCard(Product barang, double screenWidth, double screenHeight) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context)
//             .pushNamed(
//               BarangScreen.ROUTE_NAME,
//               arguments:
//                   BarangScreenArguments(barangId: barang.id, barang: barang),
//             )
//             .then((_) => _refreshData());
//       },
//       child: Card(
//         margin:
//             EdgeInsets.all(screenWidth * 0.008), // Margin card yang lebih kecil
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 10,
//               child: Padding(
//                 padding: EdgeInsets.all(
//                     screenWidth * 0.015), // 1.5% dari lebar layar
//                 child: CachedNetworkImage(
//                   placeholder: (_, __) =>
//                       const Center(child: CircularProgressIndicator()),
//                   imageUrl: barang.gallery.isNotEmpty
//                       ? barang.gallery[0].path
//                       : 'https://placeholder.com/400',
//                   fit: BoxFit.contain,
//                   errorWidget: (_, __, ___) => const Icon(Icons.error),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 4,
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.02), // 2% dari lebar layar
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       barang.nama,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           fontSize: screenWidth * 0.03), // 3% dari lebar layar
//                     ),
//                     SizedBox(
//                         height: screenHeight *
//                             0.003), // 0.3% dari tinggi layar (dikurangi dari 0.5%)
//                     Text(
//                       barang.getTotalPriceFormatted(),
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: const Color(0xFF959595),
//                         fontWeight: FontWeight.bold,
//                         fontSize: screenWidth * 0.028, // 2.8% dari lebar layar
//                       ),
//                     ),
//                     SizedBox(
//                         height: screenHeight *
//                             0.003), // 0.3% dari tinggi layar (dikurangi dari 0.5%)
//                     RatingBar.builder(
//                       initialRating: barang.averageRating ?? 0.0,
//                       minRating: 1,
//                       direction: Axis.horizontal,
//                       allowHalfRating: true,
//                       itemCount: 5,
//                       itemSize: screenWidth * 0.025, // 2.5% dari lebar layar
//                       itemBuilder: (_, __) =>
//                           const Icon(Icons.star, color: Colors.black),
//                       unratedColor: Colors.grey.withAlpha(50),
//                       onRatingUpdate: (_) {},
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
