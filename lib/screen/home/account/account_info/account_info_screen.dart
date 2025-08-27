import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/account/account_info/account_info_controller.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/custom_text_field.dart';
import 'package:pensiunku/widget/elevated_button_loading.dart';
import 'package:http/http.dart' as http;

class AccountInfoScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/account/info';

  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController _inputNameController;
  late TextEditingController _inputPhoneController;
  late TextEditingController _inputEmailController;
  late TextEditingController _inputAddressController;

  bool _isBottomNavBarVisible = false;
  AccountInfoController _controller = AccountInfoController();
  late Future<ResultModel<UserModel>> _futureData;
  bool _isLoading = false;

  String _inputName = '';
  String _inputPhone = '';
  String _inputEmail = '';
  String _inputAddress = '';
  UserModel? _userModel;
  File? _imageFile;

  // Hapus _inputProvinsi
  // OptionModel _inputProvinsi = OptionModel(id: 0, text: '');

  // Tambahkan state baru untuk Kota/Kabupaten
  OptionModel _inputCity = OptionModel(id: 0, text: '');
  List<OptionModel> _allCityOptions = []; // Ganti _allDomisiliOptions
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    _inputNameController = TextEditingController();
    _inputPhoneController = TextEditingController();
    _inputEmailController = TextEditingController();
    _inputAddressController = TextEditingController();

    _fetchCities(); // Panggil fungsi ini di initState
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

  // Tambahkan fungsi untuk mengambil data kota/kabupaten
  Future<void> _fetchCities() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCities = true;
    });

    try {
      final String domisiliApiUrl =
          'https://api.pensiunku.id/new.php/getDomisili';
      final response = await http.get(Uri.parse(domisiliApiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        if (decodedData.containsKey('text') && decodedData['text'] is Map) {
          final Map<String, dynamic> textData = decodedData['text'];
          if (textData.containsKey('message') &&
              textData['message'] == 'success' &&
              textData.containsKey('data') &&
              textData['data'] is List) {
            final List<dynamic> rawCityList = textData['data'];
            setState(() {
              _allCityOptions = rawCityList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return OptionModel(
                    id: index + 1, text: item['city'].toString());
              }).toList();
            });
          } else {
            WidgetUtil.showSnackbar(context,
                'Gagal memuat data kota: Struktur respons tidak sesuai.');
          }
        } else {
          WidgetUtil.showSnackbar(context,
              'Gagal memuat data kota: Struktur respons tidak sesuai.');
        }
      } else {
        WidgetUtil.showSnackbar(
            context, 'Gagal memuat data kota (HTTP ${response.statusCode}).');
      }
    } catch (e) {
      WidgetUtil.showSnackbar(
          context, 'Terjadi kesalahan saat memuat data kota.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
      });
      _uploadProfilePicture(_imageFile!);
    }
  }

  void _uploadProfilePicture(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    final token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || _userModel?.id == null) {
      _showErrorDialog('Authentication token or user ID is missing');
      return;
    }

    try {
      final result = await UserRepository()
          .uploadProfilePicture(token, _userModel!.id, imageFile);

      if (result.isSuccess) {
        _refreshData();
        WidgetUtil.showSnackbar(context, 'Foto profil berhasil diunggah!');
        setState(() {
          _imageFile = null;
        });
      } else {
        _showErrorDialog(result.error ?? 'Gagal mengunggah foto profil.');
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat mengunggah foto profil.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    var formData = {
      'username': _inputName,
      'email': _inputEmail,
      'phone': _inputPhone,
    };

    if (_inputAddress.isNotEmpty) {
      formData['alamat'] = _inputAddress;
    }

    // Ganti 'provinsi' dengan 'kecamatan' (mengadopsi dari page pengajuan)
    if (_inputCity.text.isNotEmpty) {
      formData['kecamatan'] = _inputCity.text;
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
      isSuccess: result.isSuccess,
    );

    WidgetUtil.showSnackbar(
      context,
      result.isSuccess
          ? 'Informasi akun berhasil diubah'
          : result.error ?? 'Gagal menyimpan data user',
    );
    if (result.isSuccess) {
      _refreshData();
    }
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
        Column(
          children: [
            _buildCustomAppBar(context),
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
                      _buildNameAndEmailContainer(),
                      const SizedBox(height: 40.0),
                      _buildAccountContent(context, theme),
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
        top: 32.0,
        bottom: 10.0,
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAccountContent(BuildContext context, ThemeData theme) {
    return FutureBuilder(
      future: _futureData,
      builder: (context, AsyncSnapshot<ResultModel<UserModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _isLoadingCities) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data?.data != null) {
          _userModel = snapshot.data!.data!;
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
          Stack(
            children: [
              CircleAvatar(
                radius: 80.0,
                backgroundColor: const Color(0xfff7f7f7),
                backgroundImage: (_userModel?.profilePictureUrl != null &&
                        _imageFile == null)
                    ? NetworkImage(_userModel!.profilePictureUrl!)
                        as ImageProvider<Object>?
                    : _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider<Object>?
                        : null,
                child:
                    _userModel?.profilePictureUrl == null && _imageFile == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF017964),
                            size: 80.0,
                          )
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF017964),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userModel?.username?.isNotEmpty == true
                        ? _userModel!.username!
                        : 'Nama belum diatur',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (_userModel?.isPensiunkuPlus == true)
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 20.0,
                    ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                _userModel?.email?.isNotEmpty == true
                    ? _userModel!.email!
                    : 'Email belum diatur',
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
        _buildStatusAccount(),
        SizedBox(height: 30.0),
        _buildPhone(),
        SizedBox(height: 5.0),
        _buildAlamat(),
        SizedBox(height: 5.0),
        _buildCitySelection(), // Ganti _buildProvinsi()
        SizedBox(height: 5.0),
        _buildSimpan(),
        SizedBox(height: 24),
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
                _userModel?.isPensiunkuPlus == true
                    ? 'Pensiunku+'
                    : 'Akun Reguler',
                style: TextStyle(
                  fontSize: 14.0,
                  color: _userModel?.isPensiunkuPlus == true
                      ? Color(0xFF017964)
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
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
                _userModel?.isWalletActive == true
                    ? 'Sudah Aktif'
                    : 'Belum Aktif',
                style: TextStyle(
                  fontSize: 14.0,
                  color: _userModel?.isWalletActive == true
                      ? Color(0xFF017964)
                      : Colors.black,
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
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'No. Handphone',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _inputPhone.isNotEmpty ? _inputPhone : 'No. Handphone',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alamat',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: CustomTextField(
              controller: _inputAddressController,
              labelText: '',
              keyboardType: TextInputType.multiline,
              enabled: !_isLoading,
              minLines: 1,
              maxLines: 5,
              fillColor: Colors.transparent,
              textAlign: TextAlign.left,
            ),
          ),
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  // Ganti widget _buildProvinsi menjadi _buildCitySelection
  Widget _buildCitySelection() {
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
                const Text(
                  'Kota/Kabupaten', // Ganti teks
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
                          : 'Pilih Kota/Kabupaten', // Ganti teks
                      style: TextStyle(
                        fontSize: 12.0,
                        color: _inputCity.text.isNotEmpty
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
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

  // Ganti helper method _showProvinceSelectionDialog menjadi _showCitySelectionDialog
  void _showCitySelectionDialog() {
    // Gunakan StatefulBuilder untuk mengelola state di dalam dialog
    List<OptionModel> filteredCities = List.from(_allCityOptions);
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void handleSearch(String query) {
              setDialogState(() {
                if (query.isEmpty) {
                  filteredCities = List.from(_allCityOptions);
                } else {
                  filteredCities = _allCityOptions
                      .where((city) =>
                          city.text.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            return Dialog(
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pilih Kota/Kabupaten',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF017964)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: handleSearch,
                      decoration: InputDecoration(
                        hintText: 'Cari kota/kabupaten...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoadingCities
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF017964)),
                              ),
                            )
                          : filteredCities.isEmpty
                              ? Center(
                                  child: Text('Tidak ada kota yang ditemukan'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredCities.length,
                                  itemBuilder: (context, index) {
                                    final city = filteredCities[index];
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 5. Save Button
  Widget _buildSimpan() {
    return ElevatedButtonLoading(
      text: 'Simpan',
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
        color: Colors.black,
      ),
      onTap: _saveAccountInfo,
      isLoading: _isLoading,
      disabled: _isLoading,
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

  void _updateUserData(ResultModel<UserModel> value) async {
    if (!mounted) return;

    setState(() {
      _userModel = value.data;
      _inputName = value.data?.username ?? '';
      _inputPhone = value.data?.phone ?? '';
      _inputEmail = value.data?.email ?? '';
      _inputAddress = value.data?.address ?? '';

      _inputNameController.text = _inputName;
      _inputPhoneController.text = _inputPhone;
      _inputEmailController.text = _inputEmail;
      _inputAddressController.text = _inputAddress;
    });

    // Sesuaikan logika ini untuk mengisi data kota/kabupaten
    if (value.data?.kecamatan != null && value.data!.kecamatan!.isNotEmpty) {
      final cityFromAPI = value.data!.kecamatan!;
      final existingCity = _allCityOptions.firstWhere(
        (city) => city.text == cityFromAPI,
        orElse: () => OptionModel(id: 0, text: ''),
      );
      setState(() {
        _inputCity = existingCity;
      });
    } else {
      setState(() {
        _inputCity = OptionModel(id: 0, text: '');
      });
    }
  }
}
