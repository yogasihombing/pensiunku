import 'dart:convert'; // Tetap diperlukan untuk json.decode jika parsing manual di getDataFromApiResponse
import 'dart:developer';
import 'dart:io'; // Tetap diperlukan jika ada penanganan SocketException di luar getResultModel, tapi idealnya tidak
import 'package:http/http.dart' as http; // Menggunakan paket http
import 'package:pensiunku/data/api/forum_api.dart'; // Pastikan path ini benar
import 'package:pensiunku/model/forum_model.dart'; // Pastikan semua model di sini
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';
import 'package:pensiunku/util/shared_preferences_util.dart';


class ForumRepository extends BaseRepository {
  static String tag = 'Forum Repository';
  ForumApi api = ForumApi();

  // Mengambil semua postingan forum
  Future<ResultModel<List<ForumModel>>> getAllForumPost(String token) {
    assert(() {
      log('getAllForumPost Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<List<ForumModel>>(
      tag: tag,
      getFromDb: () async => null, // Tidak ada interaksi DB untuk fungsi ini
      getFromApi: () async {
        log('Mencoba ambil semua postingan forum dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.getAllForumPost(token);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk getAllForumPost: $responseJson', name: tag);
        if (responseJson['status'] == 'success' && responseJson['data'] != null) {
          List<dynamic> itemsJson = responseJson['data'];
          List<ForumModel> forumList = [];
          for (var value in itemsJson) {
            try {
              forumList.add(
                ForumModel.fromJson(value),
              );
            } catch (e) {
              log('!!! ERROR parsing ForumModel dari data: $value. Error: $e. Type of error: ${e.runtimeType} !!!', name: tag, error: e);
              rethrow;
            }
          }
          log('ForumModel berhasil diparsing: ${forumList.length} item.', name: tag);
          return forumList;
        } else {
          log('Status API bukan sukses atau data kosong untuk getAllForumPost. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {}, // Tidak ada interaksi DB untuk fungsi ini
      insertToDb: (_) async {}, // Tidak ada interaksi DB untuk fungsi ini
      errorMessage: 'Gagal mengambil data forum terbaru. Tolong periksa Internet Anda.',
    );
  }

  // Mengambil postingan forum berdasarkan ID pengguna
  Future<ResultModel<List<ForumModel>>> getForumPostbyUserID(
    String token,
    int userID,
  ) {
    assert(() {
      log('getForumPostbyUserID Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<List<ForumModel>>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba ambil postingan forum berdasarkan userID dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.getForumPostByUserID(token, userID);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk getForumPostbyUserID: $responseJson', name: tag);
        if (responseJson['status'] == 'success' && responseJson['data'] != null) {
          List<dynamic> itemsJson = responseJson['data'];
          List<ForumModel> forumList = [];
          for (var value in itemsJson) {
            try {
              forumList.add(
                ForumModel.fromJson(value),
              );
            } catch (e) {
              log('!!! ERROR parsing ForumModel dari data: $value. Error: $e. Type of error: ${e.runtimeType} !!!', name: tag, error: e);
              rethrow;
            }
          }
          log('ForumModel berhasil diparsing: ${forumList.length} item.', name: tag);
          return forumList;
        } else {
          log('Status API bukan sukses atau data kosong untuk getForumPostbyUserID. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Gagal mengambil data forum terbaru. Tolong periksa Internet Anda.',
    );
  }

  // Mengambil detail postingan forum berdasarkan ID postingan
  Future<ResultModel<List<ForumDetailModel>>> getForumPostbyPostID(
      String token, int postID) {
    assert(() {
      log('getForumPostbyPostID Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<List<ForumDetailModel>>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba ambil detail postingan forum berdasarkan postID dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.getForumPostByPostID(token, postID);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk getForumPostbyPostID: $responseJson', name: tag);
        if (responseJson['status'] == 'success' && responseJson['data'] != null) {
          List<dynamic> itemsJson = responseJson['data'];
          List<ForumDetailModel> forumDetailList = [];
          for (var value in itemsJson) {
            try {
              forumDetailList.add(
                ForumDetailModel.fromJson(value),
              );
            } catch (e) {
              log('!!! ERROR parsing ForumDetailModel dari data: $value. Error: $e. Type of error: ${e.runtimeType} !!!', name: tag, error: e);
              rethrow;
            }
          }
          log('ForumDetailModel berhasil diparsing: ${forumDetailList.length} item.', name: tag);
          return forumDetailList;
        } else {
          log('Status API bukan sukses atau data kosong untuk getForumPostbyPostID. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Gagal mengambil data detail forum. Tolong periksa Internet Anda.',
    );
  }

  // Menambahkan like pada postingan
  Future<ResultModel<bool>> addPostLike(String token, int id) {
    assert(() {
      log('addLikePost Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<bool>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba menambahkan like pada postingan dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.addPostLike(token, id);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk addPostLike: $responseJson', name: tag);
        if (responseJson['status'] == 'success') {
          log('Berhasil menambahkan like.', name: tag);
          return true;
        } else {
          log('Status API bukan sukses untuk addPostLike. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Tidak dapat menambahkan like. Tolong periksa Internet Anda.',
    );
  }

  // Menghapus like pada postingan
  Future<ResultModel<bool>> removeLike(String token, int id) {
    assert(() {
      log('removeLike Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<bool>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba menghapus like dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.removeLike(token, id);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk removeLike: $responseJson', name: tag);
        if (responseJson['status'] == 'success') {
          log('Berhasil menghapus like.', name: tag);
          return true;
        } else {
          log('Status API bukan sukses untuk removeLike. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Tidak dapat menghapus like. Tolong periksa Internet Anda.',
    );
  }

  // Menambahkan komentar pada postingan forum
  Future<ResultModel<bool>> addForumComment(String token, dynamic data) {
    assert(() {
      log('addForumComment Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<bool>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba menambahkan komentar forum dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.addForumComment(token, data);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk addForumComment: $responseJson', name: tag);
        if (responseJson['status'] == 'success') {
          log('Berhasil menambahkan komentar.', name: tag);
          return true;
        } else {
          log('Status API bukan sukses untuk addForumComment. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Tidak dapat menambahkan komentar. Tolong periksa Internet Anda.',
    );
  }

  // Menambahkan postingan forum baru
  Future<ResultModel<bool>> addForumPost(String token, dynamic data) {
    assert(() {
      log('addForumPost Repository dipanggil.', name: tag);
      return true;
    }());
    return super.getResultModel<bool>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba menambahkan postingan forum baru dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.addForumPost(token, data);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk addForumPost: $responseJson', name: tag);
        if (responseJson['status'] == 'success') {
          log('Berhasil menambahkan postingan.', name: tag);
          return true;
        } else {
          log('Status API bukan sukses untuk addForumPost. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: 'Tidak dapat membuat postingan. Tolong periksa Internet Anda.',
    );
  }

  // Memeriksa status like pada postingan
  Future<ResultModel<String>> checkStatusLike(int idPost) async {
    assert(() {
      log('checkStatusLike Repository dipanggil.', name: tag);
      return true;
    }());
    String finalErrorMessage = 'Gagal mengambil data forum. Tolong periksa Internet Anda.';
    String? token = SharedPreferencesUtil().sharedPreferences.getString(SharedPreferencesUtil.SP_KEY_TOKEN);

    // Periksa jika token null sebelum melanjutkan
    if (token == null) {
      log('Token tidak ditemukan di SharedPreferences. Mengembalikan error.', name: tag);
      return ResultModel(
        isSuccess: false,
        error: 'Token otentikasi tidak tersedia.',
      );
    }

    return super.getResultModel<String>(
      tag: tag,
      getFromDb: () async => null,
      getFromApi: () async {
        log('Mencoba memeriksa status like dari API.', name: tag);
        // --- PERUBAHAN: Langsung panggil API dan kembalikan http.Response, hapus try-catch di sini ---
        return await api.checkStatusLike(token, idPost);
        // --- AKHIR PERUBAHAN ---
      },
      getDataFromApiResponse: (responseJson) {
        log('Mengolah respons API untuk checkStatusLike: $responseJson', name: tag);
        if (responseJson['status'] == 'success' && responseJson['data'] != null && responseJson['data']['isLike'] != null) {
          String isLiked = responseJson['data']['isLike'].toString();
          log('Isliked: ' + isLiked, name: tag);
          return isLiked;
        } else {
          log('Status API bukan sukses atau data isLike kosong untuk checkStatusLike. Respons: $responseJson', name: tag);
          throw Exception(responseJson['msg'] ?? 'Respons API tidak valid atau data isLike tidak ditemukan.');
        }
      },
      removeFromDb: (_) async {},
      insertToDb: (_) async {},
      errorMessage: finalErrorMessage,
    );
  }
}