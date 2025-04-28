class KarirModal {
  final String title;
  final String company;
  final String location;
  final List<String> tags;
  final String? description;
  final List<String> qualifications;
  final List<String> responsibilities;

  KarirModal({
    required this.title,
    required this.company,
    required this.location,
    required this.tags,
    this.description,
    this.qualifications = const [],
    this.responsibilities = const [],
  });
}

// Data dummy untuk lowongan kerja
final List<KarirModal> dummyJobs = [
  KarirModal(
    title: 'Marketing Representative',
    company: 'PT Cama Marsit Kreasi',
    location: 'Manado, Sulawesi Utara',
    tags: ['Full-Time', 'On-Site'],
    description:
        'Kami mencari Marketing Representative yang berdedikasi untuk bergabung dengan tim kami di Manado. Posisi ini bertanggung jawab untuk memasarkan produk kredit pensiun dan melayani nasabah dengan profesional.',
    qualifications: [
      'Pendidikan min SMA/ SMK',
      'Usia maks 45 Tahun',
      'Memiliki skill komunikasi yang baik',
      'Memiliki pengetahuan dasar akan marketing/sales',
      'Memiliki semangat tinggi',
    ],
    responsibilities: [
      'Mencari nasabah pinjaman di seluruh Indonesia',
      'Memasarkan produk Kredit Pensiun',
      'Membantu nasabah memahami produk dan proses pengajuan kredit',
      'Memenuhi target penjualan',
      'Menjaga hubungan baik dengan nasabah',
    ],
  ),
  KarirModal(
    title: 'Software Developer',
    company: 'PT Cama Marsit Kreasi',
    location: 'Jakarta, DKI Jakarta',
    tags: ['Full-Time', 'Remote'],
    description:
        'Kami mencari Software Developer yang berpengalaman untuk mengembangkan aplikasi mobile dan web. Anda akan bekerja dengan tim yang dinamis dan inovatif.',
  ),
  KarirModal(
    title: 'Customer Service',
    company: 'PT Retail Sukses',
    location: 'Surabaya, Jawa Timur',
    tags: ['Part-Time', 'On-Site'],
    description:
        'Posisi Customer Service untuk melayani pelanggan di toko retail kami di Surabaya. Jadwal kerja fleksibel dan lingkungan kerja yang menyenangkan.',
  ),
  KarirModal(
    title: 'Digital Marketing Internship',
    company: 'PT Media Kreasi',
    location: 'Bandung, Jawa Barat',
    tags: ['Internship', 'Hybrid'],
    description:
        'Program magang untuk mahasiswa atau fresh graduate yang tertarik dengan digital marketing. Durasi 3 bulan dengan kemungkinan perpanjangan kontrak.',
  ),
  KarirModal(
    title: 'Finance Manager',
    company: 'PT Investasi Global',
    location: 'Makassar, Sulawesi Selatan',
    tags: ['Full-Time', 'On-Site'],
    description:
        'Kami mencari Finance Manager yang berpengalaman untuk mengelola keuangan perusahaan. Minimal pengalaman 5 tahun di bidang keuangan.',
  ),
];
