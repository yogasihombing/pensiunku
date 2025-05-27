import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_orang_lain_model.dart';

class StatusPengajuanOrangLainScreen extends StatelessWidget {
  final RiwayatPengajuanOrangLainModel pengajuanOrangLain;

  const StatusPengajuanOrangLainScreen(
      {Key? key, required this.pengajuanOrangLain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna untuk memberikan kesan elegan
    const Color primaryColor = Color(0xFF017964); // Warna biru elegan
    const Color secondaryColor = Color(0xFFF5F5F5); // Latar belakang lembut

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

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFF017964)),
            title: const Text(
              'Status Pengajuan',
              style: TextStyle(
                color: Color(0xFF017964),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail data
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Nama Pemohon: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                pengajuanOrangLain.nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number,
                                  color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Kode Pengajuan: ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              Text(
                                pengajuanOrangLain.tiket,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Tanggal Pengajuan: ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              Text(
                                pengajuanOrangLain.tanggal,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Arti Kode Tiket
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: secondaryColor,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: const Text(
                              'Pemberkasan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mohon Siapkan Dokumen Berikut:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Kartu Tanda Penduduk (KTP)\n'
                            '2. Kartu Keluarga\n'
                            '3. Kartu Nomor Pokok Wajib Pajak (NPWP)\n'
                            '4. Kartu Identitas Pensiunan (KARIP)\n'
                            '5. SK Pensiun (Untuk Pensiunan)\n'
                            '6. SK 80 atau SK 100 (Untuk Pra Pensiun)\n'
                            '7. Buku Tabungan\n'
                            '8. Cover Buku Tabungan Bank Asal\n'
                            '9. Rekening Koran Tiga Bulan Terakhir (Rekening Penerima Gaji Pensiun)\n'
                            '10. Slip Gaji Pensiun 2 Bulan Terakhir\n'
                            '11. 2 Lembar Pas Foto Nasabah\n'
                            '12. Surat Permohonan Pelunasan dipercepat yang telah ditandatangani (Bila Take Over)\n'
                            '13. Surat Keterangan Kematian (Apabila Pemohon Pensiunan Janda atau Duda)\n'
                            '14. Surat Pernyataan Tidak Menikah Kembali (Pemohon Janda atau Duda)',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}


// Text('Nama: ${pengajuan.nama}', style: TextStyle(fontSize: 18)),
//                   Text('Kode Tiket: ${pengajuan.tiket}',
//                       style: TextStyle(fontSize: 18)),
//                   Text('Tanggal: ${pengajuan.tanggal}',
//                       style: TextStyle(fontSize: 18)),
// import 'package:flutter/material.dart';

// class StatusPengajuanPage extends StatefulWidget {
//   final String nama;
//   final String telepon;
//   final String domisili;
//   final String nip;
//   final String nama_foto_ktp;
//   final String npwpFileName;
//   final String statusPengajuan; // Menambahkan status pengajuan

//   StatusPengajuanPage({
//     required this.nama,
//     required this.telepon,
//     required this.domisili,
//     required this.nip,
//     required this.nama_foto_ktp,
//     required this.npwpFileName,
//     required this.statusPengajuan, // Inisialisasi
//   });

//   @override
//   _StatusPengajuanPageState createState() => _StatusPengajuanPageState();
// }

// class _StatusPengajuanPageState extends State<StatusPengajuanPage> {
//   double currentStep = 0; // Inisialisasi dengan nilai 0 (pengajuan baru)

//   List<String> steps = [
//     'Pengajuan Kredit',
//     'Cek SLIK',
//     'Simulasi Kredit',
//     'Pemberkasan',
//     'Pencairan',
//   ];

//   List<bool> _isExpanded = List.generate(5, (_) => false);

//   @override
//   void initState() {
//     super.initState();

//     // Ubah currentStep berdasarkan status pengajuan yang diterima
//     switch (widget.statusPengajuan) {
//       case 'Pengajuan Kredit':
//         currentStep = 0;
//         break;
//       case 'Cek SLIK':
//         currentStep = 1;
//         break;
//       case 'Simulasi Kredit':
//         currentStep = 2;
//         break;
//       case 'Pemberkasan':
//         currentStep = 3;
//         break;
//       case 'Pencairan':
//         currentStep = 4;
//         break;
//       default:
//         currentStep = 0;
//     }
//   }

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Status Pengajuan'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             // Container Pertama: Status Pengajuan dan Slider Bertahap
//             Container(
//               width: double.infinity, // Sesuaikan dengan lebar layar
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Color(0xFFFFAE58),
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Status Pengajuan',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                         vertical: 8.0, horizontal: 16.0),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green,
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 4,
//                                           offset: Offset(2, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         'Simulasi Kredit',
//                                         style: TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),

//                             SizedBox(height: 8.0),
//                             Text('Pinjaman Pra-Pensiun'),
//                             Text('Plafon: Rp 50.000.000,-'),
//                             SizedBox(height: 16.0),

//                             // Range Slider Bertahap
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Progres Pengajuan',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.0),

//                                 // RangeSlider with steps
//                                 RangeSlider(
//                                   values: RangeValues(0, currentStep),
//                                   min: 0,
//                                   max: steps.length - 1,
//                                   divisions: steps.length - 1,
//                                   labels: RangeLabels(
//                                       steps[0], steps[currentStep.toInt()]),
//                                   onChanged: (RangeValues values) {},
//                                   activeColor: Colors.green,
//                                   inactiveColor: Colors.grey[300],
//                                 ),
//                                 SizedBox(height: 16.0),

//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: steps.map((step) {
//                                     return Text(
//                                       step,
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16.0),

//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Tanggal Pengajuan: 12/09/2024',
//                                     style: TextStyle(
//                                       fontSize: 12, // Ukuran font lebih kecil
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Estimasi Pencairan: 20/09/2024',
//                                     style: TextStyle(
//                                       fontSize: 12, // Ukuran font lebih kecil
//                                       color: Colors.grey, // Warna lebih ringan
//                                     ),
//                                     textAlign: TextAlign.right,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(width: 16.0),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16.0),

//             // Container Kedua: Detail Setiap Tahap Pengajuan
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Detail Tahap Pengajuan',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 8.0),

//                   // Detail Expandable List untuk setiap tahap
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: steps.length,
//                     itemBuilder: (context, index) {
//                       return Column(
//                         children: [
//                           ListTile(
//                             title: Text(steps[index]),
//                             trailing: Icon(_isExpanded[index]
//                                 ? Icons.keyboard_arrow_up
//                                 : Icons.keyboard_arrow_down),
//                             onTap: () {
//                               setState(() {
//                                 _isExpanded[index] = !_isExpanded[index];
//                               });
//                             },
//                           ),
//                           if (_isExpanded[index])
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16.0, vertical: 8.0),
//                               child: Text(
//                                 'Detail dari tahap ${steps[index]}. '
//                                 'Informasi lebih lanjut mengenai proses ini akan dijelaskan di sini.',
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }