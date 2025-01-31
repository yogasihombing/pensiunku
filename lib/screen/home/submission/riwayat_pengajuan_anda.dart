import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';
import 'package:pensiunku/repository/riwayat_pengajuan_anda_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_orang_lain.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/util/widget_util.dart';

import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class RiwayatPengajuanAndaScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/riwayat_pengajuan_anda';
  final void Function(int index) onChangeBottomNavIndex;
  const RiwayatPengajuanAndaScreen({
    Key? key,
    required this.onChangeBottomNavIndex,
  }) : super(key: key);

  @override
  State<RiwayatPengajuanAndaScreen> createState() =>
      _RiwayatPengajuanAndaScreenState();
}

class _RiwayatPengajuanAndaScreenState
    extends State<RiwayatPengajuanAndaScreen> {
  final RiwayatPengajuanAndaRepository _repository =
      RiwayatPengajuanAndaRepository();
  List<RiwayatPengajuanAndaModel> pengajuanAndaData = [];
  bool isLoading = true;
  String telepon = '';

  Future<void> _getProfile() async {
    String? token = SharedPreferencesUtil().sharedPreferences.getString(
        SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

    UserRepository().getOne(token!).then((value) {
      telepon = value.data?.phone ?? '';
      print(value.data);
      fetchPengajuanAndaData(telepon);
    });
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> fetchPengajuanAndaData(String telepon) async {
    setState(() => isLoading = true); // Set loading menjadi true
    try {
      print('UI: Memulai fetch data untuk telepon $telepon');
      final data = await _repository
          .getRiwayatPengajuanAnda(telepon); // Panggil data dari repository
      print('UI: Data diterima dari repository: $data');

      setState(() {
        pengajuanAndaData = data; // Update data ke state
        isLoading = false; // Selesai loading
      });

      if (pengajuanAndaData.isEmpty) {
        _showNoPengajuanDialog(
          title: 'Informasi',
          description:
              'Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.',
          buttonText: 'Ajukan Sekarang',
          onButtonPress: () {
            Navigator.pushNamed(context, '/pengajuan_anda');
          },
          dialogType: DialogType.info,
        );
      }
    } catch (e, stackTrace) {
      print('UI: Error saat fetch data - $e');
      print('UI: StackTrace - $stackTrace');

      setState(() => isLoading = false); // Selesaikan loading meski ada error
      _showNoPengajuanDialog(
        title: 'Gagal Memuat Data',
        description:
            'Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.',
        buttonText: 'Ajukan Sekarang',
        onButtonPress: () {
          Navigator.pushNamed(context, '/pengajuan_anda');
        },
        dialogType: DialogType.info,
      );
    }
  }

  void _showNoPengajuanDialog({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPress,
    DialogType dialogType = DialogType.info,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.bottomSlide,
      title: title,
      desc: description,
      btnOkText: buttonText,
      btnOkOnPress: onButtonPress,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Riwayat Pengajuan      ',
            style: TextStyle(
              color: Color(0xFF017964), // Kode warna #017964
              fontWeight: FontWeight.bold, // Teks bold
              fontSize: 20,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              widget.onChangeBottomNavIndex(0);
            }
          },
        ),
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan bayangan di bawah AppBar
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchPengajuanAndaData(telepon);
        }, // Fungsi refresh saat swipe down
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Loader saat loading
            : pengajuanAndaData.isEmpty
                ? ListView(children: const [
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                            'Tidak ada riwayat pengajuan Anda.'), // Pesan jika data kosong
                      ),
                    ),
                  ])
                : ListView.builder(
                    itemCount: pengajuanAndaData.length, // Jumlah data
                    itemBuilder: (context, index) {
                      final pengajuanAnda = pengajuanAndaData[
                          index]; // Mendefinisikan variabel pengajuan
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              pengajuanAnda.tiket
                                  .substring(0, 2)
                                  .toUpperCase(), // Inisial dari tiket
                            ),
                          ),
                          title: Text(
                            pengajuanAnda.nama,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Nama pemohon
                          subtitle: Text(
                              'Tanggal: ${pengajuanAnda.tanggal}'), // Tanggal pengajuan
                          trailing: Text(
                            'Kode: ${pengajuanAnda.tiket}', // Tiket pengajuan
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatusPengajuanAndaScreen(
                                  pengajuanAnda:
                                      pengajuanAnda, // Kirim data pengajuan
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


// class RiwayatPengajuanAndaScreen extends StatefulWidget {
//   static const String ROUTE_NAME = '/riwayat_pengajuan_anda';
//   final void Function(int index) onChangeBottomNavIndex;
//   const RiwayatPengajuanAndaScreen({
//     Key? key,
//     required this.onChangeBottomNavIndex,
//   }) : super(key: key);

//   @override
//   State<RiwayatPengajuanAndaScreen> createState() =>
//       _RiwayatPengajuanAndaScreenState();
// }

// class _RiwayatPengajuanAndaScreenState
//     extends State<RiwayatPengajuanAndaScreen> {
//   final RiwayatPengajuanAndaRepository _repository =
//       RiwayatPengajuanAndaRepository();
//   List<RiwayatPengajuanAndaModel> pengajuanAndaData = [];
//   bool isLoading = true;
//   String telepon = '';

//   Future<void> _getProfile() async {
//     String? token = SharedPreferencesUtil().sharedPreferences.getString(
//         SharedPreferencesUtil.SP_KEY_TOKEN); // Mendapatkan token pengguna

//     UserRepository().getOne(token!).then((value) {
//       telepon = value.data?.phone ?? '';
//       print(value.data);
//       fetchPengajuanAndaData(telepon);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getProfile();
//   }

//   Future<void> fetchPengajuanAndaData(telepon) async {
//     setState(() => isLoading = true); // Set loading menjadi true
//     try {
//       print('UI: memulai fetch data untuk telepon $telepon');
//       final data = await _repository
//           .getRiwayatPengajuanAnda(telepon); // Panggil data dari repository
//       print('UI: Data diterima dari repository: $data');

//       setState(() {
//         pengajuanAndaData = data; // Update data ke state
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
//       appBar: WidgetUtil.getNewAppBar(
//         context,
//         'Riwayat Pengajuan Anda',
//         1,
//         (newIndex) {
//           widget.onChangeBottomNavIndex(newIndex);
//         },
//         () {
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           } else {
//             widget.onChangeBottomNavIndex(0);
//           }
//         },
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           fetchPengajuanAndaData(telepon);
//         }, // Fungsi refresh saat swipe down
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator()) // Loader saat loading
//             : pengajuanAndaData.isEmpty
//                 // Tambahkan ListView agar RefreshIndicator bekerja meskipun data kosong
//                 ? ListView(children: const [
//                     SizedBox(
//                       height: 400,
//                       child: const Center(
//                         child: Text(
//                             'Tidak ada riwayat pengajuan Anda.'), // Pesan jika data kosong
//                       ),
//                     ),
//                   ])
//                 : ListView.builder(
//                     itemCount: pengajuanAndaData.length, // Jumlah data
//                     itemBuilder: (context, index) {
//                       final pengajuanAnda = pengajuanAndaData[
//                           index]; // Mendefinisikan variabel pengajuan
//                       return Card(
//                         margin: const EdgeInsets.all(8.0),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             child: Text(
//                               pengajuanAnda.tiket
//                                   .substring(0, 2)
//                                   .toUpperCase(), // Inisial dari tiket
//                             ),
//                           ),
//                           title: Text(
//                             pengajuanAnda.nama,
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ), // Nama pemohon
//                           subtitle: Text(
//                               'Tanggal: ${pengajuanAnda.tanggal}'), // Tanggal pengajuan
//                           trailing: Text(
//                             'Kode: ${pengajuanAnda.tiket}', // Tiket pengajuan
//                             style: const TextStyle(
//                                 color: Colors.blue,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => StatusPengajuanAndaScreen(
//                                   pengajuanAnda:
//                                       pengajuanAnda, // Kirim data pengajuan
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
