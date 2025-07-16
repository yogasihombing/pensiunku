// data/api/forum_api.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pensiunku/util/api_util.dart';
import 'package:pensiunku/config.dart'; // untuk apiHost

class ForumApi {
  final String _baseUrl;

  ForumApi() : _baseUrl = apiHost;

  /// Mendapatkan semua post forum
  Future<http.Response> getAllForumPost(String token) async {
    final uri = Uri.parse('$_baseUrl/forums/');
    print('ForumApi: getAllForumPost calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Mendapatkan post forum berdasarkan user ID
  Future<http.Response> getForumPostByUserID(String token, int userID) async {
    final uri = Uri.parse('$_baseUrl/forums/uid/$userID');
    print('ForumApi: getForumPostByUserID calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Mendapatkan post forum berdasarkan post ID
  Future<http.Response> getForumPostByPostID(String token, int postID) async {
    final uri = Uri.parse('$_baseUrl/forums/pid/$postID');
    print('ForumApi: getForumPostByPostID calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menambahkan like pada post forum
  Future<http.Response> addPostLike(String token, int id) async {
    final uri = Uri.parse('$_baseUrl/forums/saveLike/$id');
    print('ForumApi: addPostLike calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menghapus like dari post forum
  Future<http.Response> removeLike(String token, int id) async {
    final uri = Uri.parse('$_baseUrl/forums/deleteLike/$id');
    print('ForumApi: removeLike calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }

  /// Menambahkan komentar pada post forum
  Future<http.Response> addForumComment(String token, dynamic data) async {
    final uri = Uri.parse('$_baseUrl/forums/saveComment');
    print('ForumApi: addForumComment calling: $uri with body: $data');
    return await http.post(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
      body: jsonEncode(data),
    );
  }

  /// Menambahkan post baru ke forum
  /// Mengubah parameter `data` menjadi `content` dan `photos` (List<File>)
  Future<http.Response> addForumPost(
      String token, String content, List<File> photos) async {
    final uri = Uri.parse('$_baseUrl/forums/savePost');
    print(
        'ForumApi: addForumPost calling: $uri with content: "$content" and ${photos.length} photos');

    // Membuat MultipartRequest untuk mengirim data dan file
    var request = http.MultipartRequest('POST', uri);

    // Menambahkan header token
    request.headers.addAll(ApiUtil.getTokenHeaders(token));

    // Menambahkan field content
    request.fields['content'] = content;

    // Menambahkan file-file
    for (var photoFile in photos) {
      request.files.add(await http.MultipartFile.fromPath(
        'photos[]', // Nama field yang diharapkan oleh server untuk array file
        photoFile.path,
        filename: photoFile.path.split('/').last, // Nama file asli
      ));
    }

    // Mengirim request dan mengembalikan response
    return await http.Response.fromStream(await request.send());
  }

  /// Mengecek status like untuk forum tertentu
  Future<http.Response> checkStatusLike(String token, int idForum) async {
    final uri = Uri.parse('$_baseUrl/forums/statusLike/$idForum');
    print('ForumApi: checkStatusLike calling: $uri');
    return await http.get(
      uri,
      headers: ApiUtil.getTokenHeaders(token),
    );
  }
}
