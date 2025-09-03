import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/poster_dialog/popup_model.dart';
import 'package:pensiunku/model/result_model.dart';

class PopupRepository {
  static const String _baseUrl = 'https://api.pensiunku.id/new.php';

  Future<ResultModel<PopupModel>> getPopupApps() async {
    try {
      print('PopupRepository: Memulai request ke $_baseUrl/getPopApps');
      final response = await http.get(
        Uri.parse('$_baseUrl/getPopApps'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('PopupRepository: Response status: ${response.statusCode}');
      print('PopupRepository: Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.contains('One moment, please...') ||
            response.body
                .contains('Access denied by Imunify360 bot-protection') ||
            response.body.trim().startsWith('<!DOCTYPE html>')) {
          throw Exception(
              'Deteksi tantangan keamanan (Cloudflare/Imunify360). Mohon coba lagi.');
        }

        try {
          final Map<String, dynamic> jsonData = jsonDecode(response.body);

          // Cek apakah 'text' ada dan merupakan sebuah List
          if (jsonData['text'] != null &&
              jsonData['text'] is List &&
              jsonData['text'].isNotEmpty) {
            // Ambil elemen pertama dari daftar dan kirim ke fromJson
            final popupData = jsonData['text'][0];
            final popup = PopupModel.fromJson(popupData);
            print('PopupRepository: Popup data berhasil diparsing: $popup');
            return ResultModel<PopupModel>(
              isSuccess: true,
              error: null,
              data: popup,
            );
          } else {
            // Beri pesan yang lebih spesifik jika data tidak ditemukan atau format tidak sesuai
            throw Exception(
                'Format response tidak sesuai: field "text" tidak ditemukan atau kosong');
          }
        } catch (e) {
          print('PopupRepository: Error parsing JSON: $e');
          throw Exception('Error parsing response: $e');
        }
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('PopupRepository: Error dalam getPopupApps: $e');
      return ResultModel<PopupModel>(
        isSuccess: false,
        error: e.toString(),
        data: null,
      );
    }
  }
}
