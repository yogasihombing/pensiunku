import 'package:flutter/material.dart';
import 'package:pensiunku/model/karir/karir_modal.dart';

class KarirDetailScreen extends StatelessWidget {
  final KarirModal job;

  const KarirDetailScreen({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Color(0xFFDCE293),
                ],
                stops: [0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                SizedBox(
                  height: kToolbarHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF017964),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Detail Pekerjaan',
                          style: TextStyle(
                            color: Color(0xFF017964),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.company,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Tambahan nama perusahaan

                          // Job Tags (Full-Time, On-Site, etc)
                          Row(
                            children: job.tags.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tag.toLowerCase().contains('time')
                                        ? Colors.blue.shade100
                                        : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: tag.toLowerCase().contains('time')
                                          ? Colors.blue.shade800
                                          : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // Location
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                job.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Kualifikasi Section
                          _buildSectionCard(
                            title: 'Kualifikasi',
                            items: [
                              'Pendidikan min SMA/ SMK',
                              'Usia maks 45 Tahun',
                              'Memiliki skill komunikasi yang baik',
                              'Memiliki pengetahuan dasar akan marketing/sales',
                              'Memiliki semangat tinggi',
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tugas Utama Section
                          _buildSectionCard(
                            title: 'Tugas Utama',
                            items: [
                              'Mencari nasabah pinjaman di seluruh Indonesia',
                              'Memasarkan produk Kredit Pensiun',
                              'Membantu nasabah memahami produk dan proses pengajuan kredit',
                              'Memenuhi target penjualan',
                              'Menjaga hubungan baik dengan nasabah',
                            ],
                            isBlueLink: true,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          if (job.description != null &&
                              job.description!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Deskripsi Pekerjaan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  job.description ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Apply Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Action for applying to the job
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Lamaran Anda telah dikirim!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC95F),
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionCard({
    required String title,
    required List<String> items,
    bool isBlueLink = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isBlueLink ? Colors.blue : Colors.black87,
                                decoration: isBlueLink
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
