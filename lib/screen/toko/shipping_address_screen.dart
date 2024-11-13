import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/toko_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko_repository.dart';
import 'package:pensiunku/screen/toko/add_shipping_address_screen.dart';
import 'package:pensiunku/screen/toko/checkout_screen.dart';
import 'package:pensiunku/screen/toko/toko_screen.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/error_card.dart';

class ShippingAddressScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/shipping-address';

  const ShippingAddressScreen({Key? key}) : super(key: key);

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

enum AddressTypes {
  Home,
  Work,
  Other,
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  late Future<ResultModel<List<ShippingAddress>>> _futureData;
  late List<ShippingAddress> shippingAddress;
  ShippingAddress? _selectedShippingAddrees;

  @override
  void initState() {
    super.initState();

    shippingAddress = [];
    _refreshData();
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData =
        TokoRepository().getShippingAddressPreview(token!).then((value) {
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
          shippingAddress = value.data!;
        });
      }
      return value;
    });
  }

  setAddress(ShippingAddress shippingAddress) {
    TokoRepository().setShippingAddressFromLocal(shippingAddress).then((value) {
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
    });
  }

  void showDeleteDialog(int shippingAddressId, BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Batal"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Ya"),
      onPressed: () {
        String? token = SharedPreferencesUtil()
            .sharedPreferences
            .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

        TokoRepository()
            .deleteShippingAddress(token!, shippingAddressId)
            .then((value) {
          log(value.toString());
          if (value.error != null) {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text(value.error.toString(),
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      elevation: 24.0,
                    ));
          } else {
            //jika sama dengan local maka hapus
            TokoRepository().deleteShippingAddressFromLocal(shippingAddressId);
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text('Alamat pengiriman berhasil dihapus',
                          style: TextStyle(color: Colors.black)),
                      backgroundColor: Colors.white,
                      elevation: 24.0,
                    ));
            setState(() {
              _refreshData();
            });
          }
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Apakah benar Anda akan menghapus alamat ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    Color dividerColor = Color.fromRGBO(236, 236, 236, 1.0);
    Color iconColor = Color.fromARGB(76, 167, 157, 1);
    Color fontColor = Color.fromRGBO(0, 186, 175, 1.0);
    double carouselWidth = screenSize.width * 0.9;
    double cardWidth = carouselWidth - 16.0;
    double promoCardHeight = cardWidth * (746 / 1697) + 24.0;
    double promoCarouselHeight = promoCardHeight + 16.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
          title: Text(
            "Alamat Pengiriman",
            style: theme.textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.secondaryHeaderColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(AddShippingAddressScreen.ROUTE_NAME,
                  arguments: AddShippingAddressArguments(shippingAddressId: 0))
              .then((value) {
            setState(() {
              _refreshData();
            });
          });
        },
      ),
      bottomNavigationBar: FutureBuilder(
        future: _futureData,
        builder: ((context,
            AsyncSnapshot<ResultModel<List<ShippingAddress>>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.data?.isNotEmpty == true) {
              return Container(
                height: 55.0,
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          setAddress(_selectedShippingAddrees!);
                          Navigator.pop(context, _selectedShippingAddrees);
                        },
                        child: Container(
                          width: screenSize.width,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.red),
                          child: Text(
                            'Pilih Alamat',
                            style: theme.textTheme.subtitle1
                                ?.copyWith(color: Colors.white),
                          ),
                        ))
                  ],
                ),
              );
            } else {
              return Container(
                height: 55.0,
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            CheckoutScreen.ROUTE_NAME,
                          );
                        },
                        child: Container(
                          width: screenSize.width,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.red),
                          child: Text(
                            'Tambah Alamat',
                            style: theme.textTheme.subtitle1
                                ?.copyWith(color: Colors.white),
                          ),
                        ))
                  ],
                ),
              );
            }
          } else {
            return Container();
          }
        }),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshData();
        },
        child: ListView(
          children: [
            ListTile(
              title: Text("Dikirimkan ke"),
            ),
            Divider(
              height: 1,
            ),
            FutureBuilder(
              future: _futureData,
              builder: (BuildContext context,
                  AsyncSnapshot<ResultModel<List<ShippingAddress>>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data?.data?.isNotEmpty == true) {
                    List<ShippingAddress> shippingAddresses =
                        snapshot.data!.data!;
                    return Column(
                      children: [
                        ...shippingAddresses.map((e) => singleDeliveryItem(e)),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    );
                  } else {
                    String errorTitle =
                        'Belum ada data alamat pengiriman.\nSilahkan tambahkan data alamat pengiriman';
                    String? errorSubtitle = snapshot.data?.error;
                    return Container(
                      child: ErrorCard(
                        title: errorTitle,
                        subtitle: errorSubtitle,
                        iconData: Icons.info_outline,
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
            )
          ],
        ),
      ),
    );
  }

  Widget singleDeliveryItem(ShippingAddress address) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: [
        RadioListTile<ShippingAddress>(
          onChanged: (value) {
            setState(() {
              _selectedShippingAddrees = value;
            });
          },
          groupValue: _selectedShippingAddrees,
          value: address,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(address.address!),
              address.isPrimary == 1
                  ? Container(
                      width: 60,
                      padding: EdgeInsets.all(1),
                      height: 20,
                      decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address.subdistrict!),
              Text(address.city!),
              Text(address.province!),
              Text('Kodepos: ' + address.postalCode!),
              Text('Telp: ${address.mobile}'),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AddShippingAddressScreen.ROUTE_NAME,
                                arguments: AddShippingAddressArguments(
                                    shippingAddressId: address.id!))
                            .then((value) {
                          setState(() {
                            _refreshData();
                          });
                        });
                      },
                      child: Icon(Icons.edit),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      onTap: () {
                        showDeleteDialog(address.id!, context);
                      },
                      child: Icon(Icons.delete),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Divider(
          height: 35,
        ),
      ],
    );
  }
}
