import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/forum_api.dart';
import 'package:pensiunku/model/forum_model.dart';
import 'package:pensiunku/repository/base_repository.dart';
import 'package:pensiunku/model/result_model.dart';

import '../util/shared_preferences_util.dart';

class ForumRepository extends BaseRepository {
  static String tag = 'Forum Repository';
  ForumApi api = ForumApi();

  Future<ResultModel<List<ForumModel>>> getAllForumPost(String token) async {
    assert(() {
      log('getAllForumPost', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data forum terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getAllForumPost(token);

      var responseJson = response.data;

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<ForumModel> forumList = [];
        itemsJson.forEach((value) {
          forumList.add(
            ForumModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: forumList,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: [],
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<List<ForumModel>>> getForumPostbyUserID(
    String token,
    int userID,
  ) async {
    assert(() {
      log('getForumPostbyUserID', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data forum terbaru. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getForumPostbyUserID(token, userID);
      var responseJson = response.data;
      // log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<ForumModel> forumList = [];
        itemsJson.forEach((value) {
          forumList.add(
            ForumModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: forumList,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: [],
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<List<ForumDetailModel>>> getForumPostbyPostID(
      String token, int postID) async {
    assert(() {
      log('getForumPostbyPostID', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data detail forum. Tolong periksa Internet Anda.';
    try {
      Response response = await api.getForumPostbyPostID(token, postID);
      var responseJson = response.data;
      // log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        List<dynamic> itemsJson = responseJson['data'];
        List<ForumDetailModel> forumDetailList = [];
        itemsJson.forEach((value) {
          forumDetailList.add(
            ForumDetailModel.fromJson(value),
          );
        });
        return ResultModel(
          isSuccess: true,
          data: forumDetailList,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> addPostLike(String token, int id) async {
    assert(() {
      log('addLikePost:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menambahkan like. Tolong periksa Internet Anda.';
    try {
      Response response = await api.addPostLike(token, id);
      var responseJson = response.data;
      log(responseJson.toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: false,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> removeLike(String token, int id) async {
    assert(() {
      log('removeLike:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menghapus like. Tolong periksa Internet Anda.';
    try {
      Response response = await api.removeLike(token, id);
      var responseJson = response.data;
      log(responseJson.toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> addForumComment(String token, dynamic data) async {
    assert(() {
      log('addForumComment:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat menambahkan komentar. Tolong periksa Internet Anda.';
    try {
      Response response = await api.addForumComment(token, data);
      var responseJson = response.data;
      // log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: false,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  Future<ResultModel<bool>> addForumPost(String token, dynamic data) async {
    assert(() {
      log('addForumPost:', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Tidak dapat membuat postingan. Tolong periksa Internet Anda.';
    try {
      Response response = await api.addForumPost(token, data);
      var responseJson = response.data;
      // log(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        return ResultModel(
          isSuccess: true,
          data: true,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
          data: false,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }

  // Future<int> checkStatusLike(String token, int idPost) async {
  //   Response response = await api.checkStatusLike(token, idPost);
  //   print(response.data.toString());
  //   return 1;
  // }

  Future<ResultModel<String>> checkStatusLike(
    int idPost,
  ) async {
    assert(() {
      log('checkStatusLike', name: tag);
      return true;
    }());
    String finalErrorMessage =
        'Gagal mengambil data forum . Tolong periksa Internet Anda.';
    String? token = SharedPreferencesUtil()
        .sharedPreferences
        .getString(SharedPreferencesUtil.SP_KEY_TOKEN);
    try {
      Response response = await api.checkStatusLike(token!, idPost);
      var responseJson = response.data;
      // log(responseJson['data']['isLike'].toString());
      // print(responseJson['data'].toString());

      if (responseJson['status'] == 'success') {
        String isLiked = responseJson['data']['isLike'];
        log('Isliked : ' + isLiked);
        return ResultModel(
          isSuccess: true,
          data: isLiked,
        );
      } else {
        return ResultModel(
          isSuccess: false,
          error: finalErrorMessage,
        );
      }
    } catch (e) {
      log(e.toString(), name: tag, error: e);
      if (e is DioError) {
        int? statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            // Client error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          } else if (statusCode >= 500 && statusCode < 600) {
            // Server error
            return ResultModel(
              isSuccess: false,
              error: finalErrorMessage,
            );
          }
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ResultModel(
            isSuccess: false,
            error: finalErrorMessage,
          );
        }
      }
      return ResultModel(
        isSuccess: false,
        error: finalErrorMessage,
      );
    }
  }
}
