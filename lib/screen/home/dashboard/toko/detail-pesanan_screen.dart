import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/toko/toko-order_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko/toko-order_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/penilaian-produk_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';


class DetailPesanan extends StatefulWidget {
  final OrderModel order;
  final String status;
  const DetailPesanan({
    Key? key,
    required this.order,
    required this.status,
  }) : super(key: key);

  @override
  State<DetailPesanan> createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  Future<ResultModel<List<OrderModel>>>? _futureData;
  ShippingAddressModel? shippingAddressModel;

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    Future.delayed(Duration(seconds: 2));

    TokoOrderRepository()
        .getShippingAddressPreviewById(
            token!, widget.order.shippingAddress!.id!)
        .then(
      (value) {
        setState(() {
          print('shippingAddressModel' + shippingAddressModel.toString());
          shippingAddressModel = value.data!;
        });
      },
    );

    return _futureData = TokoOrderRepository()
        .getOrderHistoryById(token, widget.order.id!)
        .then((value) {
      setState(() {});
      return value;
    });
  }

  @override
  void initState() {
    super.initState();
    shippingAddressModel = null;
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // font style
    TextStyle blackTextStyle = TextStyle(color: Colors.black);
    TextStyle greyTextStyle = TextStyle(
      color: Color.fromRGBO(149, 149, 149, 1.0),
    );

    // color style
    Color greenColor = Color.fromRGBO(1, 169, 159, 1.0);

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
      Widget buildProdukCard(
        ProductModel product,
        int orderId,
      ) {
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

    Widget statusPesanan(OrderModel detailOrder) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detailOrder.CodeToText(widget.status),
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.order.id_transaksi!,
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Pembelian',
                ),
                Text(
                  DateFormat('dd MMMM yyyy,')
                      .add_Hm()
                      .format(widget.order.created_at!),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget detailProduk() {
      Widget produk(ProductModel product, int jumlah_barang) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: CachedNetworkImage(
                    imageUrl: product.gallery![0].path!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama!,
                      style: greyTextStyle.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      NumberFormat.currency(
                              decimalDigits: 0, locale: 'id', symbol: 'Rp. ')
                          .format(product.harga),
                      style: greyTextStyle.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'x$jumlah_barang',
                      style: greyTextStyle.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        decoration: BoxDecoration(color: Colors.white),
        margin: EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Detail Produk',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Column(
            children: widget.order.order_details!
                .map((item) => produk(item.product!, item.jumlah_barang!))
                .toList(),
          )
        ]),
      );
    }

    Widget infoPengiriman() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Info Pengiriman',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            //Kurir
            Row(
              children: [
                Container(
                  width: 100,
                  child: Text(
                    'Kurir',
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.order.kurir!,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            //Nomor Resi
            Row(
              children: [
                InkWell(
                  onTap: () {
                    if (widget.order.nomorResiPengiriman == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor resi tidak tersedia'),
                        ),
                      );
                    } else {
                      Clipboard.setData(ClipboardData(
                              text: widget.order.nomorResiPengiriman!))
                          .then(
                        (value) {
                          return ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nomor resi berhasil di salin'),
                            ),
                          );
                        },
                      );
                    }
                  },
                  hoverColor: Colors.black12,
                  child: Container(
                    width: 100,
                    child: Row(
                      children: [
                        Text(
                          'No Resi',
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(
                          Icons.copy,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.order.nomorResiPengiriman != null
                        ? widget.order.nomorResiPengiriman!
                        : '-',
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            //Alamat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  child: Text(
                    'Alamat',
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.user!.username!,
                        style: blackTextStyle.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        widget.order.user!.phone,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        shippingAddressModel == null
                            ? ""
                            : "${shippingAddressModel!.address}, ${shippingAddressModel!.subdistrict}, ${shippingAddressModel!.city}, ${shippingAddressModel!.province}, ${shippingAddressModel!.postal_code}",
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Container(
                  width: 100,
                  child: Text(
                    'Keterangan',
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.order.status_message!,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget rincianPembayaran(OrderModel detailOrder) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rincian Pembayaran',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metode Pembayaran',
                ),
                Text(
                  widget.order.metode_pembayaran!,
                ),
              ],
            ),
            Divider(
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga',
                ),
                Text(
                  NumberFormat.currency(
                          decimalDigits: 0, locale: 'id', symbol: 'Rp. ')
                      .format(widget.order.harga_total! -
                          widget.order.ongkosKirim!),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Ongkos Kirim',
                ),
                Text(
                  NumberFormat.currency(
                          decimalDigits: 0, locale: 'id', symbol: 'Rp. ')
                      .format(widget.order.ongkosKirim),
                ),
              ],
            ),
            Divider(
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Belanja',
                  style: blackTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  NumberFormat.currency(
                          decimalDigits: 0, locale: 'id', symbol: 'Rp. ')
                      .format(widget.order.harga_total!),
                  style: blackTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            (widget.status == '7' &&
                    detailOrder.reviewProduct!.length !=
                        detailOrder.order_details!.length)
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => bottomSheetModal(
                          detailOrder.order_details!,
                          detailOrder.reviewProduct!),
                      child: Text('Beri Penilaian'),
                      style: ElevatedButton.styleFrom(
                        primary: greenColor,
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
        title: Text(
          "Rincian Pesanan",
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<ResultModel<List<OrderModel>>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<OrderModel> data = snapshot.data!.data!;
              data.sort((a, b) => b.created_at!.compareTo(a.created_at!));
              return Column(
                children: [
                  statusPesanan(data[0]),
                  detailProduk(),
                  infoPengiriman(),
                  rincianPembayaran(data[0]),
                ],
              );
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
      ),
    );
  }
}
