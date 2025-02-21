import 'dart:io';

import 'package:pensiunku/model/camera_result_model.dart';

class SelfieModel extends CameraResultModel {
  final File image;
  final String imagePath;
  double? faceConfidence;

  SelfieModel({
    required this.image,
    required this.imagePath,
    this.faceConfidence,
  });

  SelfieModel clone() {
    return SelfieModel(
      image: image,
      imagePath: imagePath,
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
