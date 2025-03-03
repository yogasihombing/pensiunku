// Definisi CameraResultModel
import 'package:pensiunku/model/ktp_model.dart';

class CameraResultModel {
  final String imagePath;
  final KtpModel? ktpData;

  CameraResultModel({
    required this.imagePath,
    this.ktpData,
  });
}


