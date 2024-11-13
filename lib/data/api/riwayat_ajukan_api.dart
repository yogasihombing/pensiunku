// lib/data/api/riwayat_pengajuan_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pensiunku/model/riwayat_ajukan_model.dart';

class RiwayatPengajuanApi {
  static const String baseUrl = 'https://api.pensiunku.id/new.php/getPengajuan';

  Future<List<RiwayatPengajuan>> getPengajuan(String telepon) async {
    try {
      print('📤 Mengirim request ke API dengan telepon: $telepon');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"telepon": telepon}),
      );

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('📦 Data diterima: ${response.body}');
        
        if (responseData['data'] != null) {
          if (responseData['data'] is List) {
            return (responseData['data'] as List)
                .map((item) => RiwayatPengajuan.fromJson(item))
                .toList();
          } else if (responseData['data'] is Map) {
            return [RiwayatPengajuan.fromJson(responseData['data'])];
          }
        }
        return [];
      } else {
        print('❌ Error response: ${response.body}');
        throw Exception('Gagal memuat data pengajuan');
      }
    } catch (e) {
      print('❌ Error saat memanggil API: $e');
      rethrow;
    }
  }
}
