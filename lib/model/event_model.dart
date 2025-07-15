class EventModel {
  final int id;
  final String nama;
  final String tempat;
  final String tanggal;
  // --- PERUBAHAN: Menambahkan field 'status' ke EventModel dan menjadikannya String ---
  final String status;
  // --- AKHIR PERUBAHAN ---
  final String foto;

  EventModel({
    required this.id,
    required this.nama,
    required this.tempat,
    required this.tanggal,
    // --- PERUBAHAN: Menambahkan 'status' ke konstruktor ---
    required this.status,
    // --- AKHIR PERUBAHAN ---
    required this.foto
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
        // --- PERUBAHAN: Parsing id dengan aman jika datang sebagai String ---
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        // --- AKHIR PERUBAHAN ---
        nama: json['nama'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
        tempat: json['tempat'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
        tanggal: json['tanggal'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
        // --- PERUBAHAN: Parsing status sebagai String ---
        status: json['status']?.toString() ?? '',
        // --- AKHIR PERUBAHAN ---
        foto: json['foto'] ?? '' // --- PERUBAHAN: Menambahkan null-safety ---
    );
  }
}

class EventDetailModel {
  // --- PERUBAHAN: Mengubah tipe data 'status' menjadi String ---
  final String status; // Log menunjukkan ini datang sebagai String ("1")
  // --- AKHIR PERUBAHAN ---
  final String eflyer;
  final String nama;
  final String tanggal;
  final String waktu;
  // --- PERUBAHAN: Menambahkan kembali field 'tempat' dan 'alamat' ---
  final String tempat;
  final String alamat;
  // --- AKHIR PERUBAHAN ---
  final String description;
  final String? link; // Link bisa null
  // --- PERUBAHAN: Menggunakan EventFotoModel sesuai original Anda ---
  final List<EventFotoModel> foto;

  EventDetailModel({
    required this.status,
    required this.eflyer,
    required this.nama,
    required this.tanggal,
    required this.waktu,
    // --- PERUBAHAN: Menambahkan 'tempat' dan 'alamat' ke konstruktor ---
    required this.tempat,
    required this.alamat,
    // --- AKHIR PERUBAHAN ---
    required this.description,
    this.link,
    required this.foto,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    // --- PERUBAHAN: Memastikan json['foto'] adalah List dan menggunakan EventFotoModel.fromJson ---
    List<EventFotoModel> fotoList = [];
    if (json['foto'] != null && json['foto'] is List) {
      fotoList = (json['foto'] as List)
          .map((item) => EventFotoModel.fromJson(item))
          .toList();
    }
    // --- AKHIR PERUBAHAN ---

    return EventDetailModel(
      // --- PERUBAHAN: Parsing 'status' sebagai String ---
      status: json['status']?.toString() ?? '', // Pastikan status selalu string
      // --- AKHIR PERUBAHAN ---
      eflyer: json['eflyer'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      nama: json['nama'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      tanggal: json['tanggal'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      waktu: json['waktu'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      // --- PERUBAHAN: Menambahkan parsing untuk 'tempat' dan 'alamat' ---
      tempat: json['tempat'] ?? '',
      alamat: json['alamat'] ?? '',
      // --- AKHIR PERUBAHAN ---
      description: json['description'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      link: json['link'],
      foto: fotoList, // Menggunakan list yang sudah diparsing
    );
  }
}

// --- PERUBAHAN: Menggunakan nama kelas EventFotoModel sesuai original Anda ---
class EventFotoModel {
  final String path;
  // --- PERUBAHAN: Menggunakan nama field 'type' dan memastikan parsing aman ---
  final int type; // Asumsi 0 for image, 1 for video
  // --- AKHIR PERUBAHAN ---

  EventFotoModel({
    required this.path,
    required this.type,
  });

  factory EventFotoModel.fromJson(Map<String, dynamic> json) {
    return EventFotoModel(
      path: json['path'] ?? '', // --- PERUBAHAN: Menambahkan null-safety ---
      // --- PERUBAHAN: Parsing 'type' dengan aman (handle 'tipe' atau 'type' dan String ke int) ---
      type: json['tipe'] is String ? int.parse(json['tipe']) : json['tipe'] ?? 0, // Menggunakan 'tipe' dari original Anda
      // --- AKHIR PERUBAHAN ---
    );
  }
}