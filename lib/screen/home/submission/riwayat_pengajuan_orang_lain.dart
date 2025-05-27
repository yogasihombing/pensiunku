import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_orang_lain_model.dart';
import 'package:pensiunku/model/user_model.dart';
import 'package:pensiunku/repository/riwayat_pengajuan_orang_lain_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_orang_lain.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';

class RiwayatPengajuanOrangLainScreen extends StatefulWidget {
  static const String ROUTE_NAME =
      '/riwayat_ajukan'; // Mendefenisikan rute statis untuk navigasi ke halaman ini.
  final void Function(int index) onChangeBottomNavIndex;
  const RiwayatPengajuanOrangLainScreen({
    Key? key,
    required this.onChangeBottomNavIndex,
  }) : super(key: key);

  @override
  _RiwayatPengajuanOrangLainScreenState createState() =>
      _RiwayatPengajuanOrangLainScreenState();
}

class _RiwayatPengajuanOrangLainScreenState
    extends State<RiwayatPengajuanOrangLainScreen> {
  final RiwayatPengajuanOrangLainRepository _repository =
      RiwayatPengajuanOrangLainRepository(); // Inisialisasi repository
  List<RiwayatPengajuanOrangLainModel> pengajuanOrangLainData =
      []; // Data yang akan ditampilkan
  // bool isLoading = true; // Indikator apakah data sedang dimuat
  bool _isLoadingOverlay = true;
  String telepon = '';
  UserModel? _userModel; // Model pengguna (opsional)

  Future<void> _getProfile() async {
    String? token = SharedPreferencesUtil().sharedPreferences.getString(
        SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

    try {
      final value = await UserRepository().getOne(token!); // 3️⃣ Gunakan await
      setState(() {
        _userModel = value.data;
        telepon = value.data?.phone ?? '';
      });
      await fetchPengajuanOrangLainData(telepon); // 4️⃣ Tunggu hingga selesai
    } catch (e) {
      print('Error mengambil profil: $e');
      setState(
          () => _isLoadingOverlay = false); // 5️⃣ Matikan overlay jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> fetchPengajuanOrangLainData(telepon) async {
    setState(() => _isLoadingOverlay = true); // Set loading menjadi true
    try {
      print('UI: memulai fetch data untuk telepon $telepon');
      final data = await _repository.getRiwayatPengajuanOrangLain(
          telepon); // Panggil data dari repository
      print('UI: Data diterima dari repository: $data');

      setState(() {
        pengajuanOrangLainData = data; // Update data ke state
        _isLoadingOverlay = false; // Selesai loading
      });

      // Cek apakah data kosong
      if (pengajuanOrangLainData.isEmpty) {
        _showNoPengajuanDialog(); // Tampilkan dialog AwesomeDialog
      }
    } catch (e, stackTrace) {
      print('UI: Error saat fetch data - $e');
      print('UI: StackTrace - $stackTrace');

      setState(() =>
          _isLoadingOverlay = false); // Selesaikan loading meski ada error

      // Tambahkan kondisi khusus untuk menangani "data tidak ditemukan"
      if (e.toString().contains('data tidak ditemukan')) {
        _showNoPengajuanDialog(); // Tampilkan dialog AwesomeDialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showNoPengajuanDialog() {
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
                  color: Color(0xFF017964), // Set the background color to green
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Anda belum Pernah melakukan Pengajuan, klik fitur Pensiunku+',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors
                              .white, // Set the text color to white for better contrast
                        ),
                        textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF017964),
                        backgroundColor:
                            Colors.white, // Set the text color to green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context); // Kembali ke layar sebelumnya
                        }
                      },
                      child: Text('Kembali'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

 @override
Widget build(BuildContext context) {
  return Stack(
    fit: StackFit.expand,
    children: [
      // 🎨 Background Gradient
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFDCE293),
            ],
            stops: [0.6, 1.0],
          ),
        ),
      ),

      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Riwayat Pengajuan',
            style: TextStyle(
              color: Color(0xFF017964),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF017964)),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                widget.onChangeBottomNavIndex(0); // Kembali ke HOME
              }
            },
          ),
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            fetchPengajuanOrangLainData(telepon);
          },
          child: pengajuanOrangLainData.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: Text(
                            'AJUKAN PINJAMAN SEKARANG!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: pengajuanOrangLainData.length,
                  itemBuilder: (context, index) {
                    final pengajuan = pengajuanOrangLainData[index];
                    return Card(
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            pengajuan.tiket
                                .substring(0, 2)
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(
                          pengajuan.nama,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Tanggal: ${pengajuan.tanggal}'),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Kode: ${pengajuan.tiket}',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'ID: ${_userModel?.id ?? 'Tidak tersedia'}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StatusPengajuanOrangLainScreen(
                                pengajuanOrangLain: pengajuan,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF017964)),
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
  );
}

}


// // menampilkan data melalui state management. Data diambil dari repository. dev by Yoga
// class RiwayatPengajuanOrangLainScreen extends StatefulWidget {
//   static const String ROUTE_NAME =
//       '/riwayat_ajukan'; // Mendefenisikan rute statis untuk navigasi ke halaman ini.
//   final void Function(int index) onChangeBottomNavIndex;
//   const RiwayatPengajuanOrangLainScreen({
//     Key? key,
//     required this.onChangeBottomNavIndex,
//   }) : super(key: key);

//   @override
//   _RiwayatPengajuanOrangLainScreenState createState() =>
//       _RiwayatPengajuanOrangLainScreenState();
// }

// class _RiwayatPengajuanOrangLainScreenState
//     extends State<RiwayatPengajuanOrangLainScreen> {
//   final RiwayatPengajuanOrangLainRepository _repository =
//       RiwayatPengajuanOrangLainRepository(); // Inisialisasi repository
//   List<RiwayatPengajuanOrangLainModel> pengajuanOrangLainData =
//       []; // Data yang akan ditampilkan
//   bool isLoading = true; // Indikator apakah data sedang dimuat
//   String telepon = '';
//   UserModel? _userModel; // Model pengguna (opsional)

//   Future<void> _getProfile() async {
//     String? token = SharedPreferencesUtil().sharedPreferences.getString(
//         SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

//     UserRepository().getOne(token!).then((value) {
//       setState(() {
//         _userModel = value.data; /// simpan data pengguna ke _userModel
//       });
//       telepon = value.data?.phone ?? '';
//       print(value.data);
//       fetchPengajuanOrangLainData(
//           telepon); // Memanggil fungsi untuk mengambil data
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getProfile();
//   }

//   Future<void> fetchPengajuanOrangLainData(telepon) async {
//     setState(() => isLoading = true); // Set loading menjadi true
//     try {
//       print('UI: memulai fetch data untuk telepon $telepon');
//       final data = await _repository.getRiwayatPengajuanOrangLain(
//           telepon); // Panggil data dari repository
//       print('UI: Data diterima dari repository: $data');

//       setState(() {
//         pengajuanOrangLainData = data; // Update data ke state
//         isLoading = false; // Selesai loading
//       });
//     } catch (e, stackTrace) {
//       print('UI: Error saat fetch data - $e');
//       print('UI: StackTrace - $stackTrace');

//       setState(() => isLoading = false); // Selesaikan loading meski ada error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal memuat data: ${e.toString()}'),
//           behavior: SnackBarBehavior.floating,
//         ), // Tampilkan pesan error
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           WidgetUtil.getNewAppBar(context, 'Riwayat Pengajuan', 1, (newIndex) {
//         widget.onChangeBottomNavIndex(newIndex);
//       }, () {
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         } else {
//           widget.onChangeBottomNavIndex(0);
//         }
//       }),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           fetchPengajuanOrangLainData(telepon);
//         }, // Fungsi refresh saat swipe down
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator()) // Loader saat loading
//             : pengajuanOrangLainData.isEmpty
//                 // Tambahkan ListView agar RefreshIndicator bekerja meskipun data kosong
//                 ? ListView(children: const [
//                     SizedBox(
//                       height: 400,
//                       child: const Center(
//                         child: Text(
//                             'Tidak ada riwayat pengajuan.'), // Pesan jika data kosong
//                       ),
//                     ),
//                   ])
//                 : ListView.builder(
//                     itemCount: pengajuanOrangLainData.length, // Jumlah data
//                     itemBuilder: (context, index) {
//                       final pengajuanOrangLain = pengajuanOrangLainData[
//                           index]; // Mendefinisikan variabel pengajuan
//                       return Card(
//                         margin: const EdgeInsets.all(10.0),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Text(
//                               pengajuanOrangLain.tiket
//                                   .substring(0, 2)
//                                   .toUpperCase(), // Inisial dari tiket
//                             ),
//                           ),
//                           title: Text(
//                             pengajuanOrangLain.nama,
//                             style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold),
//                           ), // Nama pemohon
//                           subtitle: Text(
//                               'Tanggal: ${pengajuanOrangLain.tanggal}'), // Tanggal pengajuan
//                           trailing: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'Kode: ${pengajuanOrangLain.tiket}', // Tiket pengajuan
//                                 style: const TextStyle(
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 'ID: ${_userModel?.id ?? 'Tidak tersedia'}',
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     StatusPengajuanOrangLainScreen(
//                                   pengajuanOrangLain:
//                                       pengajuanOrangLain, // Kirim data pengajuan
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }


