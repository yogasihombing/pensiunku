import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/submission_model.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/selfie/prepare_selfie_screen.dart';
import 'package:pensiunku/screen/home/dashboard/pensiunku_plus/upload_ktp_screen.dart';

class UploadFotoWajahPensiunkuPlusScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/UploadFotoWajahPensiunkuPlusScreen';

  const UploadFotoWajahPensiunkuPlusScreen({Key? key}) : super(key: key);

  @override
  _UploadFotoWajahPensiunkuPlusScreenState createState() =>
      _UploadFotoWajahPensiunkuPlusScreenState();
}

class _UploadFotoWajahPensiunkuPlusScreenState
    extends State<UploadFotoWajahPensiunkuPlusScreen> {
  bool _isLoading = false;
  SelfieModel? _selfieResult;

  void _handleSelfieSuccess(BuildContext context) {
    setState(() {
      _isLoading = false;
    
    });
    // Navigasi ke halaman berikutnya
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadKTPPensiunkuPlusScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double backButtonToImageDistance =
        20.0; // Jarak antara tombol back dan gambar
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Color.fromARGB(255, 233, 208, 127),
                  ],
                  stops: [0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  // Back button and progress bar
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.25,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF006C4E)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  // Logo
                  Image.asset(
                    'assets/pensiunkuplus/pensiunku.png',
                    height: 100,
                  ),
                  SizedBox(height: 10),
                  // Illustration
                  Image.asset(
                    'assets/pensiunkuplus/uploadfotowajah.png',
                    height: 150,
                  ),
                  SizedBox(height: 10),
                  // Title
                  Text(
                    'Upload foto wajah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoading = true;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrepareSelfieScreen(
                            onSuccess: _handleSelfieSuccess,
                            submissionModel: SubmissionModel(
                              id: 0,
                              name: '',
                              birthDate: DateTime.now(),
                              phone: '',
                              bankName: '',
                              plafond: 0,
                              produk: '',
                              salary: 0,
                              tenor: 0,
                            ), // Sesuaikan dengan model yang Anda gunakan
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                  'assets/pensiunkuplus/icon_upload_dokumen.png'),
                              SizedBox(height: 8),
                              Text(
                                'Ambil Foto Wajah',
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
                  ),
                  SizedBox(height: 24),
                  // Submit Button
                  ElevatedButton(
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
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_selfieResult != null) {
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.file(
                                    File(_selfieResult!.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                              // Menggunakan _selfieResult yang sudah dideklarasikan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UploadKTPPensiunkuPlusScreen(),
                                ),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Harap ambil foto wajah terlebih dahulu'),
                                ),
                              );
                            }
                          },
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit'),
                  ),

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


// class UploadFotoWajahPensiunkuPlusScreen extends StatelessWidget {
//   static const String ROUTE_NAME = '/UploadFotoWajahPensiunkuPlusScreen';

//   const UploadFotoWajahPensiunkuPlusScreen({Key? key}) : super(key: key);

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
//                           value: 0.25,
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
//                     'assets/pensiunkuplus/uploadfotowajah.png',
//                     height: 150,
//                   ),
//                   SizedBox(height: 10),
//                   // Title
//                   Text(
//                     'Upload foto wajah',
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
//                             Image.asset('assets/pensiunkuplus/icon_upload_dokumen.png'),
//                             // Icon(Icons.image, size: 40, color: Colors.grey),
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
//                       // Navigasi ke halaman UploadKTPPensiunkuPlusScreen
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               UploadKTPPensiunkuPlusScreen(),
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
