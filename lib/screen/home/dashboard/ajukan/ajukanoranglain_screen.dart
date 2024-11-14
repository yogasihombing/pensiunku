import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pensiunku/data/db/ajukan_dao.dart';
import 'package:pensiunku/data/db/ajukanoranglain_dao.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan.dart';

class AjukanOrangLainScreen extends StatefulWidget {
  @override
  _AjukanOrangLainScreenState createState() => _AjukanOrangLainScreenState();
}

class _AjukanOrangLainScreenState extends State<AjukanOrangLainScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isKtpUploading = false; // Tambahan untuk KTP
  bool _isNpwpUploading = false; // Tambahan untuk NPWP
  bool _isSkpensiunUploading = false; // Tambahan Untuk SK Pensiun
  double _ktpUploadProgress = 0.0; // Progres upload KTP
  double _npwpUploadProgress = 0.0; // Progres upload NPWP
  double _skpensiunUploadProgress = 0.0; // Progres upload SK Pensiun

  // Controllers for the form fields
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();
  TextEditingController nipController = TextEditingController();

  String? filePathKTP;
  String? filePathNPWP;
  String? filePathSKPensiun;

  AjukanOrangLainDao ajukanOrangLainDao = AjukanOrangLainDao();

  Future<void> _pickFile(String label) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        if (label == 'KTP') {
          filePathKTP = result.files.single.path;
          _isKtpUploading = true; // Mulai upload KTP
        } else if (label == 'NPWP') {
          filePathNPWP = result.files.single.path;
          _isNpwpUploading = true; // Mulai upload NPWP
        } else if (label == 'SK Pensiun') {
          filePathSKPensiun = result.files.single.path;
          _isSkpensiunUploading = true; // Mulai Upload SK Pensiun
        }
      });

      // Simulasikan proses upload file dengan timer
      _simulateUpload(label);
    }
  }

  void _simulateUpload(String label) {
    const oneSec = Duration(seconds: 1);
    int seconds = 0;

    // Timer untuk mensimulasikan progres upload
    Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (seconds < 10) {
          seconds++;
          if (label == 'KTP') {
            _ktpUploadProgress = seconds / 10; // Progres 10 detik untuk KTP
          } else if (label == 'NPWP') {
            _npwpUploadProgress = seconds / 10; // Progres 10 detik untuk NPWP
          } else if (label == 'SK Pensiun') {
            _skpensiunUploadProgress =
                seconds / 5; // Progres 5 detik untuk SK Pensiun
          }
        } else {
          timer.cancel();
          setState(() {
            if (label == 'KTP') {
              _isKtpUploading = false;
              _ktpUploadProgress = 0.0; // Reset progres setelah selesai
            } else if (label == 'NPWP') {
              _isNpwpUploading = false;
              _npwpUploadProgress = 0.0; // Reset progres setelah selesai
            } else if (label == 'SK Pensiun') {
              _isSkpensiunUploading = false;
              _skpensiunUploadProgress = 0.0; // Reset progres setelah selesai
            }
          });
        }
      });
    });
  }

  Future<void> _submitPengajuan() async {
    if (_formKey.currentState!.validate() &&
        filePathKTP != null &&
        filePathNPWP != null &&
        filePathSKPensiun != null) {
      setState(() {
        _isLoading = true;
      });

      bool success = await ajukanOrangLainDao.kirimPengajuan(
        nama: namaController.text,
        telepon: teleponController.text,
        domisili: domisiliController.text,
        nip: nipController.text,
        fotoKTP: filePathKTP!,
        namaFotoKTP: filePathKTP!.split('/').last,
        fotoNPWP: filePathNPWP!,
        namaFotoNPWP: filePathNPWP!.split('/').last,
        fotoSKPensiun: filePathSKPensiun!,
        namaFotoSKPensiun: filePathSKPensiun!.split('/').last,
      );

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
                // Navigate to RiwayatPengajuanPage after the dialog is closed
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiwayatPengajuanPage(
                      telepon: '085243861919',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 5.0),
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
                            text: filePathKTP != null
                                ? filePathKTP!.split('/').last
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'KTP',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (filePathKTP == null || filePathKTP!.isEmpty) {
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
                              onPressed: () => _pickFile('KTP'),
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
                            text: filePathNPWP != null
                                ? filePathNPWP!.split('/').last
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'NPWP',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (filePathNPWP == null || filePathNPWP!.isEmpty) {
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
                              onPressed: () => _pickFile('NPWP'),
                              child: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  // SK Pensiun Upload Field
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text: filePathSKPensiun != null
                                ? filePathSKPensiun!.split('/').last
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: 'SK Pensiun/SK Aktif/Karip/Karpeg',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (filePathSKPensiun == null ||
                                filePathSKPensiun!.isEmpty) {
                              return 'Harap upload dokumen SK Pensiun';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      _isSkpensiunUploading // Jika sedang upload, tampilkan progres
                          ? Expanded(
                              child: LinearProgressIndicator(
                                value:
                                    _npwpUploadProgress, // Menampilkan progres upload SK Pensiun
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _pickFile('SKPensiun'),
                              child: Text('Upload'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 24.0),

                  ElevatedButton(
                    onPressed: _submitPengajuan,
                    child: Text('Ajukan Orang Lain Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF017964),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
