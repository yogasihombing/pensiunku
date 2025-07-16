import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/camera_result_model.dart';

class KtpModel extends CameraResultModel {
  final File image;
  String? name;
  String? nik;
  String? address;
  DateTime? birthDate;
  String? job;
  String? jobOriginalText;
  double? jobConfidence;
  RecognisedText? recognisedText;

  KtpModel({
    required this.image,
    this.name,
    this.nik,
    this.address,
    this.birthDate,
    this.job,
    this.jobOriginalText,
    this.jobConfidence,
    this.recognisedText,
  });

  KtpModel clone() {
    return KtpModel(
      image: image,
      name: name,
      nik: nik,
      address: address,
      birthDate: birthDate,
      job: job,
      jobOriginalText: jobOriginalText,
      jobConfidence: jobConfidence,
      recognisedText: recognisedText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name ?? '-',
      'nik': nik ?? '-',
      'address': address ?? '-',
      'birthDate':
          birthDate != null ? DateFormat('dd/MM/yy').format(birthDate!) : '-',
      'job': job ?? '-',
      'jobOriginalText': jobOriginalText ?? '-',
      'jobConfidence': jobConfidence?.toString() ?? '-',
    };
  }

  @override
  String toString() {
    return "${name != null ? '✅' : '❌'} Name:\n" +
        "    ${name ?? '-'}\n" +
        "${nik != null ? '✅' : '❌'} NIK:\n" +
        "    ${nik ?? '-'} ${nik != null ? '(Length: ${nik!.length}/16)' : ''}\n" +
        "${address != null ? '✅' : '❌'} Address:\n" +
        "    ${address ?? '-'}\n" +
        "${birthDate != null ? '✅' : '❌'} BirthDate:\n" +
        "    ${birthDate != null ? DateFormat('dd/MM/yyyy').format(birthDate!) : '-'}\n" +
        "${job != null ? '✅' : '❌'} Job:\n" +
        "    ${job ?? '-'} (Confidence: ${jobConfidence?.toString() ?? '-'})\n";
  }

  String toStringVision() {
    String str = '';
    int counter = 1;
    recognisedText?.blocks.forEach((block) {
      str += '>> BLOCK $counter\n';
      block.lines.forEach((line) {
        str += '   LINE: ${line.text}\n';
      });
      counter++;
    });
    return str;
  }
}
