import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/promo_model.dart';
import 'package:pensiunku/model/toko_model.dart';
import 'package:pensiunku/repository/promo_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko_repository.dart';
import 'package:pensiunku/screen/toko/history_screen.dart';
import 'package:pensiunku/screen/toko/keranjang_screen.dart';
import 'package:pensiunku/screen/toko/toko_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/expanded_button.dart';
import 'package:pensiunku/widget/item_promo.dart';

class CategoryScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/toko-category';

  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController editingController = TextEditingController();
  late Future<ResultModel<List<PromoModel>>> _futureDataPromos;
  late Future<ResultModel<List<Category>>> _futureDataCategories;
  late Future<ResultModel<List<Cart>>> _futureDataShoppingCart;
  late int totalCart;
  String _searchText = "";
  List<Color> color1 = [
    Color.fromRGBO(0, 170, 187, 1.0),
    Color.fromRGBO(233, 47, 125, 1.0),
    Color.fromRGBO(245, 125, 51, 1.0),
  ];
  List<Color> color2 = [
    Color.fromRGBO(98, 147, 229, 1.0),
    Color.fromRGBO(174, 66, 181, 1.0),
    Color.fromRGBO(242, 79, 76, 1.0),
  ];
  List<String> image1 = [
    'assets/toko/kategori/kesehatan1.png',
    'assets/toko/kategori/kesehatan2.png',
    'assets/toko/kategori/kesehatan3.png',
  ];
  List<String> image2 = [
    'assets/toko/kategori/tradisional1.png',
    'assets/toko/kategori/tradisional2.png',
    'assets/toko/kategori/tradisional3.png',
  ];
  List<String> image3 = [
    'assets/toko/kategori/hobi1.png',
    'assets/toko/kategori/hobi2.png',
    'assets/toko/kategori/hobi3.png',
  ];
  List<List<Color>> filteredColor = [];
  List<List<String>> filteredImage = [];
  List<bool> links = [false, false, false];

  @override
  void initState() {
    super.initState();

    totalCart = 0;
    _refreshData();
  }

  _refreshData() {
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

    _futureDataCategories =
        TokoRepository().getAllCategories(token!).then((value) {
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
        List<Category> categories = value.data!;
        List<Category> filteredCategories = [];
        filteredColor = [];
        filteredImage = [];
        categories.asMap().forEach((key, category) {
          if (category.nama.toLowerCase().contains(_searchText.toLowerCase())) {
            filteredCategories
                .add(Category(id: category.id, nama: category.nama));
            switch (key) {
              case 0:
                filteredColor.add([color1[0], color2[0]]);
                filteredImage.add(image1);
                break;
              case 1:
                filteredColor.add([color1[1], color2[1]]);
                filteredImage.add(image2);
                break;
              case 2:
                filteredColor.add([color1[2], color2[2]]);
                filteredImage.add(image3);
                break;
            }
          }
        });
        log('filteredColor:' + filteredColor.toString());
        ResultModel<List<Category>> result =
            ResultModel(isSuccess: true, data: filteredCategories);
        value = result;
      });
      return value;
    });

    return _futureDataShoppingCart =
        TokoRepository().getShoppingCart(token).then((value) {
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
        totalCart = 0;
        value.data!.forEach((element) {
          totalCart = totalCart + element.jumlahBarang;
        });
      });
      return value;
    });
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
          padding: const EdgeInsets.only(left: 12.0, right: 0.0),
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
                        AsyncSnapshot<ResultModel<List<PromoModel>>> snapshot) {
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
                    future: _futureDataCategories,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<List<Category>>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data?.isNotEmpty == true) {
                          List<Category> categories = snapshot.data!.data!;
                          // if()
                          return Column(
                            children: [
                              ...categories.map((category) {
                                return GestureDetector(
                                  onTap: () {
                                    print('tapped');
                                    if (links[categories.indexOf(category)]) {
                                      Navigator.of(context)
                                          .pushNamed(TokoScreen.ROUTE_NAME,
                                              arguments: TokoScreenArguments(
                                                  categoryId: category.id))
                                          .then((value) => _refreshData());
                                    } else {
                                      setState(() {
                                        links[categories.indexOf(category)] =
                                            true;
                                        print(
                                            "link${categories.indexOf(category).toString()}" +
                                                ":" +
                                                links[categories
                                                        .indexOf(category)]
                                                    .toString());
                                      });
                                    }
                                  },
                                  child: ExpandedButton(
                                    text: category.nama,
                                    color1: filteredColor[
                                        categories.indexOf(category)][0],
                                    color2: filteredColor[
                                        categories.indexOf(category)][1],
                                    image1: filteredImage[
                                        categories.indexOf(category)][0],
                                    image2: filteredImage[
                                        categories.indexOf(category)][1],
                                    image3: filteredImage[
                                        categories.indexOf(category)][2],
                                    isActive:
                                        links[categories.indexOf(category)],
                                  ),
                                );
                              }),
                            ],
                          );
                        } else {
                          String errorTitle =
                              'Tidak dapat menampilkan kategori barang';
                          String? errorSubtitle = snapshot.data?.error;
                          return Container(
                            child: ErrorCard(
                              title: errorTitle,
                              subtitle: errorSubtitle,
                              iconData: Icons.warning_rounded,
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
    );
  }
}
