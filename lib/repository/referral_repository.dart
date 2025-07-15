import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pensiunku/data/api/referral_api.dart';
import 'package:pensiunku/data/db/app_database.dart';
import 'package:pensiunku/model/referral_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ReferralRepository extends BaseRepository {
  static String tag = 'ReferralRepository';
  ReferralApi api = ReferralApi();
  AppDatabase database = AppDatabase(); // Asumsi AppDatabase tidak menggunakan Dio

  Future<ResultModel<ReferralModel>> getAll(String token) async {
    assert(() {
      log('Referral Repository: $token', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Belum ada data referral. Silakan mengambil Foto KTP dan mengisi data referral.';

    try {
      // Menggunakan http.Response dari ReferralApi
      http.Response response = await api.getAll(token);
      
      // Periksa status code HTTP terlebih dahulu
      if (response.statusCode != 200) {
        log('HTTP Error: ${response.statusCode} - ${response.body}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: 'Terjadi kesalahan server (${response.statusCode}). Coba lagi nanti.',
        );
      }

      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);
      log(responseJson.toString(), name: tag); // Log seluruh responseJson

      if (responseJson['status'] == 'success') {
        if (responseJson['data'] != null) {
          return ResultModel(
            isSuccess: true,
            data: ReferralModel.fromJson(responseJson['data']),
          );
        } else {
          // Jika 'data' null tapi status success, kembalikan data null
          return ResultModel(
            isSuccess: true,
            data: null,
          );
        }
      } else {
        // Jika status bukan success
        log('API Response Error: ${responseJson['message'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['message'] ?? finalErrorMessage, // Gunakan pesan dari API jika ada
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);

      // Penanganan error untuk package http
      if (e is SocketException) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      // Tangani error lain yang mungkin terjadi saat upload file (misal file tidak ditemukan)
      if (e is Exception && e.toString().contains('File KTP tidak ditemukan')) {
        return ResultModel(
          isSuccess: false,
          error: e.toString(),
        );
      }
      
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<ReferralModel>> uploadKtp(
    String token,
    ReferralModel referralModel,
    String ktpFile,
  ) async {
    assert(() {
      log('uploadKtp', name: tag);
      return true;
    }());

    String finalErrorMessage =
        'Tidak dapat mengirimkan data referal. Mohon periksa internet Anda.';

    try {
      // Menggunakan http.Response dari ReferralApi
      http.Response response = await api.uploadKtp(token, referralModel, ktpFile);
      
      // Periksa status code HTTP terlebih dahulu
      if (response.statusCode != 200) {
        log('HTTP Error: ${response.statusCode} - ${response.body}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: 'Terjadi kesalahan server (${response.statusCode}). Coba lagi nanti.',
        );
      }

      // Decoding response.body ke Map
      var responseJson = json.decode(response.body);

      if (responseJson['status'] == 'success') {
        ReferralModel dataReferal = ReferralModel.fromJson(responseJson['data']);
        
        // Logika menyalin file tetap di sini
        if (File(ktpFile).existsSync()) {
          log('copy file: $ktpFile', name: tag);
          final appDir = await SharedPreferencesUtil.getAppDir();
          final destinationPath = path.join(appDir.path, dataReferal.fotoKtp.toString());
          
          try {
            File(ktpFile).copySync(destinationPath);
            log('cek foto ktp sudah ada atau tidak : ${File(destinationPath).existsSync()}', name: tag);
          } catch (copyError) {
            log('Gagal menyalin file KTP: $copyError', name: tag, error: copyError);
            // Anda bisa memilih untuk mengembalikan error di sini
            // atau membiarkan proses berlanjut jika penyalinan file tidak krusial
          }
        } else {
          log('File KTP tidak ditemukan untuk disalin: $ktpFile', name: tag);
        }

        return ResultModel(
          isSuccess: true,
          data: ReferralModel.fromJson(responseJson['data']),
        );
      } else {
        log('API Response Error: ${responseJson['msg'] ?? 'Unknown Error'}', name: tag);
        return ResultModel(
          isSuccess: false,
          error: responseJson['msg'] ?? finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is SocketException) {
        return ResultModel(
          isSuccess: false,
          error: 'Tidak ada koneksi internet. Mohon periksa jaringan Anda.',
        );
      }
      if (e is FormatException) {
        return ResultModel(
          isSuccess: false,
          error: 'Respons dari server tidak valid (bukan format JSON).',
        );
      }
      // Tangani error spesifik dari upload file (misal Exception dari ReferralApi)
      if (e is Exception && e.toString().contains('File KTP tidak ditemukan')) {
        return ResultModel(
          isSuccess: false,
          error: e.toString(),
        );
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  // Metode createFolder tetap sama karena tidak menggunakan Dio
  Future<String> createFolder(String cow) async {
    final folderName = cow;
    // Perbaikan: Gunakan path.join dengan benar dan pastikan getAppDir() mengembalikan Directory
    final appDir = await SharedPreferencesUtil.getAppDir();
    final folderPath = path.join(appDir.path, folderName);
    final directory = Directory(folderPath);

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    if (await directory.exists()) {
      return directory.path;
    } else {
      await directory.create(recursive: true); // Gunakan recursive: true untuk membuat folder induk jika tidak ada
      return directory.path;
    }
  }
}