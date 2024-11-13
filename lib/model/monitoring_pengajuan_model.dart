// ignore_for_file: non_constant_identifier_names

class MonitoringPengajuanModel{
  final String? message;
  final int? progress;
  final String status;
  final DateTime? tanggal_ajukan;
  final DateTime? tanggal_verifikasi_admin;
  final DateTime? tanggal_verifikasi_bank;
  final DateTime? tanggal_akad;
  final DateTime? tanggal_pencairan;

  MonitoringPengajuanModel({
    this.message,
    required this.progress,
    required this.status,
    required this.tanggal_ajukan,
    required this.tanggal_verifikasi_admin,
    required this.tanggal_verifikasi_bank,
    required this.tanggal_akad,
    required this.tanggal_pencairan,
  });

  factory MonitoringPengajuanModel.fromJson(Map<String, dynamic> json) {
    return MonitoringPengajuanModel(
      message: json['message'],
      progress: json['progress'] != null
          ? json['progress']
          : null,
      status: json['status'],
      tanggal_ajukan: json['tanggal_ajukan'] != null
          ? DateTime.tryParse(json['tanggal_ajukan'])
          : null,
      tanggal_verifikasi_admin: json['tanggal_verifikasi_admin'] != null
          ? DateTime.tryParse(json['tanggal_verifikasi_admin'])
          : null,
      tanggal_verifikasi_bank: json['tanggal_verifikasi_bank'] != null
          ? DateTime.tryParse(json['tanggal_verifikasi_bank'])
          : null,
      tanggal_akad: json['tanggal_akad'] != null
          ? DateTime.tryParse(json['tanggal_akad'])
          : null,
      tanggal_pencairan: json['tanggal_pencairan']!= null
          ? DateTime.tryParse(json['tanggal_pencairan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'progress': progress,
      'status': status,
      'tanggal_ajukan': tanggal_ajukan,
      'tanggal_verifikasi_admin': tanggal_verifikasi_admin,
      'tanggal_verifikasi_bank': tanggal_verifikasi_bank,
      'tanggal_akad': tanggal_akad,
      'tanggal_pencairan': tanggal_pencairan,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}