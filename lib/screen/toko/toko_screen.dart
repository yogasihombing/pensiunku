import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pensiunku/model/promo_model.dart';
import 'package:pensiunku/model/toko_model.dart';
import 'package:pensiunku/repository/promo_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko_repository.dart';
import 'package:pensiunku/screen/toko/barang_screen.dart';
import 'package:pensiunku/screen/toko/keranjang_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/screen/toko/history_screen.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/item_promo.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

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
        // WidgetUtil.showSnackbar(
        //   context,
        //   value.error.toString(),
        // );
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
      // TokoRepository().getAllProductFull(_currentPage, token!).then((value) {
      //   log(value.toString());
      //   if (value.error != null) {
      //     showDialog(
      //         context: context,
      //         builder: (_) => AlertDialog(
      //               content: Text(value.error.toString(),
      //                   style: TextStyle(color: Colors.white)),
      //               backgroundColor: Colors.red,
      //               elevation: 24.0,
      //             ));
      //   } else {
      //     value.data!.products.data.asMap().forEach((key, barang) {
      //       setState(() {
      //         listBarang.add(barang);
      //       });
      //     });
      //     print('jumlah barang:' + listBarang.length.toString());
      //   }
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double carouselWidth = screenSize.width * 0.9;
    double cardWidth = carouselWidth - 16.0;
    double promoCardHeight = cardWidth * (746 / 1697) + 24.0;
    double promoCarouselHeight = promoCardHeight + 16.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        leadingWidth: 15.0,
        // titleSpacing: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            log('back butto pressed');
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 0.0),
          child: Container(
            height: 36.0,
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
                      borderRadius: BorderRadius.all(Radius.circular(36.0)))),
            ),
          ),
        ),
        actions: [
          IconButton(
              visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              tooltip: 'Keranjang',
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(
                      KeranjangScreen.ROUTE_NAME,
                    )
                    .then((value) => _refreshData());
              },
              // icon: NotificationCounter(),
              icon: SizedBox(
                height: 30.0,
                child: totalCart == 0
                    ? Image.asset('assets/toko/keranjang.png')
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
                        child: Image.asset('assets/toko/keranjang.png')),
              )),
          IconButton(
              visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              tooltip: 'History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(),
                  ),
                ).then((value) => _refreshData());
              },
              // icon: NotificationCounter(),
              icon: SizedBox(
                height: 30.0,
                child: Image.asset('assets/toko/history.png'),
              )),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshData();
        },
        child: LazyLoadScrollView(
          onEndOfPage: () => loadMore(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height * 1.2,
                ),
                Column(
                  children: [
                    FutureBuilder(
                      future: _futureDataPromos,
                      builder: (BuildContext context,
                          AsyncSnapshot<ResultModel<List<PromoModel>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data?.data?.isNotEmpty == true) {
                            List<PromoModel> data = snapshot.data!.data!;
                            return CarouselSlider(
                              options: CarouselOptions(
                                height: promoCarouselHeight,
                                viewportFraction: 1.1,
                                enableInfiniteScroll: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                              ),
                              items: data.map((promo) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return ItemPromo(
                                      promo: promo,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          } else {
                            String errorTitle = 'Tidak dapat menampilkan promo';
                            String? errorSubtitle = snapshot.data?.error;
                            return Container(
                              height: promoCarouselHeight,
                              child: ErrorCard(
                                title: errorTitle,
                                subtitle: errorSubtitle,
                                iconData: Icons.warning_rounded,
                              ),
                            );
                          }
                        } else {
                          return Container(
                            height: promoCarouselHeight,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    FutureBuilder(
                      future: _futureData,
                      builder: (BuildContext context,
                          AsyncSnapshot<ResultModel<TokoModel>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data?.data?.products.data.isNotEmpty ==
                              true) {
                            // List<Product> products = snapshot.data!.data!.products.data;
                            return Column(
                              children: [
                                filter(context),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: listBarang.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 5,
                                              crossAxisSpacing: 5,
                                              childAspectRatio: 0.65),
                                      itemBuilder: (context, position) {
                                        return itemCard(listBarang[position]);
                                      }),
                                )
                              ],
                            );
                          } else {
                            String errorTitle =
                                'Tidak ada barang dalam kategori ini';
                            String? errorSubtitle = snapshot.data?.error;
                            return Container(
                              child: ErrorCard(
                                title: errorTitle,
                                subtitle: errorSubtitle,
                                iconData: Icons.info_outline_rounded,
                              ),
                            );
                          }
                        } else {
                          return Container(
                            height: promoCarouselHeight + 36 + 16.0,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
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
                    "Terbaru",
                    style: TextStyle(
                        color: _filterIndex == 0
                            ? Color.fromRGBO(149, 149, 149, 1.0)
                            : Colors.white),
                  )),
            ))
          ],
        ));
  }

  Widget itemCard(Product barang) {
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
      child: Container(
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  padding: EdgeInsets.all(6),
                  alignment: Alignment.center,
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    imageUrl: barang.gallery[0].path,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang.nama,
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(barang.getTotalPriceFormatted(),
                            style: new TextStyle(
                                // fontSize: 10.0,
                                color: Color.fromRGBO(149, 149, 149, 1.0),
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        RatingBar.builder(
                          initialRating: barang.averageRating!,
                          minRating: 1,
                          // maxRating: 5,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 12.0,
                          // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.black,
                            // size: 2.0,
                          ),
                          unratedColor: Colors.grey.withAlpha(50),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                        SizedBox(
                          height: 2,
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
