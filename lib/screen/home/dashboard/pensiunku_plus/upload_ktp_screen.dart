import 'package:flutter/material.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/daftarkan_pin_screen.dart';

import 'package:flutter/material.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/ktp/prepare_ktp_screen.dart';

class UploadKTPPensiunkuPlusScreen extends StatelessWidget {
  // Nama route untuk navigasi
  static const String ROUTE_NAME = '/UploadFotoWajahScreen';

  const UploadKTPPensiunkuPlusScreen({Key? key}) : super(key: key);

  // Konstanta untuk styling
  static const double _horizontalPadding = 20.0;
  static const double _verticalPadding = 20.0;
  static const double _logoHeight = 100.0;
  static const double _illustrationHeight = 150.0;
  static const double _uploadBoxHeight = 150.0;

  // Warna untuk gradient background
  static const List<Color> _gradientColors = [
    Colors.white,
    Colors.white,
    Colors.white,
    Color.fromARGB(255, 233, 208, 127),
  ];

  static const List<double> _gradientStops = [0.25, 0.5, 0.75, 1.0];

  // Widget untuk background gradient
  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradientColors,
            stops: _gradientStops,
          ),
        ),
      ),
    );
  }

  // Widget untuk header (back button dan progress bar)
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: 0.5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
          ),
        ),
      ],
    );
  }

  // Widget untuk logo
  Widget _buildLogo() {
    return Image.asset(
      'assets/pensiunkuplus/pensiunku.png',
      height: _logoHeight,
    );
  }

  // Widget untuk ilustrasi
  Widget _buildIllustration() {
    return Image.asset(
      'assets/pensiunkuplus/uploadktp.png',
      height: _illustrationHeight,
    );
  }

  // Widget untuk box upload dokumen
  Widget _buildUploadBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          // Navigasi ke PrepareKtpScreen dengan arguments
          Navigator.pushNamed(
            context,
            PrepareKtpScreen.ROUTE_NAME,
            arguments: PrepareKtpScreenArguments(
              onSuccess: (context) {
                // Callback ketika proses berhasil
                print('KTP berhasil diupload');
                // Tambahkan logika yang diperlukan setelah upload berhasil
              },
              submissionModel: SubmissionModel(
                  id: 0,
                  name: '',
                  birthDate: DateTime.now(),
                  phone: '',
                  bankName: '',
                  plafond: 0,
                  produk: '',
                  salary: 0,
                  tenor: 0), // Sesuaikan dengan model data Anda
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: _uploadBoxHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/pensiunkuplus/icon_upload_dokumen.png'),
                SizedBox(height: 8),
                Text(
                  'Pilih dokumen',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol submit
  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFC950),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 40.0,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DaftarkanPinPensiunkuPlusScreen(),
          ),
        );
      },
      child: isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'Submit',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: _verticalPadding,
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  SizedBox(height: 0),
                  _buildLogo(),
                  SizedBox(height: 10),
                  _buildIllustration(),
                  SizedBox(height: 20),
                  Text(
                    'Upload foto KTP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildUploadBox(context),
                  SizedBox(height: 24),
                  _buildSubmitButton(context, isLoading),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// class UploadKTPPensiunkuPlusScreen extends StatelessWidget {
//   static const String ROUTE_NAME = '/UploadFotoWajahScreen';

//   const UploadKTPPensiunkuPlusScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool _isLoading = false;
//     double backButtonToImageDistance =
//         20.0; // Jarak antara tombol back dan gambar
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.white,
//                     Colors.white,
//                     Colors.white,
//                     Color.fromARGB(255, 233, 208, 127),
//                   ],
//                   stops: [0.25, 0.5, 0.75, 1.0],
//                 ),
//               ),
//             ),
//           ),
//           // Content
//           SafeArea(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//               child: Column(
//                 children: [
//                   // Back button and progress bar
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.arrow_back, color: Colors.black),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                       Expanded(
//                         child: LinearProgressIndicator(
//                           value: 0.5,
//                           backgroundColor: Colors.grey[300],
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 0),
//                   // Logo
//                   Image.asset(
//                     'assets/pensiunkuplus/pensiunku.png',
//                     height: 100,
//                   ),
//                   SizedBox(height: 10),
//                   // Illustration
//                   Image.asset(
//                     'assets/pensiunkuplus/uploadktp.png',
//                     height: 150,
//                   ),
//                   SizedBox(height: 20),
//                   // Title
//                   Text(
//                     'Upload foto KTP',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Upload Box
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Container(
//                       width: double.infinity,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.grey,
//                           // style: BorderStyle.dashed,
//                         ),
//                       ),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                                 'assets/pensiunkuplus/icon_upload_dokumen.png'),
//                             SizedBox(height: 8),
//                             Text(
//                               'Pilih dokumen',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   // Submit Button
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFFFC950),
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         vertical: 10.0,
//                         horizontal: 40.0,
//                       ),
//                     ),
//                     onPressed: () {
//                       // Navigasi ke halaman DaftarkanPinScreen
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               DaftarkanPinPensiunkuPlusScreen(),
//                         ),
//                       );
//                     },
//                     child: _isLoading
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             'Submit',
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
