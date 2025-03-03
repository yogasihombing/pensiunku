import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:pensiunku/model/camera_result_model.dart';

class KtpModel extends CameraResultModel {
  final File image; // Ini tetap required, tapi pastikan selalu valid
  String? name;
  String? nik;
  String? address;
  DateTime? birthDate;
  String? job;
  String? jobOriginalText;
  double? jobConfidence;
  RecognisedText? recognisedText;
  Rect? nikRect;
  Rect? nameRect;
  Rect? birthDateRect;
  Rect? addressRect;
  Rect? jobRect;

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
    this.nikRect,
    this.nameRect,
    this.birthDateRect,
    this.addressRect,
    this.jobRect,
  }) : super(imagePath: image.path);

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
      nikRect: nikRect,
      nameRect: nameRect,
      birthDateRect: birthDateRect,
      addressRect: addressRect,
      jobRect: jobRect,
    );
  }

  Future<KtpModel> extractKtpData(File imageFile) async {
    // Contoh fungsi untuk mengekstraksi data KTP dan kotak pembatas
    // Gantilah dengan implementasi ekstraksi data KTP yang sesuai

    // Misalnya, hasil ekstraksi data KTP
    String nik = "3171234567890123";
    String name = "MIRA SETIAWAN";
    DateTime birthDate = DateTime.parse("1996-02-18");
    String address = "JL PASTI CEPAT A7IGG";
    String job = "22-02-2017";

    // Misalnya, hasil ekstraksi kotak pembatas
    Rect nikRect = Rect.fromLTWH(50, 100, 200, 50);
    Rect nameRect = Rect.fromLTWH(50, 200, 200, 50);
    Rect birthDateRect = Rect.fromLTWH(50, 300, 200, 50);
    Rect addressRect = Rect.fromLTWH(50, 400, 200, 50);
    Rect jobRect = Rect.fromLTWH(50, 500, 200, 50);

    return KtpModel(
      image: imageFile,
      nik: nik,
      name: name,
      birthDate: birthDate,
      address: address,
      job: job,
      nikRect: nikRect,
      nameRect: nameRect,
      birthDateRect: birthDateRect,
      addressRect: addressRect,
      jobRect: jobRect,
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
