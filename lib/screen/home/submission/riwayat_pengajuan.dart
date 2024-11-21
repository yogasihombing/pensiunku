import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pensiunku/data/api/riwayat_ajukan_api.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';
import 'package:pensiunku/repository/riwayat_ajukan_repository.dart';

class RiwayatPengajuanPage extends StatefulWidget {
  const RiwayatPengajuanPage({Key? key}) : super(key: key);

  @override
  _RiwayatPengajuanPageState createState() => _RiwayatPengajuanPageState();
}

class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
  final RiwayatPengajuanRepository _repository = RiwayatPengajuanRepository();
  List<RiwayatPengajuanModel> pengajuanData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengajuanData();
  }

  Future<void> fetchPengajuanData() async {
    setState(() => isLoading = true); // Set state menjadi loading
    try {
      const String telepon = '085243861919';

      // Memanggil repository untuk mendapatkan data
      final data = await _repository.getRiwayatPengajuan(telepon);

      // Debug log untuk memeriksa isi data
      print('Data yang diterima: $data');

      // Pastikan data adalah List<Map<String, dynamic>> sebelum mapping
      if (data is List<Map<String, dynamic>>) {
        setState(() {
          pengajuanData = data
              .map((e) =>
                  RiwayatPengajuanModel.fromJson(e as Map<String, dynamic>))
              .toList(); // Mapping data ke model
          isLoading = false; // Loading selesai
        });
      } else {
        throw Exception('Format data tidak sesuai: $data');
      }
    } catch (e, stackTrace) {
      // Log error untuk debugging
      print('Error saat fetch data: $e');
      print('StackTrace: $stackTrace');

      // Handle error dengan menampilkan Snackbar
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pengajuan'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchPengajuanData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPengajuanData,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : pengajuanData.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada riwayat pengajuan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: pengajuanData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(pengajuanData[index].nama),
                        subtitle: Text(
                            'Tanggal: ${pengajuanData[index].tanggal} - Tiket: ${pengajuanData[index].tiket}'),
                      );
                    },
                  ),
      ),
    );
  }
}


// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:pensiunku/data/api/riwayat_ajukan_api.dart'; // API untuk mengambil data riwayat pengajuan
// import 'package:pensiunku/model/riwayat_ajukan_model.dart'; // Model data pengajuan
// import 'package:pensiunku/repository/riwayat_ajukan_repository.dart'; // Repository untuk menghubungkan UI dan API

// class RiwayatPengajuanPage extends StatefulWidget {
//   const RiwayatPengajuanPage({Key? key}) : super(key: key);

//   @override
//   _RiwayatPengajuanPageState createState() => _RiwayatPengajuanPageState();
// }

// class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
//   // Membuat instance repository
//   final RiwayatPengajuanRepository _repository = RiwayatPengajuanRepository();

//   // Variabel untuk menyimpan data pengajuan
//   List<RiwayatPengajuanModel> pengajuanData = [];

//   // Variabel untuk mengatur state loading
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Memanggil fungsi untuk mengambil data pengajuan saat widget pertama kali dibangun
//     fetchPengajuanData();
//   }

//   // Fungsi untuk mengambil data pengajuan dari repository
//   Future<void> fetchPengajuanData() async {
//     // Menyetel state loading menjadi true saat data sedang dimuat
//     setState(() => isLoading = true);

//     try {
//       // Mengambil nomor telepon (contoh saja, ganti sesuai sumber data)
//       const String telepon = '085243861919';

//       // Memanggil fungsi repository untuk mendapatkan data
//       final data = await _repository.getRiwayatPengajuan(telepon);
//       print('data yang diterima: $data');

//       // Menyimpan data ke dalam state
//       setState(() {
//         pengajuanData = data.map((e) => RiwayatPengajuanModel.fromJson(e)).toList();
//         isLoading = false; // Menyelesaikan proses loading
//       });
//     } catch (e, stackTrace) {
//       print('Error: $e');
//       print('StackTrace: $stackTrace');
//       // Mengatasi error jika data gagal dimuat
//       setState(() => isLoading = false);

//       // Menampilkan pesan error menggunakan Snackbar
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal memuat data: ${e.toString()}'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   // Widget untuk menampilkan pesan ketika data kosong
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.history, size: 64, color: Colors.grey), // Ikon riwayat
//           SizedBox(height: 16),
//           Text(
//             'Belum ada riwayat pengajuan',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget untuk menampilkan satu item data pengajuan
//   Widget _buildPengajuanItem(RiwayatPengajuanModel pengajuan) {
//     return Card(
//       elevation: 5, // Efek bayangan pada card
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16),
//         title: Text(
//           'Tiket: ${pengajuan.tiket}',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 8),
//             Text(
//               'Nama: ${pengajuan.nama}', // Menampilkan nama pemohon
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Tanggal Pengajuan: ${pengajuan.tanggal}', // Menampilkan tanggal pengajuan
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//         onTap: () {
//           // Aksi ketika item diklik (opsional, tambahkan navigasi jika perlu)
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Riwayat Pengajuan'), // Judul halaman
//         actions: [
//           // Tombol untuk refresh data
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: fetchPengajuanData,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: fetchPengajuanData, // Menyegarkan data saat swipe ke bawah
//         child: isLoading
//             ? Center(
//                 child: CircularProgressIndicator()) // Loader saat data dimuat
//             : pengajuanData.isEmpty
//                 ? _buildEmptyState() // Menampilkan pesan jika data kosong
//                 : ListView.builder(
//                     itemCount: pengajuanData.length, // Jumlah item data
//                     padding: EdgeInsets.symmetric(vertical: 8),
//                     itemBuilder: (context, index) {
//                       // Membuat item untuk setiap data
//                       return _buildPengajuanItem(pengajuanData[index]);
//                     },
//                   ),
//       ),
//     );
//   }
// }
