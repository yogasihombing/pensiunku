// ignore_for_file: non_constant_identifier_names

class PhotoGallery {
  final String path;

  PhotoGallery({
    required this.path,
  });

  factory PhotoGallery.fromJson(Map<String, dynamic> json) {
    return PhotoGallery(
      path: json['path']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'path' adalah String
    );
  }
}

class DetailUsaha {
  final String banner;
  final String nama;
  final String description;
  final List<PhotoGallery> photo_gallery;

  DetailUsaha({
    required this.banner,
    required this.nama,
    required this.description,
    required this.photo_gallery,
  });

  factory DetailUsaha.fromJson(Map<String, dynamic> json) {
    // Perubahan yang kamu buat: Memastikan 'photo_gallery' adalah List atau default ke list kosong
    List<dynamic> photoGalleryJson =
        json['photo_gallery'] is List ? json['photo_gallery'] : [];

    return DetailUsaha(
      banner: json['banner']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'banner' adalah String
      nama: json['nama']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'nama' adalah String
      description: json['description']?.toString() ??
          '', // Perubahan yang kamu buat: Memastikan 'description' adalah String
      photo_gallery:
          photoGalleryJson.map((json) => PhotoGallery.fromJson(json)).toList(),
    );
  }
}

// class PhotoGallery {
//   final String path;

//   PhotoGallery({
//     required this.path,
//   });

//   factory PhotoGallery.fromJson(Map<String, dynamic> json) {
//     return PhotoGallery(
//       path: json['path'],
//     );
//   }
// }

// class DetailUsaha {
//   final String banner;
//   final String nama;
//   final String description;
//   final List<PhotoGallery> photo_gallery;

//   DetailUsaha({
//     required this.banner,
//     required this.nama,
//     required this.description,
//     required this.photo_gallery,
//   });

//   factory DetailUsaha.fromJson(Map<String, dynamic> json) {
//     List<dynamic> photoGalleryJson = json['photo_gallery'];

//     return DetailUsaha(
//       banner: json['banner'],
//       nama: json['nama'],
//       description: json['description'],
//       photo_gallery: photoGalleryJson.map((json) => PhotoGallery.fromJson(json)).toList(),
//     );
//   }
// }
