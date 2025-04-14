import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SimulasiCepatScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/simulasi-cepat';

  SimulasiCepatScreen();

  @override
  State<SimulasiCepatScreen> createState() => _SimulasiCepatScreenState();
}

class _SimulasiCepatScreenState extends State<SimulasiCepatScreen> {
  // Controller dan state variables
  final _formKey = GlobalKey<FormState>();
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _tanggalPensiunController =
      TextEditingController();
  final TextEditingController _gajiPensiunController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  String _statusPengaju = 'Pra-Pensiun';
  bool _hasilSimulasi = false;
  bool _isLoading = false;

  Map<String, dynamic>? _simulationResult;
  String _errorMessage = '';
  String _generatedCode = '';

  // Error tracking - NEW
  Map<String, String> _fieldErrors = {
    'nama': '',
    'tanggalLahir': '',
    'tanggalPensiun': '',
    'gajiPensiun': '',
    'nomorTelepon': '',
  };

  // Format number
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Format number tanpa symbol
  final NumberFormat _numberFormat = NumberFormat.decimalPattern('id');

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _tanggalPensiunController.dispose();
    _gajiPensiunController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  // Fungsi untuk call API
  Future<void> _callSimulationAPI() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _simulationResult = null;
      });

      debugPrint("Memulai proses API simulasi");

      final produk = _statusPengaju == 'Pra-Pensiun' ? 'PRA' : 'KPB';
      final tglLahir = _tanggalLahirController.text;
      final tmtPensiun =
          _statusPengaju == 'Pra-Pensiun' ? _tanggalPensiunController.text : '';
      final gaji = _gajiPensiunController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .replaceAll(',', '');

      var headers = {
        'x-api-key':
            '3G6jo4zVuoT6sTvxPy3FksxbJ872OxfziXRCRlSwxdMdH4j7O2ACKi3ZDQ8qmPbs',
      };

      debugPrint("Headers: $headers");

      var request = http.MultipartRequest('POST',
          Uri.parse('https://www.nabasa.co.id/bank_capital/bci/tes.php'));
      request.headers.addAll(headers);
      request.fields.addAll({
        'nopen': '',
        'chek_v2': '0',
        'produk': produk,
        'gaji': gaji,
        'tgl_lahir': tglLahir,
        'tmt_pensiun': tmtPensiun,
        'nominal': '0',
        'jangka_waktu': '0',
        'sisa_hutang': '0',
        'master_dapem': 'NO',
        'versi_simulasi': 'SV12',
      });

      debugPrint("Request Fields: ${request.fields}");

      http.StreamedResponse response = await request.send();
      debugPrint("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint("Response Body: $responseBody");

        final data = json.decode(responseBody);
        debugPrint("Status API: ${data['status']}");
        debugPrint("Data structure: ${data['data'].runtimeType}");

        if (data['status'] == 'true' || data['status'] == 'success') {
          if (data.containsKey('data') &&
              data['data'] is List &&
              data['data'].isNotEmpty) {
            debugPrint("First data element: ${data['data'][0]}");

            // Simpan hasil simulasi terlebih dahulu
            await _saveSimulation(data['data'][0]);

            // Setelah penyimpanan selesai, tampilkan hasil simulasi
            setState(() {
              _simulationResult = data['data'][0];
              _hasilSimulasi = true;
            });
          } else {
            throw Exception('Format data tidak sesuai');
          }
        } else {
          throw Exception(data['message'] ?? 'Gagal melakukan simulasi');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Terjadi error: ${e.toString()}");

      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _simulationResult = null; // Reset hasil jika error
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Terjadi Kesalahan'),
          content: Text(_errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Proses API simulasi selesai");
    }
  }

  // 4. FUNGSI BARU UNTUK API SAVE
  Future<void> _saveSimulation(dynamic simulationData) async {
    try {
      debugPrint("[SAVE SIMULASI] Memulai proses penyimpanan...");
      debugPrint("[SAVE SIMULASI] Data yang dikirim:");
      debugPrint("- Nama: ${_namaController.text}");
      debugPrint("- Tanggal Lahir: ${_tanggalLahirController.text}");
      debugPrint(
          "- Status: ${_statusPengaju == 'Pra-Pensiun' ? 'PRA' : 'KPB'}");
      debugPrint("- Tanggal Pensiun: ${_tanggalPensiunController.text}");
      debugPrint(
          "- Gaji: ${_gajiPensiunController.text.replaceAll(RegExp(r'[^0-9]'), '')}");
      debugPrint("- Telepon: ${_nomorTeleponController.text}");

      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/saveSimulasi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            "nama": _namaController.text,
            "tanggal_lahir": _tanggalLahirController.text,
            "status": _statusPengaju == 'Pra-Pensiun' ? 'PRA' : 'KPB',
            "tanggal_pensiun": _tanggalPensiunController.text,
            "gaji":
                _gajiPensiunController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            "telepon": _nomorTeleponController.text,
            "usia": simulationData['usia']?.toString() ?? '',
            "max_jangka": simulationData['max_jangka']?.toString() ?? '',
            "nominal": simulationData['nominal']?.toString() ?? '',
            "biaya_tata_laksana":
                simulationData['biaya_tata_laksana']?.toString() ?? '',
            "biaya_premi_suransi":
                simulationData['biaya_premi_suransi']?.toString() ?? '',
            "biaya_provisi": simulationData['biaya_provisi']?.toString() ?? '',
            "biaya_administrasi":
                simulationData['biaya_administrasi']?.toString() ?? '',
            "jumlah_blokir": simulationData['jumlah_blokir']?.toString() ?? '',
            "jumlah_diterima":
                simulationData['jumlah_diterima']?.toString() ?? '',
            "angsuran_bank": simulationData['angsuran_bank']?.toString() ?? '',
            "angsuran_mitra":
                simulationData['angsuran_mitra']?.toString() ?? '',
            "angsuran_efektif":
                simulationData['angsuran_efektif']?.toString() ?? '',
            "biaya_angsuran":
                simulationData['biaya_angsuran']?.toString() ?? '',
            "cicilan_asuransi":
                simulationData['cicilan_asuransi']?.toString() ?? '',
            "rate_bunga_tahun":
                simulationData['rate_bunga_tahun']?.toString() ?? '',
            "rate_premi_asuransi":
                simulationData['rate_premi_asuransi']?.toString() ?? '',
            "versi_simulasi":
                simulationData['versi_simulasi']?.toString() ?? '',
          },
        ),
      );

      debugPrint(
          "[SAVE SIMULASI] Response Status Code: ${response.statusCode}");
      debugPrint("[SAVE SIMULASI] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Perbaiki cara mengambil kode dari response JSON
        final simCode = responseData['text']?['code'];
        debugPrint("[SAVE SIMULASI] Simulasi tersimpan dengan code: $simCode");
        setState(() {
          _generatedCode = simCode ?? 'KOSONG';
        });
      } else {
        debugPrint("[SAVE SIMULASI] Gagal menyimpan. Status code tidak 200");
      }
    } catch (e) {
      debugPrint("[SAVE SIMULASI] ERROR: ${e.toString()}");
      print('Error save simulation: $e');
    }
  }

  // Fungsi untuk menampilkan hasil
  Widget _buildResultDisplay() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Berikut Hasil dari simulasi Bapak/Ibu:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF017964),
            ),
          ),
          SizedBox(height: 8),
          _buildResultRow('Plafond Pinjaman:', _simulationResult!['nominal']),
          _buildResultRow('Jangka Waktu/Tenor:',
              '${_simulationResult!['max_jangka']} bulan'),
          _buildResultRow('Angsuran:', _simulationResult!['angsuran_efektif']),
          _buildResultRow(
              'Terima Bersih:', _simulationResult!['jumlah_diterima']),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, dynamic value) {
    final formattedValue =
        value is num ? _numberFormat.format(value) : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            formattedValue,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

// Fungsi untuk membuka WhatsApp
  void _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
        'whatsapp://send?phone=+6287785833344&text=Hallo%20admin%20pensiunku,%20saya%20mau%20menanyakan%20perihal%20simulasi%20aplikasi%20Pensiunku%3F');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl); // Buka langsung di aplikasi WhatsApp
    } else {
      // Fallback ke versi web jika WhatsApp tidak terinstall
      await launchUrl(
          Uri.parse('https://web.whatsapp.com/send?phone=+6287785833344'));
    }
  }

  // Fungsi untuk mengambil screenshot dan menyimpannya ke galeri
  Future<void> _captureAndSaveScreenshot() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: Duration(milliseconds: 200), // Delay untuk render widget
        // captureMode: CaptureMode.entireWidget, // Ambil seluruh konten widget
      );

      if (imageBytes != null) {
        // Simpan ke galeri
        await ImageGallerySaver.saveImage(imageBytes);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Screenshot tersimpan!')));
      }
    } catch (e) {
      print("Gagal: $e");
    }
  }

  // NEW - Field validation functions that set error messages but don't change layout
  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['nama'] = 'Harap masukkan nama';
      return '';
    }
    _fieldErrors['nama'] = '';
    return null;
  }

  String? validateTanggalLahir(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['tanggalLahir'] = 'Harap masukkan tanggal lahir';
      return '';
    }

    // Validasi format dd-mm-yyyy
    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(value)) {
      _fieldErrors['tanggalLahir'] = 'Format tanggal harus dd-mm-yyyy';
      return '';
    }

    // Ekstrak nilai tanggal, bulan, dan tahun
    final parts = value.split('-');
    final day = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final year = int.tryParse(parts[2]) ?? 0;

    // Validasi nilai tanggal dan bulan
    if (day < 1 || day > 31) {
      _fieldErrors['tanggalLahir'] = 'Tanggal harus antara 1-31';
      return '';
    }
    if (month < 1 || month > 12) {
      _fieldErrors['tanggalLahir'] = 'Bulan harus antara 1-12';
      return '';
    }

    // Validasi tanggal valid untuk bulan tertentu
    if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
      _fieldErrors['tanggalLahir'] = 'Bulan ini hanya memiliki 30 hari';
      return '';
    }

    // Validasi Februari dan tahun kabisat
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (day > (isLeapYear ? 29 : 28)) {
        _fieldErrors['tanggalLahir'] =
            'Februari ${isLeapYear ? "hanya memiliki 29 hari" : "hanya memiliki 28 hari"}';
        return '';
      }
    }

    _fieldErrors['tanggalLahir'] = '';
    return null;
  }

  String? validateTanggalPensiun(String? value) {
    if (_statusPengaju != 'Pra-Pensiun') {
      _fieldErrors['tanggalPensiun'] = '';
      return null;
    }

    if (value == null || value.isEmpty) {
      _fieldErrors['tanggalPensiun'] = 'Harap masukkan tanggal pensiun';
      return '';
    }

    // Validasi format dd-mm-yyyy
    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(value)) {
      _fieldErrors['tanggalPensiun'] = 'Format tanggal harus dd-mm-yyyy';
      return '';
    }

    // Ekstrak nilai tanggal, bulan, dan tahun
    final parts = value.split('-');
    final day = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;

    // Validasi nilai tanggal dan bulan
    if (day < 1 || day > 31) {
      _fieldErrors['tanggalPensiun'] = 'Tanggal harus antara 1-31';
      return '';
    }
    if (month < 1 || month > 12) {
      _fieldErrors['tanggalPensiun'] = 'Bulan harus antara 1-12';
      return '';
    }

    _fieldErrors['tanggalPensiun'] = '';
    return null;
  }

  String? validateGajiPensiun(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['gajiPensiun'] = 'Harap masukkan gaji pensiun';
      return '';
    }
    _fieldErrors['gajiPensiun'] = '';
    return null;
  }

  String? validateNomorTelepon(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['nomorTelepon'] = 'Harap masukkan nomor telepon yang aktif';
      return '';
    }
    _fieldErrors['nomorTelepon'] = '';
    return null;
  }

  // NEW - Check if all fields are valid
  bool validateForm() {
    validateNama(_namaController.text);
    validateTanggalLahir(_tanggalLahirController.text);
    if (_statusPengaju == 'Pra-Pensiun') {
      validateTanggalPensiun(_tanggalPensiunController.text);
    } else {
      _fieldErrors['tanggalPensiun'] = '';
    }
    validateGajiPensiun(_gajiPensiunController.text);
    validateNomorTelepon(_nomorTeleponController.text);

    // Check if any errors exist
    return !_fieldErrors.values.any((error) => error.isNotEmpty);
  }

  // Build a form field with error message below
  Widget buildFormFieldWithError({
    required TextEditingController controller,
    required String fieldKey,
    required String label,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFF017964),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 36,
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              isDense: true,
              hintText: hintText,
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _fieldErrors[fieldKey]!.isNotEmpty
                        ? Colors.red
                        : Color(0xFF017964)),
                borderRadius: BorderRadius.circular(30.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _fieldErrors[fieldKey]!.isNotEmpty
                        ? Colors.red
                        : Color(0xFF017964),
                    width: 2.0),
                borderRadius: BorderRadius.circular(30.0),
              ),
              errorStyle: TextStyle(height: 0, fontSize: 0),
            ),
            validator: validator,
          ),
        ),
        if (_fieldErrors[fieldKey]!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 2.0),
            child: Text(
              _fieldErrors[fieldKey]!,
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          ),
        SizedBox(height: 10.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi top bar (misalnya 56) dan padding atas dari SafeArea.
    final double topBarHeight = 56.0;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true, // untuk menghindari masalah keyboard
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            // Latar belakang gradien yang mengisi layar.
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
            // Custom top bar dengan tombol back dan judul.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: topBarHeight,
                  child: Stack(
                    children: [
                      // Tombol back di kiri.
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF017964)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Judul di tengah.
                      Center(
                        child: Text(
                          'Simulasi Cepat Pensiunku (SCP)',
                          style: const TextStyle(
                            color: Color(0xFF017964),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Konten layar. Mengatur posisi agar tidak tertutup top bar.
            Positioned.fill(
              top: topBarHeight + topPadding,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gambar pensiunku.png di tengah.
                      Center(
                        child: Image.asset(
                          'assets/register_screen/pensiunku.png',
                          height: 35,
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field Nama
                          buildFormFieldWithError(
                            controller: _namaController,
                            fieldKey: 'nama',
                            label: 'Nama Pengaju:',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                            ],
                            validator: validateNama,
                          ),

                          // Field Tanggal Lahir
                          buildFormFieldWithError(
                            controller: _tanggalLahirController,
                            fieldKey: 'tanggalLahir',
                            label: 'Tanggal Lahir Pengaju:',
                            keyboardType: TextInputType.number,
                            hintText: 'dd-mm-yyyy',
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            onChanged: (value) {
                              String digitsOnly = value.replaceAll('-', '');
                              String formatted = '';

                              // Format saat mengetik
                              if (digitsOnly.isNotEmpty) {
                                // Tambahkan 2 digit pertama (tanggal)
                                formatted = digitsOnly.substring(
                                    0, min(2, digitsOnly.length));

                                // Tambahkan pemisah dan 2 digit bulan
                                if (digitsOnly.length > 2) {
                                  formatted += '-' +
                                      digitsOnly.substring(
                                          2, min(4, digitsOnly.length));
                                }

                                // Tambahkan pemisah dan digit tahun
                                if (digitsOnly.length > 4) {
                                  formatted += '-' +
                                      digitsOnly.substring(
                                          4, min(8, digitsOnly.length));
                                }

                                // Atur ulang teks dan posisi kursor
                                _tanggalLahirController.value =
                                    TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length),
                                );
                              }
                            },
                            validator: validateTanggalLahir,
                          ),

                          // Field Status Pengaju
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Status pengaju:',
                              style: TextStyle(
                                color: Color(0xFF017964),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Radio<String>(
                                value: 'Pra-Pensiun',
                                groupValue: _statusPengaju,
                                onChanged: (String? value) {
                                  setState(() {
                                    _statusPengaju = value!;
                                  });
                                },
                              ),
                              Text('Pra-Pensiun'),
                              SizedBox(width: 16),
                              Radio<String>(
                                value: 'Pensiun',
                                groupValue: _statusPengaju,
                                onChanged: (String? value) {
                                  setState(() {
                                    _statusPengaju = value!;
                                  });
                                },
                              ),
                              Text('Pensiun'),
                            ],
                          ),
                          SizedBox(height: 10.0),

                          // Field Tanggal Pensiun - hanya muncul jika status Pra-Pensiun
                          if (_statusPengaju == 'Pra-Pensiun')
                            buildFormFieldWithError(
                              controller: _tanggalPensiunController,
                              fieldKey: 'tanggalPensiun',
                              label: 'Tanggal Pensiun:',
                              keyboardType: TextInputType.number,
                              hintText: 'dd-mm-yyyy',
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              onChanged: (value) {
                                String digitsOnly = value.replaceAll('-', '');
                                String formatted = '';

                                // Format saat mengetik
                                if (digitsOnly.isNotEmpty) {
                                  // Tambahkan 2 digit pertama (tanggal)
                                  formatted = digitsOnly.substring(
                                      0, min(2, digitsOnly.length));

                                  // Tambahkan pemisah dan 2 digit bulan
                                  if (digitsOnly.length > 2) {
                                    formatted += '-' +
                                        digitsOnly.substring(
                                            2, min(4, digitsOnly.length));
                                  }

                                  // Tambahkan pemisah dan digit tahun
                                  if (digitsOnly.length > 4) {
                                    formatted += '-' +
                                        digitsOnly.substring(
                                            4, min(8, digitsOnly.length));
                                  }

                                  // Atur ulang teks dan posisi kursor
                                  _tanggalPensiunController.value =
                                      TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length),
                                  );
                                }
                              },
                              validator: validateTanggalPensiun,
                            ),

                          // Field Gaji Pensiun
                          buildFormFieldWithError(
                            controller: _gajiPensiunController,
                            fieldKey: 'gajiPensiun',
                            label: 'Gaji pensiun:',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              // Format input sebagai mata uang (Rupiah)
                              if (value.isNotEmpty) {
                                final numericValue = int.parse(
                                    value.replaceAll(RegExp(r'[^0-9]'), ''));
                                _gajiPensiunController.value = TextEditingValue(
                                  text: _currencyFormat.format(numericValue),
                                  selection: TextSelection.collapsed(
                                    offset: _currencyFormat
                                        .format(numericValue)
                                        .length,
                                  ),
                                );
                              }
                            },
                            validator: validateGajiPensiun,
                          ),

                          // Field Nomor Telepon
                          buildFormFieldWithError(
                            controller: _nomorTeleponController,
                            fieldKey: 'nomorTelepon',
                            label: 'Nomor Telepon Yang Dapat Dihubungi:',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: validateNomorTelepon,
                          ),

                          // Field Hasil simulasi
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF017964)),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: _isLoading
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                            color: Color(0xFF017964)),
                                        SizedBox(height: 8),
                                        Text(
                                          "Sedang menghitung simulasi...",
                                          style: TextStyle(
                                              color: Color(0xFF017964),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Tombol Lihat Hasil Simulasi
                                          Flexible(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (validateForm()) {
                                                      _callSimulationAPI();
                                                    } else {
                                                      setState(() {});
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color(0xFFFFC950),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      side: BorderSide(
                                                          color: Color(
                                                              0xFF017964)),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                  ),
                                                  child: Text(
                                                    "Lihat Hasil Simulasi!",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Kode Generate
                                          if (_generatedCode.isNotEmpty)
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 16.0),
                                                child: Text(
                                                  'Kode: $_generatedCode',
                                                  style: TextStyle(
                                                    color: Color(0xFF017964),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // Tampilkan hasil di bawah tombol dan kode
                                      if (_simulationResult != null)
                                        _buildResultDisplay(),
                                    ],
                                  ),
                          ),
                          SizedBox(height: 10.0),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Widget pertama - Unduh Simulasi
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ElevatedButton(
                                      onPressed: _hasilSimulasi
                                          ? _captureAndSaveScreenshot
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.grey.shade300,
                                        fixedSize: Size(150, 20),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            "Unduh Simulasi!",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _hasilSimulasi
                                                  ? Colors.black
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              // Widget kedua - Hubungi Kami
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: ElevatedButton(
                                      onPressed: _launchWhatsApp,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF017964),
                                        fixedSize: Size(150, 20),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            "Hubungi Kami!",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 16.0),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Syarat Dan Ketentuan:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF017964)),
                          ),
                          SizedBox(height: 10),
                          // Point 1
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30, // lebar untuk nomor
                                child: Text(
                                  '1.',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Pastikan anda memasukkan data keterangan sesuai dengan benar dan tepat!',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                            ],
                          ),

                          // Point 2
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '2.',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Kalkuator ini bersifat hitungan sementara, karena belum dihitung sisa hutang bapak/ibu (bila ada)',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                            ],
                          ),

                          // Point 3
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '3.',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Untuk solusi keuangan bapak/ibu, silahkan hubungi petugas kami.',
                                  style: TextStyle(color: Color(0xFF017964)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
