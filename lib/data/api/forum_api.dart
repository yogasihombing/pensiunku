import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pensiunku/data/api/base_api.dart';
import 'package:pensiunku/util/api_util.dart';

class ForumApi extends BaseApi {
  Future<Response> getAllForumPost(String token) {
    return httpGet('/forums/', options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> getForumPostbyUserID(String token, int userID) {
    return httpGet('/forums/uid/$userID',
        options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> getForumPostbyPostID(String token, int postID) {
    return httpGet('/forums/pid/$postID',
        options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> addPostLike(String token, int id) {
    return httpGet('/forums/saveLike/$id',
        options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> removeLike(String token, int id) {
    return httpGet('/forums/deleteLike/$id',
        options: ApiUtil.getTokenOptions(token));
  }

  Future<Response> addForumComment(String token, dynamic data) {
    return httpPost(
      '/forums/saveComment',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> addForumPost(
    String token,
    dynamic data,
  ) {
    return httpPost(
      '/forums/savePost',
      data: data,
      options: ApiUtil.getTokenOptions(token),
    );
  }

  Future<Response> checkStatusLike(String token, int idForum) {
    return httpGet('/forums/statusLike/$idForum',
        options: ApiUtil.getTokenOptions(token));
  }
}
