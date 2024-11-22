
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

// import 'package:flutter/material.dart';
// // import 'package:pensiunku/data/repository/riwayat_ajukan_repository.dart';
// import 'package:pensiunku/model/riwayat_ajukan_model.dart';
// import 'package:pensiunku/repository/riwayat_ajukan_repository.dart';

// class RiwayatPengajuanPage extends StatefulWidget {
//   final String telepon;

//   const RiwayatPengajuanPage({Key? key, required this.telepon})
//       : super(key: key);

//   @override
//   _RiwayatPengajuanPageState createState() => _RiwayatPengajuanPageState();
// }

// class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
//   final RiwayatPengajuanRepository _repository = RiwayatPengajuanRepository();
//   late Future<List<RiwayatPengajuanModel>> _riwayatFuture;

//   @override
//   void initState() {
//     super.initState();
//     _riwayatFuture = _repository.getRiwayatPengajuan(widget.telepon);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Riwayat Pengajuan'),
//       ),
//       body: FutureBuilder<List<RiwayatPengajuanModel>>(
//         future: _riwayatFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Text('Tidak ada data pengajuan.'),
//             );
//           }

//           final data = snapshot.data!;
//           return ListView.builder(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final pengajuan = data[index];
//               return Card(
//                 child: ListTile(
//                   title: Text(pengajuan.nama),
//                   subtitle: Text(
//                       'Tiket: ${pengajuan.tiket}\nTanggal: ${pengajuan.tanggal}'),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

