import 'dart:async';
import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/services.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:camera/camera.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imageLib;
import 'package:pensiunku/model/ktp_model.dart';
import 'package:path/path.dart' as pathLib;
import 'package:path_provider/path_provider.dart';

class FirebaseVisionUtils {
  static DateTime extractBirthDateFromNik(String text) {
    print("Ekstraksi tanggal lahir dari NIK: $text");
    String dayStr = text.substring(6, 8);
    String monthStr = text.substring(8, 10);
    String yearStr = text.substring(10, 12);
    print("Day: $dayStr, Month: $monthStr, Year: $yearStr");

    // Untuk perempuan, tanggalnya dikurangi 40
    if (int.parse(dayStr) > 31) {
      print("NIK menunjukkan jenis kelamin perempuan (tanggal > 31)");
      dayStr = (int.parse(dayStr) - 40).toString();
      print("Tanggal setelah pengurangan 40: $dayStr");
    }

    int day = int.parse(dayStr);
    int month = int.parse(monthStr);
    int year = int.parse('19$yearStr');
    DateTime birthDate19 = DateTime(year, month, day);
    print("Tanggal lahir awal: $birthDate19");

    DateDuration duration = AgeCalculator.age(birthDate19);
    int age = duration.years;
    print("Umur: $age tahun");

    // Jika umur >= 90, kemungkinan lahir di tahun 2000-an, bukan 1900-an
    if (age >= 90) {
      print("Umur >= 90 tahun, menggunakan tahun 2000-an");
      int day = int.parse(dayStr);
      int month = int.parse(monthStr);
      int year = int.parse('20$yearStr');
      DateTime birthDate20 = DateTime(year, month, day);
      print("Tanggal lahir diperbarui: $birthDate20");
      return birthDate20;
    }
    return birthDate19;
  }

  static DateTime? tryExtractBirthDate(String line) {
    print("Mencoba ekstraksi tanggal lahir dari teks: $line");
    RegExp regex = RegExp(r"[0-9]{2}-[0-9]{2}-[0-9]{4}");
    RegExpMatch? firstMatch = regex.firstMatch(line);
    if (firstMatch != null) {
      var birthDateStr =
          line.substring(firstMatch.start, firstMatch.end).trim();
      print("Tanggal lahir ditemukan: $birthDateStr");
      var birthDateStrSplit = birthDateStr.split('-');
      int day = int.parse(birthDateStrSplit[0]);
      int month = int.parse(birthDateStrSplit[1]);
      int year = int.parse(birthDateStrSplit[2]);
      DateTime birthDate = DateTime(year, month, day);
      print("Tanggal lahir: $birthDate");
      return birthDate;
    }
    print("Tidak ditemukan format tanggal lahir yang sesuai");
    return null;
  }

  static Future<imageLib.Image?> getOriginalImage(XFile file) async {
    print("Membaca gambar asli dari file: ${file.path}");
    final fileBytes = await file.readAsBytes();
    var image = imageLib.decodeJpg(fileBytes);
    print("Ukuran gambar asli: ${image?.width}x${image?.height}");
    return image;
  }

  static Future<InputImage> preProcessImage(
    imageLib.Image originalImage, {
    double imageRotation = -90,
  }) async {
    print("Memproses gambar dengan rotasi: $imageRotation derajat");
    // Rotate image
    final rotatedImage = imageLib.copyRotate(originalImage, imageRotation);
    print(
        "Ukuran gambar setelah rotasi: ${rotatedImage.width}x${rotatedImage.height}");

    // Create new file
    final tempDir = await getTemporaryDirectory();
    final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
    print("Menyimpan gambar yang diproses ke: $path");
    File processedFile = File(path)
      ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

    return InputImage.fromFile(processedFile);
  }

  static Future<ResultModel<SelfieModel>> getSelfieVisionDataFromImage(
    XFile file, {
    double imageRotation = 90,
  }) async {
    print("Mendapatkan data selfie dari gambar: ${file.path}");
    imageLib.Image? originalImage = await getOriginalImage(file);
    if (originalImage == null) {
      print("Gambar asli tidak dapat dibaca");
      return ResultModel(isSuccess: false, error: 'Tidak dapat membaca gambar');
    }

    // Rotate image
    print("Merotasi gambar sebesar $imageRotation derajat");
    final rotatedImage = imageLib.copyRotate(originalImage, imageRotation);
    print(
        "Ukuran gambar setelah rotasi: ${rotatedImage.width}x${rotatedImage.height}");

    // Create new file
    final tempDir = await getTemporaryDirectory();
    final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
    print("Menyimpan gambar yang diproses ke: $path");
    File processedFile = File(path)
      ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

    final inputImage = InputImage.fromFile(processedFile);
    print("Memulai deteksi wajah");
    final faceDetector = GoogleMlKit.vision.faceDetector();

    final List<Face> faces = await faceDetector.processImage(inputImage);
    print("Jumlah wajah terdeteksi: ${faces.length}");
    if (faces.length <= 0) {
      print("Tidak ada wajah terdeteksi");
      return ResultModel(
          isSuccess: false, error: 'Tidak dapat menemukan objek wajah.');
    }

    Face detectedObjectSelfie = faces.first;
    final rect = detectedObjectSelfie.boundingBox;
    print("Wajah terdeteksi pada posisi: $rect");

    /**
     * Draw Selfie
     */
    print("Menggambar kotak pada wajah yang terdeteksi");
    imageLib.drawRect(
      rotatedImage,
      rect.topLeft.dx.toInt(),
      rect.topLeft.dy.toInt(),
      rect.bottomRight.dx.toInt(),
      rect.bottomRight.dy.toInt(),
      0xffffffff,
    );

    final pathDrawn = pathLib.join(
      tempDir.path,
      '${DateTime.now()}_final.jpg',
    );
    print("Menyimpan gambar dengan kotak wajah ke: $pathDrawn");
    File imageDrawnFile = File(pathDrawn)
      ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

    print("Berhasil membuat model selfie");
    return ResultModel(
      isSuccess: true,
      data: SelfieModel(
        image: imageDrawnFile,
      ),
    );
  }

  static Future<ResultModel<KtpModel>> getKtpVisionDataFromImage(
    XFile file, {
    bool isDrawSearchingArea = true,
    bool isDrawExtractedArea = true,
  }) async {
    print("Mendapatkan data KTP dari gambar: ${file.path}");
    print(
        "Draw search area: $isDrawSearchingArea, Draw extracted area: $isDrawExtractedArea");

    imageLib.Image? originalImage = await getOriginalImage(file);
    if (originalImage == null) {
      print("Gambar asli tidak dapat dibaca");
      return ResultModel(isSuccess: false, error: 'Tidak dapat membaca gambar');
    }

    print("Merotasi gambar -90 derajat");
    imageLib.Image rotatedImage = imageLib.copyRotate(originalImage, -90);
    print(
        "Ukuran gambar setelah rotasi: ${rotatedImage.width}x${rotatedImage.height}");

    // Crop image according to frame
    print("Melakukan crop pada gambar sesuai bingkai KTP");
    int cropWidth = (rotatedImage.width * 0.7).toInt();
    int croppedX = (rotatedImage.width * 0.3) ~/ 2;
    int cropHeight = (cropWidth * 0.6).toInt();
    int croppedY = ((rotatedImage.height / 2) - (cropHeight / 2)).toInt();
    print(
        "Crop area: X=$croppedX, Y=$croppedY, Width=$cropWidth, Height=$cropHeight");

    imageLib.Image croppedImage = imageLib.copyCrop(
      rotatedImage,
      croppedX,
      croppedY,
      cropWidth,
      cropHeight,
    );
    print(
        "Ukuran gambar setelah crop: ${croppedImage.width}x${croppedImage.height}");

    final tempDir = await getTemporaryDirectory();
    final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
    print("Menyimpan gambar yang diproses ke: $path");
    File processedFile = File(path)
      ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
    final inputImage = InputImage.fromFile(processedFile);

    /**
     * 1. Try finding [KtpModel.nik].
     */
    print("Memulai deteksi teks untuk mencari NIK");
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);
    print("Teks terdeteksi: ${recognisedText.blocks.length} blok");

    String? extractedNik;
    Rect? extractedNikRect;
    print("Mencari pola NIK (14-16 digit)");
    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        String lineText = line.text;
        lineText.split(' ').asMap().forEach((indexWord, word) {
          if (extractedNik == null) {
            RegExp regex = RegExp(r"[0-9]{14,16}");
            RegExpMatch? firstMatch = regex.firstMatch(word);
            if (firstMatch != null) {
              extractedNik =
                  word.substring(firstMatch.start, firstMatch.end).trim();
              extractedNikRect = line.rect;
              print(
                  "NIK ditemukan: $extractedNik pada posisi $extractedNikRect");
            }
          }
        });
      });
    });

    if (extractedNikRect != null && isDrawExtractedArea) {
      print("Menandai area NIK pada gambar");
      imageLib.drawRect(
        croppedImage,
        extractedNikRect!.topLeft.dx.toInt(),
        extractedNikRect!.topLeft.dy.toInt(),
        extractedNikRect!.bottomRight.dx.toInt(),
        extractedNikRect!.bottomRight.dy.toInt(),
        0xff00ff00,
      );
    } else {
      print("NIK tidak ditemukan, tidak dapat memproses KTP");
      return ResultModel(
        isSuccess: false,
        error: 'Tidak dapat menemukan objek KTP.',
      );
    }

    /**
     * 2. Try finding [KtpModel.name]
     */
    print("Mencari nama berdasarkan posisi relatif terhadap NIK");
    Rect? extractedNameRect;
    String? extractedName;
    Rect nameRect = Rect.fromLTRB(
      extractedNikRect!.left,
      extractedNikRect!.bottom + (extractedNikRect!.height * 0.1),
      extractedNikRect!.right,
      extractedNikRect!.bottom + (extractedNikRect!.height * 1.1),
    );
    print("Area pencarian nama: $nameRect");

    if (isDrawSearchingArea) {
      print("Menandai area pencarian nama pada gambar");
      imageLib.drawRect(
        croppedImage,
        nameRect.topLeft.dx.toInt(),
        nameRect.topLeft.dy.toInt(),
        nameRect.bottomRight.dx.toInt(),
        nameRect.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        if (extractedName == null) {
          final intersectRect = line.rect.intersect(nameRect);
          if (intersectRect.height >= 0 && intersectRect.width >= 0) {
            extractedName = line.text;
            extractedNameRect = line.rect;
            print(
                "Nama ditemukan: $extractedName pada posisi $extractedNameRect");
          }
        }
      });
    });

    if (extractedNameRect != null && isDrawExtractedArea) {
      print("Menandai area nama yang terdeteksi pada gambar");
      imageLib.drawRect(
        croppedImage,
        extractedNameRect!.topLeft.dx.toInt(),
        extractedNameRect!.topLeft.dy.toInt(),
        extractedNameRect!.bottomRight.dx.toInt(),
        extractedNameRect!.bottomRight.dy.toInt(),
        0xff00ff00,
      );
    } else {
      print("Nama tidak ditemukan");
    }

    /**
     * 3. Try finding [KtpModel.birthDate]
     */
    print("Mencari tanggal lahir");
    Rect? extractedBirthDateRect;
    DateTime? extractedBirthDate;
    if (extractedNik?.length == 16) {
      print("Mencoba ekstraksi tanggal lahir dari NIK");
      extractedBirthDate = extractBirthDateFromNik(extractedNik!);
      print("Tanggal lahir dari NIK: $extractedBirthDate");
    } else {
      print("Mencari tanggal lahir dari teks KTP");
      Rect birthDateRect = Rect.fromLTRB(
        nameRect.left,
        nameRect.bottom,
        nameRect.right,
        nameRect.bottom + nameRect.height,
      );
      print("Area pencarian tanggal lahir: $birthDateRect");

      if (isDrawSearchingArea) {
        print("Menandai area pencarian tanggal lahir pada gambar");
        imageLib.drawRect(
          croppedImage,
          birthDateRect.topLeft.dx.toInt(),
          birthDateRect.topLeft.dy.toInt(),
          birthDateRect.bottomRight.dx.toInt(),
          birthDateRect.bottomRight.dy.toInt(),
          0xff0000ff,
        );
      }

      recognisedText.blocks.asMap().forEach((indexBlock, block) {
        block.lines.asMap().forEach((indexLine, line) {
          final intersectRect = line.rect.intersect(birthDateRect);
          if (intersectRect.height >= 0 && intersectRect.width >= 0) {
            String lineText = line.text.replaceAll('-', '');
            print("Teks dalam area tanggal lahir: $lineText");
            RegExp regex = RegExp(r"[0-9]{2}[0-9]{2}[0-9]{4}");
            RegExpMatch? firstMatch = regex.firstMatch(lineText);
            if (firstMatch != null) {
              var birthDateStr =
                  lineText.substring(firstMatch.start, firstMatch.end).trim();
              print("Format tanggal lahir ditemukan: $birthDateStr");
              int day = int.parse(birthDateStr.substring(0, 2));
              int month = int.parse(birthDateStr.substring(2, 4));
              int year = int.parse(birthDateStr.substring(4, 8));
              extractedBirthDate = DateTime(year, month, day);
              extractedBirthDateRect = line.rect;
              print(
                  "Tanggal lahir: $extractedBirthDate pada posisi $extractedBirthDateRect");
            }
          }
        });
      });
    }

    if (extractedBirthDateRect != null && isDrawExtractedArea) {
      print("Menandai area tanggal lahir yang terdeteksi pada gambar");
      imageLib.drawRect(
        croppedImage,
        extractedBirthDateRect!.topLeft.dx.toInt(),
        extractedBirthDateRect!.topLeft.dy.toInt(),
        extractedBirthDateRect!.bottomRight.dx.toInt(),
        extractedBirthDateRect!.bottomRight.dy.toInt(),
        0xff00ff00,
      );
    } else if (extractedBirthDate != null) {
      print("Tanggal lahir diekstrak dari NIK: $extractedBirthDate");
    } else {
      print("Tanggal lahir tidak ditemukan");
    }

    /**
     * 4. Try finding [KtpModel.address].
     */
    print("Mencari alamat");
    Rect addressRect = Rect.fromLTRB(
      0,
      extractedNikRect!.bottom + (extractedNikRect!.height * 3),
      croppedImage.width.toDouble() / 2,
      extractedNikRect!.bottom + (extractedNikRect!.height * 7),
    );
    print("Area pencarian alamat: $addressRect");

    if (isDrawSearchingArea) {
      print("Menandai area pencarian alamat pada gambar");
      imageLib.drawRect(
        croppedImage,
        addressRect.topLeft.dx.toInt(),
        addressRect.topLeft.dy.toInt(),
        addressRect.bottomRight.dx.toInt(),
        addressRect.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    List<String> allAddressList = [];
    String? extractedAddress;
    String? extractedProvinsi;
    String? extractedKotaKab;
    print("Mengekstrak teks alamat");

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(addressRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          print("Baris alamat: $lineText");
          allAddressList.add(lineText);
        }
        if (indexBlock == 0 && indexLine == 0) {
          extractedProvinsi = line.text;
          print("Provinsi: $extractedProvinsi");
        }
        if (indexBlock == 0 && indexLine == 1) {
          extractedKotaKab = line.text;
          print("Kota/Kabupaten: $extractedKotaKab");
        }
      });
    });

    if (extractedKotaKab != null) {
      allAddressList.add(extractedKotaKab!);
    }
    if (extractedProvinsi != null) {
      allAddressList.add(extractedProvinsi!);
    }

    if (allAddressList.isNotEmpty) {
      extractedAddress = allAddressList.join('\n');
      print("Alamat lengkap: $extractedAddress");
    } else {
      print("Alamat tidak ditemukan");
    }

    /**
     * 5. Try finding [KtpModel.job].
     */
    print("Mencari pekerjaan");
    Rect jobRect = Rect.fromLTRB(
      0,
      extractedNikRect!.bottom + (extractedNikRect!.height * 6),
      croppedImage.width.toDouble() / 2,
      croppedImage.height.toDouble(),
    );
    print("Area pencarian pekerjaan: $jobRect");

    if (isDrawSearchingArea) {
      print("Menandai area pencarian pekerjaan pada gambar");
      imageLib.drawRect(
        croppedImage,
        jobRect.topLeft.dx.toInt(),
        jobRect.topLeft.dy.toInt(),
        jobRect.bottomRight.dx.toInt(),
        jobRect.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    Rect? extractedJobRect;
    String? extractedJob;
    print("Mengekstrak teks pekerjaan");

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(jobRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          print("Teks pekerjaan: $lineText");
          extractedJob = lineText;
          extractedJobRect = line.rect;
        }
      });
    });

    if (extractedJobRect != null && isDrawExtractedArea) {
      print("Menandai area pekerjaan yang terdeteksi pada gambar");
      imageLib.drawRect(
        croppedImage,
        extractedJobRect!.topLeft.dx.toInt(),
        extractedJobRect!.topLeft.dy.toInt(),
        extractedJobRect!.bottomRight.dx.toInt(),
        extractedJobRect!.bottomRight.dy.toInt(),
        0xff00ff00,
      );
    } else {
      print("Pekerjaan tidak ditemukan");
    }

    final pathDrawn = pathLib.join(
      tempDir.path,
      '${DateTime.now()}_final.jpg',
    );
    print("Menyimpan gambar akhir KTP ke: $pathDrawn");
    File imageDrawnFile = File(pathDrawn)
      ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));

    print("Berhasil membuat model KTP dengan data:");
    print("NIK: $extractedNik");
    print("Nama: $extractedName");
    print("Tanggal Lahir: $extractedBirthDate");
    print("Alamat: $extractedAddress");
    print("Pekerjaan: $extractedJob");

    return ResultModel(
      isSuccess: true,
      data: KtpModel(
        image: imageDrawnFile,
        nik: extractedNik,
        name: extractedName,
        birthDate: extractedBirthDate,
        address: extractedAddress,
        job: extractedJob,
        jobOriginalText: null,
        jobConfidence: 0.0,
        recognisedText: recognisedText,
      ),
    );
  }
}

// class FirebaseVisionUtils {
//   static DateTime extractBirthDateFromNik(String text) {
//     String dayStr = text.substring(6, 8);
//     String monthStr = text.substring(8, 10);
//     String yearStr = text.substring(10, 12);
//     if (int.parse(dayStr) > 31) {
//       dayStr = (int.parse(dayStr) - 40).toString();
//     }

//     int day = int.parse(dayStr);
//     int month = int.parse(monthStr);
//     int year = int.parse('19$yearStr');
//     DateTime birthDate19 = DateTime(year, month, day);

//     DateDuration duration = AgeCalculator.age(birthDate19);
//     int age = duration.years;
//     if (age >= 90) {
//       int day = int.parse(dayStr);
//       int month = int.parse(monthStr);
//       int year = int.parse('20$yearStr');
//       return DateTime(year, month, day);
//     }
//     return birthDate19;
//   }

//   static DateTime? tryExtractBirthDate(String line) {
//     RegExp regex = RegExp(r"[0-9]{2}-[0-9]{2}-[0-9]{4}");
//     RegExpMatch? firstMatch = regex.firstMatch(line);
//     if (firstMatch != null) {
//       var birthDateStr =
//           line.substring(firstMatch.start, firstMatch.end).trim();
//       var birthDateStrSplit = birthDateStr.split('-');
//       int day = int.parse(birthDateStrSplit[0]);
//       int month = int.parse(birthDateStrSplit[1]);
//       int year = int.parse(birthDateStrSplit[2]);
//       return DateTime(year, month, day);
//     }
//     return null;
//   }

//   static Future<imageLib.Image?> getOriginalImage(XFile file) async {
//     final fileBytes = await file.readAsBytes();
//     return imageLib.decodeJpg(fileBytes);
//   }

//   static Future<InputImage> preProcessImage(
//     imageLib.Image originalImage, {
//     double imageRotation = -90,
//   }) async {
//     // Rotate image 90 degrees
//     final rotatedImage = imageLib.copyRotate(originalImage, imageRotation);

//     // Create new file
//     final tempDir = await getTemporaryDirectory();
//     final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
//     File processedFile = File(path)
//       ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

//     return InputImage.fromFile(processedFile);
//   }

//   static Future<ResultModel<SelfieModel>> getSelfieVisionDataFromImage(
//     XFile file, {
//     double imageRotation = 90,
//   }) async {
//     imageLib.Image? originalImage = await getOriginalImage(file);

//     // TODO: Uncomment to bypass selfie checking
//     // File imageDrawnFileX = File(file.path)
//     //   ..writeAsBytesSync(imageLib.encodeJpg(originalImage));
//     // return ResultModel(
//     //   isSuccess: true,
//     //   data: SelfieModel(
//     //     image: imageDrawnFileX,
//     //   ),
//     // );
//     // final inputImage =
//     //     await preProcessImage(originalImage, imageRotation: imageRotation);
//     // Rotate image 90 degrees
//     final rotatedImage = imageLib.copyRotate(originalImage!, imageRotation);

//     // Create new file
//     final tempDir = await getTemporaryDirectory();
//     final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
//     File processedFile = File(path)
//       ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

//     final inputImage = InputImage.fromFile(processedFile);

//     final faceDetector = GoogleMlKit.vision.faceDetector();

//     final List<Face> faces = await faceDetector.processImage(inputImage);
//     if (faces.length <= 0) {
//       return ResultModel(
//           isSuccess: false, error: 'Tidak dapat menemukan objek wajah.');
//     }

//     Face detectedObjectSelfie = faces.first;
//     final rect = detectedObjectSelfie.boundingBox;

//     /**
//      * Draw Selfie
//      */
//     imageLib.drawRect(
//       rotatedImage,
//       rect.topLeft.dx.toInt(),
//       rect.topLeft.dy.toInt(),
//       rect.bottomRight.dx.toInt(),
//       rect.bottomRight.dy.toInt(),
//       0xffffffff,
//     );

//     // final tempDir = await getTemporaryDirectory();
//     final pathDrawn = pathLib.join(
//       tempDir.path,
//       '${DateTime.now()}_final.jpg',
//     );
//     File imageDrawnFile = File(pathDrawn)
//       ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

//     return ResultModel(
//       isSuccess: true,
//       data: SelfieModel(
//         image: imageDrawnFile,
//       ),
//     );
//   }

//   static Future<ResultModel<KtpModel>> getKtpVisionDataFromImageOld(
//     XFile file, {
//     bool isDrawDebugLine = true,
//   }) async {
//     imageLib.Image? originalImage = await getOriginalImage(file);
//     // Rotate image 90 degrees
//     imageLib.Image rotatedImage = imageLib.copyRotate(originalImage!, -90);

//     // Crop image according to frame
//     // int cropHeight = rotatedImage.height;
//     // int croppedY = ((rotatedImage.height / 2)).toInt();
//     int cropWidth = (rotatedImage.width * 0.7).toInt();
//     int croppedX = (rotatedImage.width * 0.3) ~/ 2;

//     int cropHeight = (cropWidth * 0.6).toInt();
//     int croppedY = ((rotatedImage.height / 2) - (cropHeight / 2)).toInt();
//     // int cropWidth = rotatedImage.width;
//     // int croppedX = ((rotatedImage.width * 0.3) ~/ 2).toInt();
//     // final citizenCardHeightImage = (rotatedImage.height * 0.7).toInt();
//     // final citizenCardWidthImage = rotatedImage.width ~/ 0.6;
//     // int croppedY =
//     //     ((rotatedImage.height / 2) - (citizenCardHeightImage / 2)).toInt();
//     // int croppedX = (rotatedImage.width * 0.1 ~/ 2).toInt();
//     imageLib.Image croppedImage = imageLib.copyCrop(
//       rotatedImage,
//       croppedX,
//       croppedY,
//       cropWidth,
//       cropHeight,
//     );

//     final tempDir = await getTemporaryDirectory();
//     final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
//     File processedFile = File(path)
//       ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
//     final inputImage = InputImage.fromFile(processedFile);

//     /// 1. Try finding KTP object
//     final objectDetector =
//         GoogleMlKit.vision.objectDetector(ObjectDetectorOptions());
//     final List<DetectedObject> objects =
//         await objectDetector.processImage(inputImage);

//     if (objects.length <= 0) {
//       return ResultModel(
//           isSuccess: false, error: 'Tidak dapat menemukan objek KTP.');
//     }

//     DetectedObject detectedObjectKtp = objects.first;
//     final rect = detectedObjectKtp.getBoundinBox();

//     /**
//      * Draw KTP
//      */
//     imageLib.drawRect(
//       rotatedImage,
//       rect.topLeft.dx.toInt(),
//       rect.topLeft.dy.toInt(),
//       rect.bottomRight.dx.toInt(),
//       rect.bottomRight.dy.toInt(),
//       0xffffffff,
//     );

//     /**
//      * 1. Try finding [KtpModel.nik].
//      */
//     final textDetector = GoogleMlKit.vision.textDetector();
//     final RecognisedText recognisedText =
//         await textDetector.processImage(inputImage);
//     String? extractedNik;
//     Rect? extractedNikRect;
//     Rect nikRect = Rect.fromLTRB(
//       rect.left,
//       rect.top,
//       rect.right,
//       rect.top + (1.5 / 5.4 * rect.height),
//     );
//     // imageLib.drawRect(
//     //   originalImage,
//     //   nikRect.topLeft.dx.toInt(),
//     //   nikRect.topLeft.dy.toInt(),
//     //   nikRect.bottomRight.dx.toInt(),
//     //   nikRect.bottomRight.dy.toInt(),
//     //   0xffff0000,
//     // );
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(nikRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           lineText.split(' ').asMap().forEach((indexWord, word) {
//             if (extractedNik == null) {
//               RegExp regex = RegExp(r"[0-9]{14,16}");
//               RegExpMatch? firstMatch = regex.firstMatch(word);
//               if (firstMatch != null) {
//                 extractedNik =
//                     word.substring(firstMatch.start, firstMatch.end).trim();
//                 extractedNikRect = line.rect;
//               }
//             }
//           });
//         }
//       });
//     });
//     if (extractedNikRect != null) {
//       imageLib.drawRect(
//         originalImage,
//         extractedNikRect!.topLeft.dx.toInt(),
//         extractedNikRect!.topLeft.dy.toInt(),
//         extractedNikRect!.bottomRight.dx.toInt(),
//         extractedNikRect!.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }

//     /**
//      * 2. Try finding [KtpModel.name]
//      */
//     Rect nameRect = Rect.fromLTRB(
//       rect.left,
//       rect.top + (1.2 / 5.4 * rect.height),
//       rect.left + (4 / 8.6 * rect.width),
//       rect.top + (2.2 / 5.4 * rect.height),
//     );
//     // imageLib.drawRect(
//     //   originalImage,
//     //   nameRect.topLeft.dx.toInt(),
//     //   nameRect.topLeft.dy.toInt(),
//     //   nameRect.bottomRight.dx.toInt(),
//     //   nameRect.bottomRight.dy.toInt(),
//     //   0xff0000ff,
//     // );
//     Rect? recognizedNameRect;
//     String? recognizedName;
//     List<String> allNameList = [];
//     bool isFoundNama = false;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(nameRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           if (isFoundNama && recognizedName == null) {
//             recognizedName = lineText;
//             recognizedNameRect = line.rect;
//           }
//           if (!isFoundNama) {
//             lineText.split(' ').asMap().forEach((indexWord, word) {
//               if (isFoundNama) {
//                 recognizedName = lineText;
//                 recognizedNameRect = line.rect;
//               }
//               double similarityNama = lineText.similarityTo('Nama');
//               RegExp regexNik = RegExp(r"[0-9]");
//               RegExpMatch? matchNik = regexNik.firstMatch(lineText);
//               if (similarityNama >= 0.6 || matchNik != null) {
//                 isFoundNama = true;
//               }
//             });
//           }
//           allNameList.add(lineText);
//         }
//       });
//     });
//     if (recognizedName == null) {
//       recognizedName = allNameList.join(' ');
//     }
//     if (recognizedNameRect != null) {
//       imageLib.drawRect(
//         croppedImage,
//         recognizedNameRect!.topLeft.dx.toInt(),
//         recognizedNameRect!.topLeft.dy.toInt(),
//         recognizedNameRect!.bottomRight.dx.toInt(),
//         recognizedNameRect!.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }

//     /**
//      * 3. Try finding [KtpModel.birthDate]
//      */
//     Rect? extractedBirthDateRect;
//     DateTime? extractedBirthDate;
//     if (extractedNik?.length == 16) {
//       extractedBirthDate = extractBirthDateFromNik(extractedNik!);
//     } else {
//       Rect birthDateRect = Rect.fromLTRB(
//         rect.left,
//         rect.top + (1.5 / 5.4 * rect.height),
//         rect.left + (4 / 8.6 * rect.width),
//         rect.top + (2.5 / 5.4 * rect.height),
//       );
//       // imageLib.drawRect(
//       //   originalImage,
//       //   birthDateRect.topLeft.dx.toInt(),
//       //   birthDateRect.topLeft.dy.toInt(),
//       //   birthDateRect.bottomRight.dx.toInt(),
//       //   birthDateRect.bottomRight.dy.toInt(),
//       //   0xff0000ff,
//       // );
//       recognisedText.blocks.asMap().forEach((indexBlock, block) {
//         block.lines.asMap().forEach((indexLine, line) {
//           final intersectRect = line.rect.intersect(birthDateRect);
//           if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//             String lineText = line.text;
//             RegExp regex = RegExp(r"[0-9]{2}-[0-9]{2}-[0-9]{4}");
//             RegExpMatch? firstMatch = regex.firstMatch(lineText);
//             if (firstMatch != null) {
//               var birthDateStr =
//                   lineText.substring(firstMatch.start, firstMatch.end).trim();
//               var birthDateStrSplit = birthDateStr.split('-');
//               int day = int.parse(birthDateStrSplit[0]);
//               int month = int.parse(birthDateStrSplit[1]);
//               int year = int.parse(birthDateStrSplit[2]);
//               extractedBirthDate = DateTime(year, month, day);
//               extractedBirthDateRect = line.rect;
//             }
//           }
//         });
//       });
//     }
//     if (extractedBirthDateRect != null) {
//       imageLib.drawRect(
//         croppedImage,
//         extractedBirthDateRect!.topLeft.dx.toInt(),
//         extractedBirthDateRect!.topLeft.dy.toInt(),
//         extractedBirthDateRect!.bottomRight.dx.toInt(),
//         extractedBirthDateRect!.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }

//     /**
//      * 4. Try finding [KtpModel.address].
//      */
//     Rect addressRect = Rect.fromLTRB(
//       rect.left,
//       rect.top + (1.9 / 5.4 * rect.height),
//       rect.left + (4 / 8.6 * rect.width),
//       rect.top + (3.4 / 5.4 * rect.height),
//     );
//     imageLib.drawRect(
//       croppedImage,
//       addressRect.topLeft.dx.toInt(),
//       addressRect.topLeft.dy.toInt(),
//       addressRect.bottomRight.dx.toInt(),
//       addressRect.bottomRight.dy.toInt(),
//       0xff0000ff,
//     );
//     List<String> recognizedAddressList = [];
//     List<String> allAddressList = [];
//     String? recognizedAddress;
//     bool isFoundAlamat = false;
//     // bool isFoundAgama = false;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(addressRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           // double similarityAgama = lineText.similarityTo('Agama');
//           // if (similarityAgama >= 0.5) {
//           //   isFoundAgama = true;
//           // }
//           if (isFoundAlamat) {
//             recognizedAddressList.add(lineText);
//           }
//           allAddressList.add(lineText);
//           double similarityAlamat = lineText.similarityTo('Alamat');
//           if (similarityAlamat >= 0.5) {
//             isFoundAlamat = true;
//           }
//         }
//       });
//     });
//     if (recognizedAddressList.isNotEmpty) {
//       recognizedAddress = recognizedAddressList.join('\n');
//     } else {
//       recognizedAddress = allAddressList.join('\n');
//     }

//     /**
//      * 5. Try finding [KtpModel.job].
//      */
//     Rect jobRect = Rect.fromLTRB(
//       rect.left,
//       rect.top + (3.4 / 5.4 * rect.height),
//       rect.left + (4 / 8.6 * rect.width),
//       rect.bottom,
//     );
//     // imageLib.drawRect(
//     //   originalImage,
//     //   jobRect.topLeft.dx.toInt(),
//     //   jobRect.topLeft.dy.toInt(),
//     //   jobRect.bottomRight.dx.toInt(),
//     //   jobRect.bottomRight.dy.toInt(),
//     //   0xff0000ff,
//     // );
//     Rect? recognizedJobRect;
//     String? recognizedJob;
//     double maxSimilarityJob = 0.0;
//     String? maxSimilarityJobText;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(jobRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           recognizedJob = lineText;
//           recognizedJobRect = line.rect;
//         }
//       });
//     });
//     if (recognizedJobRect != null) {
//       imageLib.drawRect(
//         croppedImage,
//         recognizedJobRect!.topLeft.dx.toInt(),
//         recognizedJobRect!.topLeft.dy.toInt(),
//         recognizedJobRect!.bottomRight.dx.toInt(),
//         recognizedJobRect!.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }

//     // final tempDir = await getTemporaryDirectory();
//     final pathDrawn = pathLib.join(
//       tempDir.path,
//       '${DateTime.now()}_final.jpg',
//     );
//     // File imageDrawnFile = File(pathDrawn)
//     //   ..writeAsBytesSync(
//     //       imageLib.encodeJpg(imageLib.copyRotate(originalImage, -90)));
//     File imageDrawnFile = File(pathDrawn)
//       ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
//     return ResultModel(
//       isSuccess: true,
//       data: KtpModel(
//         image: imageDrawnFile,
//         nik: extractedNik,
//         name: recognizedName,
//         birthDate: extractedBirthDate,
//         address: recognizedAddress,
//         job: recognizedJob,
//         jobOriginalText: maxSimilarityJobText,
//         jobConfidence: maxSimilarityJob,
//         recognisedText: recognisedText,
//       ),
//     );
//   }

//   static Future<ResultModel<KtpModel>> getKtpVisionDataFromImage(
//     XFile file, {
//     bool isDrawSearchingArea = true,
//     bool isDrawExtractedArea = true,
//   }) async {
//     imageLib.Image? originalImage = await getOriginalImage(file);
//     imageLib.Image rotatedImage = imageLib.copyRotate(originalImage!, -90);

//     // TODO: Uncomment to bypass KTP checking
//     // File imageDrawnFileX = File(file.path)
//     //   ..writeAsBytesSync(imageLib.encodeJpg(originalImage));
//     // return ResultModel(
//     //   isSuccess: true,
//     //   data: KtpModel(
//     //     image: imageDrawnFileX,
//     //     nik: '1234567890123456',
//     //     name: 'Name',
//     //     birthDate: DateTime.now(),
//     //     address: 'Alamat',
//     //     job: null,
//     //     // jobOriginalText: maxSimilarityJobText,
//     //     // jobConfidence: maxSimilarityJob,
//     //     // recognisedText: recognisedText,
//     //   ),
//     // );

//     // Crop image according to frame
//     int cropWidth = (rotatedImage.width * 0.7).toInt();
//     int croppedX = (rotatedImage.width * 0.3) ~/ 2;
//     int cropHeight = (cropWidth * 0.6).toInt();
//     int croppedY = ((rotatedImage.height / 2) - (cropHeight / 2)).toInt();
//     imageLib.Image croppedImage = imageLib.copyCrop(
//       rotatedImage,
//       croppedX,
//       croppedY,
//       cropWidth,
//       cropHeight,
//     );

//     final tempDir = await getTemporaryDirectory();
//     final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
//     File processedFile = File(path)
//       ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
//     final inputImage = InputImage.fromFile(processedFile);

//     /**
//      * 1. Try finding [KtpModel.nik].
//      */
//     final textDetector = GoogleMlKit.vision.textDetector();
//     final RecognisedText recognisedText =
//         await textDetector.processImage(inputImage);
//     String? extractedNik;
//     Rect? extractedNikRect;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         String lineText = line.text;
//         lineText.split(' ').asMap().forEach((indexWord, word) {
//           if (extractedNik == null) {
//             RegExp regex = RegExp(r"[0-9]{14,16}");
//             RegExpMatch? firstMatch = regex.firstMatch(word);
//             if (firstMatch != null) {
//               extractedNik =
//                   word.substring(firstMatch.start, firstMatch.end).trim();
//               extractedNikRect = line.rect;
//             }
//           }
//         });
//       });
//     });
//     if (extractedNikRect != null && isDrawExtractedArea) {
//       imageLib.drawRect(
//         croppedImage,
//         extractedNikRect!.topLeft.dx.toInt(),
//         extractedNikRect!.topLeft.dy.toInt(),
//         extractedNikRect!.bottomRight.dx.toInt(),
//         extractedNikRect!.bottomRight.dy.toInt(),
//         0xff00ff00,
//       );
//     } else {
//       return ResultModel(
//         isSuccess: false,
//         error: 'Tidak dapat menemukan objek KTP.',
//       );
//     }

//     /**
//      * 2. Try finding [KtpModel.name]
//      */
//     Rect? extractedNameRect;
//     String? extractedName;
//     Rect nameRect = Rect.fromLTRB(
//       extractedNikRect!.left,
//       extractedNikRect!.bottom + (extractedNikRect!.height * 0.1),
//       extractedNikRect!.right,
//       extractedNikRect!.bottom + (extractedNikRect!.height * 1.1),
//     );
//     if (isDrawSearchingArea) {
//       imageLib.drawRect(
//         croppedImage,
//         nameRect.topLeft.dx.toInt(),
//         nameRect.topLeft.dy.toInt(),
//         nameRect.bottomRight.dx.toInt(),
//         nameRect.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         if (extractedName == null) {
//           final intersectRect = line.rect.intersect(nameRect);
//           if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//             extractedName = line.text;
//             extractedNameRect = line.rect;
//           }
//         }
//       });
//     });
//     if (extractedNameRect != null && isDrawExtractedArea) {
//       imageLib.drawRect(
//         croppedImage,
//         extractedNameRect!.topLeft.dx.toInt(),
//         extractedNameRect!.topLeft.dy.toInt(),
//         extractedNameRect!.bottomRight.dx.toInt(),
//         extractedNameRect!.bottomRight.dy.toInt(),
//         0xff00ff00,
//       );
//     }

//     /**
//      * 3. Try finding [KtpModel.birthDate]
//      */
//     Rect? extractedBirthDateRect;
//     DateTime? extractedBirthDate;
//     if (extractedNik?.length == 16) {
//       extractedBirthDate = extractBirthDateFromNik(extractedNik!);
//     } else {
//       Rect birthDateRect = Rect.fromLTRB(
//         nameRect.left,
//         nameRect.bottom,
//         nameRect.right,
//         nameRect.bottom + nameRect.height,
//       );
//       if (isDrawSearchingArea) {
//         imageLib.drawRect(
//           croppedImage,
//           birthDateRect.topLeft.dx.toInt(),
//           birthDateRect.topLeft.dy.toInt(),
//           birthDateRect.bottomRight.dx.toInt(),
//           birthDateRect.bottomRight.dy.toInt(),
//           0xff0000ff,
//         );
//       }
//       recognisedText.blocks.asMap().forEach((indexBlock, block) {
//         block.lines.asMap().forEach((indexLine, line) {
//           final intersectRect = line.rect.intersect(birthDateRect);
//           if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//             String lineText = line.text.replaceAll('-', '');
//             RegExp regex = RegExp(r"[0-9]{2}[0-9]{2}[0-9]{4}");
//             RegExpMatch? firstMatch = regex.firstMatch(lineText);
//             if (firstMatch != null) {
//               var birthDateStr =
//                   lineText.substring(firstMatch.start, firstMatch.end).trim();
//               // var birthDateStrSplit = birthDateStr.split('-');
//               int day = int.parse(birthDateStr.substring(0, 2));
//               int month = int.parse(birthDateStr.substring(2, 4));
//               int year = int.parse(birthDateStr.substring(4, 8));
//               extractedBirthDate = DateTime(year, month, day);
//               extractedBirthDateRect = line.rect;
//             }
//           }
//         });
//       });
//     }
//     if (extractedBirthDateRect != null && isDrawExtractedArea) {
//       imageLib.drawRect(
//         croppedImage,
//         extractedBirthDateRect!.topLeft.dx.toInt(),
//         extractedBirthDateRect!.topLeft.dy.toInt(),
//         extractedBirthDateRect!.bottomRight.dx.toInt(),
//         extractedBirthDateRect!.bottomRight.dy.toInt(),
//         0xff00ff00,
//       );
//     }

//     /**
//      * 4. Try finding [KtpModel.address].
//      */
//     Rect addressRect = Rect.fromLTRB(
//       0,
//       extractedNikRect!.bottom + (extractedNikRect!.height * 3),
//       croppedImage.width.toDouble() / 2,
//       extractedNikRect!.bottom + (extractedNikRect!.height * 7),
//     );
//     if (isDrawSearchingArea) {
//       imageLib.drawRect(
//         croppedImage,
//         addressRect.topLeft.dx.toInt(),
//         addressRect.topLeft.dy.toInt(),
//         addressRect.bottomRight.dx.toInt(),
//         addressRect.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }
//     List<String> allAddressList = [];
//     String? extractedAddress;
//     String? extractedProvinsi;
//     String? extractedKotaKab;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(addressRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           allAddressList.add(lineText);
//         }
//         if (indexBlock == 0 && indexLine == 0) {
//           extractedProvinsi = line.text;
//         }
//         if (indexBlock == 0 && indexLine == 1) {
//           extractedKotaKab = line.text;
//         }
//       });
//     });
//     allAddressList.add(extractedKotaKab!);
//     allAddressList.add(extractedProvinsi!);
//     if (allAddressList.isNotEmpty) {
//       extractedAddress = allAddressList.join('\n');
//     }

//     /**
//      * 5. Try finding [KtpModel.job].
//      */
//     Rect jobRect = Rect.fromLTRB(
//       0,
//       extractedNikRect!.bottom + (extractedNikRect!.height * 6),
//       croppedImage.width.toDouble() / 2,
//       croppedImage.height.toDouble(),
//     );
//     if (isDrawSearchingArea) {
//       imageLib.drawRect(
//         croppedImage,
//         jobRect.topLeft.dx.toInt(),
//         jobRect.topLeft.dy.toInt(),
//         jobRect.bottomRight.dx.toInt(),
//         jobRect.bottomRight.dy.toInt(),
//         0xff0000ff,
//       );
//     }
//     Rect? extractedJobRect;
//     String? extractedJob;
//     double maxSimilarityJob = 0.0;
//     String? maxSimilarityJobText;
//     recognisedText.blocks.asMap().forEach((indexBlock, block) {
//       block.lines.asMap().forEach((indexLine, line) {
//         final intersectRect = line.rect.intersect(jobRect);
//         if (intersectRect.height >= 0 && intersectRect.width >= 0) {
//           String lineText = line.text;
//           extractedJob = lineText;
//           extractedJobRect = line.rect;
//         }
//       });
//     });
//     if (extractedJobRect != null && isDrawExtractedArea) {
//       imageLib.drawRect(
//         croppedImage,
//         extractedJobRect!.topLeft.dx.toInt(),
//         extractedJobRect!.topLeft.dy.toInt(),
//         extractedJobRect!.bottomRight.dx.toInt(),
//         extractedJobRect!.bottomRight.dy.toInt(),
//         0xff00ff00,
//       );
//     }

//     final pathDrawn = pathLib.join(
//       tempDir.path,
//       '${DateTime.now()}_final.jpg',
//     );
//     File imageDrawnFile = File(pathDrawn)
//       ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));

//     return ResultModel(
//       isSuccess: true,
//       data: KtpModel(
//         image: imageDrawnFile,
//         nik: extractedNik,
//         name: extractedName,
//         birthDate: extractedBirthDate,
//         address: extractedAddress,
//         job: extractedJob,
//         jobOriginalText: maxSimilarityJobText,
//         jobConfidence: maxSimilarityJob,
//         recognisedText: recognisedText,
//       ),
//     );
//   }
// }


