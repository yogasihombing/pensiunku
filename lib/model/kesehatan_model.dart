class ListHospital {
  final int id;
  final String nama;
  final String logo;
  final String telepon;
  final String alamat;
  final String harga;
  final String? kota;

  ListHospital({
    required this.id,
    required this.nama,
    required this.logo,
    required this.telepon,
    required this.alamat,
    required this.harga,
    this.kota
  });

  factory ListHospital.fromJson(Map<String, dynamic> json) {
    return ListHospital(
      id: json['id'],
      nama: json['nama'],
      logo: json['logo'],
      telepon: json['telepon'],
      alamat: json['alamat'],
      harga: json['harga'],
      kota: json['kota'],
    );
  }
}

class KesehatanModel {
  final String description;
  final List<ListHospital> list;

  KesehatanModel({
    required this.description,
    required this.list,
  });

  factory KesehatanModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>hospitalJson = json['list'];

    return KesehatanModel(
      description: json['description'],
      list: hospitalJson.map((json) => ListHospital.fromJson(json)).toList(),
    );
  }
}

class DetailHospitalModel {
  final int id;
  final String nama;
  final String logo;
  final String? banner;
  final String? telepon;
  final String? jenis;
  final String? deskripsi;
  final String alamat;
  final String? harga;
  final String? kota;
  final List<KesehatanPhotoGallery> photoGallery;

  DetailHospitalModel({
    required this.id,
    required this.nama,
    required this.logo,
    this.banner,
    this.telepon,
    this.jenis,
    this.deskripsi,
    required this.alamat,
    required this.harga,
    this.kota,
    required this.photoGallery,
  });

  factory DetailHospitalModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> photoGalleryJson = json['photo_gallery'];

    return DetailHospitalModel(
      id: json['id'],
      nama: json['nama'],
      logo: json['logo'],
      telepon: json['telepon'],
      jenis: json['jenis'],
      deskripsi: json['deskripsi'],
      alamat: json['alamat'],
      harga: json['harga'],
      banner: json['banner'],
      kota: json['kota'],
      photoGallery: photoGalleryJson.map((json) => KesehatanPhotoGallery.fromJson(json)).toList(),
    );
  }
}

class KesehatanPhotoGallery {
  final String path;

  KesehatanPhotoGallery({
    required this.path,
  });

  factory KesehatanPhotoGallery.fromJson(Map<String, dynamic> json) {
    return KesehatanPhotoGallery(
      path: json['path'],
    );
  }
}