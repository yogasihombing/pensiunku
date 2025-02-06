import 'package:flutter/material.dart';
import 'package:pensiunku/model/riwayat_pengajuan_anda_model.dart';

class StatusPengajuanAndaScreen extends StatelessWidget {
  final RiwayatPengajuanAndaModel pengajuanAnda;

  const StatusPengajuanAndaScreen({Key? key, required this.pengajuanAnda})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna untuk memberikan kesan elegan
    const Color primaryColor = Color(0xFF017964); // Warna biru elegan
    const Color secondaryColor = Color(0xFFF5F5F5); // Latar belakang lembut

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF017964)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              // } else {
              //   widget.onChangeBottomNavIndex(0);
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Center(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
            child: Text(
              pengajuanAnda.tiket,
              style: TextStyle(
                color: Color(0xFF017964),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
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
                          const Icon(Icons.person, color: Colors.black),
                          const SizedBox(width: 8),
                          const Text(
                            ' ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Flexible(
                            child: Text(
                              pengajuanAnda.nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow
                                  .ellipsis, // Teks panjang akan terpotong dengan elipsis
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.confirmation_number,
                      //         color: primaryColor),
                      //     const SizedBox(width: 8),
                      //     const Text(
                      //       'Kode Pengajuan: ',
                      //       style: TextStyle(fontWeight: FontWeight.normal),
                      //     ),
                      //     Text(
                      //       pengajuanAnda.tiket,
                      //       style:
                      //           const TextStyle(fontWeight: FontWeight.normal),
                      //     ),
                      //   ],
                      // ),
                      // const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.black),
                          const SizedBox(width: 12),
                          const Text(
                            'Pengajuan: ',
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            pengajuanAnda.tanggal,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
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
                      Text(
                        '• Kartu Tanda Penduduk (KTP)\n'
                        '• Kartu Keluarga\n'
                        '• Kartu Nomor Pokok Wajib Pajak (NPWP)\n'
                        '• Kartu Identitas Pensiunan (KARIP)\n'
                        '• SK Pensiun (Untuk Pensiunan)\n'
                        '• SK 80 atau SK 100 (Untuk Pra Pensiun)\n'
                        '• Buku Tabungan\n'
                        '• Cover Buku Tabungan Bank Asal\n'
                        '• Rekening Koran Tiga Bulan Terakhir (Rekening Penerima Gaji Pensiun)\n'
                        '• Slip Gaji Pensiun 2 Bulan Terakhir\n'
                        '• 2 Lembar Pas Foto Nasabah\n'
                        '• Surat Permohonan Pelunasan dipercepat yang telah ditandatangani (Bila Take Over)\n'
                        '• Surat Keterangan Kematian (Apabila Pemohon Pensiunan Janda atau Duda)\n'
                        '• Surat Pernyataan Tidak Menikah Kembali (Pemohon Janda atau Duda)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5, // Menambah jarak antar baris
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
