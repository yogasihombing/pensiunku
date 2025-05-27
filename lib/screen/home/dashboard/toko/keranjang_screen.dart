import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/checkout_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/history_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';

class KeranjangScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/keranjang';

  const KeranjangScreen({Key? key}) : super(key: key);

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  late Future<ResultModel<List<Cart>>> _futureDataCarts;
  int totalHarga = 0;

  @override
  void initState() {
    super.initState();

    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureDataCarts =
        TokoRepository().getShoppingCart(token!).then((value) {
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
        // WidgetUtil.showSnackbar(
        //   context,
        //   value.error.toString(),
        // );
      } else {
        setState(() {
          totalHarga = 0;
          value.data!.asMap().forEach((key, cart) {
            totalHarga = totalHarga + cart.totalPrice;
          });
        });
      }
      return value;
    });
  }

  _deleteShoppingCart(int idCart) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    TokoRepository().deleteShoppingCart(token!, idCart).then((value) {
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
      } else {
        _refreshData();
      }
    });
  }

  _putShoppingCart(int idCart, int jumlah) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    PushToShoppingCart pushToShoppingCart =
        PushToShoppingCart(id: idCart, stok: jumlah);

    TokoRepository()
        .putToShoppingCart(token!, pushToShoppingCart)
        .then((value) {
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
      } else {
        _refreshData();
      }
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
        centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
            color: Color(0xFF017964),
          ),
          title: Text(
            "Keranjang Belanjaan",
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: Color(0xFF017964),
            ),
          )),
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
                    Container(
                      height: 40.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xFF017964))),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Color(0xFF017964)),
                              child: Text(
                                'Keranjang',
                                style: theme.textTheme.subtitle1
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .popAndPushNamed(HistoryScreen.ROUTE_NAME);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Text(
                                  'Riwayat',
                                  style: theme.textTheme.subtitle1
                                      ?.copyWith(color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    FutureBuilder(
                        future: _futureDataCarts,
                        builder: (BuildContext context,
                            AsyncSnapshot<ResultModel<List<Cart>>> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.data?.isNotEmpty == true) {
                              List<Cart> carts = snapshot.data!.data!;
                              return Column(
                                children: [...carts.map((e) => itemCard(e))],
                              );
                            } else {
                              String errorTitle =
                                  'Wah, keranjang belanjaanmu kosong';
                              String? errorSubtitle = snapshot.data?.error;
                              return Container(
                                child: ErrorCard(
                                  title: errorTitle,
                                  subtitle: errorSubtitle,
                                  iconData: Icons.shopping_cart_outlined,
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
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 55.0,
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.only(left: screenSize.width * 0.1),
                width: screenSize.width * 0.6,
                height: 55.0,
                decoration:
                    BoxDecoration(color: Color(0xFF017964)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Harga', style: TextStyle(color: Colors.white)),
                    totalHarga == 0
                        ? Text('Rp. 0,-', style: TextStyle(color: Colors.white))
                        : Text(
                            CurrencyTextInputFormatter(
                              locale: 'id',
                              decimalDigits: 0,
                              symbol: 'Rp. ', 
                            ).format(totalHarga.toString()),
                            style: theme.textTheme.subtitle1
                                ?.copyWith(fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                  ],
                )),
            GestureDetector(
                onTap: () {
                  if (totalHarga == 0) {
                  } else {
                    Navigator.of(context).pushNamed(
                      CheckoutScreen.ROUTE_NAME,
                    );
                  }
                },
                child: Container(
                  width: screenSize.width * 0.4,
                  alignment: Alignment.center,
                  decoration: totalHarga == 0
                      ? BoxDecoration(color: Color(0xFFFEC842))
                      : BoxDecoration(color: Color(0xFFFEC842)),
                  child: Text(
                    'Bayar',
                    style: theme.textTheme.subtitle1?.copyWith(
                        color: totalHarga == 0 ? Colors.white54 : Colors.black),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget itemCard(Cart cart) {
    Size screenSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color.fromRGBO(76, 169, 156, 1.0)))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              child: Image.network(
                cart.product.gallery[0].path,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cart.product.nama),
                  Text(
                    cart.product.getTotalPriceFormatted(),
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Color(0xFF017964)),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        margin: EdgeInsets.only(right: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            _deleteShoppingCart(cart.id);
                          },
                          child: Image.asset(
                            'assets/toko/delete.png',
                            height: 20,
                            width: 20.0,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          if (cart.jumlahBarang == 1) {
                            _deleteShoppingCart(cart.id);
                          } else {
                            _putShoppingCart(
                                cart.idBarang, cart.jumlahBarang - 1);
                          }
                        },
                        color: Color.fromRGBO(218, 218, 218, 1.0),
                        textColor: Colors.black,
                        child: Icon(
                          Icons.remove,
                          size: 16,
                        ),
                        height: 20.0,
                        minWidth: 0.0,
                        splashColor: Color(0xFF017964),
                        padding: EdgeInsets.all(0.0),
                        shape: CircleBorder(),
                      ),
                      Container(
                          width: 50.0,
                          margin: EdgeInsets.only(left: 0.0, right: 0.0),
                          padding: EdgeInsets.symmetric(
                              // horizontal: 15.0,
                              vertical: 0.0),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black, width: 1.0))),
                          child: Text(
                            cart.jumlahBarang.toString(),
                            textAlign: TextAlign.center,
                          )),
                      MaterialButton(
                        onPressed: () {
                          _putShoppingCart(
                              cart.idBarang, cart.jumlahBarang + 1);
                        },
                        color: Color.fromRGBO(218, 218, 218, 1.0),
                        textColor: Colors.black,
                        child: Icon(
                          Icons.add,
                          size: 16,
                        ),
                        height: 20.0,
                        minWidth: 20.0,
                        splashColor: Color.fromRGBO(76, 169, 156, 1.0),
                        padding: EdgeInsets.all(0.0),
                        shape: CircleBorder(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
