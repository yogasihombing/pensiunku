// lib/model/riwayat_pengajuan_model.dart
class RiwayatPengajuan {
  final String? kodePengajuan;
  final String? tanggalPengajuan;
  final String? status;
  final String? nama;
  final String? telepon;
  final String? domisili;
  final String? nip;
  final String? namaFotoKtp;
  final String? namaFotoNpwp;

  RiwayatPengajuan({
    this.kodePengajuan,
    this.tanggalPengajuan, 
    this.status,
    this.nama,
    this.telepon,
    this.domisili,
    this.nip,
    this.namaFotoKtp,
    this.namaFotoNpwp,
  });

  factory RiwayatPengajuan.fromJson(Map<String, dynamic> json) {
    return RiwayatPengajuan(
      kodePengajuan: json['kode_pengajuan'],
      tanggalPengajuan: json['tanggal_pengajuan'],
      status: json['status'] ?? 'Pending',
      nama: json['nama'],
      telepon: json['telepon'],
      domisili: json['domisili'],
      nip: json['nip'],
      namaFotoKtp: json['nama_foto_ktp'],
      namaFotoNpwp: json['nama_foto_npwp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_pengajuan': kodePengajuan,
      'tanggal_pengajuan': tanggalPengajuan,
      'status': status,
      'nama': nama,
      'telepon': telepon,
      'domisili': domisili,
      'nip': nip,
      'nama_foto_ktp': namaFotoKtp,
      'nama_foto_npwp': namaFotoNpwp,
    };
  }
}