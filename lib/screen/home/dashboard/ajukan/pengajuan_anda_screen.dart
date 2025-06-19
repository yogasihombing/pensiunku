import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pensiunku/data/db/pengajuan_anda_dao.dart';
import 'package:pensiunku/model/option_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/location_repository.dart';
import 'package:pensiunku/model/result_model.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015),
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
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          filePath ?? 'Belum ada file dipilih',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenWidth * 0.04,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.06,
                    width: 1,
                    color: Colors.grey[300],
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  ),
                  if (isUploading)
                    SizedBox(
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
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
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Image.asset(
                          'assets/dashboard_screen/upload_icon.png',
                          width: screenWidth * 0.08,
                          height: screenWidth * 0.08,
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
            padding: EdgeInsets.only(
                left: screenWidth * 0.03, top: screenHeight * 0.005),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.03,
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

  final TextEditingController _searchController = TextEditingController();
  List<OptionModel> _filteredCities = List.from(LocationRepository.cities);

  late Future<ResultModel<UserModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _isLoadingOverlay = true;
    _refreshData();
  }

  late OptionModel _selectedCity = OptionModel(id: 0, text: '');

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

    if (_selectedCity.id == 0 || _selectedCity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap pilih kota/kabupaten Anda'),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.04,
            ),
            child: Container(
              width: screenWidth * 0.8,
              constraints: BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // // Optional icon for success/failure
                  // Icon(
                  //   isSuccess ? Icons.check_circle : Icons.error,
                  //   color: Colors.white,
                  //   size: screenWidth * 0.15,
                  // ),
                  // SizedBox(height: screenHeight * 0.02),
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Button
                  Container(
                    width: screenWidth * 0.3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: color,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
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
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
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

  _refreshData() {
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    _futureData = UserRepository().getOne(token!).then((value) {
      if (value.error != null) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                    value.error.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. Background gradient
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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // 1. Atur total tinggi toolbar (toolbarHeight) lebih besar dari default
            toolbarHeight: kToolbarHeight + screenHeight * 0.02,
            // 2. Padding di leading agar ikon back juga turun
            leading: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.02),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // 3. Hapus flexibleSpace, pakai title dengan Padding
            title: Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.02),
              child: Text(
                'Form Pengajuan',
                style: TextStyle(
                  color: Color(0xFF017964),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
            ),
            centerTitle:
                true, // opsional: agar teks berada di tengah horizontal
          ),
          body: SafeArea(
            child: Stack(
              children: [
                _isLoadingOverlay
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    screenHeight - kToolbarHeight - safeAreaTop,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: screenHeight * 0.02),
                                  // Nama field
                                  // Text(
                                  //   'Nama',
                                  //   style: TextStyle(
                                  //     fontSize: screenWidth * 0.035,
                                  //     color: Colors.grey[700],
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
                                  // SizedBox(height: screenHeight * 0.01),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: namaController,
                                      readOnly: true,
                                      enabled: !_isLoadingOverlay,
                                      decoration: InputDecoration(
                                          labelText: 'Nama',
                                          border: OutlineInputBorder()),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Harap masukkan nama'
                                              : null,
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // Telepon field
                                  // Text(
                                  //   'No. Telepon',
                                  //   style: TextStyle(
                                  //     fontSize: screenWidth * 0.035,
                                  //     color: Colors.grey[700],
                                  //     fontWeight: FontWeight.w500,
                                  //   ),
                                  // ),
                                  // SizedBox(height: screenHeight * 0.01),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: TextFormField(
                                      controller: teleponController,
                                      readOnly: true,
                                      enabled: !_isLoadingOverlay,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                          labelText: 'No Telepon',
                                          border: OutlineInputBorder()),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return 'Harap masukkan no. telepon';
                                        if (!RegExp(r'^[0-9]+$')
                                            .hasMatch(value))
                                          return 'No. telepon hanya boleh angka';
                                        return null;
                                      },
                                      style: TextStyle(
                                          fontSize: screenWidth * 0.04),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  GestureDetector(
                                    onTap: _showCitySelectionDialog,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Kota/Kabupaten',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth *
                                              0.02, // disesuaikan agar tidak dobel padding
                                          // vertical: screenHeight * 0.015,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedCity.id != 0
                                                    ? _selectedCity.text
                                                    : 'Pilih Kota/Kabupaten',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: _selectedCity.id != 0
                                                      ? Colors.black87
                                                      : Colors.grey[500],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey[600],
                                              size: screenWidth * 0.06,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.04),

                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.06,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _submitPengajuanAnda,
                                      child: _isSubmitting
                                          ? SizedBox(
                                              height: screenHeight * 0.025,
                                              width: screenHeight * 0.025,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Ajukan Sekarang',
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04),
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF017964),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.02),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        if (_isLoadingOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: screenWidth * 0.4,
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.08,
                        height: screenWidth * 0.08,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF017964),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Mohon tunggu...',
                        style: TextStyle(
                          color: Color(0xFF017964),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
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
