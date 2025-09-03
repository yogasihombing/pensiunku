import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import ini DITAMBAH

class SimulasiCepatScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/simulasi-cepat';

  SimulasiCepatScreen();

  @override
  State<SimulasiCepatScreen> createState() => _SimulasiCepatScreenState();
}

class _SimulasiCepatScreenState extends State<SimulasiCepatScreen>
    with SingleTickerProviderStateMixin {
  // --- Controller dan Variabel State ---
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _scrollingContentKey = GlobalKey();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _tanggalPensiunController =
      TextEditingController();
  final TextEditingController _gajiPensiunController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();

  String? _selectedDomisili;
  List<String> _allDomisiliOptions = [];
  bool _isLoadingDomisili = false;
  bool _initialDomisiliFetchDone = false;

  String _statusPengaju = 'Pra-Pensiun';
  bool _hasilSimulasi = false;
  bool _isLoading = false;

  Map<String, dynamic>? _simulationResult;
  String _errorMessage = '';
  String _generatedCode = '';

  late AnimationController _logoAnimationController;
  bool _isLoadingOverlay = false;
  bool _isSavingScreenshot = false;

  // --- Map untuk Tracking Error Validasi Field ---
  Map<String, String> _fieldErrors = {
    'nama': '',
    'tanggalLahir': '',
    'tanggalPensiun': '',
    'gajiPensiun': '',
    'nomorTelepon': '',
    'domisili': '',
    'pekerjaan': '',
  };

  // --- Format Number ---
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final NumberFormat _numberFormat = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      debugPrint("Locale data for id_ID initialized successfully.");
    }).catchError((e) {
      debugPrint("Failed to initialize locale data: $e");
    });
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _logoAnimationController.repeat();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialDomisiliFetchDone) {
      _initialDomisiliFetchDone = true;
      _fetchDomisili();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _tanggalPensiunController.dispose();
    _gajiPensiunController.dispose();
    _nomorTeleponController.dispose();
    _pekerjaanController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
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

  // --- Fungsi untuk call API Simulasi ---
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
        'domisili': _selectedDomisili ?? '',
        'pekerjaan': _pekerjaanController.text,
      });

      debugPrint("Request Fields: ${request.fields}");

      http.StreamedResponse response = await request.send();
      debugPrint("Response Status Code: ${response.statusCode}");

      if (!mounted) return;

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

            await _saveSimulation(data['data'][0]);

            if (mounted) {
              setState(() {
                _simulationResult = data['data'][0];
                _hasilSimulasi = true;
              });
            }
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
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _simulationResult = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint("Proses API simulasi selesai");
    }
  }

  // --- Fungsi Penyimpanan Simulasi ---
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
      debugPrint("- Domisili: ${_selectedDomisili ?? ''}");
      debugPrint("- Pekerjaan: ${_pekerjaanController.text}");

      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/saveSimulasi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nama": _namaController.text,
          "tanggal_lahir": _tanggalLahirController.text,
          "status": _statusPengaju == 'Pra-Pensiun' ? 'PRA' : 'KPB',
          "tanggal_pensiun": _tanggalPensiunController.text,
          "gaji": _gajiPensiunController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          "telepon": _nomorTeleponController.text,
          "domisili": _selectedDomisili ?? '',
          "pekerjaan": _pekerjaanController.text,
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
          "angsuran_mitra": simulationData['angsuran_mitra']?.toString() ?? '',
          "angsuran_efektif":
              simulationData['angsuran_efektif']?.toString() ?? '',
          "biaya_angsuran": simulationData['biaya_angsuran']?.toString() ?? '',
          "cicilan_asuransi":
              simulationData['cicilan_asuransi']?.toString() ?? '',
          "rate_bunga_tahun":
              simulationData['rate_bunga_tahun']?.toString() ?? '',
          "rate_premi_asuransi":
              simulationData['rate_premi_asuransi']?.toString() ?? '',
          "versi_simulasi": simulationData['versi_simulasi']?.toString() ?? '',
        }),
      );

      debugPrint(
          "[SAVE SIMULASI] Response Status Code: ${response.statusCode}");
      debugPrint("[SAVE SIMULASI] Response Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final simCode = responseData['text']?['code'];
        if (mounted) {
          setState(() {
            _generatedCode = simCode ?? 'KOSONG';
          });
        }
        debugPrint("[SAVE SIMULASI] Simulasi tersimpan dengan code: $simCode");
      } else {
        debugPrint("[SAVE SIMULASI] Gagal menyimpan. Status code tidak 200");
      }
    } catch (e) {
      debugPrint("[SAVE SIMULASI] ERROR: ${e.toString()}");
      print('Error save simulation: $e');
    }
  }

  // --- Widget Tampilan Hasil dan Fungsi Pendukung ---
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
    final numericValue = double.tryParse(value.toString()) ?? 0;
    final formattedValue = (label.contains('Angsuran') ||
            label.contains('Plafond') ||
            label.contains('Terima Bersih'))
        ? _currencyFormat.format(numericValue)
        : value.toString();

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

  // === FUNGSI SCREENSHOT BARU ===
  Future<void> _captureFullScreenAndSave() async {
    if (!mounted) return;

    setState(() {
      _isSavingScreenshot = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Menggunakan ScreenshotController untuk menangkap widget secara programatis
      final controller = ScreenshotController();

      // Membuat widget khusus untuk screenshot yang berisi seluruh konten
      Widget screenshotWidget = _buildScreenshotContent();

      // Menggunakan ScreenshotController.captureFromWidget untuk menangkap widget
      final Uint8List? imageBytes = await controller.captureFromWidget(
        screenshotWidget,
        pixelRatio: 3.0, // Kualitas tinggi
        context: context,
      );

      if (imageBytes != null) {
        // Menyimpan gambar dengan kualitas tinggi
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          quality: 95, // Kualitas sangat tinggi
          name: 'pensiunku_simulasi_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (mounted) {
          if (result['isSuccess'] == true) {
            _showSnackBar(
                'Screenshot berhasil disimpan dengan kualitas tinggi!');
          } else {
            _showSnackBar('Gagal menyimpan screenshot.');
          }
        }
      } else {
        if (mounted) {
          _showSnackBar('Gagal mengambil screenshot.');
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil screenshot: $e");
      if (mounted) {
        _showSnackBar('Gagal mengambil screenshot: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingScreenshot = false;
        });
      }
    }
  }

  // Fungsi untuk membuat konten screenshot yang lengkap
  Widget _buildScreenshotContent() {
    return Material(
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
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
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    'assets/register_screen/pensiunku.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 50,
                        width: 200,
                        color: Color(0xFF017964),
                        child: Center(
                          child: Text(
                            'PENSIUNKU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Simulasi Cepat Pensiunku (SCP)',
                  style: TextStyle(
                    color: Color(0xFF017964),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF017964), width: 2),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DATA PENGAJU',
                        style: TextStyle(
                          color: Color(0xFF017964),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDataRow('Nama', _namaController.text),
                      _buildDataRow(
                          'Tanggal Lahir', _tanggalLahirController.text),
                      _buildDataRow('Status', _statusPengaju),
                      if (_statusPengaju == 'Pra-Pensiun')
                        _buildDataRow(
                            'Tanggal Pensiun', _tanggalPensiunController.text),
                      _buildDataRow(
                          'Gaji Pensiun', _gajiPensiunController.text),
                      _buildDataRow('Domisili', _selectedDomisili ?? ''),
                      _buildDataRow('Pekerjaan', _pekerjaanController.text),
                      _buildDataRow(
                          'No. Telepon', _nomorTeleponController.text),
                      if (_generatedCode.isNotEmpty)
                        _buildDataRow('Kode Simulasi', _generatedCode),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                if (_simulationResult != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF017964), width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFFFFC950).withOpacity(0.3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HASIL SIMULASI',
                          style: TextStyle(
                            color: Color(0xFF017964),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildResultRowForScreenshot(
                            'Plafond Pinjaman', _simulationResult!['nominal']),
                        _buildResultRowForScreenshot('Jangka Waktu/Tenor',
                            '${_simulationResult!['max_jangka']} bulan'),
                        _buildResultRowForScreenshot(
                            'Angsuran', _simulationResult!['angsuran_efektif']),
                        _buildResultRowForScreenshot('Terima Bersih',
                            _simulationResult!['jumlah_diterima']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF017964), width: 1),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white.withOpacity(0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYARAT DAN KETENTUAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF017964),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildSyaratRow('1.',
                          'Pastikan anda memasukkan data keterangan sesuai dengan benar dan tepat!'),
                      _buildSyaratRow('2.',
                          'Kalkulator ini bersifat hitungan sementara, karena belum dihitung sisa hutang bapak/ibu (bila ada)'),
                      _buildSyaratRow('3.',
                          'Untuk solusi keuangan bapak/ibu, silahkan hubungi petugas kami.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF017964),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Simulasi dibuat pada: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hubungi: +62 812-2035-7098 (WhatsApp)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget untuk menampilkan data dalam format yang rapi
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF017964),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk hasil simulasi dalam screenshot
  Widget _buildResultRowForScreenshot(String label, dynamic value) {
    final numericValue = double.tryParse(value.toString()) ?? 0;
    final formattedValue = (label.contains('Angsuran') ||
            label.contains('Plafond') ||
            label.contains('Terima Bersih'))
        ? _currencyFormat.format(numericValue)
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF017964),
              ),
            ),
          ),
          Expanded(
            child: Text(
              formattedValue,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk syarat dan ketentuan
  Widget _buildSyaratRow(String nomor, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              nomor,
              style: TextStyle(
                color: Color(0xFF017964),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Color(0xFF017964),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi yang diperbarui untuk menggunakan tautan wa.me
  void _launchWhatsApp() async {
    final String phoneNumber = '+6281220357098';
    final String message =
        'Hallo admin pensiunku, saya mau menanyakan perihal simulasi aplikasi Pensiunku?';
    final Uri whatsappUrl = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Gagal membuka WhatsApp. Pastikan aplikasi terinstal.');
    }
  }

  // --- Fungsi Validasi Field ---
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

    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(value)) {
      _fieldErrors['tanggalLahir'] = 'Format tanggal harus dd-mm-yyyy';
      return '';
    }

    final parts = value.split('-');
    final day = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final year = int.tryParse(parts[2]) ?? 0;

    if (day < 1 || day > 31) {
      _fieldErrors['tanggalLahir'] = 'Tanggal harus antara 1-31';
      return '';
    }
    if (month < 1 || month > 12) {
      _fieldErrors['tanggalLahir'] = 'Bulan harus antara 1-12';
      return '';
    }

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

    final datePattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!datePattern.hasMatch(value)) {
      _fieldErrors['tanggalPensiun'] = 'Format tanggal harus dd-mm-yyyy';
      return '';
    }

    final parts = value.split('-');
    final day = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;

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

  String? validateDomisili(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['domisili'] = 'Harap pilih domisili';
      return '';
    }
    _fieldErrors['domisili'] = '';
    return null;
  }

  String? validatePekerjaan(String? value) {
    if (value == null || value.isEmpty) {
      _fieldErrors['pekerjaan'] = 'Harap masukkan pekerjaan';
      return '';
    }
    _fieldErrors['pekerjaan'] = '';
    return null;
  }

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
    validateDomisili(_selectedDomisili);
    validatePekerjaan(_pekerjaanController.text);

    return !_fieldErrors.values.any((error) => error.isNotEmpty);
  }

  // --- Widget Pembantu untuk Form Field ---
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

  // --- Metode Build Utama ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'Simulasi Cepat Pensiunku (SCP)',
          style: TextStyle(
            color: Color(0xFF017964),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF017964)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0, // Menghilangkan shadow
      ),
      body: Stack(
        children: [
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
          RepaintBoundary(
            key: _scrollingContentKey,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/register_screen/pensiunku.png',
                        height: 45,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint("Error loading image: $error");
                          return Icon(Icons.error, color: Colors.red);
                        },
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            if (digitsOnly.isNotEmpty) {
                              formatted = digitsOnly.substring(
                                  0, min(2, digitsOnly.length));
                              if (digitsOnly.length > 2) {
                                formatted += '-' +
                                    digitsOnly.substring(
                                        2, min(4, digitsOnly.length));
                              }
                              if (digitsOnly.length > 4) {
                                formatted += '-' +
                                    digitsOnly.substring(
                                        4, min(8, digitsOnly.length));
                              }
                              _tanggalLahirController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                    offset: formatted.length),
                              );
                            }
                          },
                          validator: validateTanggalLahir,
                        ),
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
                              if (digitsOnly.isNotEmpty) {
                                formatted = digitsOnly.substring(
                                    0, min(2, digitsOnly.length));
                                if (digitsOnly.length > 2) {
                                  formatted += '-' +
                                      digitsOnly.substring(
                                          2, min(4, digitsOnly.length));
                                }
                                if (digitsOnly.length > 4) {
                                  formatted += '-' +
                                      digitsOnly.substring(
                                          4, min(8, digitsOnly.length));
                                }
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
                        buildFormFieldWithError(
                          controller: _gajiPensiunController,
                          fieldKey: 'gajiPensiun',
                          label: 'Gaji pensiun:',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final numericValue = int.parse(
                                  value.replaceAll(RegExp(r'[^0-9]'), ''));
                              _gajiPensiunController.value = TextEditingValue(
                                text: _currencyFormat.format(numericValue),
                                selection: TextSelection.collapsed(
                                    offset: _currencyFormat
                                        .format(numericValue)
                                        .length),
                              );
                            }
                          },
                          validator: validateGajiPensiun,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Domisili:',
                                style: TextStyle(
                                  color: Color(0xFF017964),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            DropdownSearch<String>(
                              onFind: (String? filter) async {
                                return _allDomisiliOptions
                                    .where((element) => element
                                        .toLowerCase()
                                        .contains(filter?.toLowerCase() ?? ''))
                                    .toList();
                              },
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Cari domisili...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide:
                                        BorderSide(color: Color(0xFF017964)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                        color: Color(0xFF017964), width: 2.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                              emptyBuilder: (context, searchEntry) => Center(
                                child: Text(
                                  _isLoadingDomisili
                                      ? 'Memuat domisili...'
                                      : 'Tidak ada domisili ditemukan.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12),
                                isDense: true,
                                hintText: _isLoadingDomisili
                                    ? 'Memuat domisili!'
                                    : 'Pilih Domisili',
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF017964)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          _fieldErrors['domisili']!.isNotEmpty
                                              ? Colors.red
                                              : Color(0xFF017964)),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          _fieldErrors['domisili']!.isNotEmpty
                                              ? Colors.red
                                              : Color(0xFF017964),
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                errorStyle: TextStyle(height: 0, fontSize: 0),
                              ),
                              selectedItem: _selectedDomisili,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDomisili = newValue;
                                  validateDomisili(newValue);
                                });
                              },
                              validator: (value) => validateDomisili(value),
                              itemAsString: (String? item) => item ?? '',
                            ),
                            if (_fieldErrors['domisili']!.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20.0, top: 2.0),
                                child: Text(
                                  _fieldErrors['domisili']!,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10),
                                ),
                              ),
                            SizedBox(height: 10.0),
                          ],
                        ),
                        buildFormFieldWithError(
                          controller: _pekerjaanController,
                          fieldKey: 'pekerjaan',
                          label: 'Pekerjaan:',
                          validator: validatePekerjaan,
                          hintText: 'Masukkan pekerjaan',
                        ),
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFFFFC950),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    side: BorderSide(
                                                        color:
                                                            Color(0xFF017964)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                ),
                                                child: Text(
                                                  "Lihat Hasil Simulasi!",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
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
                                    if (_simulationResult != null)
                                      _buildResultDisplay(),
                                  ],
                                ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: ElevatedButton(
                                    onPressed: _hasilSimulasi
                                        ? _captureFullScreenAndSave
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30,
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
                                    'Kalkulator ini bersifat hitungan sementara, karena belum dihitung sisa hutang bapak/ibu (bila ada)',
                                    style: TextStyle(color: Color(0xFF017964)),
                                  ),
                                ),
                              ],
                            ),
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
                  ],
                ),
              ),
            ),
          ),
          if (_isLoadingOverlay || _isSavingScreenshot)
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            ),
          if (_isLoadingOverlay || _isSavingScreenshot)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _logoAnimationController,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: Image.asset('assets/logo.png',
                          errorBuilder: (context, error, stackTrace) {
                        debugPrint("Error loading logo image: $error");
                        return Icon(Icons.error, color: Colors.red);
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isSavingScreenshot
                        ? 'Menyimpan tangkapan layar...'
                        : 'Mohon tunggu...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
