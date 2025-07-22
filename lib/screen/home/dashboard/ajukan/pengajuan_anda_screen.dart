import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/data/db/pengajuan_anda_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:http/http.dart' as http;

class CustomUploadField extends StatelessWidget {
  final String label;
  final String? filePath;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onUpload;
  final String? errorText;

  const CustomUploadField({
    Key? key,
    required this.label,
    required this.filePath,
    required this.isUploading,
    required this.uploadProgress,
    required this.onUpload,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          filePath ?? 'Belum ada file dipilih',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenWidth * 0.04,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.06,
                    width: 1,
                    color: Colors.grey[300],
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  ),
                  if (isUploading)
                    SizedBox(
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      child: CircularProgressIndicator(
                        value: uploadProgress,
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
                      ),
                    )
                  else
                    InkWell(
                      onTap: onUpload,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Image.asset(
                          'assets/dashboard_screen/upload_icon.png',
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
                          color: Color(0xFF017964),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.03, top: screenHeight * 0.005),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }
}

class PengajuanAndaScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/pengajuan_anda';

  @override
  _PengajuanAndaScreenState createState() => _PengajuanAndaScreenState();
}

class _PengajuanAndaScreenState extends State<PengajuanAndaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoadingOverlay = false;

  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController pekerjaanController = TextEditingController();

  // State baru untuk data domisili dari API
  List<String> _allDomisiliOptions = [];
  bool _isLoadingDomisili = false;
  String _errorMessage = '';

  late Future<ResultModel<UserModel>> _futureData;

  DateTime? _selectedDate;
  late OptionModel _selectedCity; // Deklarasi _selectedCity di sini

  @override
  void initState() {
    super.initState();
    _isLoadingOverlay = true;
    _selectedCity = OptionModel(id: 0, text: ''); // Inisialisasi awal
    _refreshData();
    _fetchDomisili(); // Panggil fungsi untuk mengambil data domisili
  }

  // --- FUNGSI: Mengambil data domisili dari API ---
  Future<void> _fetchDomisili() async {
    if (!mounted) return;

    setState(() {
      _isLoadingDomisili = true;
      _errorMessage = '';
    });

    try {
      final String domisiliApiUrl =
          'https://api.pensiunku.id/new.php/getDomisili';
      debugPrint("Fetching domisili from URL: $domisiliApiUrl");

      final response = await http.get(Uri.parse(domisiliApiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        debugPrint("Raw Response Body (getDomisili): ${response.body}");

        if (decodedData.containsKey('text') && decodedData['text'] is Map) {
          final Map<String, dynamic> textData = decodedData['text'];

          if (textData.containsKey('message') &&
              textData['message'] == 'success' &&
              textData.containsKey('data') &&
              textData['data'] is List) {
            final List<dynamic> rawDomisiliList = textData['data'];

            setState(() {
              _allDomisiliOptions =
                  List<String>.from(rawDomisiliList.map((item) {
                if (item.containsKey('city') && item['city'] != null) {
                  return item['city'].toString();
                }
                return '';
              }).where((name) => name.isNotEmpty));
            });
          } else {
            String specificErrorMessage = 'Gagal memuat data domisili. ';
            if (textData.containsKey('message') &&
                textData['message'] != 'success') {
              specificErrorMessage +=
                  'Pesan API bukan sukses (${textData['message']}).';
            } else if (!textData.containsKey('data') ||
                !(textData['data'] is List)) {
              specificErrorMessage +=
                  'Format data domisili tidak valid: kunci "data" tidak ada atau bukan list (tipe: ${textData['data'].runtimeType}).';
            }
            print('Error fetching domisili: $specificErrorMessage');
            _showSnackBar(specificErrorMessage);
          }
        } else {
          print(
              'Error fetching domisili: Kunci "text" tidak ditemukan atau bukan map.');
          _showSnackBar(
              'Gagal memuat data domisili: Struktur respons tidak sesuai.');
        }
      } else {
        print('HTTP Error fetching domisili: ${response.statusCode}');
        _showSnackBar(
            'Gagal memuat data domisili (HTTP ${response.statusCode}).');
      }
    } catch (e) {
      print('Exception fetching domisili: $e');
      _showSnackBar('Terjadi kesalahan saat memuat domisili: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDomisili = false;
        });
      }
    }
  }

  // Fungsi pembantu untuk menampilkan SnackBar dengan aman
  void _showSnackBar(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  Future<void> _showCitySelectionDialog() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Gunakan StatefulBuilder untuk mengelola state di dalam dialog
    List<String> filteredCities = List.from(_allDomisiliOptions);
    TextEditingController searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void handleSearch(String query) {
              setDialogState(() {
                if (query.isEmpty) {
                  filteredCities = List.from(_allDomisiliOptions);
                } else {
                  filteredCities = _allDomisiliOptions
                      .where((city) =>
                          city.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                }
              });
            }

            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.05,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.6,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Kota/Kabupaten',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF017964),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: handleSearch,
                        decoration: InputDecoration(
                          hintText: 'Cari kota/kabupaten...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.02,
                          ),
                        ),
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Expanded(
                      child: _isLoadingDomisili
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF017964))))
                          : _errorMessage.isNotEmpty
                              ? Center(
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : filteredCities.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Tidak ada kota yang ditemukan',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredCities.length,
                                      itemBuilder: (context, index) {
                                        final city = filteredCities[index];
                                        return Card(
                                          elevation: 0,
                                          margin: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.004),
                                          color: Colors.grey[50],
                                          child: ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.005,
                                              horizontal: screenWidth * 0.02,
                                            ),
                                            title: Text(
                                              city,
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                // Create OptionModel with dummy ID or index
                                                _selectedCity = OptionModel(
                                                    id: index + 1, text: city);
                                                domisiliController.text = city;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Color(0xFF017964),
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now()
              .subtract(const Duration(days: 365 * 20)), // Usia awal 20 tahun
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF017964), // Warna header date picker
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF017964)), // Warna elemen date picker
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        tanggalLahirController.text =
            DateFormat('yyyy-MM-dd').format(picked); // Format YYYY-MM-DD
      });
    }
  }

  Future<void> _submitPengajuanAnda() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua data yang diperlukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCity.id == 0 || _selectedCity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap pilih kota/kabupaten Anda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap masukkan tanggal lahir Anda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (pekerjaanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap masukkan pekerjaan Anda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success = await PengajuanAndaDao.kirimPengajuanAnda(
        nama: namaController.text,
        telepon: teleponController.text,
        domisili: domisiliController.text,
        tanggalLahir: tanggalLahirController.text,
        pekerjaan: pekerjaanController.text,
      );

      if (success) {
        _showCustomDialog(
          context: context,
          title: 'Sukses',
          message: 'Pengajuan Anda Berhasil Dikirim.',
          color: Color(0xFF017964),
          isSuccess: true,
        );
      } else {
        _showCustomDialog(
          context: context,
          title: 'Gagal',
          message:
              'Anda sudah pernah melakukan pengajuan atau terjadi kesalahan!',
          color: Colors.red,
          isSuccess: false,
        );
      }
    } catch (e) {
      debugPrint('Error submitting pengajuan: $e');
      _showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Terjadi kesalahan saat mengirim pengajuan: ${e.toString()}',
        color: Colors.red,
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    required Color color,
    required bool isSuccess,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.04,
            ),
            child: Container(
              width: screenWidth * 0.8,
              constraints: BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    width: screenWidth * 0.3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: color,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (isSuccess) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RiwayatPengajuanAndaScreen(
                                onChangeBottomNavIndex: (index) => 1,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoadingOverlay = false;
      });
      return;
    }

    _futureData = UserRepository().getOne(token).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                    value.error.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  elevation: 24.0,
                ));
      }

      setState(() {
        namaController.text = value.data?.username ?? '';
        teleponController.text = value.data?.phone ?? '';
        // Inisialisasi tanggal lahir dan pekerjaan jika ada di data user
        // ASUMSI: UserModel memiliki properti 'birthDate' dan 'job'
        tanggalLahirController.text = value.data?.birthDate ?? '';
        pekerjaanController.text = value.data?.job ?? '';

        // Inisialisasi domisili dan _selectedCity
        // ASUMSI: UserModel memiliki properti 'kecamatan'
        if (value.data?.kecamatan != null &&
            value.data!.kecamatan!.isNotEmpty) {
          domisiliController.text = value.data!.kecamatan!;
          // Cari OptionModel yang sesuai dari _allDomisiliOptions
          // Karena _allDomisiliOptions adalah List<String>, kita perlu membuat OptionModel
          // Jika tidak ditemukan, default ke OptionModel kosong
          _selectedCity = _allDomisiliOptions
                  .firstWhere(
                    (cityText) => cityText == value.data!.kecamatan,
                    orElse: () => '', // Return empty string if not found
                  )
                  .isNotEmpty
              ? OptionModel(
                  id: _allDomisiliOptions.indexOf(value.data!.kecamatan!) +
                      1, // Dummy ID
                  text: value.data!.kecamatan!)
              : OptionModel(id: 0, text: '');
        } else {
          domisiliController.text = '';
          _selectedCity = OptionModel(id: 0, text: '');
        }

        // Set _selectedDate jika tanggalLahir ada
        if (tanggalLahirController.text.isNotEmpty) {
          try {
            _selectedDate = DateTime.parse(tanggalLahirController.text);
          } catch (e) {
            debugPrint('Error parsing tanggalLahir: $e');
            _selectedDate = null;
          }
        } else {
          _selectedDate = null;
        }

        _isLoadingOverlay = false;
      });

      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. Background gradient
        Container(
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: kToolbarHeight + screenHeight * 0.02,
            leading: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.02),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.02),
              child: Text(
                'Form Pengajuan',
                style: TextStyle(
                  color: Color(0xFF017964),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                _isLoadingOverlay || _isLoadingDomisili
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF017964)), // Warna hijau
                      ))
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    screenHeight - kToolbarHeight - safeAreaTop,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: screenHeight * 0.02),
                                  // Nama field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: namaController,
                                      readOnly: true,
                                      enabled: !_isLoadingOverlay,
                                      decoration: InputDecoration(
                                          labelText: 'Nama',
                                          border: OutlineInputBorder()),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Harap masukkan nama'
                                              : null,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // Telepon field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: teleponController,
                                      readOnly: true,
                                      enabled: !_isLoadingOverlay,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                          labelText: 'No Telepon',
                                          border: OutlineInputBorder()),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return 'Harap masukkan no. telepon';
                                        if (!RegExp(r'^[0-9]+$')
                                            .hasMatch(value))
                                          return 'No. telepon hanya boleh angka';
                                        return null;
                                      },
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // Domisili / Kota/Kabupaten field
                                  GestureDetector(
                                    onTap: _showCitySelectionDialog,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Kota/Kabupaten',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedCity.id != 0
                                                    ? _selectedCity.text
                                                    : 'Pilih Kota/Kabupaten',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: _selectedCity.id != 0
                                                      ? Colors.black87
                                                      : Colors.grey[500],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey[600],
                                              size: screenWidth * 0.06,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // New: Tanggal Lahir field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: tanggalLahirController,
                                      readOnly: true,
                                      onTap: () => _selectDate(
                                          context), // Panggil pemilih tanggal
                                      decoration: InputDecoration(
                                        labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Harap masukkan tanggal lahir'
                                              : null,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // New: Pekerjaan field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: pekerjaanController,
                                      decoration: InputDecoration(
                                          labelText: 'Pekerjaan',
                                          border: OutlineInputBorder()),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Harap masukkan pekerjaan'
                                              : null,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.04),

                                  // Submit button
                                  Center(
                                    child: SizedBox(
                                      // width: double.infinity,
                                      height: screenHeight * 0.06,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting
                                            ? null
                                            : _submitPengajuanAnda,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF017964),
                                          padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.015,
                                            horizontal: screenWidth * 0.04,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.02),
                                          ),
                                        ),
                                        child: _isSubmitting
                                            ? SizedBox(
                                                height: screenHeight * 0.025,
                                                width: screenHeight * 0.025,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                'Ajukan Sekarang',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white, // Tambahkan warna teks putih
                                                    fontSize:
                                                        screenWidth * 0.04),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          screenHeight * 0.04), // Padding bawah
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        if (_isLoadingOverlay || _isLoadingDomisili)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: screenWidth * 0.4,
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF017964),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Mohon tunggu...',
                        style: TextStyle(
                          color: Color(0xFF017964),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    domisiliController.dispose();
    tanggalLahirController.dispose();
    pekerjaanController.dispose();
    super.dispose();
  }
}
