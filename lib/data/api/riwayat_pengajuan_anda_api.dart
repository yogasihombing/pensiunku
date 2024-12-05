import 'dart:convert';
import 'package:http/http.dart' as http;

class RiwayatPengajuanAndaApi {
  final String baseUrl = 'https://api.pensiunku.id/new.php';

// fetchpengajuan method
  Future<List<dynamic>> fetchPengajuanAnda(String telepon) async {
    final url = Uri.parse('$baseUrl/getPengajuan');
    final startTime = DateTime.now();
    print('API: Mengirim POST request ke $url dengan telepon: $telepon');

    try {
      // POST Request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telepon': telepon,
        }),
      );
      // Response Handling
      if (response.statusCode == 200) {
        print('API: Response berhasil diterima: ${response.body}');
        final responseData = jsonDecode(response.body);

        // Pastikan data berada pada key yang benar: text > data
        if (responseData is Map &&
            responseData['text'] is Map &&
            responseData['text']['data'] is List) {
          return responseData['text']['data'] as List<dynamic>;
        } else {
          throw Exception('Format respons tidak sesuai: ${response.body}');
        }
      } else {
        print('API: Error response - ${response.statusCode}: ${response.body}');
        throw Exception('Failed to fetch data from API');
      }

      // Error Handling
    } catch (e) {
      print('API: Error saat fetch data - $e');
      rethrow;
    }
  }
}
