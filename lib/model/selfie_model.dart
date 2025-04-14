// Definisi SelfieModel
import 'dart:io';

import 'package:pensiunku/model/camera_result_model.dart';

class SelfieModel extends CameraResultModel {
  final File image;
  double? faceConfidence;

  SelfieModel({
    required this.image,
    this.faceConfidence,
  });

  SelfieModel clone() {
    return SelfieModel(
      image: image,
      faceConfidence: faceConfidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faceConfidence': faceConfidence?.toString() ?? '-',
    };
  }

  @override
  String toString() {
    return "✅ Face:\n" +
        "    Confidence: ${faceConfidence?.toString() ?? '-'}\n";
  }
}
