import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_model.dart';
import 'package:pensiunku/repository/riwayat_pengajuan_orang_lain_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_orang_lain.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';

import '../../../util/widget_util.dart';

// menampilkan data melalui state management. Data diambil dari repository. dev by Yoga
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
  bool isLoading = true; // Indikator apakah data sedang dimuat
  String telepon = '';

  Future<void> _getProfile() async {
    String? token = SharedPreferencesUtil().sharedPreferences.getString(
        SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

    UserRepository().getOne(token!).then((value) {
      telepon = value.data?.phone ?? '';
      print(value.data);
      fetchPengajuanOrangLainData(
          telepon); // Memanggil fungsi untuk mengambil data
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> fetchPengajuanOrangLainData(telepon) async {
    setState(() => isLoading = true); // Set loading menjadi true
    try {
      print('UI: memulai fetch data untuk telepon $telepon');
      final data = await _repository.getRiwayatPengajuanOrangLain(
          telepon); // Panggil data dari repository
      print('UI: Data diterima dari repository: $data');

      setState(() {
        pengajuanOrangLainData = data; // Update data ke state
        isLoading = false; // Selesai loading
      });
    } catch (e, stackTrace) {
      print('UI: Error saat fetch data - $e');
      print('UI: StackTrace - $stackTrace');

      setState(() => isLoading = false); // Selesaikan loading meski ada error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ), // Tampilkan pesan error
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          WidgetUtil.getNewAppBar(context, 'Riwayat Pengajuan', 1, (newIndex) {
        widget.onChangeBottomNavIndex(newIndex);
      }, () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          widget.onChangeBottomNavIndex(0);
        }
      }),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchPengajuanOrangLainData(telepon);
        }, // Fungsi refresh saat swipe down
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Loader saat loading
            : pengajuanOrangLainData.isEmpty
                // Tambahkan ListView agar RefreshIndicator bekerja meskipun data kosong
                ? ListView(children: const [
                    SizedBox(
                      height: 400,
                      child: const Center(
                        child: Text(
                            'Tidak ada riwayat pengajuan.'), // Pesan jika data kosong
                      ),
                    ),
                  ])
                : ListView.builder(
                    itemCount: pengajuanOrangLainData.length, // Jumlah data
                    itemBuilder: (context, index) {
                      final pengajuanOrangLain = pengajuanOrangLainData[
                          index]; // Mendefinisikan variabel pengajuan
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              pengajuanOrangLain.tiket
                                  .substring(0, 2)
                                  .toUpperCase(), // Inisial dari tiket
                            ),
                          ),
                          title: Text(pengajuanOrangLain.nama), // Nama pemohon
                          subtitle: Text(
                              'Tanggal: ${pengajuanOrangLain.tanggal}'), // Tanggal pengajuan
                          trailing: Text(
                            'Kode: ${pengajuanOrangLain.tiket}', // Tiket pengajuan
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StatusPengajuanOrangLainScreen(
                                  pengajuanOrangLain:
                                      pengajuanOrangLain, // Kirim data pengajuan
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:pensiunku/model/riwayat_ajukan_model.dart';
// import 'package:pensiunku/repository/riwayat_ajukan_repository.dart';

// // menampilkan data melalui state management. Data diambil dari repository. dev by Yoga
// class RiwayatPengajuanPage extends StatefulWidget {
//   const RiwayatPengajuanPage({Key? key}) : super(key: key);

//   @override
//   _RiwayatPengajuanPageState createState() => _RiwayatPengajuanPageState();
// }

// class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
//   final RiwayatPengajuanRepository _repository =
//       RiwayatPengajuanRepository(); // Inisialisasi repository
//   List<RiwayatPengajuanModel> pengajuanData = []; // Data yang akan ditampilkan
//   bool isLoading = true; // Indikator apakah data sedang dimuat

//   @override
//   void initState() {
//     super.initState();
//     fetchPengajuanData(); // Memanggil fungsi untuk mengambil data
//   }

//   Future<void> fetchPengajuanData() async {
//     setState(() => isLoading = true); // Set loading menjadi true
//     try {
//       const String telepon = '085243861919'; // Nomor telepon sebagai parameter
//       print('UI: memulai fetch data untuk telepon $telepon');
//       final data = await _repository
//           .getRiwayatPengajuan(telepon); // Panggil data dari repository
//       print('UI: Data diterima dari repository: $data');

//       setState(() {
//         pengajuanData = data; // Update data ke state
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
//       appBar: AppBar(
//         title: const Text('Riwayat Pengajuan'), // Judul halaman
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh), // Tombol refresh
//             onPressed: fetchPengajuanData, // Memanggil ulang fetch data
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchPengajuanData, // Fungsi refresh saat swipe down
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator()) // Loader saat loading
//             : pengajuanData.isEmpty
//                 ? const Center(
//                     child: Text(
//                         'Tidak ada riwayat pengajuan.'), // Pesan jika data kosong
//                   )
//                 : ListView.builder(
//                     itemCount:
//                         pengajuanData.length, // Jumlah item dalam ListView
//                     itemBuilder: (context, index) {
//                       final pengajuan =
//                           pengajuanData[index]; // Ambil data per item
//                       return Card(
//                         margin: const EdgeInsets.all(8.0),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Text(
//                               pengajuan.tiket
//                                   .substring(0, 2)
//                                   .toUpperCase(), // Inisial dari tiket
//                             ),
//                           ),
//                           title: Text(pengajuan.nama), // Nama pemohon
//                           subtitle: Text(
//                               'Tanggal: ${pengajuan.tanggal}'), // Tanggal pengajuan
//                           trailing: Text(
//                             'Kode: ${pengajuan.tiket}', // Tiket pengajuan
//                             style: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }
