import 'dart:async';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_anda_dao.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/error_card.dart';

class PengajuanAndaScreen extends StatefulWidget {
  @override
  _PengajuanAndaScreenState createState() => _PengajuanAndaScreenState();
}

class _PengajuanAndaScreenState extends State<PengajuanAndaScreen> {
  // GlobalKey untuk form, digunakan untuk validasi
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false; // Indikator loading untuk "Ajukan Sekarang"
  bool _isLoading = false; // Flag untuk menandakan proses loading
  bool _isKtpUploading = false; // Tambahan untuk KTP
  bool _isNpwpUploading = false; // Tambahan untuk NPWP
  bool _isKaripUploading = false; // Tambahan Untuk SK Pensiun
  // Deklarasi Future yang akan digunakan untuk menyimpan data asinkron // untuk mengambil data pengguna (1 yoga)
  late Future<ResultModel<UserModel>> _futureData;

  // Variabel untuk melacak progres upload
  double _ktpUploadProgress = 0.0; // Progres upload KTP
  double _npwpUploadProgress = 0.0; // Progres upload NPWP
  double _karipUploadProgress = 0.0; // Progres upload SK Pensiun

  // Controller untuk input teks
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();
  TextEditingController nipController = TextEditingController();

  // Variabel untuk menyimpan path file
  String? fileKTP;
  String? fileNPWP;
  String? fileKarip;

  // Data Access Object untuk pengajuan
  PengajuanAndaDao pengajuanAndaDao = PengajuanAndaDao();
  // Simulasi progres upload
  Future<void> _simulateUpload(String label) async {
    setState(() {
      if (label == 'KTP') _isKtpUploading = true;
      if (label == 'NPWP') _isNpwpUploading = true;
      if (label == 'Karip') _isKaripUploading = true;
    });

    for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
      await Future.delayed(Duration(milliseconds: 300)); // Simulasi delay
      setState(() {
        if (label == 'KTP') _ktpUploadProgress = progress;
        if (label == 'NPWP') _npwpUploadProgress = progress;
        if (label == 'Karip') _karipUploadProgress = progress;
      });
    }

    setState(() {
      if (label == 'KTP') _isKtpUploading = false;
      if (label == 'NPWP') _isNpwpUploading = false;
      if (label == 'Karip') _isKaripUploading = false;
    });
  }

  // Fungsi untuk memilih file
  // Modifikasi tombol upload untuk simulasi progres upload
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

  Future<void> _submitPengajuanAnda() async {
    if (_formKey.currentState!.validate() &&
        fileKTP != null &&
        fileNPWP != null &&
        fileKarip != null) {
      setState(() {
        _isSubmitting = true; // Menampilkan indikator loading
      });

      // cetak data yang akan dikirim untuk logging
      debugPrint('Submitting pengajuan with data:');

      bool success = await PengajuanAndaDao.kirimPengajuanAnda(
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
      // Set loading state to false
      setState(() {
        _isLoading = false;
      });
      if (success) {
        _showCustomDialog('Sukses', 'Pengajuan Anda Berhasil Dikirim.',
            Icons.check_circle, Colors.green);
      } else {
        _showCustomDialog(
            'Gagal', 'Gagal Mengirim pengajuan', Icons.error, Colors.red);
      }
    }
  }

  void _showCustomDialog(
      String title, String message, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.all(20),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to RiwayatPengajuanPage after the dialog is closed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatPengajuanAndaScreen(
                      onChangeBottomNavIndex: (index) => 1,
                    ),
                  ),
                );
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  //ini berfungsi untuk membuat data user untuk ditampilkan diform (yoga 2)
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller untuk nama dan telepon
    namaController = TextEditingController();
    teleponController = TextEditingController();

    // Memuat data pengguna
    _refreshData();
  }

  // agar mengisi TextEditingController dengan data pengguna yang diperoleh (yoga 3)
  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    _futureData = UserRepository().getOne(token!).then((value) {
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
      // Set data ke TextEditingController
      setState(() {
        namaController.text = value.data?.username ?? '';
        teleponController.text = value.data?.phone ?? '';
      });
      // Cek apakah id_user ada
      if (value.data?.id != null) {
        print('ID User: ${value.data?.id}');
      } else {
        print('ID User tidak tersedia.');
      }
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengajuan Anda'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 5.0),
                        TextFormField(
                          controller: namaController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                              labelText: 'Nama', border: OutlineInputBorder()),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Harap masukkan nama'
                              : null,
                        ),
                        SizedBox(height: 16.0),

                        TextFormField(
                          controller: teleponController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: 'No. Telepon',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Harap masukkan no. telepon';
                            if (!RegExp(r'^[0-9]+$').hasMatch(value))
                              return 'No. telepon hanya boleh angka';
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),

                        TextFormField(
                          controller: domisiliController,
                          decoration: InputDecoration(
                              labelText: 'Kota Domisili',
                              border: OutlineInputBorder()),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Harap masukkan kota domisili'
                              : null,
                        ),
                        SizedBox(height: 16.0),

                        TextFormField(
                          controller: nipController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'NOTAS/NIP',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Harap masukkan NOTAS/NIP';
                            if (value.length != 10) return 'NIP harus 10 digit';
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
                                  text: fileKTP != null
                                      ? fileKTP!.split('/').last
                                      : '',
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
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
                        SizedBox(height: 18.0),

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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
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
                          onPressed: _submitPengajuanAnda,
                          child: Text('Ajukan Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF017964),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
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

  void _resetForm() {
    setState(() {
      namaController.clear();
      teleponController.clear();
      domisiliController.clear();
      nipController.clear();
      fileKTP = null;
      fileNPWP = null;
      fileKarip = null;
    });
  }
}
