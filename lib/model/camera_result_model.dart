// Definisi CameraResultModel
import 'package:flutter/widgets.dart';
import 'package:pensiunku/model/ktp_model.dart';

class CameraResultModel {
  final String imagePath;
  final KtpModel? ktpData;
  final List<Rect> textBoxes;
  String? nik;
  String? nama;
  String? tempatLahir;
  DateTime? tanggalLahir;
  String? alamat;
  String? rtRw;
  String? kelurahan;
  String? kecamatan;
  String? statusPerkawinan;
  String? kewarganegaraan;

  CameraResultModel({
    required this.imagePath,
    required this.textBoxes,
    this.ktpData,
  });
}
