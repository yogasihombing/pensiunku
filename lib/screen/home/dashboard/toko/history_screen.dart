import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/config.dart';
import 'package:pensiunku/model/toko/toko-order_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart' as TokoMod;
import 'package:pensiunku/repository/toko/toko-order_repository.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/detail-pesanan_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/keranjang_screen.dart';
import 'package:pensiunku/screen/home/dashboard/toko/penilaian-produk_screen.dart';
import 'package:pensiunku/screen/web_view/web_view_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/url_util.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// import '../../model/toko_model.dart';


class HistoryScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/history';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<ResultModel<List<OrderModel>>>? _futureData;
  final List<Widget> toggleButtonPosting = [Text('Keranjang'), Text('Riwayat')];
  late List<TokoMod.Cart> carts;
  // kode status
  // 1. Dibatalkan
  // 2. Kadaluarsa
  // 3. Menunggu Pembayaran ==> Menunggu konfirmasi pembayaran
  // 4. Menunggu Konfirmasi ==> Pembayaran Berhasil dilakukan dan Order akan diproses oleh penjual
  // 5. Dikemas
  // 6. Dikirim
  // 7. Selesai

  final List<bool> toggleButtonPostingSelected = [false, true];

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    return _futureData =
        TokoOrderRepository().getAllOrderHistory(token!).then((value) {
      setState(() {
        carts = [];
      });
      return value;
    });
  }

  _updateStatusOrder(
      int id, String status, DateTime? tanggalTerima, String? statusMessage) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    TokoOrderRepository()
        .updateStatusOrder(token!, id, status, tanggalTerima, statusMessage);
  }

  _postToShoppingCart(int idBarang, int amount) {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    TokoMod.PushToShoppingCart pushToShoppingCart =
        TokoMod.PushToShoppingCart(id: idBarang, stok: amount);

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
          .putToShoppingCart(token!,
              TokoMod.PushToShoppingCart(id: idBarang, stok: jumlahBarang))
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
            // _refreshData();
          });
        }
        return value;
      });
    } else {
      //masukkan baru
      TokoRepository()
          .postToShoppingCart(token!, pushToShoppingCart)
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
            // _refreshData();
          });
        }
        return value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // font style
    TextStyle blackTextStyle = TextStyle(color: Colors.black);
    TextStyle whiteTextStyle = TextStyle(color: Colors.white);
    TextStyle greenTextTyle =
        TextStyle(color: Color(0xFF017964));
    TextStyle greyTextStyle = TextStyle(
      color: Color.fromRGBO(149, 149, 149, 1.0),
    );

    // color style
    Color greenColor = Color(0xFF017964);
    Color greyColor = Color.fromRGBO(149, 149, 149, 1.0);

    Future<void> _showMyDialog({
      String title = '',
      String subTitle = '',
      bool isRating = false,
      required OrderModel order,
      // required Product product,
    }) async {
      Alert(
          context: context,
          style: AlertStyle(
            alertPadding: EdgeInsets.all(8),
            titleStyle: greenTextTyle.copyWith(
                fontSize: 20, fontWeight: FontWeight.w600),
            buttonAreaPadding: EdgeInsets.zero,
          ),
          title: title,
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              subTitle,
              style: blackTextStyle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          buttons: [
            DialogButton(
              radius: BorderRadius.zero,
              color: Colors.transparent,
              child: Text(
                'BATAL',
                style: greenTextTyle,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            DialogButton(
              radius: BorderRadius.zero,
              color: Colors.transparent,
              child: Text(
                'KONFIRMASI',
                style: greenTextTyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                _updateStatusOrder(
                    order.id!, '7', DateTime.now(), 'Telah Diterima');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPesanan(
                      order: order,
                      status: '7',
                    ),
                  ),
                ).whenComplete(() => _refreshData());
              },
            ),
          ]).show();
    }

    bottomSheetModal(
        List<OrderDetailsModel> product, List<ReviewProduct> reviews) {
      List<OrderDetailsModel> filteredProduct = [];
      if (reviews.length > 0) {
        product.asMap().forEach((index, prod) {
          bool reviewed = false;
          reviews.asMap().forEach((index, rev) {
            if (prod.id_produk == rev.idBarang.toString()) {
              reviewed = true;
            }
          });
          if (reviewed == false) {
            filteredProduct.add(prod);
          }
        });
      } else {
        filteredProduct = product;
      }
      Widget buildProdukCard(ProductModel product, int orderId) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PenilaianProduk(
                  product: product,
                  orderId: orderId,
                ),
              ),
            ).then((value) => _refreshData());
          },
          child: Container(
            width: double.infinity,
            height: 100,
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 5,
                  ),
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    padding: EdgeInsets.all(8),
                    child: CachedNetworkImage(
                      imageUrl: product.gallery![0].path!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    product.nama!,
                    style: blackTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                    ),
                    child: Text(
                      'Beri Penilaian',
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: filteredProduct
                      .map(
                        (itemProduct) => buildProdukCard(
                          itemProduct.product!,
                          int.parse(itemProduct.id_order!),
                        ),
                      )
                      .toList(),
                )
              ],
            ),
          );
        },
      );
    }

    Widget toggleButton() {
      return Container(
        height: 40.0,
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF017964))),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .popAndPushNamed(KeranjangScreen.ROUTE_NAME);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Text(
                    'Keranjang',
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: Color(0xFF017964)),
                  child: Text(
                    'Riwayat',
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget cardBarang() {
      Widget buildItem(OrderModel item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: greyColor),
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  color: item.status == "3"
                      ? Colors.red
                      : item.status == "5"
                          ? Colors.amber[900]
                          : item.status == "6"
                              ? Colors.amber[900]
                              : (item.status == "1" || item.status == "2")
                                  ? Colors.red
                                  : item.status == "4"
                                      ? Colors.amber[900]
                                      : Colors.grey,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    item.CodeToText(item.status!),
                    style: whiteTextStyle,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 85,
                      width: 85,
                      child: CachedNetworkImage(
                        imageUrl:
                            item.order_details![0].product!.gallery![0].path!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.order_details![0].product!.nama!,
                            style: blackTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${item.order_details![0].jumlah_barang} barang",
                            // 'Keterangan',
                            style: greyTextStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            NumberFormat.currency(
                                    decimalDigits: 0,
                                    locale: 'id',
                                    symbol: 'Rp. ')
                                .format(item.harga_total),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: greenTextTyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  (item.status == "7" &&
                          item.reviewProduct!.length ==
                              item.order_details!.length)
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: RatingBar.builder(
                            direction: Axis.horizontal,
                            initialRating: double.parse(
                                item.reviewProduct![0].star.toString()),
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            ignoreGestures: true,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                        )
                      : Container(),
                  Spacer(),
                  item.status == "1" || item.status == "4" || item.status == "2"
                      ? Container()
                      : item.status == '5'
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  UrlUtil.launchURL(
                                      'https://wa.me/+6287785833344?text=Hallo%20admin%20pensiunku,%20saya%20mau%20membatalkan%20pesanan%20dengan%20kode%20transaksi%20${item.id_transaksi}');
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: greyColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                child: Text(
                                  'Batalkan Pesanan',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (item.status == "6") {
                                    _showMyDialog(
                                      title: 'Konfirmasi Pesanan',
                                      subTitle:
                                          'Saya telah memastikan bahwa produk saya telah diterima dan tidak ada masalah',
                                      isRating: false,
                                      order: item,
                                    );
                                  }
                                  if (item.status == "3") {
                                    String snapToken = item.snapToken!;
                                    String url = '$midtransURL$snapToken';
                                    print('url:' + url);
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamed(
                                      WebViewScreen.ROUTE_NAME,
                                      arguments: WebViewScreenArguments(
                                        initialUrl: url,
                                      ),
                                    );
                                  }
                                  if (item.status == '7' &&
                                      item.reviewProduct!.length !=
                                          item.order_details!.length) {
                                    bottomSheetModal(item.order_details!,
                                        item.reviewProduct!);
                                  }
                                  if (item.status == '7' &&
                                      item.reviewProduct!.length ==
                                          item.order_details!.length) {
                                    item.order_details!
                                        .asMap()
                                        .forEach((index, element) {
                                      _postToShoppingCart(
                                          int.parse(element.id_produk!),
                                          element.jumlah_barang!);
                                    });
                                    Navigator.of(context).pushReplacementNamed(
                                        KeranjangScreen.ROUTE_NAME);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: greenColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                child: Text(
                                  item.status == "3"
                                      ? 'Bayar Sekarang'
                                      : item.status == "6"
                                          ? 'Pesanan Diterima'
                                          : (item.status == "7" &&
                                                  item.reviewProduct!.length !=
                                                      item.order_details!
                                                          .length)
                                              ? 'Beri Penilaian'
                                              : 'Beli Lagi',
                                  style: whiteTextStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                ],
              )
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: FutureBuilder<ResultModel<List<OrderModel>>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<OrderModel> data = snapshot.data!.data!;
              data.sort((a, b) => b.created_at!.compareTo(a.created_at!));
              if (data.isNotEmpty) {
                return Column(
                  children: data
                      .map((item) => InkWell(
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPesanan(
                                    order: item,
                                    // status: item.CodeToText(item.status!),
                                    status: item.status!,
                                  ),
                                ),
                              ),
                          child: buildItem(item)))
                      .toList(),
                );
              } else {
                return Container(
                  child: Center(
                    child: Text('Riwayat belanja kosong!'),
                  ),
                );
              }
            } else {
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                ),
              );
            }
          },
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Color(0xFF017964),
          ),
          title: Text(
            "Riwayat Belanja",
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: Color(0xFF017964),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshData(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                toggleButton(),
                cardBarang(),
              ],
            ),
          ),
        ));
  }
}
