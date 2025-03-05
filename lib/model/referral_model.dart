import 'package:intl/intl.dart';
import 'package:pensiunku/model/camera_result_model.dart';

class ReferralModel extends CameraResultModel {
  final String? fotoKtp;
  final String? nameKtp;
  final String? nikKtp;
  final String? addressKtp;
  final String? jobKtp;
  final DateTime? birthDateKtp;
  final String? referal;

  ReferralModel({
    required this.fotoKtp,
    this.nameKtp,
    this.nikKtp,
    this.addressKtp,
    this.jobKtp,
    this.birthDateKtp,
    this.referal,
  }) : super(
          imagePath: fotoKtp ?? '',
          textBoxes: [],
        );

  ReferralModel copyWith({
    String? fotoKtp,
    String? nameKtp,
    String? nikKtp,
    String? addressKtp,
    String? jobKtp,
    DateTime? birthDateKtp,
    String? referal,
  }) {
    return ReferralModel(
      fotoKtp: fotoKtp ?? this.fotoKtp,
      nameKtp: nameKtp ?? this.nameKtp,
      nikKtp: nikKtp ?? this.nikKtp,
      addressKtp: addressKtp ?? this.addressKtp,
      jobKtp: jobKtp ?? this.jobKtp,
      birthDateKtp: birthDateKtp ?? this.birthDateKtp,
      referal: referal ?? this.referal,
    );
  }

  bool isKtpComplete() {
    return fotoKtp?.isNotEmpty == true &&
        nameKtp?.isNotEmpty == true &&
        nikKtp?.isNotEmpty == true &&
        addressKtp?.isNotEmpty == true &&
        jobKtp != null;
  }

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      fotoKtp: json['foto_ktp'],
      nameKtp: json['nama_ktp'],
      nikKtp: json['nik_ktp'],
      addressKtp: json['alamat_ktp'],
      jobKtp: json['pekerjaan_ktp'],
      birthDateKtp: json['tanggal_lahir_ktp'] != null
          ? DateTime.tryParse(json['tanggal_lahir_ktp'])
          : null,
      referal: json['referal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foto_ktp': fotoKtp,
      'nama_ktp': nameKtp,
      'nik_ktp': nikKtp,
      'alamat_ktp': addressKtp,
      'pekerjaan_ktp': jobKtp,
      'tanggal_lahir_ktp': birthDateKtp != null
          ? DateFormat('y-MM-dd').format(birthDateKtp!)
          : null,
      'referal': referal,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
