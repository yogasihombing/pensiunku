import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_orang_lain_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_orang_lain.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

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

  //Fungsi untuk memilih file dan modifikasi tombol upload untuk simulasi progres upload
  Future<void> _pickImage(String label) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    setState(() {
      if (label == 'KTP') fileKTP = image.path;
      if (label == 'NPWP') fileNPWP = image.path;
      if (label == 'Karip') fileKarip = image.path;
    });
    // Simulasi proses upload
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
      setState(() {});
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
        namaFotoKTP: fileKTP!.split('/').last,
        fotoNPWP: fileNPWP!,
        namaFotoNPWP: fileNPWP!.split('/').last,
        fotoKarip: fileKarip!,
        namaFotoKarip: fileKarip!.split('/').last,
      );
      print('Pengajuan berhasil: $success');

      // Set loading state to false
      setState(() {
        _isLoadingOverlay = false;
      });

      if (success) {
        _showCustomDialog('Sukses', 'Pengajuan Orang Lain berhasil dikirim');
      } else {
        _showCustomDialog(
            'Gagal', 'Nomor telepon harus beda dengan nomor telepon anda!');
      }
    }
  }

  Future<void> _showCitySelectionDialog() async {
    final city = await showDialog<OptionModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Kota/Kabupaten'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocationRepository.cities.length,
              itemBuilder: (context, index) {
                final city = LocationRepository.cities[index];
                return ListTile(
                  title: Text(city.text),
                  onTap: () {
                    Navigator.of(context).pop(city);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (city != null) {
      setState(() {
        _selectedCity = city;
        domisiliController.text = city.text;
      });
    }
  }

  void _showCustomDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          appBar: AppBar(title: Text('Form Mitra')),
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
                            text:
                                fileKTP != null ? fileKTP!.split('/').last : '',
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
                                value:
                                    _ktpUploadProgress, // Menampilkan progres upload KTP
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
                          controller: TextEditingController(
                            text: fileNPWP != null
                                ? fileNPWP!.split('/').last
                                : '',
                          ),
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
                                value:
                                    _npwpUploadProgress, // Menampilkan progres upload NPWP
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
                          controller: TextEditingController(
                            text: fileKarip != null
                                ? fileKarip!.split('/').last
                                : '',
                          ),
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
                                value:
                                    _karipUploadProgress, // Menampilkan progres upload SK Pensiun
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
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF017964))),
                    SizedBox(height: 16),
                    Text('Mohon tunggu...',
                        style: TextStyle(
                            color: Color(0xFF017964),
                            fontWeight: FontWeight.bold)),
                  ],
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
