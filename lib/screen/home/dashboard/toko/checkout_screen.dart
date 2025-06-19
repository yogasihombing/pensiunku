import 'dart:developer';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:pensiunku/config.dart';
import 'package:pensiunku/model/toko/ongkir_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/toko/toko-order_repository.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/expedition_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/history_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/shipping_address_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';
// import 'package:midtrans_sdk/midtrans_sdk.dart';

class CheckoutScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/checkout';

  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<ResultModel<List<Cart>>> _futureDataCarts;
  late Future<ResultModel<ShippingAddress>> _futureDataShippingAddress;
  late List<Cart>? listCart;
  late ShippingAddress? selectedShippingAddress;
  late int totalHarga = 0;
  late int weight = 0;
  late int? destination;
  String origin = "455";
  List<String> couriers = ["tiki", "jne", "pos"];
  late ExpedisiModel? selectedExpedisiModel;
  late PostExpeditionModel? postExpeditionModel;
  // MidtransSDK? _midtrans;

  @override
  void initState() {
    super.initState();
    // initSDK();

    _refreshData();
    selectedShippingAddress = null;
    selectedExpedisiModel = null;
    listCart = [];
  }

  _refreshData() {
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
          listCart = value.data!;
          totalHarga = 0;
          value.data!.asMap().forEach((key, cart) {
            totalHarga = totalHarga + cart.totalPrice;
          });
          weight = 0;
          value.data!.asMap().forEach((key, cart) {
            weight = weight + (cart.product.berat * cart.jumlahBarang);
          });
        });
      }
      return value;
    });

    return _futureDataShippingAddress =
        TokoRepository().getShippingAddressFromLocal().then((value) {
      if (value.error == null) {
        setState(() {
          selectedShippingAddress = value.data;
          destination = selectedShippingAddress!.kodeongkir;
        });
      }
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    Color dividerColor = Color.fromRGBO(236, 236, 236, 1.0);
    Color fontColor = Color.fromRGBO(0, 186, 175, 1.0);
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
            "Checkout",
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
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Image.asset(
                              'assets/toko/alamat.png',
                              width: 24.0,
                              height: 24.0,
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                selectedShippingAddress != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Alamat Pengiriman'),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(selectedShippingAddress!
                                              .address!),
                                          Text(selectedShippingAddress!
                                              .subdistrict!),
                                          Text(selectedShippingAddress!.city!),
                                          Text(selectedShippingAddress!
                                              .province!),
                                          Text('Kodepos: ' +
                                              selectedShippingAddress!
                                                  .postalCode!),
                                          Text('Telp:' +
                                              selectedShippingAddress!.mobile!)
                                        ],
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          _navigateToShippingAddress(context);
                                          // Navigator.of(context)
                                          //     .pushNamed(ShippingAddressScreen
                                          //         .ROUTE_NAME)
                                          //     .then((value) {
                                          //   _refreshData();
                                          // });
                                        },
                                        child: Container(
                                          // alignment: Alignment.center,
                                          child:
                                              Text('Pilih alamat pengiriman'),
                                        )),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // SizedBox(
                                //   height: 50.0,
                                // ),
                                IconButton(
                                    onPressed: () {
                                      _navigateToShippingAddress(context);
                                      // Navigator.of(context)
                                      //     .pushNamed(
                                      //         ShippingAddressScreen.ROUTE_NAME)
                                      //     .then((value) {
                                      //   _refreshData();
                                      // });
                                    },
                                    icon: Icon(
                                      Icons.navigate_next,
                                      color: Color.fromRGBO(149, 149, 149, 1.0),
                                    )),
                              ],
                            ),
                          )
                        ]),
                    Divider(
                      thickness: 8.0,
                      color: dividerColor,
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
                                  'Tidak dapat menampilkan daftar barang dalam cart';
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
                        }),
                    Divider(
                      thickness: 8.0,
                      color: Colors.white,
                    ),
                    // Opsi Pengiriman
                    GestureDetector(
                      onTap: () {
                        if (destination != null) {
                          _navigateToExpedition(
                              context, destination!, origin, weight);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opsi Pengiriman',
                              style: theme.textTheme.subtitle1?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: fontColor),
                            ),
                            Divider(
                              thickness: 2.0,
                              color: Color.fromRGBO(230, 236, 235, 1.0),
                            ),
                            selectedExpedisiModel != null
                                ? pengiriman(selectedExpedisiModel!)
                                : Container(
                                    padding: EdgeInsets.only(left: 25),
                                    height: 40.0,
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child:
                                                Text('Pilih opsi pengiriman')),
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.navigate_next,
                                              color: Color.fromRGBO(
                                                  149, 149, 149, 1.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 8.0,
                      color: dividerColor,
                    ),
                    // Metode Pembayaran
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/toko/rincian_pembayaran.png',
                            width: 24.0,
                            height: 24.0,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Rincian Pembayaran',
                            style: theme.textTheme.subtitle1?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Spacer(),
                          Icon(
                            Icons.navigate_next,
                            color: Color.fromRGBO(149, 149, 149, 1.0),
                          )
                        ],
                      ),
                    ),
                    ...listCart!.map((cart) {
                      return Container(
                        width: screenSize.width - 10.0,
                        padding: EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: Text(
                                cart.product.nama,
                                maxLines: 2,
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(CurrencyTextInputFormatter(
                                  locale: 'id',
                                  decimalDigits: 0,
                                  symbol: 'Rp. ',
                                ).format(cart.totalPrice.toString())),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    selectedExpedisiModel != null
                        ? Container(
                            width: screenSize.width - 10.0,
                            padding: EdgeInsets.only(
                                left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text('Ongkos kirim'),
                                ),
                                Spacer(),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(CurrencyTextInputFormatter(
                                      locale: 'id',
                                      decimalDigits: 0,
                                      symbol: 'Rp. ',
                                    ).format(selectedExpedisiModel!.cost
                                        .toString())),
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      width: screenSize.width - 10.0,
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Total harga',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                CurrencyTextInputFormatter(
                                  locale: 'id',
                                  decimalDigits: 0,
                                  symbol: 'Rp. ',
                                ).format(totalHarga.toString()),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
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
                                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          )
                  ],
                )),
            GestureDetector(
                onTap: () {
                  _navigateToPayment(
                      context,
                      selectedShippingAddress!.id!,
                      selectedExpedisiModel!.cost,
                      destination!,
                      selectedExpedisiModel!.name);
                },
                child: Container(
                  width: screenSize.width * 0.4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0xFFFFC950)),
                  child: Text(
                    'Buat Pesanan',
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Colors.black),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget itemCard(Cart cart) {
    ThemeData theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color.fromRGBO(76, 169, 156, 1.0)))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                  Text(
                    cart.product.nama,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    cart.product.getTotalPriceFormatted(),
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Color.fromRGBO(76, 167, 157, 1.0)),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('x' + cart.jumlahBarang.toString())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pengiriman(ExpedisiModel expedisiModel) {
    ThemeData theme = Theme.of(context);
    Color fontColor = Color.fromRGBO(0, 186, 175, 1.0);

    return Padding(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0, left: 25),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  expedisiModel.name,
                  style:
                      theme.textTheme.subtitle1?.copyWith(color: Colors.black),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Jenis: ${expedisiModel.service}',
                  style: theme.textTheme.subtitle1?.copyWith(color: fontColor),
                ),
                Text(
                  'Deskripsi: ${expedisiModel.description}',
                  style: theme.textTheme.subtitle1?.copyWith(color: fontColor),
                ),
                Text(
                  'Estimasi: ${expedisiModel.estimationDate} hari',
                  style: theme.textTheme.subtitle1?.copyWith(color: fontColor),
                ),
                SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(CurrencyTextInputFormatter(
                    locale: 'id',
                    decimalDigits: 0,
                    symbol: 'Rp. ',
                  ).format(expedisiModel.cost.toString())))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.navigate_next,
                color: Color.fromRGBO(149, 149, 149, 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToExpedition(
      BuildContext context, int destination, String origin, int weight) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExpeditionScreen(
                destination: destination.toString(),
                origin: origin,
                weight: weight)));

    setState(() {
      selectedExpedisiModel = result;
      totalHarga = 0;
      listCart!.asMap().forEach((key, cart) {
        totalHarga = totalHarga + cart.totalPrice;
      });
      totalHarga = totalHarga + selectedExpedisiModel!.cost;
    });
  }

  Future<void> _navigateToShippingAddress(BuildContext context) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ShippingAddressScreen()));

    setState(() {
      log(result.toString());
      selectedShippingAddress = result;
      destination = selectedShippingAddress!.kodeongkir;
      log('destinnation:' + destination.toString());
      selectedExpedisiModel = null;
    });
  }

  Future<void> _navigateToPayment(BuildContext context, int idAlamat,
      int ongkir, int destination, String kurir) async {
    CheckoutModel checkoutModel = CheckoutModel(
        idAlamat: idAlamat,
        ongkir: ongkir,
        destination: destination,
        kurir: kurir);

    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    TokoOrderRepository().checkoutCart(token!, checkoutModel).then((value) {
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
        TokoOrderRepository()
            .getOrderHistoryById(token, value.data!.id!)
            .then((valueHistory) {
          if (valueHistory.error != null) {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text(valueHistory.error.toString(),
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      elevation: 24.0,
                    ));
          } else {
            String snapToken = valueHistory.data![0].snapToken!;
            // String url = '$apiHost/api/payments/$snapToken';
            String url = '$midtransURL$snapToken';
            print('url:' + url);
            Navigator.of(
              context,
              rootNavigator: true,
            )
                .pushNamed(
              WebViewScreen.ROUTE_NAME,
              arguments: WebViewScreenArguments(
                initialUrl: url,
              ),
            )
                .then((value) {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed(HistoryScreen.ROUTE_NAME);
            });
          }
        });
      }
    });
  }
}
