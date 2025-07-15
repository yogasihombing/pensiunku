import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/gender_repository.dart';
import 'package:pensiunku/repository/job_repository.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/religion_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_controller.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/custom_date_field.dart';
import 'package:pensiunku/widget/custom_select_field.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/dummy_custom_select_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:pensiunku/widget/error_card.dart';
import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';

class AccountInfoScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/account/info';

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  bool _isBottomNavBarVisible = false;
  AccountInfoController _controller = AccountInfoController();
  late Future<ResultModel<UserModel>> _futureData;
  bool _isLoading = false;

  late TextEditingController _inputNameController;
  late TextEditingController _inputPhoneController;
  late TextEditingController _inputEmailController;
  late TextEditingController _inputAddressController;

  String _inputName = '';
  String _inputPhone = '';
  String _inputEmail = '';
  String _inputAddress = '';

  OptionModel _inputProvinsi = OptionModel(id: 0, text: '');
  OptionModel _inputCity = OptionModel(id: 0, text: '');
  late List<OptionModel> listKabupaten = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _inputNameController.dispose();
    _inputPhoneController.dispose();
    _inputEmailController.dispose();
    _inputAddressController.dispose();
    super.dispose();
  }

  void _saveAccountInfo() {
    if (_controller.isAllInputValid(
      _inputName,
      _inputPhone,
      _inputEmail,
    )) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      _handleSaveError('Authentication token is missing');
      return;
    }

    String? _inputCityName;
    if (_inputCity.id != 0) {
      _inputCityName = _inputCity.text;
    }

    var formData = {
      'username': _inputName,
      'email': _inputEmail,
      'phone': _inputPhone,
    };

    if (_inputAddress.isNotEmpty) {
      formData['alamat'] = _inputAddress;
    }
    if (_inputProvinsi.text.isNotEmpty) {
      formData['provinsi'] = _inputProvinsi.id.toString();
    }
    if (_inputCityName?.isNotEmpty == true) {
      formData['kota'] = _inputCity.id.toString();
    }

    UserRepository().updateOne(token, formData).then((result) {
      setState(() {
        _isLoading = false;
      });

      _handleSaveResult(result);
    });
  }

  void _handleSaveError(String message) {
    setState(() {
      _isLoading = false;
    });
    _showErrorDialog(message);
    WidgetUtil.showSnackbar(context, message);
  }

  void _handleSaveResult(ResultModel result) {
    _showErrorDialog(
        result.isSuccess
            ? 'Informasi akun berhasil diubah'
            : result.error ?? 'Gagal menyimpan data user',
        isSuccess: result.isSuccess);

    WidgetUtil.showSnackbar(
      context,
      result.isSuccess
          ? 'Informasi akun berhasil diubah'
          : result.error ?? 'Gagal menyimpan data user',
    );
  }

  void _showErrorDialog(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        elevation: 24.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Color.fromARGB(255, 220, 226, 147),
                ],
                stops: [0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),
        // Konten utama
        Column(
          children: [
            // AppBar (tidak bisa di-scroll)
            _buildCustomAppBar(context),
            // Konten yang bisa di-scroll
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 20.0,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10.0),
                      _buildNameAndEmailContainer(), // Bagian ini bisa di-scroll
                      const SizedBox(height: 40.0),
                      _buildAccountContent(
                          context, theme), // Bagian ini bisa di-scroll
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0, // Jarak atas
        bottom: 10.0, // Jarak bawah
        left: 20.0,
        right: 20.0,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF017964),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Akun',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF017964),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer untuk menyeimbangkan layout
        ],
      ),
    );
  }

  Widget _buildAccountContent(BuildContext context, ThemeData theme) {
    return FutureBuilder(
      future: _futureData,
      builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data?.data != null) {
          return _buildForm(context, theme, snapshot.data!.data!);
        } else {
          return const Center(
            child: Text('Tidak dapat memuat data akun'),
          );
        }
      },
    );
  }

  Widget _buildNameAndEmailContainer() {
    return Center(
      child: Column(
        children: [
          // Icon profile
          CircleAvatar(
            radius: 80.0,
            backgroundColor: Color(0xfff7f7f7),
            child: Icon(
              Icons.person,
              color: Color(0xFF017964),
              size: 80.0,
            ),
          ),
          const SizedBox(height: 16.0),
          // Name and Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name
              Text(
                _inputName.isNotEmpty ? _inputName : 'Nama belum diatur',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4.0),
              // Email
              Text(
                _inputEmail.isNotEmpty ? _inputEmail : 'Email belum diatur',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, UserModel data) {
    return Column(
      children: [
        _buildStatusAccount(), // Add the new widget here
        SizedBox(height: 30.0),
        _buildPhone(), // Phone Field
        // Divider(color: Colors.grey[400]), // Garis pembatas
        SizedBox(height: 5.0),
        _buildAlamat(), // Address Field
        // Divider(color: Colors.grey[400]), // Garis pembatas
        SizedBox(height: 5.0),
        _buildProvinsi(), // Province Selector
        // Divider(color: Colors.grey[400]), // Garis pembatas
        SizedBox(height: 5.0),
        _buildKabupaten(), // City Selector
        // Divider(color: Colors.grey[400]), // Garis pembatas
        SizedBox(height: 5.0),
        _buildSimpan(),
        SizedBox(height: 24), // Save Button
      ],
    );
  }

  Widget _buildStatusAccount() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(217, 234, 177, 0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Status Akun Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Akun',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Akun Reguler',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Dompet Anda Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dompet Anda',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Belum Aktif',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Phone Field
  Widget _buildPhone() {
    String? inputPhoneError = _controller.getInputPhoneError(_inputPhone);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36.0),
        color: Colors.transparent, // No visible background
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: 'No. Handphone' aligned to the start
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Rata kiri dan kanan
            children: [
              Text(
                'No. Handphone',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Phone Number (text) aligned to the right
              Text(
                _inputPhone.isNotEmpty ? _inputPhone : 'No. Handphone',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54, // Adjust color if needed
                ),
              ),
            ],
          ),
          // Garis pembatas
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  // 2. Address Field
  Widget _buildAlamat() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Latar belakang transparan
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label: 'Alamat' aligned to the start
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // SizedBox(height: 8.0),
          // Input field tanpa border atau latar belakang
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent, // Latar belakang transparan
            ),
            child: CustomTextField(
              controller: _inputAddressController,
              labelText: '',
              keyboardType: TextInputType.multiline,
              enabled: !_isLoading,
              minLines: 1,
              maxLines: 5,
              fillColor: Colors.transparent, // Latar belakang transparan
              textAlign: TextAlign.left, // Teks diinput rata kiri
            ),
          ),
          // Garis pembatas
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  // 3. Province Selector
  Widget _buildProvinsi() {
    return GestureDetector(
      onTap: _isLoading ? null : _showProvinceSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Provinsi',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _inputProvinsi.text.isNotEmpty
                          ? _inputProvinsi.text
                          : 'Pilih Provinsi',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: _inputProvinsi.text.isNotEmpty
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1.0,
            ),
          ],
        ),
      ),
    );
  }

// Helper method to show province selection dialog
  void _showProvinceSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Provinsi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocationRepository.getProvinces().length,
              itemBuilder: (context, index) {
                final province = LocationRepository.getProvinces()[index];
                return ListTile(
                  title: Text(province.text),
                  onTap: () {
                    _getKabupatenList(province.id.toString());
                    setState(() {
                      _inputProvinsi = province;
                      _inputCity = OptionModel(id: 0, text: '');
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 4. City Selector (Kabupaten/Kota)
  Widget _buildKabupaten() {
    if (_inputProvinsi.id == 0) return Container();

    return GestureDetector(
      onTap: _isLoading ? null : _showCitySelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kabupaten/Kota',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _inputCity.text.isNotEmpty
                          ? _inputCity.text
                          : 'Pilih Kabupaten/Kota',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: _inputCity.text.isNotEmpty
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  // 5. Save Button
  Widget _buildSimpan() {
    return ElevatedButtonLoading(
      text: 'Simpan',
      textStyle: TextStyle(
        fontWeight: FontWeight.bold, // Membuat teks bold
        fontSize: 14.0, // Sesuaikan ukuran jika perlu
        color: Colors.black,
      ),
      onTap: _saveAccountInfo,
      isLoading: _isLoading,
      disabled: _isLoading,
    );
  }

  // Helper method to show city selection dialog
  void _showCitySelectionDialog() {
    if (listKabupaten.isEmpty) {
      // Ensure kabupaten list is populated
      _getKabupatenList(_inputProvinsi.id.toString());
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Kabupaten/Kota'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: listKabupaten.length,
              itemBuilder: (context, index) {
                final city = listKabupaten[index];
                return ListTile(
                  title: Text(city.text),
                  onTap: () {
                    setState(() {
                      _inputCity = city;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshData() async {
    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null) {
      _showErrorDialog('Authentication token is missing');
      return;
    }

    _futureData = UserRepository().getOne(token).then((value) {
      if (value.error != null) {
        _showErrorDialog(value.error.toString());
      }

      _updateUserData(value);
      return value;
    });
  }

  void _updateUserData(ResultModel<UserModel> value) {
    setState(() {
      _inputName = value.data?.username ?? '';
      _inputNameController = TextEditingController(text: _inputName)
        ..addListener(() {
          setState(() {
            _inputName = _inputNameController.text;
          });
        });

      _inputPhone = value.data?.phone ?? '';
      _inputPhoneController = TextEditingController(text: _inputPhone)
        ..addListener(() {
          setState(() {
            _inputPhone = _inputPhoneController.text;
          });
        });

      _inputEmail = value.data?.email ?? '';
      _inputEmailController = TextEditingController(text: _inputEmail)
        ..addListener(() {
          setState(() {
            _inputEmail = _inputEmailController.text;
          });
        });

      _inputAddress = value.data?.address ?? '';
      _inputAddressController = TextEditingController(text: _inputAddress)
        ..addListener(() {
          setState(() {
            _inputAddress = _inputAddressController.text;
          });
        });

      if (value.data?.provinsi != null) {
        _inputProvinsi = LocationRepository.getProvinceById(
            int.parse(value.data!.provinsi!));
      }

      if (value.data?.city != null) {
        _setInputKabupaten(value.data!.city!);
      }
    });
  }

  void _setInputKabupaten(String idKabupaten) async {
    LocationRepository.getNamaWilayah(idKabupaten).then((value) {
      if (value.error == null) {
        setState(() {
          _inputCity = value.data!;
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
}