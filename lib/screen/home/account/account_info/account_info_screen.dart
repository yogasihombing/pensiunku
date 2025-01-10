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
import 'package:pensiunku/repository/result_model.dart';
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

  // Kontrol untuk validasi dan pengelolaan data akun
  AccountInfoController _controller = AccountInfoController();
  // Future untuk mengambil data akun
  late Future<ResultModel<UserModel>> _futureData;
  bool _isLoading = false;

  // Controllers untuk input teks (nama, telepon, email, alamat)
  late TextEditingController _inputNameController;
  String _inputName = '';

  late TextEditingController _inputPhoneController;
  String _inputPhone = '';

  late TextEditingController _inputEmailController;
  String _inputEmail = '';

  late TextEditingController _inputAddressController;
  String _inputAddress = '';

  // Data untuk pilihan provinsi dan kota
  OptionModel _inputProvinsi = OptionModel(id: 0, text: '');
  OptionModel _inputCity = OptionModel(id: 0, text: '');

  late List<OptionModel> listKabupaten = [];

  @override
  void initState() {
    super.initState();
    // Memuat data akun
    _refreshData();
    // Menampilkan bottom navigation bar setelah jeda
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isBottomNavBarVisible = true;
      });
    });
  }

  @override
  void dispose() {
    // Membersihkan controller untuk menghindari kebocoran memori
    _inputNameController.dispose();
    _inputPhoneController.dispose();
    _inputEmailController.dispose();
    _inputAddressController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan informasi akun
  _saveAccountInfo() {
    if (_controller.isAllInputValid(
      _inputName,
      _inputPhone,
      _inputEmail,
    )) {
      return;
    }
    // Memulai proses loading
    setState(() {
      _isLoading = true;
    });

    // Mengambil token dari SharedPreferences
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    // Menentukan nama kota jika sudah dipilih
    String? _inputCityName;
    if (_inputCity.id != 0) {
      _inputCityName = _inputCity.text;
    }
    // Membuat data formulir untuk disimpan
    var formData = {
      'username': _inputName,
      'email': _inputEmail,
      'phone': _inputPhone, //telepon diganti ke phone
    };
    if (_inputAddress.isNotEmpty) {
      formData['alamat'] = _inputAddress;
    }
    if (_inputEmail.isNotEmpty) {
      formData['email'] = _inputEmail;
    }
    if (_inputProvinsi.text.isNotEmpty) {
      formData['provinsi'] = _inputProvinsi.id.toString();
    }
    if (_inputCityName?.isNotEmpty == true) {
      formData['kota'] = _inputCity.id.toString();
    }

    // Debug: menampilkan data formulir
    print(formData);
    // Memperbarui data akun di server melalui UserRepository
    UserRepository().updateOne(token!, formData).then((result) {
      setState(() {
        _isLoading = false;
      });
      // Menampilkan dialog hasil operasi
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(
                    result.isSuccess
                        ? 'Informasi akun berhasil diubah'
                        : result.error ?? 'Gagal menyimpan data user',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                elevation: 24.0,
              ));
      WidgetUtil.showSnackbar(
        context,
        result.isSuccess
            ? 'Informasi akun berhasil diubah'
            : result.error ?? 'Gagal menyimpan data user',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: WidgetUtil.getNewAppBar(context, 'Informasi Akun', 2, (newIndex) {
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
                        AsyncSnapshot<ResultModel<UserModel>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.data != null) {
                          UserModel data = snapshot.data!.data!;
                          return _buildBody(context, theme, data);
                        } else {
                          String errorTitle =
                              'Tidak dapat menampilkan informasi akun';
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

    return _futureData = UserRepository().getOne(token!).then((value) {
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
      return value;
    });
  }

  Widget _buildBody(BuildContext context, ThemeData theme, UserModel data) {
    String? inputNameError = _controller.getInputNameError(_inputName);
    String? inputPhoneError = _controller.getInputPhoneError(_inputPhone);
    String? inputEmailError = _controller.getInputEmailError(_inputEmail);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomTextField(
            controller: _inputNameController,
            labelText: '',
            hintText: 'Nama Lengkap (Sesuai KTP)',
            keyboardType: TextInputType.name,
            enabled: !_isLoading,
            errorText: inputNameError,
            borderRadius: 36.0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
          CustomTextField(
            controller: _inputPhoneController,
            labelText: '',
            hintText: 'No. Handphone',
            keyboardType: TextInputType.phone,
            enabled: false,
            errorText: inputPhoneError,
            borderRadius: 36.0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
          CustomTextField(
            controller: _inputEmailController,
            labelText: '',
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            errorText: inputEmailError,
            borderRadius: 36.0,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
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
                _inputCity = OptionModel(id: 0, text: '');
              });
            },
            useLabel: false,
            buttonType: 'button_text_field',
            hintText: 'Provinsi Tempat Tinggal',
            borderRadius: 36.0,
            fillColor: Color(0xfff7f7f7),
          ),
          SizedBox(height: 12.0),
          _inputProvinsi.id != 0
              ? CustomSelectField(
                  labelText: 'Kabupaten/Kota',
                  searchLabelText: 'Cari Kabupaten/Kota',
                  currentOption: _inputCity,
                  options: listKabupaten,
                  enabled: !_isLoading,
                  onChanged: (OptionModel newCity) {
                    setState(() {
                      _inputCity = newCity;
                    });
                  },
                  useLabel: false,
                  buttonType: 'button_text_field',
                  hintText: 'Kabupaten/Kota',
                  borderRadius: 36.0,
                  fillColor: Color(0xfff7f7f7),
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
                    WidgetUtil.showSnackbar(
                      context,
                      'Anda belum memilih provinsi',
                    );
                  },
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
          _inputCity = value.data!;
        });
        _getKabupatenList(_inputProvinsi.id.toString());
      }
    });
  }

  void _getKabupatenList(String id) async {
    LocationRepository.getWilayah(id).then((value) {
      if (value.error == null) {
        print('Data Kabupaten/Kota: ${value.data}');
        setState(() {
          listKabupaten = value.data!;
        });
      } else {
        print('Error: ${value.error}');
      }
    });
  }
}

// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pensiunku/model/option_model.dart';
// import 'package:pensiunku/model/user_model.dart';
// import 'package:pensiunku/repository/gender_repository.dart';
// import 'package:pensiunku/repository/job_repository.dart';
// import 'package:pensiunku/repository/location_repository.dart';
// import 'package:pensiunku/repository/religion_repository.dart';
// import 'package:pensiunku/repository/result_model.dart';
// import 'package:pensiunku/repository/user_repository.dart';
// import 'package:pensiunku/screen/home/account/account_info/account_info_controller.dart';
// import 'package:pensiunku/util/shared_preferences_util.dart';
// import 'package:pensiunku/util/widget_util.dart';
// import 'package:pensiunku/widget/custom_date_field.dart';
// import 'package:pensiunku/widget/custom_select_field.dart';
// import 'package:pensiunku/widget/custom_text_field.dart';
// import 'package:pensiunku/widget/dummy_custom_select_field.dart';
// import 'package:pensiunku/widget/elevated_button_loading.dart';
// import 'package:pensiunku/widget/error_card.dart';
// import 'package:pensiunku/widget/floating_bottom_navigation_bar.dart';

// class AccountInfoScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/account/info';

//   @override
//   _AccountInfoScreenState createState() => _AccountInfoScreenState();
// }

// class _AccountInfoScreenState extends State<AccountInfoScreen> {
//   bool _isBottomNavBarVisible = false;
//   AccountInfoController _controller = AccountInfoController();
//   late Future<ResultModel<UserModel>> _futureData;
//   bool _isLoading = false;

//   late TextEditingController _inputNameController;
//   String _inputName = '';

//   late TextEditingController _inputPhoneController;
//   String _inputPhone = '';

//   late TextEditingController _inputEmailController;
//   String _inputEmail = '';

//   late TextEditingController _inputAddressController;
//   String _inputAddress = '';

//   OptionModel _inputProvinsi = OptionModel(id: 0, text: '');
//   OptionModel _inputCity = OptionModel(id: 0, text: '');
//   OptionModel _inputKecamatan = OptionModel(id: 0, text: '');
//   OptionModel _inputKelurahan = OptionModel(id: 0, text: '');
//   OptionModel _inputKodePos = OptionModel(id: 0, text: '');
//   OptionModel _inputAgama = OptionModel(id: 0, text: '');
//   OptionModel _inputGender = OptionModel(id: 0, text: '');
//   OptionModel _inputJob = OptionModel(id: 0, text: '');
//   DateTime? _inputBirthDate;
//   late List<OptionModel> listKabupaten = [];
//   late List<OptionModel> listKecamatan = [];
//   late List<OptionModel> listKelurahan = [];
//   late List<OptionModel> listKodePos = [];

//   @override
//   void initState() {
//     super.initState();

//     _refreshData();
//     Future.delayed(Duration(milliseconds: 300), () {
//       setState(() {
//         _isBottomNavBarVisible = true;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _inputNameController.dispose();
//     _inputPhoneController.dispose();
//     _inputEmailController.dispose();
//     _inputAddressController.dispose();
//     super.dispose();
//   }

//   /// Save account information
//   _saveAccountInfo() {
//     if (_controller.isAllInputValid(
//       _inputName,
//       _inputPhone,
//       _inputEmail,
//       _inputJob.text,
//     )) {
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//     });
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     String? _inputCityName;
//     if (_inputCity.id != 0) {
//       _inputCityName = _inputCity.text;
//     }
//     var formData = {
//       'username': _inputName,
//       'email': _inputEmail,
//       'phone': _inputPhone, //telepon diganti ke phone
//       'tanggal_lahir': _inputBirthDate != null
//           ? DateFormat('yyyy-MM-dd').format(_inputBirthDate!)
//           : null,
//     };
//     if (_inputAddress.isNotEmpty) {
//       formData['alamat'] = _inputAddress;
//     }
//     if (_inputEmail.isNotEmpty) {
//       formData['email'] = _inputEmail;
//     }
//     if (_inputJob.text.isNotEmpty) {
//       formData['pekerjaan'] = _inputJob.text;
//     }
//     if (_inputGender.text.isNotEmpty) {
//       formData['jenis_kelamin'] = _inputGender.id.toString();
//     }
//     if (_inputAgama.text.isNotEmpty) {
//       formData['agama'] = _inputAgama.id.toString();
//     }
//     if (_inputProvinsi.text.isNotEmpty) {
//       formData['provinsi'] = _inputProvinsi.id.toString();
//     }
//     if (_inputCityName?.isNotEmpty == true) {
//       formData['kota'] = _inputCity.id.toString();
//     }
//     if (_inputKecamatan.text.isNotEmpty) {
//       formData['kecamatan'] = _inputKecamatan.id.toString();
//     }
//     if (_inputKelurahan.text.isNotEmpty) {
//       formData['kelurahan'] = _inputKelurahan.id.toString();
//     }
//     if (_inputKodePos.text.isNotEmpty) {
//       formData['kodepos'] = _inputKodePos.id.toString();
//     }

//     print(formData);
//     UserRepository().updateOne(token!, formData).then((result) {
//       setState(() {
//         _isLoading = false;
//       });
//       showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//                 content: Text(
//                     result.isSuccess
//                         ? 'Informasi akun berhasil diubah'
//                         : result.error ?? 'Gagal menyimpan data user',
//                     style: TextStyle(color: Colors.white)),
//                 backgroundColor: Colors.red,
//                 elevation: 24.0,
//               ));
//       // WidgetUtil.showSnackbar(
//       //   context,
//       //   result.isSuccess
//       //       ? 'Informasi akun berhasil diubah'
//       //       : result.error ?? 'Gagal menyimpan data user',
//       // );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       appBar: WidgetUtil.getNewAppBar(context, 'Informasi Akun', 2, (newIndex) {
//         Navigator.of(context).pop(newIndex);
//       }, () {
//         Navigator.of(context).pop();
//       }, useNotificationIcon: false),
//       body: Stack(
//         children: [
//           RefreshIndicator(
//             onRefresh: () {
//               return _refreshData();
//             },
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Stack(
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height -
//                         AppBar().preferredSize.height,
//                   ),
//                   FutureBuilder(
//                     future: _futureData,
//                     builder: (BuildContext context,
//                         AsyncSnapshot<ResultModel<UserModel>> snapshot) {
//                       if (snapshot.hasData) {
//                         if (snapshot.data?.data != null) {
//                           UserModel data = snapshot.data!.data!;
//                           return _buildBody(context, theme, data);
//                         } else {
//                           String errorTitle =
//                               'Tidak dapat menampilkan informasi akun';
//                           String? errorSubtitle = snapshot.data?.error;
//                           return Column(
//                             children: [
//                               SizedBox(height: 16),
//                               ErrorCard(
//                                 title: errorTitle,
//                                 subtitle: errorSubtitle,
//                                 iconData: Icons.warning_rounded,
//                               ),
//                             ],
//                           );
//                         }
//                       } else {
//                         return Column(
//                           children: [
//                             SizedBox(height: 16),
//                             Center(
//                               child: CircularProgressIndicator(
//                                 color: theme.primaryColor,
//                               ),
//                             ),
//                           ],
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // FloatingBottomNavigationBar(
//           //   isVisible: _isBottomNavBarVisible,
//           //   currentIndex: 2,
//           //   onTapItem: (newIndex) {
//           //     Navigator.of(context).pop(newIndex);
//           //   },
//           // ),
//         ],
//       ),
//     );
//   }

//   _refreshData() {
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     return _futureData = UserRepository().getOne(token!).then((value) {
//       if (value.error != null) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(value.error.toString(),
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//         // WidgetUtil.showSnackbar(
//         //   context,
//         //   value.error.toString(),
//         // );
//       }
//       setState(() {
//         _inputName = value.data?.username ?? '';
//         _inputNameController = TextEditingController(text: _inputName)
//           ..addListener(() {
//             setState(() {
//               _inputName = _inputNameController.text;
//             });
//           });
//         _inputPhone = value.data?.phone ?? '';
//         _inputPhoneController = TextEditingController(text: _inputPhone)
//           ..addListener(() {
//             setState(() {
//               _inputPhone = _inputPhoneController.text;
//             });
//           });
//         _inputEmail = value.data?.email ?? '';
//         _inputEmailController = TextEditingController(text: _inputEmail)
//           ..addListener(() {
//             setState(() {
//               _inputEmail = _inputEmailController.text;
//             });
//           });
//         _inputAddress = value.data?.address ?? '';
//         _inputAddressController = TextEditingController(text: _inputAddress)
//           ..addListener(() {
//             setState(() {
//               _inputAddress = _inputAddressController.text;
//             });
//           });
//         if (value.data?.birthDate != null) {
//           _inputBirthDate = DateTime.tryParse(value.data!.birthDate!);
//         }
//         if (value.data?.job != null) {
//           _inputJob = JobRepository.getJobByName(value.data!.job!);
//         }
//         if (value.data?.gender != null) {
//           _inputGender = GenderRepository.getGenderById(value.data!.gender!);
//         }
//         if (value.data?.religion != null) {
//           _inputAgama =
//               ReligionRepository.getReligionById(value.data!.religion!);
//         }
//         if (value.data?.provinsi != null) {
//           _inputProvinsi = LocationRepository.getProvinceById(
//               int.parse(value.data!.provinsi!));
//         }
//         if (value.data?.city != null) {
//           _setInputKabupaten(value.data!.city!);
//         }
//         if (value.data?.kecamatan != null) {
//           _setInputKecamatan(value.data!.kecamatan!);
//         }
//         if (value.data?.kelurahan != null) {
//           _setInputKelurahan(value.data!.kecamatan! + value.data!.kelurahan!);
//         }
//         if (value.data?.kodepos != null) {
//           _setInputKodePos(value.data!.kodepos!);
//         }
//       });
//       return value;
//     });
//   }

//   Widget _buildBody(BuildContext context, ThemeData theme, UserModel data) {
//     String? inputNameError = _controller.getInputNameError(_inputName);
//     String? inputPhoneError = _controller.getInputPhoneError(_inputPhone);
//     String? inputEmailError = _controller.getInputEmailError(_inputEmail);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           CustomTextField(
//             controller: _inputNameController,
//             labelText: '',
//             hintText: 'Nama Lengkap (Sesuai KTP)',
//             keyboardType: TextInputType.name,
//             enabled: !_isLoading,
//             errorText: inputNameError,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           CustomTextField(
//             controller: _inputPhoneController,
//             labelText: '',
//             hintText: 'No. Handphone',
//             keyboardType: TextInputType.phone,
//             enabled: !_isLoading,
//             errorText: inputPhoneError,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           CustomTextField(
//             controller: _inputEmailController,
//             labelText: '',
//             hintText: 'Email',
//             keyboardType: TextInputType.emailAddress,
//             enabled: !_isLoading,
//             errorText: inputEmailError,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//             fillColor: Color(0xfff7f7f7),
//           ),
//           // SizedBox(height: 12.0),
//           // CustomDateField(
//           //   labelText: 'Tanggal Lahir',
//           //   currentValue: _inputBirthDate,
//           //   enabled: !_isLoading,
//           //   onChanged: (DateTime? newBirthDate) {
//           //     setState(() {
//           //       _inputBirthDate = newBirthDate;
//           //     });
//           //   },
//           //   useLabel: false,
//           //   fillColor: Color(0xfff7f7f7),
//           //   buttonType: 'button_text_field',
//           //   borderRadius: 36.0,
//           //   lastDate: DateTime.now(),
//           // ),
//           SizedBox(height: 12.0),
//           CustomTextField(
//             controller: _inputAddressController,
//             labelText: '',
//             hintText: 'Alamat',
//             keyboardType: TextInputType.multiline,
//             enabled: !_isLoading,
//             minLines: 2,
//             maxLines: 5,
//             borderRadius: 36.0,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 20.0,
//             ),
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           CustomSelectField(
//             labelText: 'Provinsi Tempat Tinggal',
//             searchLabelText: 'Cari Provinsi',
//             currentOption: _inputProvinsi,
//             options: LocationRepository.getProvinces(),
//             enabled: !_isLoading,
//             onChanged: (OptionModel newProvince) {
//               _getKabupatenList(newProvince.id.toString());
//               setState(() {
//                 _inputProvinsi = newProvince;
//                 _inputCity = OptionModel(id: 0, text: '');
//                 _inputKecamatan = OptionModel(id: 0, text: '');
//                 _inputKelurahan = OptionModel(id: 0, text: '');
//                 _inputKodePos = OptionModel(id: 0, text: '');
//               });
//             },
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Provinsi Tempat Tinggal',
//             borderRadius: 36.0,
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           _inputProvinsi.id != 0
//               ? CustomSelectField(
//                   labelText: 'Kabupaten/Kota',
//                   searchLabelText: 'Cari Kabupaten/Kota',
//                   currentOption: _inputCity,
//                   options: listKabupaten,
//                   enabled: !_isLoading,
//                   onChanged: (OptionModel newCity) {
//                     _getKecamatanList(newCity.id.toString());
//                     setState(() {
//                       _inputCity = newCity;
//                       _inputKecamatan = OptionModel(id: 0, text: '');
//                       _inputKelurahan = OptionModel(id: 0, text: '');
//                       _inputKodePos = OptionModel(id: 0, text: '');
//                     });
//                   },
//                   useLabel: false,
//                   buttonType: 'button_text_field',
//                   hintText: 'Kabupaten/Kota',
//                   borderRadius: 36.0,
//                   fillColor: Color(0xfff7f7f7),
//                 )
//               : DummyCustomSelectField(
//                   labelText: 'Kabupaten/Kota',
//                   placeholderText: 'Kabupaten/Kota',
//                   enabled: !_isLoading,
//                   onTap: () {
//                     showDialog(
//                         context: context,
//                         builder: (_) => AlertDialog(
//                               content: Text('Anda belum memilih provinsi',
//                                   style: TextStyle(color: Colors.white)),
//                               backgroundColor: Colors.red,
//                               elevation: 24.0,
//                             ));
//                     // WidgetUtil.showSnackbar(
//                     //   context,
//                     //   'Anda belum memilih provinsi',
//                     // );
//                   },
//                 ),
//           // SizedBox(height: 12.0),
//           // _inputCity.id != 0
//           //     ? CustomSelectField(
//           //         labelText: 'Kecamatan',
//           //         searchLabelText: 'Cari Kecamatan',
//           //         currentOption: _inputKecamatan,
//           //         options: listKecamatan,
//           //         enabled: !_isLoading,
//           //         onChanged: (OptionModel newKecamatan) {
//           //           _getKelurahanList(newKecamatan.id.toString());
//           //           setState(() {
//           //             _inputKecamatan = newKecamatan;
//           //             _inputKelurahan = OptionModel(id: 0, text: '');
//           //             _inputKodePos = OptionModel(id: 0, text: '');
//           //           });
//           //         },
//           //         useLabel: false,
//           //         buttonType: 'button_text_field',
//           //         hintText: 'Kecamatan',
//           //         borderRadius: 36.0,
//           //         fillColor: Color(0xfff7f7f7),
//           //       )
//           //     : DummyCustomSelectField(
//           //         labelText: 'Kecamatan',
//           //         placeholderText: 'Kecamatan',
//           //         enabled: !_isLoading,
//           //         onTap: () {
//           //           showDialog(
//           //               context: context,
//           //               builder: (_) => AlertDialog(
//           //                     content: Text('Anda belum memilih kabupaten',
//           //                         style: TextStyle(color: Colors.white)),
//           //                     backgroundColor: Colors.red,
//           //                     elevation: 24.0,
//           //                   ));
//           //           // WidgetUtil.showSnackbar(
//           //           //   context,
//           //           //   'Anda belum memilih provinsi',
//           //           // );
//           //         },
//           //       ),
//           // SizedBox(height: 12.0),
//           // _inputKecamatan.id != 0
//           //     ? CustomSelectField(
//           //         labelText: 'Kelurahan/Desa',
//           //         searchLabelText: 'Cari Kelurahan/Desa',
//           //         currentOption: _inputKelurahan,
//           //         options: listKelurahan,
//           //         enabled: !_isLoading,
//           //         onChanged: (OptionModel newKelurahan) {
//           //           _getKodePost(_inputKecamatan.id.toString(),
//           //               newKelurahan.id.toString());
//           //           setState(() {
//           //             _inputKelurahan = newKelurahan;
//           //             _inputKodePos = OptionModel(id: 0, text: '');
//           //           });
//           //         },
//           //         useLabel: false,
//           //         buttonType: 'button_text_field',
//           //         hintText: 'Kelurahan/Desa',
//           //         borderRadius: 36.0,
//           //         fillColor: Color(0xfff7f7f7),
//           //       )
//           //     : DummyCustomSelectField(
//           //         labelText: 'Kelurahan/Desa',
//           //         placeholderText: 'Kelurahan/Desa',
//           //         enabled: !_isLoading,
//           //         onTap: () {
//           //           showDialog(
//           //               context: context,
//           //               builder: (_) => AlertDialog(
//           //                     content: Text('Anda belum memilih kecamatan',
//           //                         style: TextStyle(color: Colors.white)),
//           //                     backgroundColor: Colors.red,
//           //                     elevation: 24.0,
//           //                   ));
//           //           // WidgetUtil.showSnackbar(
//           //           //   context,
//           //           //   'Anda belum memilih provinsi',
//           //           // );
//           //         },
//           //       ),
//           // SizedBox(height: 12.0),
//           // _inputKelurahan.id != 0
//           //     ? CustomSelectField(
//           //         labelText: 'Kode Pos',
//           //         searchLabelText: 'Cari Kode Pos',
//           //         currentOption: _inputKodePos,
//           //         options: listKodePos,
//           //         enabled: !_isLoading,
//           //         onChanged: (OptionModel newKodePos) {
//           //           setState(() {
//           //             _inputKodePos = newKodePos;
//           //           });
//           //         },
//           //         useLabel: false,
//           //         buttonType: 'button_text_field',
//           //         hintText: 'Kode Pos',
//           //         borderRadius: 36.0,
//           //         fillColor: Color(0xfff7f7f7),
//           //       )
//           //     : DummyCustomSelectField(
//           //         labelText: 'Kode Pos',
//           //         placeholderText: 'Kode Pos',
//           //         enabled: !_isLoading,
//           //         onTap: () {
//           //           showDialog(
//           //               context: context,
//           //               builder: (_) => AlertDialog(
//           //                     content: Text('Anda belum memilih kelurahan/desa',
//           //                         style: TextStyle(color: Colors.white)),
//           //                     backgroundColor: Colors.red,
//           //                     elevation: 24.0,
//           //                   ));
//           //           // WidgetUtil.showSnackbar(
//           //           //   context,
//           //           //   'Anda belum memilih provinsi',
//           //           // );
//           //         },
//           //       ),
//           SizedBox(height: 12.0),
//           CustomSelectField(
//             labelText: 'Pekerjaan',
//             searchLabelText: 'Cari Pekerjaan',
//             currentOption: _inputJob,
//             options: JobRepository.getJobs(),
//             enabled: !_isLoading,
//             onChanged: (OptionModel newJob) {
//               setState(() {
//                 _inputJob = newJob;
//               });
//             },
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Pekerjaan',
//             borderRadius: 36.0,
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           CustomSelectField(
//             labelText: 'Agama',
//             searchLabelText: 'Pilih Agama',
//             currentOption: _inputAgama,
//             options: ReligionRepository.getReligions(),
//             enabled: !_isLoading,
//             onChanged: (OptionModel newReligion) {
//               setState(() {
//                 _inputAgama = newReligion;
//               });
//             },
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Agama',
//             borderRadius: 36.0,
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           CustomSelectField(
//             labelText: 'Jenis Kelamin',
//             searchLabelText: 'Pilih Jenis Kelamin',
//             currentOption: _inputGender,
//             options: GenderRepository.getGenders(),
//             enabled: !_isLoading,
//             onChanged: (OptionModel newGender) {
//               setState(() {
//                 _inputGender = newGender;
//               });
//             },
//             useLabel: false,
//             buttonType: 'button_text_field',
//             hintText: 'Jenis Kelamin',
//             borderRadius: 36.0,
//             fillColor: Color(0xfff7f7f7),
//           ),
//           SizedBox(height: 12.0),
//           ElevatedButtonLoading(
//             text: 'Simpan',
//             onTap: _saveAccountInfo,
//             isLoading: _isLoading,
//             disabled: _isLoading,
//           ),
//           SizedBox(height: 80.0), // BottomNavBar
//         ],
//       ),
//     );
//   }

//   void _setInputKabupaten(String idKabupaten) async {
//     LocationRepository.getNamaWilayah(idKabupaten).then((value) {
//       if (value.error == null) {
//         setState(() {
//           _inputCity = value.data!;
//         });
//         _getKabupatenList(_inputProvinsi.id.toString());
//       }
//     });
//   }

//   void _getKabupatenList(String id) async {
//     LocationRepository.getWilayah(id).then((value) {
//       if (value.error == null) {
//         setState(() {
//           listKabupaten = value.data!;
//         });
//       }
//     });
//   }

//   void _setInputKecamatan(String idKecamatan) async {
//     LocationRepository.getNamaWilayah(idKecamatan).then((value) {
//       if (value.error == null) {
//         setState(() {
//           _inputKecamatan = value.data!;
//         });
//         _getKecamatanList(_inputCity.id.toString());
//       }
//     });
//   }

//   void _getKecamatanList(String id) async {
//     LocationRepository.getWilayah(id).then((value) {
//       if (value.error == null) {
//         setState(() {
//           listKecamatan = value.data!;
//         });
//       }
//     });
//   }

//   void _setInputKelurahan(String idKelurahan) async {
//     LocationRepository.getNamaWilayah(idKelurahan).then((value) {
//       if (value.error == null) {
//         setState(() {
//           _inputKelurahan = value.data!;
//         });
//         _getKelurahanList(_inputKecamatan.id.toString());
//       }
//     });
//   }

//   void _getKelurahanList(String id) async {
//     LocationRepository.getWilayah(id).then((value) {
//       if (value.error == null) {
//         setState(() {
//           listKelurahan = value.data!;
//         });
//       }
//     });
//   }

//   void _setInputKodePos(String idKodePos) {
//     setState(() {
//       _inputKodePos = OptionModel(id: int.parse(idKodePos), text: idKodePos);
//     });
//     _getKodePost(_inputKecamatan.id.toString(), _inputKelurahan.id.toString());
//   }

//   void _getKodePost(String idKecamatan, String idKelurahan) async {
//     LocationRepository.getKodePos(idKecamatan, idKelurahan).then((value) {
//       if (value.error == null) {
//         setState(() {
//           listKodePos = value.data!;
//         });
//       }
//     });
//   }
// }
