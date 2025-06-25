import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pensiunku/data/api/user_api.dart';
import 'package:pensiunku/model/e_wallet/bank_model.dart';

class FormDaftarBankScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/form-daftar-bank';

  final int? userId;
  final String? token;

  const FormDaftarBankScreen({Key? key, this.userId, this.token})
      : super(key: key);

  @override
  State<FormDaftarBankScreen> createState() => _FormDaftarBankScreenState();
}

class _FormDaftarBankScreenState extends State<FormDaftarBankScreen> {
  final _formKey = GlobalKey<FormState>();
  List<BankModel> _bankList = [];
  BankModel? _selectedBank;
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderNameController =
      TextEditingController();

  String? _userId;
  String? _token;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId?.toString();
    _token = widget.token;
    debugPrint('FormDaftarBankScreen init: userId=$_userId, token=$_token');
    _loadUserDataAndFetchBanks();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndFetchBanks() async {
    debugPrint('Memulai _loadUserDataAndFetchBanks...');
    setState(() {
      _isLoading = true;
    });
    try {
      debugPrint('Token dari widget di FormDaftarBankScreen: $_token');
      debugPrint('User ID dari widget di FormDaftarBankScreen: $_userId');

      await _fetchBankMaster();
    } catch (e) {
      debugPrint('Error loading user data or fetching banks: $e');
      _showAlertDialog('Error', 'Gagal memuat data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBankMaster() async {
    debugPrint('Memulai _fetchBankMaster...');
    const String baseUrl = 'https://api.pensiunku.id/new.php/getBankMaster';
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      debugPrint(
          'Respons API Bank Master (Status: ${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('text') &&
            responseBody['text'].containsKey('data')) {
          final List<dynamic> data = responseBody['text']['data'];
          setState(() {
            _bankList = data.map((json) => BankModel.fromJson(json)).toList();
            debugPrint('Jumlah bank yang dimuat: ${_bankList.length}');
          });
        } else {
          throw Exception('Struktur respons bank master tidak sesuai.');
        }
      } else {
        throw Exception(
            'Failed to load bank list (Status: ${response.statusCode})');
      }
    } on TimeoutException {
      debugPrint('Koneksi timeout saat mengambil daftar bank.');
      throw Exception('Koneksi timeout saat mengambil daftar bank.');
    } on SocketException {
      debugPrint('Tidak ada koneksi internet saat mengambil daftar bank.');
      throw Exception('Tidak ada koneksi internet.');
    } on HttpException {
      debugPrint('Gagal mengambil data bank dari server (HttpException).');
      throw Exception('Gagal mengambil data dari server.');
    } catch (e) {
      debugPrint('Terjadi kesalahan umum saat mengambil daftar bank: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> _saveUserBank() async {
    debugPrint('Memulai _saveUserBank...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Validasi form gagal.');
      _showAlertDialog('Peringatan', 'Harap isi semua kolom dengan benar.');
      return;
    }

    if (_selectedBank == null) {
      debugPrint('Bank belum dipilih.');
      _showAlertDialog('Peringatan', 'Harap pilih nama bank.');
      return;
    }

    if (_userId == null || _token == null) {
      debugPrint(
          'userId atau token tidak tersedia. Tidak bisa menyimpan bank.');
      _showAlertDialog(
          'Error', 'Data pengguna tidak lengkap. Harap login kembali.');
      return;
    }

    _showAlertDialog(
      'Perhatian!',
      'Pastikan Nomor Rekening dan Nama Pemilik Rekening sudah benar sebelum menyimpan.',
      onConfirm: () async {
        debugPrint('Pengguna mengonfirmasi data. Melanjutkan penyimpanan.');
        setState(() {
          _isLoading = true;
        });

        const String baseUrl = 'https://api.pensiunku.id/new.php/saveUserBank';
        final Map<String, String> data = {
          "userid": _userId!,
          "bank": _selectedBank!.id,
          "norek": _accountNumberController.text,
          "nama": _accountHolderNameController.text,
        };

        debugPrint('Payload API Save Bank: $data');

        try {
          final response = await http
              .post(
                Uri.parse(baseUrl),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $_token',
                },
                body: json.encode(data),
              )
              .timeout(const Duration(seconds: 10));

          debugPrint(
              'Respons API Save Bank (Status: ${response.statusCode}): ${response.body}');

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseBody =
                json.decode(response.body);
            // Perbaiki pengecekan status sukses
            if (responseBody.containsKey('text') &&
                responseBody['text'].containsKey('message') &&
                responseBody['text']['message'] == 'success') {
              _showAlertDialog(
                  'Berhasil', 'Data rekening bank berhasil ditambahkan!',
                  onClose: () {
                Navigator.pop(context, true); // Pop dengan hasil true
              });
            } else {
              _showAlertDialog('Gagal',
                  'Gagal menyimpan data rekening bank: ${responseBody['text']['message'] ?? 'Pesan tidak diketahui'}');
            }
          } else {
            _showAlertDialog('Error',
                'Gagal menyimpan data (Status: ${response.statusCode})');
          }
        } on TimeoutException {
          debugPrint('Koneksi timeout saat menyimpan data bank.');
          _showAlertDialog('Error', 'Koneksi timeout. Silakan coba lagi.');
        } on SocketException {
          debugPrint('Tidak ada koneksi internet saat menyimpan data bank.');
          _showAlertDialog('Error', 'Tidak ada koneksi internet.');
        } on HttpException {
          debugPrint(
              'Gagal mengirim data ke server (HttpException) saat menyimpan data bank.');
          _showAlertDialog('Error', 'Gagal mengirim data ke server.');
        } catch (e) {
          debugPrint('Terjadi kesalahan umum saat menyimpan data bank: $e');
          _showAlertDialog('Error', 'Terjadi kesalahan: ${e.toString()}');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  void _showAlertDialog(String title, String message,
      {VoidCallback? onClose, VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            if (onConfirm != null)
              TextButton(
                child: const Text("Batal"),
                onPressed: () {
                  Navigator.of(context).pop();
                  debugPrint('Dialog Peringatan dibatalkan.');
                },
              ),
            TextButton(
              child: Text(onConfirm != null ? "Lanjut" : "OK"),
              onPressed: () {
                Navigator.of(context).pop();
                debugPrint('Dialog Peringatan ditutup/dikonfirmasi.');
                onConfirm?.call();
                onClose?.call();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final double horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
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
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.001),
                    _buildAppBar(context, screenWidth),
                    SizedBox(height: screenHeight * 0.04),
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF017964)))
                        : Column(
                            children: [
                              _buildBankNameField(screenWidth),
                              SizedBox(height: screenHeight * 0.02),
                              _buildAccountNumberField(screenWidth),
                              SizedBox(height: screenHeight * 0.02),
                              _buildAccountHolderNameField(screenWidth),
                              SizedBox(height: screenHeight * 0.04),
                              _buildSubmitButton(screenWidth),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double screenWidth) {
    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: const Color(0xFF017964),
                size: screenWidth * 0.06,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text(
                "Bank Tujuan",
                style: TextStyle(
                  color: Color(0xFF017964),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankNameField(double screenWidth) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<BankModel>(
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Nama Bank',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          labelStyle: TextStyle(color: Colors.black54),
        ),
        value: _selectedBank,
        hint: const Text('Pilih Bank'),
        items: _bankList.map((BankModel bank) {
          return DropdownMenuItem<BankModel>(
            value: bank,
            child: Text(bank.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (BankModel? newValue) {
          setState(() {
            _selectedBank = newValue;
            debugPrint(
                'Bank dipilih: ${_selectedBank?.name} (ID: ${_selectedBank?.id})');
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Nama Bank tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAccountNumberField(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _accountNumberController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Nomor Rekening',
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black54),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nomor Rekening tidak boleh kosong';
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return 'Nomor Rekening harus angka';
          }
          return null;
        },
        onChanged: (value) {
          debugPrint('Nomor Rekening diisi: $value');
        },
      ),
    );
  }

  Widget _buildAccountHolderNameField(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _accountHolderNameController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          labelText: 'Nama Pemilik Rekening',
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.black54),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nama Pemilik Rekening tidak boleh kosong';
          }
          return null;
        },
        onChanged: (value) {
          debugPrint('Nama Pemilik Rekening diisi: $value');
        },
      ),
    );
  }

  Widget _buildSubmitButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC950),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenWidth * 0.035,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        onPressed: _isLoading ? null : _saveUserBank,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: const Text(
                  'Tambah Rekening Baru',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
      ),
    );
  }
}
