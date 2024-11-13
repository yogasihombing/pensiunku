import 'package:flutter/material.dart';

class StatusPengajuanPage extends StatefulWidget {
  final String nama;
  final String telepon;
  final String domisili;
  final String nip;
  final String nama_foto_ktp;
  final String npwpFileName;
  final String statusPengajuan; // Menambahkan status pengajuan

  StatusPengajuanPage({
    required this.nama,
    required this.telepon,
    required this.domisili,
    required this.nip,
    required this.nama_foto_ktp,
    required this.npwpFileName,
    required this.statusPengajuan, // Inisialisasi
  });

  @override
  _StatusPengajuanPageState createState() => _StatusPengajuanPageState();
}

class _StatusPengajuanPageState extends State<StatusPengajuanPage> {
  double currentStep = 0; // Inisialisasi dengan nilai 0 (pengajuan baru)

  List<String> steps = [
    'Pengajuan Kredit',
    'Cek SLIK',
    'Simulasi Kredit',
    'Pemberkasan',
    'Pencairan',
  ];

  List<bool> _isExpanded = List.generate(5, (_) => false);

  @override
  void initState() {
    super.initState();

    // Ubah currentStep berdasarkan status pengajuan yang diterima
    switch (widget.statusPengajuan) {
      case 'Pengajuan Kredit':
        currentStep = 0;
        break;
      case 'Cek SLIK':
        currentStep = 1;
        break;
      case 'Simulasi Kredit':
        currentStep = 2;
        break;
      case 'Pemberkasan':
        currentStep = 3;
        break;
      case 'Pencairan':
        currentStep = 4;
        break;
      default:
        currentStep = 0;
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Pengajuan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Container Pertama: Status Pengajuan dan Slider Bertahap
            Container(
              width: double.infinity, // Sesuaikan dengan lebar layar
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFAE58),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Status Pengajuan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Simulasi Kredit',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            SizedBox(height: 8.0),
                            Text('Pinjaman Pra-Pensiun'),
                            Text('Plafon: Rp 50.000.000,-'),
                            SizedBox(height: 16.0),

                            // Range Slider Bertahap
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progres Pengajuan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),

                                // RangeSlider with steps
                                RangeSlider(
                                  values: RangeValues(0, currentStep),
                                  min: 0,
                                  max: steps.length - 1,
                                  divisions: steps.length - 1,
                                  labels: RangeLabels(
                                      steps[0], steps[currentStep.toInt()]),
                                  onChanged: (RangeValues values) {},
                                  activeColor: Colors.green,
                                  inactiveColor: Colors.grey[300],
                                ),
                                SizedBox(height: 16.0),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: steps.map((step) {
                                    return Text(
                                      step,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tanggal Pengajuan: 12/09/2024',
                                    style: TextStyle(
                                      fontSize: 12, // Ukuran font lebih kecil
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Estimasi Pencairan: 20/09/2024',
                                    style: TextStyle(
                                      fontSize: 12, // Ukuran font lebih kecil
                                      color: Colors.grey, // Warna lebih ringan
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.0),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),

            // Container Kedua: Detail Setiap Tahap Pengajuan
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Tahap Pengajuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),

                  // Detail Expandable List untuk setiap tahap
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(steps[index]),
                            trailing: Icon(_isExpanded[index]
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down),
                            onTap: () {
                              setState(() {
                                _isExpanded[index] = !_isExpanded[index];
                              });
                            },
                          ),
                          if (_isExpanded[index])
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Detail dari tahap ${steps[index]}. '
                                'Informasi lebih lanjut mengenai proses ini akan dijelaskan di sini.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}