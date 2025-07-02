import 'package:flutter/foundation.dart';

class RiwayatPengajuanAndaModel {
  final String nama;
  final String tanggal;
  final String tiket;
  final String
      statusPengajuan; // Tetap ada di model, meskipun mungkin tidak ada di respons API ini
  final String
      pekerjaan; // Tetap ada di model, meskipun mungkin tidak ada di respons API ini
  final String? alamat; // Menambahkan properti nullable untuk 'alamat'
  final String? nip; // Menambahkan properti nullable untuk 'nip'

  RiwayatPengajuanAndaModel({
    required this.nama,
    required this.tanggal,
    required this.tiket,
    required this.statusPengajuan,
    required this.pekerjaan,
    this.alamat, // Menjadikan nullable
    this.nip, // Menjadikan nullable
  });

  factory RiwayatPengajuanAndaModel.fromJson(Map<String, dynamic> json) {
    debugPrint('Model: Parsing JSON: $json'); // Menggunakan debugPrint
    return RiwayatPengajuanAndaModel(
      nama: json['nama'] as String,
      tanggal: json['tanggal'] as String,
      tiket: json['tiket'] as String,
      // Menggunakan null-aware operator '??' untuk memberikan nilai default jika null
      statusPengajuan:
          json['status_pengajuan'] ?? '', // Default ke string kosong jika null
      pekerjaan: json['pekerjaan'] ?? '', // Default ke string kosong jika null
      alamat: json['alamat'] as String?, // Cast ke String? untuk menangani null
      nip: json['nip'] as String?, // Cast ke String? untuk menangani null
    );
  }
}
