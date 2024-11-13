import 'dart:developer';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/toko_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko_repository.dart';
import 'package:pensiunku/screen/toko/history_screen.dart';
import 'package:pensiunku/screen/toko/keranjang_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

class BarangScreenArguments {
  final int barangId;
  final Product barang;

  BarangScreenArguments({required this.barangId, required this.barang});
}

class BarangScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/toko-item';
  final int barangId;
  final Product barang;

  const BarangScreen({Key? key, required this.barangId, required this.barang})
      : super(key: key);

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final TextEditingController editingController = TextEditingController();
  late Future<ResultModel<List<Cart>>> _futureDataCarts;
  late Future<ResultModel<List<Product>>> _futureBarang;
  late int totalCart;
  late List<Cart> carts;
  late List<Product> relatedItem; //TODO nanti harus diganti
  // late List<Review> listReview;
  late Product barang;
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();

    totalCart = 0;
    relatedItem = [];
    // _searchText = null;
    barang = widget.barang;
    _currentCarouselIndex = 0;
    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    _loadCarts();

    return _futureBarang = TokoRepository()
        .getRelatedProductById(token!, widget.barang.idKategori)
        .then((value) {
      if (!value.isSuccess) {
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
          relatedItem = value.data!;
        });
      }
      return value;
    });
  }

  _loadCarts() {
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
      }
      setState(() {
        carts = value.data!;
        totalCart = 0;
        carts.forEach((element) {
          totalCart = totalCart + element.jumlahBarang;
        });
      });
      return value;
    });
  }

  _postToShoppingCart(int idBarang, int amount) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    PushToShoppingCart pushToShoppingCart =
        PushToShoppingCart(id: idBarang, stok: amount);

    //find is the product in the shoppingCart
    bool isExist = false;
    int jumlahBarang = 0;
    carts.forEach(((cart) {
      if (idBarang == cart.idBarang) {
        isExist = true;
        jumlahBarang = cart.jumlahBarang + amount;
      }
    }));

    if (isExist) {
      //update jumlah
      TokoRepository()
          .putToShoppingCart(
              token!, PushToShoppingCart(id: idBarang, stok: jumlahBarang))
          .then((value) {
        log(value.toString());
        if (!value.isSuccess) {
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
        } else {
          setState(() {
            _refreshData();
          });
        }
        return value;
      });
    } else {
      //masukkan baru
      TokoRepository()
          .postToShoppingCart(token!, pushToShoppingCart)
          .then((value) {
        log(value.toString());
        if (!value.isSuccess) {
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
            _refreshData();
          });
        }
        return value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        leadingWidth: 15.0,
        // titleSpacing: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        // title: Padding(
        //   padding: const EdgeInsets.only(left: 8.0, right: 0.0),
        //   child: Container(
        //     height: 36.0,
        //     child: TextField(
        //       onSubmitted: (value) {
        //         // _searchText = value;
        //         // _refreshData();
        //       },
        //       controller: editingController,
        //       decoration: InputDecoration(
        //           filled: true,
        //           fillColor: Color.fromRGBO(228, 228, 228, 1.0),
        //           suffixIcon: Icon(Icons.search),
        //           contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        //           border: OutlineInputBorder(
        //               borderRadius: BorderRadius.all(Radius.circular(36.0)))),
        //     ),
        //   ),
        // ),
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
                );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenSize.height * 0.4,
                          width: double.infinity,
                          // decoration: BoxDecoration(
                          //     image: DecorationImage(
                          //         image: NetworkImage(barang.gallery[0].path),
                          //         fit: BoxFit.fitWidth)),
                          child: CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: screenSize.height * 0.4,
                              aspectRatio: 1,
                              enlargeCenterPage: false,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              autoPlay: false,
                              // autoPlayInterval: Duration(seconds: 5),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentCarouselIndex = index;
                                });
                              },
                            ),
                            items: barang.gallery.map<Widget>((e) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(0.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        imageUrl: e.path,
                                        fit: BoxFit.fitHeight,
                                      ));
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          barang.nama,
                          style: theme.textTheme.subtitle1
                              ?.copyWith(color: Colors.black),
                        ),
                        Text(
                          barang.getTotalPriceFormatted(),
                          style: theme.textTheme.subtitle1?.copyWith(
                              color: Color.fromRGBO(76, 167, 157, 1.0)),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(children: [
                          RatingBar.builder(
                            initialRating:
                                double.parse(barang.averageRating.toString()),
                            minRating: 1,
                            // maxRating: 5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 12.0,
                            ignoreGestures: true,
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
                            width: 8.0,
                          ),
                          Text(barang.terjual!)
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Deskripsi'),
                        SizedBox(
                          height: 2,
                        ),
                        Text(barang.deskripsi),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  barang.review!.length > 0
                      ? Divider(
                          thickness: 8.0,
                          color: Color.fromRGBO(236, 236, 236, 1.0),
                        )
                      : Container(),
                  barang.review!.length > 0
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 5.0),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text('Ulasan Produk'),
                              Spacer(),
                              Icon(
                                Icons.navigate_next,
                                color: Color.fromRGBO(149, 149, 149, 1.0),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  Divider(
                    thickness: 4.0,
                    color: Color.fromRGBO(236, 236, 236, 1.0),
                  ),
                  ...barang.review!.map((review) {
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Color.fromRGBO(241, 176, 86, 1.0),
                                    radius: 20,
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.userName.toString(),
                                        // style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      RatingBar.builder(
                                        initialRating: double.parse(
                                            review.star.toString()),
                                        minRating: 1,
                                        // maxRating: 5,
                                        direction: Axis.horizontal,
                                        allowHalfRating: false,
                                        itemCount: 5,
                                        itemSize: 12.0,
                                        // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color:
                                              Color.fromRGBO(241, 176, 86, 1.0),
                                          // size: 2.0,
                                        ),
                                        unratedColor: Colors.grey.withAlpha(50),
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Text(review.ulasan),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                DateFormat('dd-MM-yyyy')
                                    .format(review.createdAt)
                                    .toString(),
                                style: TextStyle(color: Colors.grey.shade400),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 4.0,
                          color: Color.fromRGBO(236, 236, 236, 1.0),
                        ),
                      ],
                    );
                  }),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text('Produk Serupa'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: relatedItem.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 0.65),
                        itemBuilder: (context, position) {
                          return itemCard(relatedItem[position]);
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55.0,
        child: Row(
          children: [
            Container(
                width: screenSize.width * 0.3,
                height: 55.0,
                decoration:
                    BoxDecoration(color: Color.fromRGBO(76, 167, 157, 1.0)),
                child: InkWell(
                    onTap: () {
                      // setState(() {
                      //   _basketItems = _basketItems + 1;
                      // });
                    },
                    child: IconButton(
                      splashRadius: 100.0,
                      splashColor: Colors.green,
                      tooltip: 'Add Cart',
                      icon: Icon(Icons.add_shopping_cart),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: () {
                        setState(() {
                          // totalCart = totalCart + 1;
                          _postToShoppingCart(barang.id, 1);
                        });
                      },
                    ))),
            InkWell(
              onTap: () {
                setState(() {
                  _postToShoppingCart(barang.id, 1);
                });
                Future.delayed(Duration(seconds: 2));
                Navigator.of(context)
                    .pushNamed(
                      KeranjangScreen.ROUTE_NAME,
                    )
                    .then((value) => _refreshData());
              },
              child: Container(
                width: screenSize.width * 0.7,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.red),
                child: Text(
                  'Beli Sekarang',
                  style:
                      theme.textTheme.subtitle1?.copyWith(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
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
