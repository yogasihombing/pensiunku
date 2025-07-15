// data/api/forum_api.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // untuk apiHost

class ForumApi {
  final String _baseUrl;

  ForumApi() : _baseUrl = apiHost;

  /// Mendapatkan semua post forum
  Future<http.Response> getAllForumPost(String token) async {
    final uri = Uri.parse('$_baseUrl/forums/');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Mendapatkan post forum berdasarkan user ID
  Future<http.Response> getForumPostByUserID(String token, int userID) async {
    final uri = Uri.parse('$_baseUrl/forums/uid/$userID');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Mendapatkan post forum berdasarkan post ID
  Future<http.Response> getForumPostByPostID(String token, int postID) async {
    final uri = Uri.parse('$_baseUrl/forums/pid/$postID');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menambahkan like pada post forum
  Future<http.Response> addPostLike(String token, int id) async {
    final uri = Uri.parse('$_baseUrl/forums/saveLike/$id');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menghapus like dari post forum
  Future<http.Response> removeLike(String token, int id) async {
    final uri = Uri.parse('$_baseUrl/forums/deleteLike/$id');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menambahkan komentar pada post forum
  Future<http.Response> addForumComment(String token, dynamic data) async {
    final uri = Uri.parse('$_baseUrl/forums/saveComment');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }

  /// Menambahkan post baru ke forum
  Future<http.Response> addForumPost(String token, dynamic data) async {
    final uri = Uri.parse('$_baseUrl/forums/savePost');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }

  /// Mengecek status like untuk forum tertentu
  Future<http.Response> checkStatusLike(String token, int idForum) async {
    final uri = Uri.parse('$_baseUrl/forums/statusLike/$idForum');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
}
