import 'dart:async';
// import 'dart:html';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_anda_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';
import 'package:pensiunku/widget/error_card.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          filePath ?? 'Belum ada file dipilih',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey[300],
                    margin: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  if (isUploading)
                    SizedBox(
                      width: 24,
                      height: 24,
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
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/dashboard_screen/upload_icon.png',
                          width: 32,
                          height: 32,
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
            padding: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
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
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isLoading = false;
  bool _isKtpUploading = false;
  bool _isNpwpUploading = false;
  bool _isKaripUploading = false;
  late Future<ResultModel<UserModel>> _futureData;
  UserModel? _userModel;

  double _ktpUploadProgress = 0.0;
  double _npwpUploadProgress = 0.0;
  double _karipUploadProgress = 0.0;

  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();
  TextEditingController nipController = TextEditingController();

  String? fileKTP;
  String? fileNPWP;
  String? fileKarip;

  // Store the actual file paths separately for upload
  String? fileKTPPath;
  String? fileNPWPPath;
  String? fileKaripPath;

  OptionModel _inputProvinsi =
      OptionModel(id: 0, text: ''); // Untuk menyimpan provinsi yang dipilih

  Map<String, String?> fileErrors = {
    'KTP': null,
    'NPWP': null,
    'Karip': null,
  };

  PengajuanAndaDao pengajuanAndaDao = PengajuanAndaDao();

  Future<void> _simulateUpload(String label) async {
    setState(() {
      if (label == 'KTP') _isKtpUploading = true;
      if (label == 'NPWP') _isNpwpUploading = true;
      if (label == 'Karip') _isKaripUploading = true;
    });

    for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
      await Future.delayed(Duration(milliseconds: 300));
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

  Future<void> _pickImage(String label) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        if (label == 'KTP') {
          fileKTP = image.name; // Store original filename for display
          fileKTPPath = image.path; // Store path for upload
          fileErrors['KTP'] = null;
        }
        if (label == 'NPWP') {
          fileNPWP = image.name;
          fileNPWPPath = image.path;
          fileErrors['NPWP'] = null;
        }
        if (label == 'Karip') {
          fileKarip = image.name;
          fileKaripPath = image.path;
          fileErrors['Karip'] = null;
        }
      });

      await _simulateUpload(label);
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateFiles() {
    bool isValid = true;
    setState(() {
      if (fileKTP == null) {
        fileErrors['KTP'] = 'File KTP wajib diupload';
        isValid = false;
      }
      if (fileNPWP == null) {
        fileErrors['NPWP'] = 'File NPWP wajib diupload';
        isValid = false;
      }
      if (fileKarip == null) {
        fileErrors['Karip'] =
            'File SK Pensiun/SK Aktif/Karip/Karpeg wajib diupload';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _submitPengajuanAnda() async {
    if (!_formKey.currentState!.validate() || !_validateFiles()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua data dan file yang diperlukan'),
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
        nip: nipController.text,
        fotoKTP: fileKTPPath!,
        namaFotoKTP: fileKTP!,
        fotoNPWP: fileNPWPPath!,
        namaFotoNPWP: fileNPWP!,
        fotoKarip: fileKaripPath!,
        namaFotoKarip: fileKarip!,
      );

      if (success) {
        _showAwesomeDialog(
          title: 'Sukses',
          message: 'Pengajuan Anda Berhasil Dikirim.',
          dialogType: DialogType.success,
          color: Colors.green,
          isSuccess: true,
        );
      } else {
        _showAwesomeDialog(
          title: 'Gagal',
          message: 'Anda sudah pernah melakukan pengajuan!',
          dialogType: DialogType.error,
          color: Colors.red,
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error submitting pengajuan: $e');
      _showAwesomeDialog(
        title: 'Error',
        message: 'Terjadi kesalahan saat mengirim pengajuan',
        dialogType: DialogType.error,
        color: Colors.red,
        isSuccess: false,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showAwesomeDialog({
    required String title,
    required String message,
    required DialogType dialogType,
    required Color color,
    required bool isSuccess,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: 'OK',
      btnOkColor: color,
      btnOkOnPress: () {
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
    ).show();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

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

      setState(() {
        namaController.text = value.data?.username ?? '';
        teleponController.text = value.data?.phone ?? '';
      });

      return value;
    });
  }

  OptionModel _inputCity =
      OptionModel(id: 0, text: ''); // For storing selected city
  List<OptionModel> _cities = []; // To store city list

  Future<void> _loadCities() async {
    if (_inputProvinsi.id == 0) return;

    setState(() => _isLoading = true);
    try {
      final cities = await LocationRepository.getCity(_inputProvinsi.id);
      setState(() {
        _cities = cities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cities: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCitySelectionDialog() async {
    if (_cities.isEmpty) {
      await _loadCities();
    }

    final selectedCity = await showDialog<OptionModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Kabupaten/Kota'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_cities[index].text),
                  onTap: () {
                    Navigator.of(context).pop(_cities[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCity != null) {
      setState(() {
        _inputCity = selectedCity;
        domisiliController.text = selectedCity.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Center(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
            child: Text(
              'Form Pengajuan',
              style: TextStyle(
                color: Color(0xFF017964),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
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
                        SizedBox(height: 30.0),
                        TextFormField(
                          controller: namaController,
                          readOnly: true,
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
                          readOnly: true,
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
                        // Replace TextFormField with GestureDetector for city selection
                        GestureDetector(
                          onTap: _showCitySelectionDialog,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                      'Kota Domisili',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _inputCity.text.isNotEmpty
                                          ? _inputCity.text
                                          : 'Pilih Kota Domisili',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _inputCity.text.isNotEmpty
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
                              labelText: 'NOTAS/NIP',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Harap masukkan NOTAS/NIP';
                            if (value.length < 16 || value.length > 18) {
                              return 'NIP harus antara 16 hingga 18 digit';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),

                        // Custom Upload Fields
                        CustomUploadField(
                          label: 'KTP',
                          filePath: fileKTP,
                          isUploading: _isKtpUploading,
                          uploadProgress: _ktpUploadProgress,
                          onUpload: () => _pickImage('KTP'),
                          errorText: fileErrors['KTP'],
                        ),

                        CustomUploadField(
                          label: 'NPWP',
                          filePath: fileNPWP,
                          isUploading: _isNpwpUploading,
                          uploadProgress: _npwpUploadProgress,
                          onUpload: () => _pickImage('NPWP'),
                          errorText: fileErrors['NPWP'],
                        ),

                        CustomUploadField(
                          label: 'SK Pensiun/SK Aktif/Karip/Karpeg',
                          filePath: fileKarip,
                          isUploading: _isKaripUploading,
                          uploadProgress: _karipUploadProgress,
                          onUpload: () => _pickImage('Karip'),
                          errorText: fileErrors['Karip'],
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
      _inputCity = OptionModel(id: 0, text: '');
    });
  }
}

// class PengajuanAndaScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/pengajuan_anda';
//   @override
//   _PengajuanAndaScreenState createState() => _PengajuanAndaScreenState();
// }

// class _PengajuanAndaScreenState extends State<PengajuanAndaScreen> {
//   // GlobalKey untuk form, digunakan untuk validasi
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//   bool _isSubmitting = false; // Indikator loading untuk "Ajukan Sekarang"
//   bool _isLoading = false; // Flag untuk menandakan proses loading
//   bool _isKtpUploading = false; // Tambahan untuk KTP
//   bool _isNpwpUploading = false; // Tambahan untuk NPWP
//   bool _isKaripUploading = false; // Tambahan Untuk SK Pensiun
//   // Deklarasi Future yang akan digunakan untuk menyimpan data asinkron // untuk mengambil data pengguna (1 yoga)
//   late Future<ResultModel<UserModel>> _futureData;
//   UserModel? _userModel; // Model pengguna (opsional)

//   // Variabel untuk melacak progres upload
//   double _ktpUploadProgress = 0.0; // Progres upload KTP
//   double _npwpUploadProgress = 0.0; // Progres upload NPWP
//   double _karipUploadProgress = 0.0; // Progres upload SK Pensiun

//   // Controller untuk input teks
//   TextEditingController namaController = TextEditingController();
//   TextEditingController teleponController = TextEditingController();
//   TextEditingController domisiliController = TextEditingController();
//   TextEditingController nipController = TextEditingController();

//   // Variabel untuk menyimpan path file
//   String? fileKTP;
//   String? fileNPWP;
//   String? fileKarip;

//   // Data Access Object untuk pengajuan
//   PengajuanAndaDao pengajuanAndaDao = PengajuanAndaDao();
//   // Simulasi progres upload
//   Future<void> _simulateUpload(String label) async {
//     setState(() {
//       if (label == 'KTP') _isKtpUploading = true;
//       if (label == 'NPWP') _isNpwpUploading = true;
//       if (label == 'Karip') _isKaripUploading = true;
//     });

//     for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
//       await Future.delayed(Duration(milliseconds: 300)); // Simulasi delay
//       setState(() {
//         if (label == 'KTP') _ktpUploadProgress = progress;
//         if (label == 'NPWP') _npwpUploadProgress = progress;
//         if (label == 'Karip') _karipUploadProgress = progress;
//       });
//     }

//     setState(() {
//       if (label == 'KTP') _isKtpUploading = false;
//       if (label == 'NPWP') _isNpwpUploading = false;
//       if (label == 'Karip') _isKaripUploading = false;
//     });
//   }

//   // Fungsi untuk memilih file
//   // Modifikasi tombol upload untuk simulasi progres upload
//   Future<void> _pickImage(String label) async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;

//     setState(() {
//       if (label == 'KTP') fileKTP = image.path;
//       if (label == 'NPWP') fileNPWP = image.path;
//       if (label == 'Karip') fileKarip = image.path;
//     });

//     // Simulasi proses upload
//     await _simulateUpload(label);
//   }

//   Future<void> _submitPengajuanAnda() async {
//     if (_formKey.currentState!.validate() &&
//         fileKTP != null &&
//         fileNPWP != null &&
//         fileKarip != null) {
//       setState(() {
//         _isSubmitting = true; // Menampilkan indikator loading
//       });

//       // cetak data yang akan dikirim untuk logging
//       debugPrint('Submitting pengajuan with data:');

//       bool success = await PengajuanAndaDao.kirimPengajuanAnda(
//         nama: namaController.text,
//         telepon: teleponController.text,
//         domisili: domisiliController.text,
//         nip: nipController.text,
//         fotoKTP: fileKTP!,
//         namaFotoKTP: fileKTP!.split('/').last,
//         fotoNPWP: fileNPWP!,
//         namaFotoNPWP: fileNPWP!.split('/').last,
//         fotoKarip: fileKarip!,
//         namaFotoKarip: fileKarip!.split('/').last,
//       );
//       // Set loading state to false
//       setState(() {
//         _isLoading = false;
//       });
//       if (success) {
//         _showCustomDialog('Sukses', 'Pengajuan Anda Berhasil Dikirim.',
//             Icons.check_circle, Colors.green);
//       } else {
//         _showCustomDialog(
//             'Gagal', 'Gagal Mengirim pengajuan', Icons.error, Colors.red);
//       }
//     }
//   }

//   void _showCustomDialog(
//       String title, String message, IconData icon, Color iconColor) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           contentPadding: EdgeInsets.all(20),
//           title: Row(
//             children: [
//               Icon(icon, color: iconColor, size: 30),
//               SizedBox(width: 10),
//               Text(title),
//             ],
//           ),
//           content: Text(message, textAlign: TextAlign.center),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 // Navigate to RiwayatPengajuanPage after the dialog is closed
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => RiwayatPengajuanAndaScreen(
//                       onChangeBottomNavIndex: (index) => 1,
//                     ),
//                   ),
//                 );
//               },
//               child: Text('OK', style: TextStyle(color: Colors.blue)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   //ini berfungsi untuk membuat data user untuk ditampilkan diform (yoga 2)
//   @override
//   void initState() {
//     super.initState();
//     // Inisialisasi controller untuk nama dan telepon
//     namaController = TextEditingController();
//     teleponController = TextEditingController();

//     // Memuat data pengguna
//     _refreshData();
//   }

//   // agar mengisi TextEditingController dengan data pengguna yang diperoleh (yoga 3)
//   _refreshData() {
//     String? token = SharedPreferencesUtil()
//         .sharedPreferences
//         .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

//     _futureData = UserRepository().getOne(token!).then((value) {
//       if (value.error != null) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   content: Text(value.error.toString(),
//                       style: TextStyle(color: Colors.white)),
//                   backgroundColor: Colors.red,
//                   elevation: 24.0,
//                 ));
//       }
//       // Set data ke TextEditingController
//       setState(() {
//         namaController.text = value.data?.username ?? '';
//         teleponController.text = value.data?.phone ?? '';
//         //  _userModel = result.data;

//         // // Tambahkan log ini untuk melihat ID di konsol
//         // print('User ID: ${_userModel?.id}');
//       });

//       // Cek apakah id_user ada
//       if (value.data?.id != null) {
//         print('ID User: ${value.data?.id}');
//       } else {
//         print('ID User tidak tersedia.');
//       }
//       return value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''), // Judul kosong
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.transparent, // AppBar transparan
//         elevation: 0, // Menghilangkan bayangan
//         flexibleSpace: Center(
//           // Pusatkan teks di tengah AppBar
//           child: Padding(
//             padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top +
//                     5), // Sesuaikan padding atas
//             child: Text(
//               'Form Pengajuan',
//               style: TextStyle(
//                 color: Color(0xFF017964), // Warna teks
//                 fontWeight: FontWeight.bold, // Teks bold
//                 fontSize: 20, // Ukuran teks
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: ListView(
//                       children: <Widget>[
//                         SizedBox(height: 30.0),
//                         TextFormField(
//                           controller: namaController,
//                           readOnly: true,
//                           enabled: !_isLoading,
//                           decoration: InputDecoration(
//                               labelText: 'Nama', border: OutlineInputBorder()),
//                           validator: (value) => (value == null || value.isEmpty)
//                               ? 'Harap masukkan nama'
//                               : null,
//                         ),
//                         SizedBox(height: 16.0),

//                         TextFormField(
//                           controller: teleponController,
//                           readOnly: true,
//                           enabled: !_isLoading,
//                           keyboardType: TextInputType.phone,
//                           decoration: InputDecoration(
//                               labelText: 'No. Telepon',
//                               border: OutlineInputBorder()),
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'Harap masukkan no. telepon';
//                             if (!RegExp(r'^[0-9]+$').hasMatch(value))
//                               return 'No. telepon hanya boleh angka';
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),

//                         TextFormField(
//                           controller: domisiliController,
//                           decoration: InputDecoration(
//                               labelText: 'Kota Domisili',
//                               border: OutlineInputBorder()),
//                           validator: (value) => (value == null || value.isEmpty)
//                               ? 'Harap masukkan kota domisili'
//                               : null,
//                         ),
//                         SizedBox(height: 16.0),

//                         TextFormField(
//                           controller: nipController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                               labelText: 'NOTAS/NIP',
//                               border: OutlineInputBorder()),
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'Harap masukkan NOTAS/NIP';
//                             if (value.length < 16 || value.length > 18) {
//                               return 'NIP harus antara 16 hingga 18 digit';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 16.0),

//                         // KTP Upload Field
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: TextEditingController(
//                                   text: fileKTP != null
//                                       ? fileKTP!.split('/').last
//                                       : '',
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'KTP',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 readOnly: true,
//                                 validator: (value) {
//                                   if (fileKTP == null || fileKTP!.isEmpty) {
//                                     return 'Harap upload dokumen KTP';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: 8.0),
//                             _isKtpUploading // Jika sedang upload, tampilkan progres
//                                 ? Expanded(
//                                     child: LinearProgressIndicator(
//                                       value:
//                                           _ktpUploadProgress, // Menampilkan progres upload KTP
//                                       backgroundColor: Colors.grey[200],
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                           Colors.blue),
//                                     ),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: () => _pickImage('KTP'),
//                                     child: Text('Upload'),
//                                     style: ElevatedButton.styleFrom(
//                                       primary: Color(0xFF017964),
//                                     ),
//                                   ),
//                           ],
//                         ),

//                         SizedBox(height: 16.0),

//                         // NPWP Upload Field
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: TextEditingController(
//                                   text: fileNPWP != null
//                                       ? fileNPWP!.split('/').last
//                                       : '',
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'NPWP',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 readOnly: true,
//                                 validator: (value) {
//                                   if (fileNPWP == null || fileNPWP!.isEmpty) {
//                                     return 'Harap upload dokumen NPWP';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: 8.0),
//                             _isNpwpUploading // Jika sedang upload, tampilkan progres
//                                 ? Expanded(
//                                     child: LinearProgressIndicator(
//                                       value:
//                                           _npwpUploadProgress, // Menampilkan progres upload NPWP
//                                       backgroundColor: Colors.grey[200],
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                           Colors.blue),
//                                     ),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: () => _pickImage('NPWP'),
//                                     child: Text('Upload'),
//                                     style: ElevatedButton.styleFrom(
//                                       primary: Color(0xFF017964),
//                                     ),
//                                   ),
//                           ],
//                         ),
//                         SizedBox(height: 18.0),

//                         // Karip Upload Field
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: TextEditingController(
//                                   text: fileKarip != null
//                                       ? fileKarip!.split('/').last
//                                       : '',
//                                 ),
//                                 decoration: InputDecoration(
//                                   labelText: 'SK Pensiun/SK Aktif/Karip/Karpeg',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 readOnly: true,
//                                 validator: (value) {
//                                   if (fileKarip == null || fileKarip!.isEmpty) {
//                                     return 'Harap upload dokumen SK Pensiun';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: 8.0),
//                             _isKaripUploading // Jika sedang upload, tampilkan progres
//                                 ? Expanded(
//                                     child: LinearProgressIndicator(
//                                       value:
//                                           _karipUploadProgress, // Menampilkan progres upload SK Pensiun
//                                       backgroundColor: Colors.grey[200],
//                                       valueColor: AlwaysStoppedAnimation<Color>(
//                                           Colors.blue),
//                                     ),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: () => _pickImage('Karip'),
//                                     child: Text('Upload'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Color(0xFF017964),
//                                     ),
//                                   ),
//                           ],
//                         ),

//                         SizedBox(height: 24.0),

//                         ElevatedButton(
//                           onPressed: _submitPengajuanAnda,
//                           child: Text('Ajukan Sekarang'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF017964),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     namaController.dispose();
//     teleponController.dispose();
//     domisiliController.dispose();
//     nipController.dispose();
//     super.dispose();
//   }

//   void _resetForm() {
//     setState(() {
//       namaController.clear();
//       teleponController.clear();
//       domisiliController.clear();
//       nipController.clear();
//       fileKTP = null;
//       fileNPWP = null;
//       fileKarip = null;
//     });
//   }
// }
