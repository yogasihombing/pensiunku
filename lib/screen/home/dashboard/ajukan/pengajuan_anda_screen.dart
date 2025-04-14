import 'dart:async';
import 'dart:ui';
// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pensiunku/data/db/pengajuan_anda_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/riwayat_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

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
  bool _isSubmitting = false;
  bool _isLoadingOverlay = false;

  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  TextEditingController domisiliController = TextEditingController();

  late Future<ResultModel<UserModel>> _futureData;
  OptionModel _selectedProvince = OptionModel(id: 0, text: '');

  @override
  void initState() {
    super.initState();
    _isLoadingOverlay = true;
    _refreshData();
  }

  // Dialog untuk memilih provinsi
  Future<void> _showCitySelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Provinsi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LocationRepository.getProvinces().length,
              itemBuilder: (context, index) {
                final province = LocationRepository.getProvinces()[index];
                return ListTile(
                  title: Text(province.text),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedProvince = province;
                      domisiliController.text = province.text;
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
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

    // Validasi pilihan provinsi
    if (_selectedProvince.id == 0 || _selectedProvince.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap pilih provinsi Anda'),
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
      );

      if (success) {
        _showCustomDialog(
          context: context,
          title: 'Sukses',
          message: 'Pengajuan Anda Berhasil Dikirim.',
          color: Color(0XFFF017964),
          isSuccess: true,
        );
      } else {
        _showCustomDialog(
          context: context,
          title: 'Gagal',
          message: 'Anda sudah pernah melakukan pengajuan!',
          color: Colors.red,
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error submitting pengajuan: $e');
      _showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Terjadi kesalahan saat mengirim pengajuan',
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
            backgroundColor: Colors
                .transparent, // Make the AlertDialog background transparent
            insetPadding: EdgeInsets.symmetric(horizontal: 15),
            content: Container(
              decoration: BoxDecoration(
                color: color, // Set the background color
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors
                          .white, // Set the text color to white for better contrast
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: color,
                      backgroundColor:
                          Colors.white, // Set the text color to green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
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
                    child: Text('OK'),
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
        _isLoadingOverlay = false;
      });

      return value;
    });
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
          _isLoadingOverlay
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
                          enabled: !_isLoadingOverlay,
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
                          enabled: !_isLoadingOverlay,
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
                        // Field untuk memilih provinsi
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
                                      'Provinsi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _selectedProvince.id != 0
                                          ? _selectedProvince.text
                                          : 'Pilih Provinsi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedProvince.id != 0
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
                        SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : _submitPengajuanAnda,
                          child: _isSubmitting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text('Ajukan Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF017964),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          // Tampilkan overlay loading bila _isLoadingOverlay true
          if (_isLoadingOverlay)
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            ),
          if (_isLoadingOverlay)
            Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF017964),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mohon tunggu...',
                      style: TextStyle(
                        color: Color(0xFF017964),
                        fontWeight: FontWeight.bold,
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
    super.dispose();
  }
}


// class CustomUploadField extends StatelessWidget {
//   final String label;
//   final String? filePath;
//   final bool isUploading;
//   final double uploadProgress;
//   final VoidCallback onUpload;
//   final String? errorText;

//   const CustomUploadField({
//     Key? key,
//     required this.label,
//     required this.filePath,
//     required this.isUploading,
//     required this.uploadProgress,
//     required this.onUpload,
//     this.errorText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 8.0),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: errorText != null ? Colors.red : Colors.grey[300]!,
//               ),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           label,
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           filePath ?? 'Belum ada file dipilih',
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontSize: 16,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 50,
//                     width: 1,
//                     color: Colors.grey[300],
//                     margin: EdgeInsets.symmetric(horizontal: 12),
//                   ),
//                   if (isUploading)
//                     SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         value: uploadProgress,
//                         strokeWidth: 2,
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
//                       ),
//                     )
//                   else
//                     InkWell(
//                       onTap: onUpload,
//                       child: Container(
//                         padding: EdgeInsets.all(8),
//                         child: Image.asset(
//                           'assets/dashboard_screen/upload_icon.png',
//                           width: 32,
//                           height: 32,
//                           color: Color(0xFF017964),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (errorText != null)
//           Padding(
//             padding: EdgeInsets.only(left: 12, top: 4),
//             child: Text(
//               errorText!,
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class PengajuanAndaScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/pengajuan_anda';

//   @override
//   _PengajuanAndaScreenState createState() => _PengajuanAndaScreenState();
// }

// class _PengajuanAndaScreenState extends State<PengajuanAndaScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();
//   bool _isSubmitting = false;
//   bool _isLoading = false;
//   bool _isKtpUploading = false;
//   bool _isNpwpUploading = false;
//   bool _isKaripUploading = false;
//   late Future<ResultModel<UserModel>> _futureData;
//   UserModel? _userModel;

//   double _ktpUploadProgress = 0.0;
//   double _npwpUploadProgress = 0.0;
//   double _karipUploadProgress = 0.0;

//   TextEditingController namaController = TextEditingController();
//   TextEditingController teleponController = TextEditingController();
//   TextEditingController domisiliController = TextEditingController();
//   TextEditingController nipController = TextEditingController();

//   String? fileKTP;
//   String? fileNPWP;
//   String? fileKarip;

//   // Store the actual file paths separately for upload
//   String? fileKTPPath;
//   String? fileNPWPPath;
//   String? fileKaripPath;

//   OptionModel _inputProvinsi =
//       OptionModel(id: 0, text: ''); // Untuk menyimpan provinsi yang dipilih

//   Map<String, String?> fileErrors = {
//     'KTP': null,
//     'NPWP': null,
//     'Karip': null,
//   };

//   PengajuanAndaDao pengajuanAndaDao = PengajuanAndaDao();

//   Future<void> _simulateUpload(String label) async {
//     setState(() {
//       if (label == 'KTP') _isKtpUploading = true;
//       if (label == 'NPWP') _isNpwpUploading = true;
//       if (label == 'Karip') _isKaripUploading = true;
//     });

//     for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
//       await Future.delayed(Duration(milliseconds: 300));
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

//   Future<void> _pickImage(String label) async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//       if (image == null) return;

//       setState(() {
//         if (label == 'KTP') {
//           fileKTP = image.name; // Store original filename for display
//           fileKTPPath = image.path; // Store path for upload
//           fileErrors['KTP'] = null;
//         }
//         if (label == 'NPWP') {
//           fileNPWP = image.name;
//           fileNPWPPath = image.path;
//           fileErrors['NPWP'] = null;
//         }
//         if (label == 'Karip') {
//           fileKarip = image.name;
//           fileKaripPath = image.path;
//           fileErrors['Karip'] = null;
//         }
//       });

//       await _simulateUpload(label);
//     } catch (e) {
//       print('Error picking image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal memilih file. Silakan coba lagi.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   bool _validateFiles() {
//     bool isValid = true;
//     setState(() {
//       if (fileKTP == null) {
//         fileErrors['KTP'] = 'File KTP wajib diupload';
//         isValid = false;
//       }
//       if (fileNPWP == null) {
//         fileErrors['NPWP'] = 'File NPWP wajib diupload';
//         isValid = false;
//       }
//       if (fileKarip == null) {
//         fileErrors['Karip'] =
//             'File SK Pensiun/SK Aktif/Karip/Karpeg wajib diupload';
//         isValid = false;
//       }
//     });
//     return isValid;
//   }

//   Future<void> _submitPengajuanAnda() async {
//     if (!_formKey.currentState!.validate() || !_validateFiles()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Harap lengkapi semua data dan file yang diperlukan'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       bool success = await PengajuanAndaDao.kirimPengajuanAnda(
//         nama: namaController.text,
//         telepon: teleponController.text,
//         domisili: domisiliController.text,
//         nip: nipController.text,
//         fotoKTP: fileKTPPath!,
//         namaFotoKTP: fileKTP!,
//         fotoNPWP: fileNPWPPath!,
//         namaFotoNPWP: fileNPWP!,
//         fotoKarip: fileKaripPath!,
//         namaFotoKarip: fileKarip!,
//       );

//       if (success) {
//         _showAwesomeDialog(
//           title: 'Sukses',
//           message: 'Pengajuan Anda Berhasil Dikirim.',
//           dialogType: DialogType.success,
//           color: Colors.green,
//           isSuccess: true,
//         );
//       } else {
//         _showAwesomeDialog(
//           title: 'Gagal',
//           message: 'Anda sudah pernah melakukan pengajuan!',
//           dialogType: DialogType.error,
//           color: Colors.red,
//           isSuccess: false,
//         );
//       }
//     } catch (e) {
//       print('Error submitting pengajuan: $e');
//       _showAwesomeDialog(
//         title: 'Error',
//         message: 'Terjadi kesalahan saat mengirim pengajuan',
//         dialogType: DialogType.error,
//         color: Colors.red,
//         isSuccess: false,
//       );
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   void _showAwesomeDialog({
//     required String title,
//     required String message,
//     required DialogType dialogType,
//     required Color color,
//     required bool isSuccess,
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: dialogType,
//       animType: AnimType.scale,
//       title: title,
//       desc: message,
//       btnOkText: 'OK',
//       btnOkColor: color,
//       btnOkOnPress: () {
//         if (isSuccess) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RiwayatPengajuanAndaScreen(
//                 onChangeBottomNavIndex: (index) => 1,
//               ),
//             ),
//           );
//         }
//       },
//     ).show();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _refreshData();
//   }

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

//       setState(() {
//         namaController.text = value.data?.username ?? '';
//         teleponController.text = value.data?.phone ?? '';
//       });

//       return value;
//     });
//   }

//   OptionModel _inputCity =
//       OptionModel(id: 0, text: ''); // For storing selected city
//   List<OptionModel> _cities = []; // To store city list

//   Future<void> _loadCities() async {
//     if (_inputProvinsi.id == 0) return;

//     setState(() => _isLoading = true);
//     try {
//       final cities = await LocationRepository.getCity(_inputProvinsi.id);
//       setState(() {
//         _cities = cities;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading cities: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _showCitySelectionDialog() async {
//     if (_cities.isEmpty) {
//       await _loadCities();
//     }

//     final selectedCity = await showDialog<OptionModel>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Pilih Kabupaten/Kota'),
//           content: Container(
//             width: double.maxFinite,
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: _cities.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_cities[index].text),
//                   onTap: () {
//                     Navigator.of(context).pop(_cities[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );

//     if (selectedCity != null) {
//       setState(() {
//         _inputCity = selectedCity;
//         domisiliController.text = selectedCity.text;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: Center(
//           child: Padding(
//             padding:
//                 EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
//             child: Text(
//               'Form Pengajuan',
//               style: TextStyle(
//                 color: Color(0xFF017964),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
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
//                         // Replace TextFormField with GestureDetector for city selection
//                         GestureDetector(
//                           onTap: _showCitySelectionDialog,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 8),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Kota Domisili',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Text(
//                                       _inputCity.text.isNotEmpty
//                                           ? _inputCity.text
//                                           : 'Pilih Kota Domisili',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: _inputCity.text.isNotEmpty
//                                             ? Colors.black87
//                                             : Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Icon(Icons.arrow_drop_down, color: Colors.grey),
//                               ],
//                             ),
//                           ),
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

//                         // Custom Upload Fields
//                         CustomUploadField(
//                           label: 'KTP',
//                           filePath: fileKTP,
//                           isUploading: _isKtpUploading,
//                           uploadProgress: _ktpUploadProgress,
//                           onUpload: () => _pickImage('KTP'),
//                           errorText: fileErrors['KTP'],
//                         ),

//                         CustomUploadField(
//                           label: 'NPWP',
//                           filePath: fileNPWP,
//                           isUploading: _isNpwpUploading,
//                           uploadProgress: _npwpUploadProgress,
//                           onUpload: () => _pickImage('NPWP'),
//                           errorText: fileErrors['NPWP'],
//                         ),

//                         CustomUploadField(
//                           label: 'SK Pensiun/SK Aktif/Karip/Karpeg',
//                           filePath: fileKarip,
//                           isUploading: _isKaripUploading,
//                           uploadProgress: _karipUploadProgress,
//                           onUpload: () => _pickImage('Karip'),
//                           errorText: fileErrors['Karip'],
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
//       _inputCity = OptionModel(id: 0, text: '');
//     });
//   }
// }
