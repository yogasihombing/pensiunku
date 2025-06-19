import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_orang_lain_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_orang_lain.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:path/path.dart' as path;

class PengajuanOrangLainScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/pengajuan_orang_lain';
  @override
  _PengajuanOrangLainScreenState createState() =>
      _PengajuanOrangLainScreenState();
}

class _PengajuanOrangLainScreenState extends State<PengajuanOrangLainScreen> {
  // GlobalKey untuk form, digunakan untuk validasi
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingOverlay = false;
  bool _isKtpUploading = false; // Tambahan untuk KTP
  bool _isNpwpUploading = false; // Tambahan untuk NPWP
  bool _isKaripUploading = false; // Tambahan Untuk SK Pensiun
  UserModel? _userModel;
  late Future<ResultModel<UserModel>> _future;
  late OptionModel _selectedCity = OptionModel(id: 0, text: '');

  final TextEditingController _searchController = TextEditingController();
  List<OptionModel> _filteredCities = List.from(LocationRepository.cities);

  // Variabel untuk melacak progres upload
  double _ktpUploadProgress = 0.0; // Progres upload KTP
  double _npwpUploadProgress = 0.0; // Progres upload NPWP
  double _karipUploadProgress = 0.0; // Progres upload SK Pensiun

  // Controllers for the form fields
  TextEditingController idController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();
  TextEditingController nipController = TextEditingController();

  // Variabel untuk menyimpan path file
  String? fileKTP;
  String? fileNPWP;
  String? fileKarip;
  String? id; // #1 Fungsi untuk menyisipkan id user yang input data di Form

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    if (token != null) {
      _future = UserRepository().getOne(token);
      _future.then((result) {
        if (result.error == null) {
          setState(() {
            _userModel = result.data;
            print('User ID: ${_userModel?.id}');
          });
        } else {
          print('Gagal mendapatkan data pengguna: ${result.error}');
        }
      });
    } else {
      print('Token tidak tersedia.');
    }
  }

  // Data Access Object untuk pengajuan
  PengajuanOrangLainDao pengajuanOrangLainDao = PengajuanOrangLainDao();

  Future<void> _simulateUpload(String label) async {
    setState(() {
      if (label == 'KTP') _isKtpUploading = true;
      if (label == 'NPWP') _isNpwpUploading = true;
      if (label == 'Karip') _isKaripUploading = true;
    });
    for (double progres = 0.0; progres <= 1.0; progres += 0.1) {
      await Future.delayed(Duration(milliseconds: 300)); // Simulasi delay
      setState(() {
        if (label == 'KTP') _ktpUploadProgress = progres;
        if (label == 'NPWP') _npwpUploadProgress = progres;
        if (label == 'Karip') _karipUploadProgress = progres;
      });
    }
    setState(() {
      if (label == 'KTP') _isKtpUploading = false;
      if (label == 'NPWP') _isNpwpUploading = false;
      if (label == 'Karip') _isKaripUploading = false;
    });
  }

// Tambahkan variabel untuk nama file
  String? namaFotoKTP;
  String? namaFotoNPWP;
  String? namaFotoKarip;
  //Fungsi untuk memilih file dan modifikasi tombol upload untuk simulasi progres upload
  Future<void> _pickImage(String label) async {
    // Tampilkan pilihan sumber gambar
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    // Dapatkan nama file asli
    String fileName = path.basename(image.path);

    setState(() {
      if (label == 'KTP') {
        fileKTP = image.path;
        namaFotoKTP = fileName;
      } else if (label == 'NPWP') {
        fileNPWP = image.path;
        namaFotoNPWP = fileName;
      } else if (label == 'Karip') {
        fileKarip = image.path;
        namaFotoKarip = fileName;
      }
    });

    await _simulateUpload(label);
  }

  Future<void> _submitPengajuanOrangLain() async {
    // if (idController.text.isEmpty) {
    //   debugPrint(idController.text);
    //   debugPrint('Error: ID User tidak ditemukan.');
    //   _showCustomDialog(
    //       'Gagal',
    //       'ID User tidak ditemukan. Silahkan coba lagi. ',
    //       Icons.error,
    //       Colors.red);
    //   return;
    // }

    if (_formKey.currentState!.validate() &&
        fileKTP != null &&
        fileNPWP != null &&
        fileKarip != null) {
      try {
        setState(() {
          _isLoadingOverlay = true; // Aktifkan loading
        });
        // cetak data yang akan dikirim untuk logging
        debugPrint('Submitting pengajuan with data:');

        // Cetak data yang akan dikirim untuk logging
        print('Submitting pengajuan with data:');
        debugPrint('id_usersssss: ${_userModel?.id}');
        print('Nama: ${namaController.text}');
        print('Telepon: ${teleponController.text}');
        print('Domisili: ${domisiliController.text}');
        print('NIP: ${nipController.text}');

        // Kirim pengajuan melalui DAO
        bool success = await PengajuanOrangLainDao.kirimPengajuanOrangLain(
          id: "${_userModel?.id}",
          nama: namaController.text,
          telepon: teleponController.text,
          domisili: domisiliController.text,
          nip: nipController.text,
          fotoKTP: fileKTP!,
          // namaFotoKTP: fileKTP!.split('/').last,
          fotoNPWP: fileNPWP!,
          // namaFotoNPWP: fileNPWP!.split('/').last,
          fotoKarip: fileKarip!,
          // namaFotoKarip: fileKarip!.split('/').last,
          namaFotoKTP: namaFotoKTP!,
          namaFotoNPWP: namaFotoNPWP!,
          namaFotoKarip: namaFotoKarip!,
        );
        print('Pengajuan berhasil: $success');

        // Set loading state to false

        if (success) {
          _showCustomDialog('Sukses', 'Pengajuan Orang Lain berhasil dikirim');
        } else {
          _showCustomDialog(
              'Gagal', 'Nomor telepon harus beda dengan nomor telepon anda!');
        }
      } catch (e) {
        print('Error during submission: $e');
        _showCustomDialog('Error', 'Terjadi kesalahan saat mengirim pengajuan');
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingOverlay = false;
          });
        }
      }
    }
  }

  Future<void> _showCitySelectionDialog() async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Create a filtered list that will be updated with search
    List<OptionModel> filteredCities = List.from(LocationRepository.cities);
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Handle search function
            void handleSearch(String query) {
              setDialogState(() {
                if (query.isEmpty) {
                  filteredCities = List.from(LocationRepository.cities);
                } else {
                  filteredCities = LocationRepository.cities
                      .where((city) =>
                          city.text.toLowerCase().contains(query.toLowerCase()))
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
                    // Search field
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
                    // List of cities
                    Expanded(
                      child: filteredCities.isEmpty
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
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.005,
                                      horizontal: screenWidth * 0.02,
                                    ),
                                    title: Text(
                                      city.text,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _selectedCity = city;
                                        domisiliController.text = city.text;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Cancel button
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

  void _showCustomDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 15),
            content: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF017964),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF017964),
                      minimumSize: const Size(120, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiwayatPengajuanOrangLainScreen(
                            onChangeBottomNavIndex: (index) => 1,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    // Tambahkan dua baris ini
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background gradient
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
          backgroundColor: Colors.transparent, // Pastikan scaffold transparan

          appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(kToolbarHeight + screenHeight * 0.02),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: kToolbarHeight + screenHeight * 0.01,
              // 1. Bungkus leading dengan Padding agar tombol back turun
              leading: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.01),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              centerTitle: true,
              // 2. Bungkus title dengan Padding agar judul juga turun
              title: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.01),
                child: Text(
                  'Form Mitra',
                  style: TextStyle(
                    color: Color(0xFF017964),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (id != null) // ###
                    Text('ID Pengguna: $id'), // Tampilkan ID User
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                        labelText: 'Nama', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Harap masukkan nama'
                        : null,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        labelText: 'No. Telepon', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Harap masukkan no. telepon';
                      if (!RegExp(r'^[0-9]+$').hasMatch(value))
                        return 'No. telepon hanya boleh angka';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Ganti widget TextFormField domisili dengan ini
                  GestureDetector(
                    onTap: _showCitySelectionDialog,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kota/Kabupaten',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _selectedCity.id != 0
                                    ? _selectedCity.text
                                    : 'Pilih Kota/Kabupaten',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedCity.id != 0
                                      ? Colors.black87
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  TextFormField(
                    controller: nipController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'NOTAS/NIP', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harap masukkan NOTAS/NIP';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),

                  // KTP Upload Field
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: namaFotoKTP ?? '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'KTP',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (fileKTP == null || fileKTP!.isEmpty) {
                              return 'Harap upload dokumen KTP';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      _isKtpUploading // Jika sedang upload, tampilkan progres
                          ? Expanded(
                              child: LinearProgressIndicator(
                                value: _ktpUploadProgress,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _pickImage('KTP'),
                              child: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 16.0),

                  // NPWP Upload Field
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              TextEditingController(text: namaFotoNPWP ?? ''),
                          decoration: InputDecoration(
                            labelText: 'NPWP',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (fileNPWP == null || fileNPWP!.isEmpty) {
                              return 'Harap upload dokumen NPWP';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      _isNpwpUploading // Jika sedang upload, tampilkan progres
                          ? Expanded(
                              child: LinearProgressIndicator(
                                value: _npwpUploadProgress,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _pickImage('NPWP'),
                              child: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  // Karip Upload Field
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              TextEditingController(text: namaFotoKarip ?? ''),
                          decoration: InputDecoration(
                            labelText: 'SK Pensiun/SK Aktif/Karip/Karpeg',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (fileKarip == null || fileKarip!.isEmpty) {
                              return 'Harap upload dokumen SK Pensiun';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      _isKaripUploading // Jika sedang upload, tampilkan progres
                          ? Expanded(
                              child: LinearProgressIndicator(
                                value: _karipUploadProgress,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _pickImage('Karip'),
                              child: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 24.0),

                  ElevatedButton(
                    onPressed: _submitPengajuanOrangLain,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF017964)),
                    child: Text('Ajukan Orang Lain Sekarang'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoadingOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final screenHeight = MediaQuery.of(context).size.height;

                    return Container(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      width: screenWidth * 0.7, // 70% dari lebar layar
                      height: screenHeight * 0.25, // 25% dari tinggi layar
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: screenWidth * 0.02,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            child: CircularProgressIndicator(
                              strokeWidth: screenWidth * 0.015,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF017964)),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Mohon tunggu...',
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.045, // 4.5% dari lebar layar
                              color: Color(0xFF017964),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
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
    nipController.dispose();
    super.dispose();
  }
}
