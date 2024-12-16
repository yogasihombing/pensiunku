import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_orang_lain_dao.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_orang_lain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengajuanOrangLainScreen extends StatefulWidget {
  @override
  _PengajuanOrangLainScreenState createState() =>
      _PengajuanOrangLainScreenState();
}

class _PengajuanOrangLainScreenState extends State<PengajuanOrangLainScreen> {
  // GlobalKey untuk form, digunakan untuk validasi
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isKtpUploading = false; // Tambahan untuk KTP
  bool _isNpwpUploading = false; // Tambahan untuk NPWP
  bool _isKaripUploading = false; // Tambahan Untuk SK Pensiun

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
    _getId(); // Ambil ID User
  }

  Future<void> _getId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('id_user');
    debugPrint('Stored ID User: $storedId');
    setState(() {
      id = storedId;
      idController.text = storedId ?? ''; // Sinkronkan ke controller
      id = prefs.getString('id_user');
    });
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
    if (idController.text.isEmpty) {
      debugPrint('Error: ID User tidak ditemukan.');
      _showCustomDialog(
          'Gagal',
          'ID User tidak ditemukan. Silahkan coba lagi. ',
          Icons.error,
          Colors.red);
      return;
    }

    if (_formKey.currentState!.validate() &&
        fileKTP != null &&
        fileNPWP != null &&
        fileKarip != null) {
      setState(() {});
      // cetak data yang akan dikirim untuk logging
      debugPrint('Submitting pengajuan with data:');

      // Cetak data yang akan dikirim untuk logging
      print('Submitting pengajuan with data:');
      debugPrint('id_user: ${idController.text}');
      print('Nama: ${namaController.text}');
      print('Telepon: ${teleponController.text}');
      print('Domisili: ${domisiliController.text}');
      print('NIP: ${nipController.text}');

      // Kirim pengajuan melalui DAO
      bool success = await PengajuanOrangLainDao.kirimPengajuanOrangLain(
        // id: idController.text,
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
        _isLoading = false;
      });

      if (success) {
        _showCustomDialog('Sukses', 'Pengajuan Orang Lain berhasil dikirim',
            Icons.check_circle, Colors.green);
      } else {
        _showCustomDialog(
            'Gagal', 'Gagal mengirim pengajuan', Icons.error, Colors.red);
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
                // Navigate to RiwayatPengajuanOrangLainScreen after the dialog is closed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatPengajuanOrangLainScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengajuan Orang lain'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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

                TextFormField(
                  controller: domisiliController,
                  decoration: InputDecoration(
                      labelText: 'Kota Domisili', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Harap masukkan kota domisili'
                      : null,
                ),
                SizedBox(height: 16.0),

                TextFormField(
                  controller: nipController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'NOTAS/NIP', border: OutlineInputBorder()),
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
                          text: fileKTP != null ? fileKTP!.split('/').last : '',
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
                          text:
                              fileNPWP != null ? fileNPWP!.split('/').last : '',
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
                  child: Text('Ajukan Orang Lain Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF017964),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    namaController.dispose();
    teleponController.dispose();
    domisiliController.dispose();
    nipController.dispose();
    super.dispose();
  }
}
