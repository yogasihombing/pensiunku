import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:pensiunku/model/selfie_model.dart';
import 'package:pensiunku/repository/result_model.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:camera/camera.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imageLib;
import 'package:pensiunku/model/ktp_model.dart';
import 'package:path/path.dart' as pathLib;
import 'package:path_provider/path_provider.dart';

class FirebaseVisionUtils {
  static DateTime extractBirthDateFromNik(String text) {
    print('extractBirthDateFromNik: text = $text');
    try {
      print('extractBirthDateFromNik: Processing NIK = $text');

      // Validasi input
      if (text.isEmpty || text.length != 16) {
        print('extractBirthDateFromNik: Invalid NIK format');
        return DateTime.now();
      }

      // Extract components with null safety
      String dayStr = text.length >= 8 ? text.substring(6, 8) : '01';
      String monthStr = text.length >= 10 ? text.substring(8, 10) : '01';
      String yearStr = text.length >= 12 ? text.substring(10, 12) : '00';

      // Process day
      int day;
      try {
        int rawDay = int.parse(dayStr);
        // Handle female birth date (40 added to day)
        day = rawDay > 40 ? rawDay - 40 : rawDay;
        // Validate day range
        if (day < 1 || day > 31) day = 1;
      } catch (e) {
        print('extractBirthDateFromNik: Error parsing day: $e');
        day = 1;
      }

      // Process month
      int month;
      try {
        month = int.parse(monthStr);
        if (month < 1 || month > 12) month = 1;
      } catch (e) {
        print('extractBirthDateFromNik: Error parsing month: $e');
        month = 1;
      }

      // Process year
      bool isValidDate(DateTime date) {
        final now = DateTime.now();
        final hundred_years_ago = now.subtract(Duration(days: 36500));
        return date.isAfter(hundred_years_ago) && date.isBefore(now);
      }

      DateTime getSafeDate(DateTime? date) {
        if (date == null || !isValidDate(date)) {
          return DateTime.now();
        }
        return date;
      }

      int year;
      try {
        // Try 19xx first
        year = 1900 + int.parse(yearStr);

        // Check if the resulting date is too old (more than 100 years)
        DateTime birthDate = DateTime(year, month, day);
        if (DateTime.now().difference(birthDate).inDays > 36500) {
          // ~100 years
          // Try 20xx instead
          year = 2000 + int.parse(yearStr);
        }
      } catch (e) {
        print('extractBirthDateFromNik: Error parsing year: $e');
        year = 2000;
      }

      // Create and validate final date
      try {
        DateTime result = DateTime(year, month, day);
        print('extractBirthDateFromNik: Extracted date = $result');
        return result;
      } catch (e) {
        print('extractBirthDateFromNik: Error creating date: $e');
        return DateTime.now();
      }
    } catch (e) {
      print('extractBirthDateFromNik: Unexpected error: $e');
      return DateTime.now();
    }
  }

  static DateTime? tryExtractBirthDate(String line) {
    print('tryExtractBirthDate: line = $line');
    RegExp regex = RegExp(r"[0-9]{2}-[0-9]{2}-[0-9]{4}");
    RegExpMatch? firstMatch = regex.firstMatch(line);
    if (firstMatch != null) {
      var birthDateStr =
          line.substring(firstMatch.start, firstMatch.end).trim();
      var birthDateStrSplit = birthDateStr.split('-');
      int day = int.parse(birthDateStrSplit[0]);
      int month = int.parse(birthDateStrSplit[1]);
      int year = int.parse(birthDateStrSplit[2]);
      return DateTime(year, month, day);
    }
    return null;
  }

  static Future<imageLib.Image?> getOriginalImage(XFile file) async {
    print('getOriginalImage: file.path = ${file.path}');
    final fileBytes = await file.readAsBytes();
    return imageLib.decodeJpg(fileBytes);
  }

  static Future<InputImage> preProcessImage(
    imageLib.Image originalImage, {
    double imageRotation = -90,
  }) async {
    print(
        'preProcessImage: originalImage = $originalImage, imageRotation = $imageRotation');
    // Rotate image 90 degrees
    final rotatedImage = imageLib.copyRotate(originalImage, imageRotation);

    // Create new file
    final tempDir = await getTemporaryDirectory();
    final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
    File processedFile = File(path)
      ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

    return InputImage.fromFile(processedFile);
  }

  static Future<ResultModel<SelfieModel>> getSelfieVisionDataFromImage(
    XFile file, {
    double imageRotation = 90,
  }) async {
    try {
      print('getSelfieVisionDataFromImage: file.path = ${file.path}');
      imageLib.Image? originalImage = await getOriginalImage(file);

      // Rotasi gambar 90 derajat
      final rotatedImage = imageLib.copyRotate(originalImage!, imageRotation);

      // Buat file baru
      final tempDir = await getTemporaryDirectory();
      final path =
          pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
      File processedFile = File(path)
        ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

      final inputImage = InputImage.fromFile(processedFile);
      final faceDetector = GoogleMlKit.vision.faceDetector();

      try {
        final List<Face> faces = await faceDetector.processImage(inputImage);
        print('getSelfieVisionDataFromImage: faces detected = ${faces.length}');
        if (faces.isEmpty) {
          return ResultModel(
              isSuccess: false, error: 'Tidak dapat menemukan objek wajah.');
        }

        Face detectedObjectSelfie = faces.first;
        final rect = detectedObjectSelfie.boundingBox;

        // Gambar kotak wajah
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
        File imageDrawnFile = File(pathDrawn)
          ..writeAsBytesSync(imageLib.encodeJpg(rotatedImage));

        return ResultModel(
          isSuccess: true,
          data: SelfieModel(
            image: imageDrawnFile,
            imagePath: 'imagePath',
          ),
        );
      } catch (e) {
        print('getSelfieVisionDataFromImage: face detection error = $e');
        if (e.toString().contains('downloaded')) {
          // Modul deteksi wajah sedang diunduh
          return ResultModel(
              isSuccess: false,
              error:
                  'Sedang mengunduh model deteksi wajah. Silakan coba lagi dalam beberapa saat.');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print('getSelfieVisionDataFromImage: error = $e');
      return ResultModel(
          isSuccess: false,
          error: 'Terjadi kesalahan saat memproses gambar: ${e.toString()}');
    }
  }

  static Future<ResultModel<KtpModel>> getKtpVisionDataFromImageOld(
    XFile file, {
    bool isDrawDebugLine = true,
  }) async {
    print('getKtpVisionDataFromImageOld: file.path = ${file.path}');
    imageLib.Image? originalImage = await getOriginalImage(file);
    // Rotate image 90 degrees
    imageLib.Image rotatedImage = imageLib.copyRotate(originalImage!, -90);

    // Crop image according to frame
    int cropWidth = (rotatedImage.width * 0.7).toInt();
    int croppedX = (rotatedImage.width * 0.3) ~/ 2;
    int cropHeight = (cropWidth * 0.6).toInt();
    int croppedY = ((rotatedImage.height / 2) - (cropHeight / 2)).toInt();
    imageLib.Image croppedImage = imageLib.copyCrop(
      rotatedImage,
      croppedX,
      croppedY,
      cropWidth,
      cropHeight,
    );

    final tempDir = await getTemporaryDirectory();
    final path = pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
    File processedFile = File(path)
      ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
    final inputImage = InputImage.fromFile(processedFile);

    /// 1. Try finding KTP object
    final objectDetector =
        GoogleMlKit.vision.objectDetector(ObjectDetectorOptions());
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);
    print('getKtpVisionDataFromImageOld: objects detected = ${objects.length}');

    if (objects.length <= 0) {
      return ResultModel(
          isSuccess: false, error: 'Tidak dapat menemukan objek KTP.');
    }

    DetectedObject detectedObjectKtp = objects.first;
    final rect = detectedObjectKtp.getBoundinBox();

    /**
     * Draw KTP
     */
    imageLib.drawRect(
      rotatedImage,
      rect.topLeft.dx.toInt(),
      rect.topLeft.dy.toInt(),
      rect.bottomRight.dx.toInt(),
      rect.bottomRight.dy.toInt(),
      0xffffffff,
    );

    /**
     * 1. Try finding [KtpModel.nik].
     */
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);
    print(
        'getKtpVisionDataFromImageOld: recognisedText = ${recognisedText.text}');
    String? extractedNik;
    Rect? extractedNikRect;
    Rect nikRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      rect.top + (1.5 / 5.4 * rect.height),
    );
    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(nikRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          lineText.split(' ').asMap().forEach((indexWord, word) {
            if (extractedNik == null) {
              RegExp regex = RegExp(r"[0-9]{14,16}");
              RegExpMatch? firstMatch = regex.firstMatch(word);
              if (firstMatch != null) {
                extractedNik =
                    word.substring(firstMatch.start, firstMatch.end).trim();
                extractedNikRect = line.rect;
              }
            }
          });
        }
      });
    });
    print('getKtpVisionDataFromImageOld: extractedNik = $extractedNik'); //1
    if (extractedNikRect != null) {
      print(
          'Drawing NIK rectangle at: ${extractedNikRect!.topLeft} to ${extractedNikRect!.bottomRight}');
      imageLib.drawRect(
        originalImage,
        extractedNikRect!.topLeft.dx.toInt(),
        extractedNikRect!.topLeft.dy.toInt(),
        extractedNikRect!.bottomRight.dx.toInt(),
        extractedNikRect!.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    // Try finding [KtpModel.name]
    Rect nameRect = Rect.fromLTRB(
      rect.left,
      rect.top + (1.2 / 5.4 * rect.height),
      rect.left + (4 / 8.6 * rect.width),
      rect.top + (2.2 / 5.4 * rect.height),
    );
    print('Name rectangle: $nameRect');

    Rect? recognizedNameRect;
    String? recognizedName;
    List<String> allNameList = [];
    bool isFoundNama = false;

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(nameRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          print('Found text in name area: $lineText');
          if (isFoundNama && recognizedName == null) {
            recognizedName = lineText;
            recognizedNameRect = line.rect;
          }
          if (!isFoundNama) {
            lineText.split(' ').asMap().forEach((indexWord, word) {
              if (isFoundNama) {
                recognizedName = lineText;
                recognizedNameRect = line.rect;
              }
              double similarityNama = lineText.similarityTo('Nama');
              RegExp regexNik = RegExp(r"[0-9]");
              RegExpMatch? matchNik = regexNik.firstMatch(lineText);
              if (similarityNama >= 0.6 || matchNik != null) {
                isFoundNama = true;
              }
            });
          }
          allNameList.add(lineText);
        }
      });
    });

    if (recognizedName == null) {
      recognizedName = allNameList.join(' ');
    }
    if (recognizedNameRect != null) {
      print('Recognized name: $recognizedName at $recognizedNameRect');
      imageLib.drawRect(
        croppedImage,
        recognizedNameRect!.topLeft.dx.toInt(),
        recognizedNameRect!.topLeft.dy.toInt(),
        recognizedNameRect!.bottomRight.dx.toInt(),
        recognizedNameRect!.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    // Try finding [KtpModel.birthDate]
    Rect? extractedBirthDateRect;
    DateTime? extractedBirthDate;
    if (extractedNik?.length == 16) {
      extractedBirthDate = extractBirthDateFromNik(extractedNik!);
    } else {
      Rect birthDateRect = Rect.fromLTRB(
        rect.left,
        rect.top + (1.5 / 5.4 * rect.height),
        rect.left + (4 / 8.6 * rect.width),
        rect.top + (2.5 / 5.4 * rect.height),
      );
      print('Birth date rectangle: $birthDateRect');

      recognisedText.blocks.asMap().forEach((indexBlock, block) {
        block.lines.asMap().forEach((indexLine, line) {
          final intersectRect = line.rect.intersect(birthDateRect);
          if (intersectRect.height >= 0 && intersectRect.width >= 0) {
            String lineText = line.text;
            print('Found text in birth date area: $lineText');
            RegExp regex = RegExp(r"[0-9]{2}-[0-9]{2}-[0-9]{4}");
            RegExpMatch? firstMatch = regex.firstMatch(lineText);
            if (firstMatch != null) {
              var birthDateStr =
                  lineText.substring(firstMatch.start, firstMatch.end).trim();
              var birthDateStrSplit = birthDateStr.split('-');
              int day = int.parse(birthDateStrSplit[0]);
              int month = int.parse(birthDateStrSplit[1]);
              int year = int.parse(birthDateStrSplit[2]);
              extractedBirthDate = DateTime(year, month, day);
              extractedBirthDateRect = line.rect;
            }
          }
        });
      });
    }

    if (extractedBirthDateRect != null) {
      print(
          'Recognized birth date: $extractedBirthDate at $extractedBirthDateRect');
      imageLib.drawRect(
        croppedImage,
        extractedBirthDateRect!.topLeft.dx.toInt(),
        extractedBirthDateRect!.topLeft.dy.toInt(),
        extractedBirthDateRect!.bottomRight.dx.toInt(),
        extractedBirthDateRect!.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    // Try finding [KtpModel.address]
    Rect addressRect = Rect.fromLTRB(
      rect.left,
      rect.top + (1.9 / 5.4 * rect.height),
      rect.left + (4 / 8.6 * rect.width),
      rect.top + (3.4 / 5.4 * rect.height),
    );
    print('Address rectangle: $addressRect');
    imageLib.drawRect(
      croppedImage,
      addressRect.topLeft.dx.toInt(),
      addressRect.topLeft.dy.toInt(),
      addressRect.bottomRight.dx.toInt(),
      addressRect.bottomRight.dy.toInt(),
      0xff0000ff,
    );

    List<String> recognizedAddressList = [];
    List<String> allAddressList = [];
    String? recognizedAddress;
    bool isFoundAlamat = false;

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(addressRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          print('Found text in address area: $lineText');
          if (isFoundAlamat) {
            recognizedAddressList.add(lineText);
          }
          allAddressList.add(lineText);
          double similarityAlamat = lineText.similarityTo('Alamat');
          if (similarityAlamat >= 0.5) {
            isFoundAlamat = true;
          }
        }
      });
    });

    if (recognizedAddressList.isNotEmpty) {
      recognizedAddress = recognizedAddressList.join('\n');
    } else {
      recognizedAddress = allAddressList.join('\n');
    }

    // Try finding [KtpModel.job]
    Rect jobRect = Rect.fromLTRB(
      rect.left,
      rect.top + (3.4 / 5.4 * rect.height),
      rect.left + (4 / 8.6 * rect.width),
      rect.bottom,
    );
    print('Job rectangle: $jobRect');

    Rect? recognizedJobRect;
    String? recognizedJob;
    double maxSimilarityJob = 0.0;
    String? maxSimilarityJobText;

    recognisedText.blocks.asMap().forEach((indexBlock, block) {
      block.lines.asMap().forEach((indexLine, line) {
        final intersectRect = line.rect.intersect(jobRect);
        if (intersectRect.height >= 0 && intersectRect.width >= 0) {
          String lineText = line.text;
          print('Found text in job area: $lineText');
          recognizedJob = lineText;
          recognizedJobRect = line.rect;
        }
      });
    }); // 2

    if (recognizedJobRect != null) {
      print('Recognized job: $recognizedJob at $recognizedJobRect');
      imageLib.drawRect(
        croppedImage,
        recognizedJobRect!.topLeft.dx.toInt(),
        recognizedJobRect!.topLeft.dy.toInt(),
        recognizedJobRect!.bottomRight.dx.toInt(),
        recognizedJobRect!.bottomRight.dy.toInt(),
        0xff0000ff,
      );
    }

    // final tempDir = await getTemporaryDirectory();
    final pathDrawn = pathLib.join(
      tempDir.path,
      '${DateTime.now()}_final.jpg',
    );
    // File imageDrawnFile = File(pathDrawn)
    //   ..writeAsBytesSync(
    //       imageLib.encodeJpg(imageLib.copyRotate(originalImage, -90)));
    File imageDrawnFile = File(pathDrawn)
      ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));
    return ResultModel(
      isSuccess: true,
      data: KtpModel(
        image: imageDrawnFile,
        nik: extractedNik,
        name: recognizedName,
        birthDate: extractedBirthDate,
        address: recognizedAddress,
        job: recognizedJob,
        jobOriginalText: maxSimilarityJobText,
        jobConfidence: maxSimilarityJob,
        recognisedText: recognisedText,
      ),
    );
  }

  static Future<ResultModel<KtpModel>> getKtpVisionDataFromImage(
    XFile file, {
    bool isDrawSearchingArea = false,
    bool isDrawExtractedArea = true,
  }) async {
    // Deklarasi variabel yang dibutuhkan di awal method
    String? extractedNik;
    String? extractedName;
    DateTime? extractedBirthDate;
    String? extractedAddress;
    String? extractedJob;
    Rect? extractedNikRect;
    Rect? extractedNameRect;

    try {
      print(
          'getKtpVisionDataFromImage: Starting process with file ${file.path}');

      // Validasi file terlebih dahulu
      if (!await File(file.path).exists()) {
        print('File tidak ditemukan: ${file.path}');
        return ResultModel<KtpModel>(
          isSuccess: false,
          error: 'File gambar tidak ditemukan',
        );
      }

      imageLib.Image? originalImage = await getOriginalImage(file);
      if (originalImage == null) {
        return ResultModel<KtpModel>(
          isSuccess: false,
          error: 'Gagal memproses gambar. File tidak valid.',
        );
      }

      // Validasi dimensi gambar
      if (originalImage.width < 300 || originalImage.height < 300) {
        return ResultModel<KtpModel>(
          isSuccess: false,
          error: 'Resolusi gambar terlalu kecil',
        );
      }

      print('Tahapan pemrosesan:');
      print(
          '1. Ukuran gambar asli: ${originalImage.width}x${originalImage.height}');
      print(
          'getKtpVisionDataFromImage: Original image size: ${originalImage.width}x${originalImage.height}');

      imageLib.Image rotatedImage = imageLib.copyRotate(originalImage, -90);
      print(
          'getKtpVisionDataFromImage: Rotated image size: ${rotatedImage.width}x${rotatedImage.height}');

      // TODO: Uncomment to bypass KTP checking
      // File imageDrawnFileX = File(file.path)
      //   ..writeAsBytesSync(imageLib.encodeJpg(originalImage));
      // return ResultModel(
      //   isSuccess: true,
      //   data: KtpModel(
      //     image: imageDrawnFileX,
      //     nik: '1234567890123456',
      //     name: 'Name',
      //     birthDate: DateTime.now(),
      //     address: 'Alamat',
      //     job: 'buruh',
      //     // jobOriginalText: maxSimilarityJobText,
      //     // jobConfidence: maxSimilarityJob,
      //     // recognisedText: recognisedText,
      //   ),
      // );

      // Crop image according to frame
      try {
        int cropWidth = (rotatedImage.width * 0.7).toInt();
        int croppedX = (rotatedImage.width * 0.3) ~/ 2;
        int cropHeight = (cropWidth * 0.6).toInt();
        int croppedY = ((rotatedImage.height / 2) - (cropHeight / 2)).toInt();

        print(
            'getKtpVisionDataFromImage: Crop parameters - x:$croppedX, y:$croppedY, width:$cropWidth, height:$cropHeight');

        // Validasi parameter crop
        if (croppedX < 0 ||
            croppedY < 0 ||
            croppedX + cropWidth > rotatedImage.width ||
            croppedY + cropHeight > rotatedImage.height) {
          print(
              'getKtpVisionDataFromImage: Invalid crop parameters, adjusting...');
          croppedX = max(0, croppedX);
          croppedY = max(0, croppedY);
          cropWidth = min(cropWidth, rotatedImage.width - croppedX);
          cropHeight = min(cropHeight, rotatedImage.height - croppedY);
          print(
              'getKtpVisionDataFromImage: Adjusted crop parameters - x:$croppedX, y:$croppedY, width:$cropWidth, height:$cropHeight');
        }

        imageLib.Image croppedImage = imageLib.copyCrop(
          rotatedImage,
          croppedX,
          croppedY,
          cropWidth,
          cropHeight,
        );
        print(
            'getKtpVisionDataFromImage: Cropped image size: ${croppedImage.width}x${croppedImage.height}');

        // Simpan gambar yang sudah diproses
        final tempDir = await getTemporaryDirectory();
        final path =
            pathLib.join(tempDir.path, '${DateTime.now()}_processed.jpg');
        print('getKtpVisionDataFromImage: Saving processed image to $path');

        try {
          File processedFile = File(path)
            ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));

          // Validasi file yang disimpan
          if (!await processedFile.exists() ||
              await processedFile.length() == 0) {
            throw Exception('Gagal menyimpan gambar yang diproses');
          }

          print(
              'getKtpVisionDataFromImage: Processed file size: ${await processedFile.length()} bytes');

          final inputImage = InputImage.fromFile(processedFile);
          print(
              'getKtpVisionDataFromImage: Created InputImage from processed file');

          // 1. Try finding [KtpModel.nik].
          print('Starting text detection');
          final textDetector = GoogleMlKit.vision.textDetector();
          RecognisedText? recognisedText;

          try {
            recognisedText = await textDetector.processImage(inputImage);
            print(
                'Text detection completed. Found ${recognisedText.blocks.length} blocks');

            // Validasi hasil deteksi teks
            if (recognisedText.blocks.isEmpty) {
              return ResultModel<KtpModel>(
                isSuccess: false,
                error:
                    'Tidak ada teks yang terdeteksi pada gambar. Pastikan KTP terlihat jelas.',
              );
            }
          } catch (e) {
            print('Error in text detection: $e');
            return ResultModel<KtpModel>(
              isSuccess: false,
              error: 'Gagal mendeteksi teks pada gambar: ${e.toString()}',
            );
          }

          // Pencarian NIK
          print('getKtpVisionDataFromImage: Searching for NIK');
          for (var indexBlock = 0;
              indexBlock < recognisedText.blocks.length;
              indexBlock++) {
            var block = recognisedText.blocks[indexBlock];
            print(
                'getKtpVisionDataFromImage: Block $indexBlock text: ${block.text}');

            for (var indexLine = 0;
                indexLine < block.lines.length;
                indexLine++) {
              var line = block.lines[indexLine];
              print(
                  'getKtpVisionDataFromImage: Line $indexLine text: ${line.text}');

              var lineText = line.text;
              var words = lineText.split(' ');

              for (var indexWord = 0; indexWord < words.length; indexWord++) {
                var word = words[indexWord];
                if (extractedNik == null) {
                  RegExp regex = RegExp(r"[0-9]{14,16}");
                  RegExpMatch? firstMatch = regex.firstMatch(word);
                  if (firstMatch != null) {
                    extractedNik =
                        word.substring(firstMatch.start, firstMatch.end).trim();
                    extractedNikRect = line.rect;
                    print(
                        'getKtpVisionDataFromImage: Found NIK: $extractedNik at ${line.rect}');
                  }
                }
              }
            }
          }

          // Validasi NIK ditemukan
          if (extractedNikRect == null) {
            print('getKtpVisionDataFromImage: NIK not found in image');
            return ResultModel<KtpModel>(
              isSuccess: false,
              error:
                  'Tidak dapat menemukan NIK pada KTP. Pastikan KTP terlihat jelas.',
            );
          }

          // 2. Try finding [KtpModel.name]
          print('getKtpVisionDataFromImage: Searching for name');

          // Definisikan area pencarian nama berdasarkan posisi NIK
          Rect nameRect = Rect.fromLTRB(
            extractedNikRect.left,
            extractedNikRect.bottom + (extractedNikRect.height * 0.1),
            extractedNikRect.right,
            extractedNikRect.bottom + (extractedNikRect.height * 1.1),
          );
          print('getKtpVisionDataFromImage: Name search area: $nameRect');

          // Pencarian nama dalam area yang ditentukan
          for (var block in recognisedText.blocks) {
            for (var line in block.lines) {
              if (extractedName == null) {
                final intersectRect = line.rect.intersect(nameRect);
                print(
                    'getKtpVisionDataFromImage: Checking line "${line.text}" with rect ${line.rect}');
                print(
                    'getKtpVisionDataFromImage: Intersection with name area: $intersectRect');

                if (intersectRect.height > 0 && intersectRect.width > 0) {
                  extractedName = line.text;
                  extractedNameRect = line.rect;
                  print('Found name: $extractedName');
                }
              }
            }
          }

          // Metode alternatif pencarian nama jika belum ditemukan
          if (extractedName == null && extractedNikRect != null) {
            print('Mencari nama menggunakan area referensi NIK');
            Rect nameSearchRect = Rect.fromLTRB(
                extractedNikRect.left,
                extractedNikRect.bottom,
                extractedNikRect.right,
                extractedNikRect.bottom + (extractedNikRect.height * 2));

            for (var block in recognisedText.blocks) {
              for (var line in block.lines) {
                final intersectRect = line.rect.intersect(nameSearchRect);
                if (intersectRect.height > 0 && intersectRect.width > 0) {
                  if (extractedNik == null ||
                      !line.text.contains(extractedNik)) {
                    extractedName = line.text.trim();
                    extractedNameRect = line.rect;
                    print('Nama ditemukan: $extractedName');
                    break;
                  }
                }
              }
              if (extractedName != null) break;
            }
          }

// 3. Try finding [KtpModel.birthDate]
          Rect? extractedBirthDateRect;

// Ekstrak tanggal lahir dari NIK jika memungkinkan
          if (extractedNik != null &&
              extractedNik.isNotEmpty &&
              extractedNik.length == 16) {
            try {
              extractedBirthDate = extractBirthDateFromNik(extractedNik);
              print('Successfully extracted birth date: $extractedBirthDate');
            } catch (e) {
              print('Error extracting birth date from NIK: $e');
              // Coba metode alternatif
              try {
                extractedBirthDate = tryExtractBirthDate(recognisedText.text);
              } catch (e) {
                print('Error extracting birth date from text: $e');
              }
            }
          } else {
            // Coba temukan tanggal lahir dalam teks
            try {
              extractedBirthDate = tryExtractBirthDate(recognisedText.text);
            } catch (e) {
              print('Error extracting birth date from text: $e');
            }
          }

// Fallback jika kedua metode gagal
          if (extractedBirthDate == null) {
            print('Warning: Using default birth date');
            extractedBirthDate = DateTime.now();
          } else {
            // Cari area tanggal lahir untuk visualisasi
            Rect birthDateRect = Rect.fromLTRB(
              nameRect.left,
              nameRect.bottom,
              nameRect.right,
              nameRect.bottom + nameRect.height,
            );

            // Coba ekstrak tanggal lahir dari teks
            for (var indexBlock = 0;
                indexBlock < recognisedText.blocks.length;
                indexBlock++) {
              var block = recognisedText.blocks[indexBlock];
              for (var indexLine = 0;
                  indexLine < block.lines.length;
                  indexLine++) {
                var line = block.lines[indexLine];
                final intersectRect = line.rect.intersect(birthDateRect);
                if (intersectRect.height >= 0 && intersectRect.width >= 0) {
                  String lineText = line.text.replaceAll('-', '');
                  RegExp regex = RegExp(r"[0-9]{2}[0-9]{2}[0-9]{4}");
                  RegExpMatch? firstMatch = regex.firstMatch(lineText);
                  if (firstMatch != null) {
                    try {
                      var birthDateStr = lineText
                          .substring(firstMatch.start, firstMatch.end)
                          .trim();
                      int day = int.parse(birthDateStr.substring(0, 2));
                      int month = int.parse(birthDateStr.substring(2, 4));
                      int year = int.parse(birthDateStr.substring(4, 8));

                      // Validasi tanggal
                      if (day > 0 &&
                          day <= 31 &&
                          month > 0 &&
                          month <= 12 &&
                          year >= 1900 &&
                          year <= DateTime.now().year) {
                        extractedBirthDate = DateTime(year, month, day);
                        extractedBirthDateRect = line.rect;
                      }
                    } catch (e) {
                      print('Error parsing birth date: $e');
                    }
                  }
                }
              }
            }
          }

// 4. Try finding [KtpModel.address]
          Rect addressRect = Rect.fromLTRB(
            0,
            extractedNikRect.bottom + (extractedNikRect.height * 3),
            croppedImage.width.toDouble() / 2,
            extractedNikRect.bottom + (extractedNikRect.height * 7),
          );

          List<String> allAddressList = [];
          String? extractedAddress;
          String? extractedProvinsi;
          String? extractedKotaKab;

// Ekstrak alamat dari teks yang terdeteksi
          for (var indexBlock = 0;
              indexBlock < recognisedText.blocks.length;
              indexBlock++) {
            var block = recognisedText.blocks[indexBlock];
            for (var indexLine = 0;
                indexLine < block.lines.length;
                indexLine++) {
              var line = block.lines[indexLine];

              // Tambahkan data yang sudah ditemukan sebelumnya
              if (extractedKotaKab != null &&
                  !allAddressList.contains(extractedKotaKab)) {
                allAddressList.add(extractedKotaKab);
              }

              if (extractedProvinsi != null &&
                  !allAddressList.contains(extractedProvinsi)) {
                allAddressList.add(extractedProvinsi);
              }

              // Cari teks dalam area alamat
              final intersectRect = line.rect.intersect(addressRect);
              if (intersectRect.height >= 0 && intersectRect.width >= 0) {
                String lineText = line.text;
                if (!allAddressList.contains(lineText)) {
                  allAddressList.add(lineText);
                }
              }

              // Simpan provinsi dan kota/kabupaten dari blok pertama
              if (indexBlock == 0 && indexLine == 0) {
                extractedProvinsi = line.text;
              }

              if (indexBlock == 0 && indexLine == 1) {
                extractedKotaKab = line.text;
              }
            }
          }

// Pastikan provinsi dan kota/kabupaten ditambahkan ke alamat
          if (extractedKotaKab != null &&
              !allAddressList.contains(extractedKotaKab)) {
            allAddressList.add(extractedKotaKab);
          }

          if (extractedProvinsi != null &&
              !allAddressList.contains(extractedProvinsi)) {
            allAddressList.add(extractedProvinsi);
          }
// Gabungkan semua bagian alamat
          if (allAddressList.isNotEmpty) {
            extractedAddress = allAddressList.join('\n');
          }

// 5. Try finding [KtpModel.job]
          Rect jobRect = Rect.fromLTRB(
            0,
            extractedNikRect.bottom + (extractedNikRect.height * 6),
            croppedImage.width.toDouble() / 2,
            croppedImage.height.toDouble(),
          );

          Rect? extractedJobRect;
          String? extractedJob;
          double maxSimilarityJob = 0.0;
          String? maxSimilarityJobText;

// Ekstrak pekerjaan dari teks yang terdeteksi
          for (var indexBlock = 0;
              indexBlock < recognisedText.blocks.length;
              indexBlock++) {
            var block = recognisedText.blocks[indexBlock];
            for (var indexLine = 0;
                indexLine < block.lines.length;
                indexLine++) {
              var line = block.lines[indexLine];
              final intersectRect = line.rect.intersect(jobRect);
              if (intersectRect.height >= 0 && intersectRect.width >= 0) {
                String lineText = line.text;
                extractedJob = lineText;
                extractedJobRect = line.rect;
              }
            }
          }

// Simpan gambar hasil akhir
          print(
              'getKtpVisionDataFromImage: Processing complete, saving result image');
          final pathDrawn = pathLib.join(
            tempDir.path,
            '${DateTime.now()}_final.jpg',
          );

          File imageDrawnFile;
          try {
            imageDrawnFile = File(pathDrawn)
              ..writeAsBytesSync(imageLib.encodeJpg(croppedImage));

            // Validasi file hasil
            if (!await imageDrawnFile.exists() ||
                await imageDrawnFile.length() == 0) {
              throw Exception('Gagal menyimpan gambar hasil');
            }

            print(
                'getKtpVisionDataFromImage: Result image saved to $pathDrawn');
          } catch (e) {
            print('Error saving result image: $e');
            // Gunakan file asli jika gagal menyimpan hasil
            imageDrawnFile = File(file.path);
          }

// Bersihkan data yang diekstrak
          if (extractedName != null) {
            extractedName = extractedName.replaceAll(':', '').trim();
          }

// Log hasil ekstraksi
          print('Hasil ekstraksi data KTP:');
          print('NIK: ${extractedNik ?? "tidak ditemukan"}');
          print('Nama: ${extractedName ?? "tidak ditemukan"}');
          print(
              'Tanggal Lahir: ${extractedBirthDate?.toString() ?? "tidak ditemukan"}');
          print('Alamat: ${extractedAddress ?? "tidak ditemukan"}');
          print('Pekerjaan: ${extractedJob ?? "tidak ditemukan"}');

// Buat model KTP dengan data yang diekstrak
// PENTING: Gunakan nilai default untuk menghindari null
          return ResultModel(
            isSuccess: true,
            data: KtpModel(
              image: imageDrawnFile,
              nik: extractedNik ?? '0000000000000000',
              name: extractedName ?? 'Tidak Terdeteksi',
              birthDate: extractedBirthDate ?? DateTime.now(),
              address: extractedAddress ?? 'Alamat tidak terdeteksi',
              job: extractedJob ?? "Tidak Terdeteksi",
              jobOriginalText: maxSimilarityJobText ?? '',
              jobConfidence: maxSimilarityJob,
              recognisedText: recognisedText,
            ),
          );
        } catch (e) {
          print(
              'getKtpVisionDataFromImage: Error while processing image file: $e');
          return ResultModel(
            isSuccess: false,
            error:
                'Terjadi kesalahan saat memproses berkas gambar: ${e.toString()}',
          );
        }
      } catch (e) {
        print('getKtpVisionDataFromImage: Error during image cropping: $e');
        return ResultModel(
          isSuccess: false,
          error: 'Terjadi kesalahan saat memotong gambar: ${e.toString()}',
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is PlatformException) {
        errorMessage = 'Terjadi kesalahan sistem: ${e.message}';
      } else if (e is TimeoutException) {
        errorMessage = 'Waktu proses terlalu lama. Mohon coba lagi.';
      } else {
        errorMessage = 'Gagal mendeteksi KTP: ${e.toString()}';
      }

      // Logging hasil akhir dengan null check
      print('Hasil pemrosesan final:');
      print('2. NIK terdeteksi: ${extractedNik ?? "tidak ada"}');
      print('3. Nama terdeteksi: ${extractedName ?? "tidak ada"}');
      print('4. Tanggal Lahir: ${extractedBirthDate ?? "tidak ada"}');
      print('5. Alamat: ${extractedAddress ?? "tidak ada"}');
      print('6. Pekerjaan: ${extractedJob ?? "tidak ada"}');

      return ResultModel(
        isSuccess: false,
        error: errorMessage,
      );
    }
  }
}

// import 'dart:io';

// import 'package:age_calculator/age_calculator.dart';
// import 'package:pensiunku/model/selfie_model.dart';
// import 'package:pensiunku/repository/result_model.dart';
// import 'package:string_similarity/string_similarity.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image/image.dart' as imageLib;
// import 'package:pensiunku/model/ktp_model.dart';
// import 'package:path/path.dart' as pathLib;
// import 'package:path_provider/path_provider.dart';

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
//         image: imageDrawnFile, imagePath: 'imagePath',
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
