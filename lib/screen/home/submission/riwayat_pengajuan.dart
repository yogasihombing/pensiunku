import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pensiunku/screen/home/dashboard/ajukan/ajukan_screen.dart';
import 'package:pensiunku/screen/home/submission/status_pengajuan.dart';

class RiwayatPengajuanPage extends StatefulWidget {
  final String telepon;

  RiwayatPengajuanPage({required this.telepon});

  @override
  _RiwayatPengajuanPageState createState() => _RiwayatPengajuanPageState();
}

class _RiwayatPengajuanPageState extends State<RiwayatPengajuanPage> {
  bool _isLoading = false;
  List _pengajuanData = [];

  Future<void> _fetchPengajuanData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.pensiunku.id/new.php/getPengajuan'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"telepon": widget.telepon}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Check if 'text' is a list
        if (decodedResponse['text'] is List) {
          _pengajuanData = decodedResponse['text'];

          // Format dates for each entry in _pengajuanData
          _pengajuanData = _pengajuanData.map((data) {
            if (data['tanggal_pengajuan'] != null) {
              try {
                final parsedDate = DateTime.parse(data['tanggal_pengajuan']);
                data['tanggal_pengajuan'] =
                    DateFormat('dd MMMM yyyy, HH:mm').format(parsedDate);
              } catch (e) {
                print('Error formatting date: $e');
              }
            }
            return data;
          }).toList();

          setState(() {
            _isLoading = false;
          });
        } else {
          _showErrorSnackBar("Data tidak sesuai format");
        }
      } else {
        _showErrorSnackBar("Gagal memuat data pengajuan");
      }
    } catch (error) {
      _showErrorSnackBar("Terjadi kesalahan: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPengajuanData();
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData badgeIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        badgeColor = Colors.orange;
        badgeIcon = Icons.pending;
        break;
      case 'disetujui':
        badgeColor = Colors.green;
        badgeIcon = Icons.check_circle;
        break;
      case 'ditolak':
        badgeColor = Colors.red;
        badgeIcon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        badgeIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pengajuan'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _pengajuanData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "Belum ada riwayat pengajuan",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AjukanScreen(),
                                  ),
                                );
                              },
                              child: Text('Buat Pengajuan Baru'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF017964),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StatusPengajuanPage(
                                    nama: _pengajuanData[0]['nama'] ?? '',
                                    telepon: widget.telepon,
                                    domisili:
                                        _pengajuanData[0]['domisili'] ?? '',
                                    nip: _pengajuanData[0]['nip'] ?? '',
                                    nama_foto_ktp: _pengajuanData[0]
                                            ['nama_foto_ktp'] ??
                                        '',
                                    npwpFileName: _pengajuanData[0]
                                            ['nama_foto_npwp'] ??
                                        '',
                                    statusPengajuan:
                                        _pengajuanData[0]['status'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Kode Pengajuan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      _buildStatusBadge(_pengajuanData[0]
                                              ['tiket'] ??
                                          'Pending'),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _pengajuanData[0]['tiket'].toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        _pengajuanData[0]
                                                ['tanggal_pengajuan'] ??
                                            'Tidak Tersedia',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tap untuk melihat detail pengajuan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AjukanScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.add),
                            label: Text('Ajukan Pengajuan Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF017964),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
