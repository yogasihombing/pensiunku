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

// class RiwayatPengajuanApi {
//   // Base URL untuk endpoint API
//   final String _baseUrl = 'https://api.pensiunku.id/new.php/getPengajuan';

//   // Fungsi untuk mengambil daftar riwayat pengajuan berdasarkan nomor telepon
//   Future<List<Map<String, dynamic>>> getRiwayatPengajuan(String telepon) async {
//     try {
//       // Membuat body request yang hanya memuat nomor telepon
//       final Map<String, dynamic> body = {
//         "telepon": telepon, // Data yang dikirim sesuai spesifikasi API
//       };

//       // Melakukan POST request ke API dengan header JSON
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {"Content-Type": "application/json"}, // Mengatur tipe konten
//         body: jsonEncode(body), // Mengubah body ke format JSON
//       );

//       // Debugging: Mencetak isi respons untuk memverifikasi data
//       print('Response: ${response.body}');

//       // Memeriksa status HTTP apakah berhasil (200)
//       if (response.statusCode == 200) {
//         // Decode JSON dari respons
//         final decoded = jsonDecode(response.body);

//         // Memeriksa apakah data yang diharapkan ada dan dalam format List
//         if (decoded['data'] != null && decoded['data'] is List) {
//           return List<Map<String, dynamic>>.from(decoded['data']);
//         } else if (decoded['data'] != null && decoded['data'] is Map) {
//           // Jika data adalah Map, ambil array di dalamnya
//           return List<Map<String, dynamic>>.from(decoded['data']['data']);
//         } else {
//           throw Exception('Unexpected data format: ${decoded}');
//         }
//       } else {
//         // Melempar error jika status kode bukan 200
//         throw Exception(
//             'Failed to load data with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Debugging: Mencetak error jika terjadi masalah
//       print('Error: $e');
//       rethrow; // Melempar ulang error untuk ditangani di tempat lain
//     }
//   }
// }
