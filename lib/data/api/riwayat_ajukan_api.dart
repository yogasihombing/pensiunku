

import 'package:http/http.dart' as http;
import 'dart:convert';

class RiwayatPengajuanApi {
  final String _baseUrl = 'https://api.pensiunku.id/new.php/getPengajuan';

  Future<List<Map<String, dynamic>>> getRiwayatPengajuan(String telepon) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'telepon': telepon}),
      );
      print('Response status: ${response.statusCode}');
      print('Response API: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Validasi field `data` apakah berupa List
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        } else {
          throw Exception('Format data API tidak sesuai: ${decoded}');
        }
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error di API: $e');
      rethrow;
    }
  }
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // Kelas untuk berkomunikasi langsung dengan API
// class RiwayatPengajuanApi {
//   // URL base API
//   final String _baseUrl = 'https://api.pensiunku.id/new.php/getPengajuan';

//   // Fungsi untuk mengambil data riwayat pengajuan berdasarkan nomor telepon
//   Future<List<Map<String, dynamic>>> getRiwayatPengajuan(String telepon) async {
//     try {
//       // Kirim permintaan POST ke API
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'}, // Header wajib JSON
//         body: jsonEncode({'telepon': telepon}), // Data dikirim dalam bentuk JSON
//       );

//       print('Response status: ${response.statusCode}');
//       print('Response API: ${response.body}');

//       // Periksa jika status kode HTTP adalah 200 (berhasil)
//       if (response.statusCode == 200) {
//         // Decode JSON ke dalam format Dart
//         final decoded = jsonDecode(response.body);

//         // Periksa apakah field `data` adalah daftar
//         if (decoded is Map<String, dynamic> && decoded['data'] is List) {
//           return List<Map<String, dynamic>>.from(decoded['data']);
//         } else {
//           throw Exception('Format data API tidak sesuai: ${decoded}');
//         }
//       } else {
//         throw Exception(
//             'Error ${response.statusCode}: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Error di API: $e');
//       rethrow;
//     }
//   }
// }
