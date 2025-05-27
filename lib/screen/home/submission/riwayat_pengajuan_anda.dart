import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';
import 'package:pensiunku/repository/riwayat_pengajuan_anda_repository.dart';
import 'package:pensiunku/repository/user_repository.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/pengajuan_anda_screen.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan_anda.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:pensiunku/widget/dialog_helper.dart';

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
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);

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
    setState(() => isLoading = true);
    try {
      print('UI: Memulai fetch data untuk telepon $telepon');
      final data = await _repository.getRiwayatPengajuanAnda(telepon);
      print('UI: Data diterima dari repository: $data');

      setState(() {
        pengajuanAndaData = data;
        isLoading = false;
      });

      if (pengajuanAndaData.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => DialogHelper(
            title: "Gagal Memuat Data",
            description:
                "Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.",
            buttonText: "Ajukan Sekarang",
            onButtonPress: () {
              print("Ajukan Sekarang");
            },
            dialogType: DialogType.error,
            nextPage: PengajuanAndaScreen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('UI: Error saat fetch data - $e');
      print('UI: StackTrace - $stackTrace');

      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (context) => DialogHelper(
          title: "Informasi",
          description:
              "Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.",
          buttonText: "Ajukan Sekarang",
          onButtonPress: () {
            print("Ajukan Sekarang");
          },
          dialogType: DialogType.error,
          nextPage: PengajuanAndaScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
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

        // Main content with transparent scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(''),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF017964)),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  widget.onChangeBottomNavIndex(0);
                }
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 5),
                child: const Text(
                  'Riwayat Pengajuan',
                  style: TextStyle(
                    color: Color(0xFF017964),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              fetchPengajuanAndaData(telepon);
            },
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pengajuanAndaData.isEmpty
                    ? ListView(children: const [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text('Tidak ada riwayat pengajuan Anda.'),
                          ),
                        ),
                      ])
                    : ListView.builder(
                        itemCount: pengajuanAndaData.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final pengajuanAnda = pengajuanAndaData[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StatusPengajuanAndaScreen(
                                    pengajuanAnda: pengajuanAnda,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pengajuanAnda.nama,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF017964),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons
                                                    .confirmation_number_outlined,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Pengajuan ${pengajuanAnda.tiket}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                pengajuanAnda.tanggal,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: const [
                                          Text(
                                            'Lihat Detail',
                                            style: TextStyle(
                                              color: Color(0xFF017964),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Color(0xFF017964),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
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

//   Future<void> fetchPengajuanAndaData(String telepon) async {
//     setState(() => isLoading = true); // Set loading menjadi true
//     try {
//       print('UI: Memulai fetch data untuk telepon $telepon');
//       final data = await _repository
//           .getRiwayatPengajuanAnda(telepon); // Panggil data dari repository
//       print('UI: Data diterima dari repository: $data');

//       setState(() {
//         pengajuanAndaData = data; // Update data ke state
//         isLoading = false; // Selesai loading
//       });

//       if (pengajuanAndaData.isEmpty) {
//         _showNoPengajuanDialog(
//           title: 'Informasi',
//           description:
//               'Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.',
//           buttonText: 'Ajukan Sekarang',
//           onButtonPress: () {
//             Navigator.pushNamed(context, '/pengajuan_anda');
//           },
//           dialogType: DialogType.info,
//         );
//       }
//     } catch (e, stackTrace) {
//       print('UI: Error saat fetch data - $e');
//       print('UI: StackTrace - $stackTrace');

//       setState(() => isLoading = false); // Selesaikan loading meski ada error
//       _showNoPengajuanDialog(
//         title: 'Gagal Memuat Data',
//         description:
//             'Tidak ada riwayat pengajuan Anda. Ajukan permohonan sekarang.',
//         buttonText: 'Ajukan Sekarang',
//         onButtonPress: () {
//           Navigator.pushNamed(context, '/pengajuan_anda');
//         },
//         dialogType: DialogType.info,
//       );
//     }
//   }

//   void _showNoPengajuanDialog({
//     required String title,
//     required String description,
//     required String buttonText,
//     required VoidCallback onButtonPress,
//     DialogType dialogType = DialogType.info,
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: dialogType,
//       animType: AnimType.bottomSlide,
//       title: title,
//       desc: description,
//       btnOkText: buttonText,
//       btnOkOnPress: onButtonPress,
//     ).show();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''), // Judul kosong
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
//           onPressed: () {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             } else {
//               widget.onChangeBottomNavIndex(0);
//             }
//           },
//         ),
//         backgroundColor: Colors.transparent, // AppBar transparan
//         elevation: 0, // Menghilangkan bayangan
//         flexibleSpace: Center(
//           // Pusatkan teks di tengah layar
//           child: Padding(
//             padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top +
//                     5), // Sesuaikan padding atas
//             child: Text(
//               'Riwayat Pengajuan',
//               style: TextStyle(
//                 color: Color(0xFF017964), // Warna teks
//                 fontWeight: FontWeight.bold, // Teks bold
//                 fontSize: 20, // Ukuran teks
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           fetchPengajuanAndaData(telepon);
//         }, // Fungsi refresh saat swipe down
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator()) // Loader saat loading
//             : pengajuanAndaData.isEmpty
//                 ? ListView(children: const [
//                     SizedBox(
//                       height: 300,
//                       child: Center(
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
