import 'package:flutter/material.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/toko/toko_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/toko/toko_repository.dart';
import 'package:pensiunku/screen/home/dashboard/toko/add_shipping_address_controller.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/custom_select_field.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/dummy_custom_select_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/error_card.dart';

class AddShippingAddressArguments {
  final int shippingAddressId;

  AddShippingAddressArguments({required this.shippingAddressId});
}

class AddShippingAddressScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/toko/add-shipping-address';
  final int shippingAddressId;

  AddShippingAddressScreen({Key? key, required this.shippingAddressId})
      : super(key: key);

  @override
  _AddShippingAddressScreenState createState() =>
      _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  AddShippingAddressController _controller = AddShippingAddressController();
  late Future<ResultModel<ShippingAddress>> _futureData;
  bool _isLoading = false;

  late TextEditingController _inputPhoneController;
  String _inputPhone = '';

  late TextEditingController _inputAddressController;
  String _inputAddress = '';

  OptionModel _inputProvinsi = OptionModel(id: 0, text: '');
  OptionModel _inputKabupaten = OptionModel(id: 0, text: '');
  OptionModel _inputKecamatan = OptionModel(id: 0, text: '');
  OptionModel _inputKelurahan = OptionModel(id: 0, text: '');
  OptionModel _inputKodePos = OptionModel(id: 0, text: '');
  OptionModel _inputPrimaryAddress = OptionModel(id: 1, text: 'Alamat utama');
  late List<OptionModel> listKabupaten = [];
  late List<OptionModel> listKecamatan = [];
  late List<OptionModel> listKelurahan = [];
  late List<OptionModel> listKodePos = [];
  List<OptionModel> listPrimaryAddress = [
    OptionModel(id: 1, text: 'Alamat utama'),
    OptionModel(id: 0, text: 'Bukan alamat utama')
  ];
  int userId = 0;
  int shippingId = 0;

  @override
  void initState() {
    super.initState();

    _refreshData();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inputPhoneController.dispose();
    _inputAddressController.dispose();
    super.dispose();
  }

  /// Save account information
  _saveAccountInfo() {
    if (_controller.isAllInputValid(
        _inputAddress,
        _inputProvinsi.text,
        _inputKabupaten.text,
        _inputKecamatan.text,
        _inputKelurahan.text,
        _inputPhone)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    String? _inputKabupatenName;
    if (_inputKabupaten.id != 0) {
      _inputKabupatenName = _inputKabupaten.text;
    }

    if (widget.shippingAddressId == 0) {
      //add new address
      late ShippingAddress shippingAddress;
      if (_inputPrimaryAddress.id == 1) {
        shippingAddress = ShippingAddress(
            address: _inputAddress,
            province: _inputProvinsi.id.toString(),
            city: _inputKabupaten.id.toString(),
            subdistrict:
                _inputKecamatan.id.toString() + _inputKelurahan.id.toString(),
            postalCode: _inputKodePos.id.toString(),
            mobile: _inputPhone,
            isPrimary: _inputPrimaryAddress.id);
      } else {
        shippingAddress = ShippingAddress(
            address: _inputAddress,
            province: _inputProvinsi.id.toString(),
            city: _inputKabupaten.id.toString(),
            subdistrict:
                _inputKecamatan.id.toString() + _inputKelurahan.id.toString(),
            postalCode: _inputKodePos.id.toString(),
            mobile: _inputPhone);
      }

      print(shippingAddress);

      TokoRepository()
          .postShippingAddress(token!, shippingAddress)
          .then((result) {
        setState(() {
          _isLoading = false;
        });
        if (result.isSuccess) {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text('Alamat pengiriman berhasil ditambahkan',
                        style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                    elevation: 24.0,
                  ));
        } else {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(
                        result.error ?? 'Gagal menambahkan alamat pengiriman',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                    elevation: 24.0,
                  ));
        }
      });
    } else {
      ShippingAddress shippingAddress = ShippingAddress(
          address: _inputAddress,
          province: _inputProvinsi.id.toString(),
          city: _inputKabupaten.id.toString(),
          subdistrict:
              _inputKecamatan.id.toString() + _inputKelurahan.id.toString(),
          postalCode: _inputKodePos.id.toString(),
          mobile: _inputPhone,
          isPrimary: _inputPrimaryAddress.id,
          idUser: userId,
          id: shippingId);

      print(shippingAddress.toString());

      TokoRepository()
          .putShippingAddress(token!, shippingAddress)
          .then((result) {
        setState(() {
          _isLoading = false;
        });
        if (result.isSuccess) {
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text('Alamat pengiriman berhasil diubah',
                        style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                    elevation: 24.0,
                  ));
        } else {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(
                        result.error ?? 'Gagal menambahkan alamat pengiriman',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                    elevation: 24.0,
                  ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(
          context,
          widget.shippingAddressId == 0
              ? 'Tambah Alamat Pengiriman'
              : 'Edit Alamat Pengiriman',
          2, (newIndex) {
        Navigator.of(context).pop(newIndex);
      }, () {
        Navigator.of(context).pop();
      }, useNotificationIcon: false),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () {
              return _refreshData();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height,
                  ),
                  FutureBuilder(
                    future: _futureData,
                    builder: (BuildContext context,
                        AsyncSnapshot<ResultModel<ShippingAddress>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data != null) {
                          ShippingAddress data = snapshot.data!.data!;
                          return _buildBody(context, theme, data);
                        } else {
                          String errorTitle =
                              'Tidak dapat menampilkan informasi alamat pengiriman';
                          String? errorSubtitle = snapshot.data?.error;
                          return Column(
                            children: [
                              SizedBox(height: 16),
                              ErrorCard(
                                title: errorTitle,
                                subtitle: errorSubtitle,
                                iconData: Icons.warning_rounded,
                              ),
                            ],
                          );
                        }
                      } else {
                        return Column(
                          children: [
                            SizedBox(height: 16),
                            Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    return _futureData = TokoRepository()
        .getShippingAddressById(token!, widget.shippingAddressId)
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
      }
      setState(() {
        _inputPhone = value.data?.mobile ?? '';
        _inputPhoneController = TextEditingController(text: _inputPhone)
          ..addListener(() {
            setState(() {
              _inputPhone = _inputPhoneController.text;
            });
          });
        _inputAddress = value.data?.address ?? '';
        _inputAddressController = TextEditingController(text: _inputAddress)
          ..addListener(() {
            setState(() {
              _inputAddress = _inputAddressController.text;
            });
          });
        if (value.data?.province != null) {
          _inputProvinsi = LocationRepository.getProvinceById(
              int.parse(value.data!.province!));
        }
        if (value.data?.city != null) {
          _setInputKabupaten(value.data!.city!);
        }
        if (value.data?.subdistrict != null) {
          _setInputKecamatan(value.data!.subdistrict!.substring(0, 6));
        }
        if (value.data?.subdistrict != null) {
          _setInputKelurahan(value.data!.subdistrict!);
        }
        if (value.data?.postalCode != null) {
          _setInputKodePos(value.data!.postalCode!);
        }
        if (value.data?.isPrimary != null) {
          _setInputPrimaryAddress(value.data!.isPrimary!);
        }
        if (widget.shippingAddressId != 0) {
          userId = value.data!.idUser!;
          shippingId = value.data!.id!;
        }
      });
      return value;
    });
  }

  Widget _buildBody(
      BuildContext context, ThemeData theme, ShippingAddress data) {
    String? inputAddressError = _controller.getInputAddressError(_inputAddress);
    String? inputPhoneError = _controller.getInputPhoneError(_inputPhone);
    String? inputProvinceError =
        _controller.getInputProvinceError(_inputProvinsi.text);
    String? inputKabupatenError =
        _controller.getInputKabupatenError(_inputKabupaten.text);
    String? inputKecamatanError =
        _controller.getInputKecamatanError(_inputKecamatan.text);
    String? inputKelurahanError =
        _controller.getInputKelurahanError(_inputKelurahan.text);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomTextField(
            controller: _inputAddressController,
            labelText: '',
            hintText: 'Alamat',
            keyboardType: TextInputType.multiline,
            enabled: !_isLoading,
            minLines: 2,
            maxLines: 5,
            borderRadius: 36.0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            fillColor: Color(0xfff7f7f7),
            errorText: inputAddressError,
          ),
          SizedBox(height: 12.0),
          CustomSelectField(
            labelText: 'Provinsi Tempat Tinggal',
            searchLabelText: 'Cari Provinsi',
            currentOption: _inputProvinsi,
            options: LocationRepository.getProvinces(),
            enabled: !_isLoading,
            onChanged: (OptionModel newProvince) {
              _getKabupatenList(newProvince.id.toString());
              setState(() {
                _inputProvinsi = newProvince;
                _inputKabupaten = OptionModel(id: 0, text: '');
                _inputKecamatan = OptionModel(id: 0, text: '');
                _inputKelurahan = OptionModel(id: 0, text: '');
                _inputKodePos = OptionModel(id: 0, text: '');
              });
            },
            useLabel: false,
            buttonType: 'button_text_field',
            hintText: 'Provinsi Tempat Tinggal',
            borderRadius: 36.0,
            fillColor: Color(0xfff7f7f7),
            errorText: inputProvinceError,
          ),
          SizedBox(height: 12.0),
          _inputProvinsi.id != 0
              ? CustomSelectField(
                  labelText: 'Kabupaten/Kota',
                  searchLabelText: 'Cari Kabupaten/Kota',
                  currentOption: _inputKabupaten,
                  options: listKabupaten,
                  enabled: !_isLoading,
                  onChanged: (OptionModel newCity) {
                    _getKecamatanList(newCity.id.toString());
                    setState(() {
                      _inputKabupaten = newCity;
                      _inputKecamatan = OptionModel(id: 0, text: '');
                      _inputKelurahan = OptionModel(id: 0, text: '');
                      _inputKodePos = OptionModel(id: 0, text: '');
                    });
                  },
                  useLabel: false,
                  buttonType: 'button_text_field',
                  hintText: 'Kabupaten/Kota',
                  borderRadius: 36.0,
                  fillColor: Color(0xfff7f7f7),
                  errorText: inputKabupatenError,
                )
              : DummyCustomSelectField(
                  labelText: 'Kabupaten/Kota',
                  placeholderText: 'Kabupaten/Kota',
                  enabled: !_isLoading,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text('Anda belum memilih provinsi',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              elevation: 24.0,
                            ));
                    // WidgetUtil.showSnackbar(
                    //   context,
                    //   'Anda belum memilih provinsi',
                    // );
                  },
                ),
          SizedBox(height: 12.0),
          _inputKabupaten.id != 0
              ? CustomSelectField(
                  labelText: 'Kecamatan',
                  searchLabelText: 'Cari Kecamatan',
                  currentOption: _inputKecamatan,
                  options: listKecamatan,
                  enabled: !_isLoading,
                  onChanged: (OptionModel newKecamatan) {
                    _getKelurahanList(newKecamatan.id.toString());
                    setState(() {
                      _inputKecamatan = newKecamatan;
                      _inputKelurahan = OptionModel(id: 0, text: '');
                      _inputKodePos = OptionModel(id: 0, text: '');
                    });
                  },
                  useLabel: false,
                  buttonType: 'button_text_field',
                  hintText: 'Kecamatan',
                  borderRadius: 36.0,
                  fillColor: Color(0xfff7f7f7),
                  errorText: inputKecamatanError,
                )
              : DummyCustomSelectField(
                  labelText: 'Kecamatan',
                  placeholderText: 'Kecamatan',
                  enabled: !_isLoading,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text('Anda belum memilih kabupaten',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              elevation: 24.0,
                            ));
                    // WidgetUtil.showSnackbar(
                    //   context,
                    //   'Anda belum memilih provinsi',
                    // );
                  },
                ),
          SizedBox(height: 12.0),
          _inputKecamatan.id != 0
              ? CustomSelectField(
                  labelText: 'Kelurahan/Desa',
                  searchLabelText: 'Cari Kelurahan/Desa',
                  currentOption: _inputKelurahan,
                  options: listKelurahan,
                  enabled: !_isLoading,
                  onChanged: (OptionModel newKelurahan) {
                    _getKodePost(_inputKecamatan.id.toString(),
                        newKelurahan.id.toString());
                    setState(() {
                      _inputKelurahan = newKelurahan;
                      _inputKodePos = OptionModel(id: 0, text: '');
                    });
                  },
                  useLabel: false,
                  buttonType: 'button_text_field',
                  hintText: 'Kelurahan/Desa',
                  borderRadius: 36.0,
                  fillColor: Color(0xfff7f7f7),
                  errorText: inputKelurahanError,
                )
              : DummyCustomSelectField(
                  labelText: 'Kelurahan/Desa',
                  placeholderText: 'Kelurahan/Desa',
                  enabled: !_isLoading,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text('Anda belum memilih kecamatan',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              elevation: 24.0,
                            ));
                    // WidgetUtil.showSnackbar(
                    //   context,
                    //   'Anda belum memilih provinsi',
                    // );
                  },
                ),
          SizedBox(height: 12.0),
          _inputKelurahan.id != 0
              ? CustomSelectField(
                  labelText: 'Kode Pos',
                  searchLabelText: 'Cari Kode Pos',
                  currentOption: _inputKodePos,
                  options: listKodePos,
                  enabled: !_isLoading,
                  onChanged: (OptionModel newKodePos) {
                    setState(() {
                      _inputKodePos = newKodePos;
                    });
                  },
                  useLabel: false,
                  buttonType: 'button_text_field',
                  hintText: 'Kode Pos',
                  borderRadius: 36.0,
                  fillColor: Color(0xfff7f7f7),
                )
              : DummyCustomSelectField(
                  labelText: 'Kode Pos',
                  placeholderText: 'Kode Pos',
                  enabled: !_isLoading,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text('Anda belum memilih kelurahan/desa',
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              elevation: 24.0,
                            ));
                    // WidgetUtil.showSnackbar(
                    //   context,
                    //   'Anda belum memilih provinsi',
                    // );
                  },
                ),
          SizedBox(height: 12.0),
          CustomTextField(
            controller: _inputPhoneController,
            labelText: '',
            hintText: 'No. Handphone',
            keyboardType: TextInputType.phone,
            enabled: !_isLoading,
            errorText: inputPhoneError,
            borderRadius: 36.0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
          CustomSelectField(
            labelText: 'Alamat utama',
            searchLabelText: 'Alamat utama',
            currentOption: _inputPrimaryAddress,
            options: listPrimaryAddress,
            enabled: !_isLoading,
            onChanged: (OptionModel newPrimaryAddress) {
              setState(() {
                _inputPrimaryAddress = newPrimaryAddress;
              });
            },
            useLabel: false,
            buttonType: 'button_text_field',
            hintText: 'Alamat utama',
            borderRadius: 36.0,
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
          ElevatedButtonLoading(
            text: 'Simpan',
            onTap: _saveAccountInfo,
            isLoading: _isLoading,
            disabled: _isLoading,
          ),
          SizedBox(height: 80.0), // BottomNavBar
        ],
      ),
    );
  }

  void _setInputKabupaten(String idKabupaten) async {
    LocationRepository.getNamaWilayah(idKabupaten).then((value) {
      if (value.error == null) {
        setState(() {
          _inputKabupaten = value.data!;
        });
        _getKabupatenList(_inputProvinsi.id.toString());
      }
    });
  }

  void _getKabupatenList(String id) async {
    LocationRepository.getWilayah(id).then((value) {
      if (value.error == null) {
        setState(() {
          listKabupaten = value.data!;
        });
      }
    });
  }

  void _setInputKecamatan(String idKecamatan) async {
    LocationRepository.getNamaWilayah(idKecamatan).then((value) {
      if (value.error == null) {
        setState(() {
          _inputKecamatan = value.data!;
        });
        _getKecamatanList(_inputKabupaten.id.toString());
      }
    });
  }

  void _getKecamatanList(String id) async {
    LocationRepository.getWilayah(id).then((value) {
      if (value.error == null) {
        setState(() {
          listKecamatan = value.data!;
        });
      }
    });
  }

  void _setInputKelurahan(String idKelurahan) async {
    LocationRepository.getNamaWilayah(idKelurahan).then((value) {
      if (value.error == null) {
        setState(() {
          _inputKelurahan = value.data!;
        });
        _getKelurahanList(_inputKecamatan.id.toString());
      }
    });
  }

  void _getKelurahanList(String id) async {
    LocationRepository.getWilayah(id).then((value) {
      if (value.error == null) {
        setState(() {
          listKelurahan = value.data!;
        });
      }
    });
  }

  void _setInputKodePos(String idKodePos) {
    setState(() {
      _inputKodePos = OptionModel(id: int.parse(idKodePos), text: idKodePos);
    });
    _getKodePost(_inputKecamatan.id.toString(), _inputKelurahan.id.toString());
  }

  void _getKodePost(String idKecamatan, String idKelurahan) async {
    LocationRepository.getKodePos(idKecamatan, idKelurahan).then((value) {
      if (value.error == null) {
        setState(() {
          listKodePos = value.data!;
        });
      }
    });
  }

  void _setInputPrimaryAddress(int idPrimaryAddress) {
    setState(() {
      if (idPrimaryAddress == 1) {
        _inputPrimaryAddress = OptionModel(id: 1, text: 'Alamat utama');
      } else {
        _inputPrimaryAddress = OptionModel(id: 0, text: 'Bukan alamat utama');
      }
    });
  }
}
