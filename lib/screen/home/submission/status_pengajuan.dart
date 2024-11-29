import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class StatusPengajuanPage extends StatelessWidget {
  final RiwayatPengajuanModel pengajuan;

  const StatusPengajuanPage({Key? key, required this.pengajuan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna untuk memberikan kesan elegan
    const Color primaryColor = Color(0xFF4A90E2); // Warna biru elegan
    const Color secondaryColor = Color(0xFFF5F5F5); // Latar belakang lembut

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengajuan'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan tampilan elegan
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Membuat Card Melengkung
                ),
                elevation: 4, // Bayangan untuk kesan mewah
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Text(
                      'Pengajuan Anda',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Kontras dengan background
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detail informasi tentang status pengajuan Anda.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              // Detail data
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person, color: primaryColor),
                  title: const Text('Nama Pemohon'),
                  subtitle: Text(
                    pengajuan.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Detail data
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person, color: primaryColor),
                  title: const Text('Kode Tiket'),
                  subtitle: Text(
                    pengajuan.tiket,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person, color: primaryColor),
                  title: const Text('Tanggal Pengajuan'),
                  subtitle: Text(
                    pengajuan.tanggal,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      const Text(
                        'Arti Kode Tiket',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '- **AB**: Pengajuan diterima dan dalam proses verifikasi.\n'
                        '- **CD**: Pengajuan membutuhkan dokumen tambahan.\n'
                        '- **EF**: Pengajuan disetujui dan sedang dalam proses pencairan.\n'
                        '- **GH**: Pengajuan ditolak. Silakan hubungi layanan pelanggan.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
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