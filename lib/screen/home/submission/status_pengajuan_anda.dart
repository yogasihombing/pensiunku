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
        title: const Text('Pengajuan Anda'),
        backgroundColor: primaryColor,
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
                            pengajuanAnda.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                            pengajuanAnda.tiket,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Tanggal Pengajuan: ',
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
                        style: TextStyle(fontSize: 14, color: Colors.black87),
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
